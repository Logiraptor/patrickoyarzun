+++
date = "2014-02-28T20:29:22-05:00"
draft = false
title = "Writing a LISP Interpreter in Go"

+++


I've wanted to write my own programming language since I started programming in highschool, but it always seemed impossible. I thought only the mythical wizards of the internet could actually forge their own language as a hobby. 5 years later and it turns out it's [not](http://norvig.com/lispy.html) [that](http://bobappleyard.wordpress.com/2010/02/18/writing-a-lisp-interpreter-in-go/) [hard](http://www.essenceandartifact.com/2012/09/how-to-create-turing-complete.html). (I didn't find that second one until after I had finished).

I tried my hand at writing a few mini-languages, but they always felt over complicated for the small feature set they offered. I remembered reading that LISPs are super easy to parse and so decided that would be my next project, but first I needed to generalize this whole idea of parsing. I stumbled upon [parsing expression grammars](http://en.wikipedia.org/wiki/Parsing_expression_grammar) and I was off. I wrote a peg parser over the weekend to make my life easier on future projects, which you can find [here](https://github.com/Logiraptor/chicken).

Ok! Enough talking, here's the grammar for my LISP:

    prgm <- list+
    list <- _?^ open atom_left+ close
    atom_left <- atom _?^
    atom <- number / name / list
    name <- ~'[a-zA-Z/\-\*\+=><]+'
    number <- ~'-?\d+\.?\d*'
    open <- '('
    close <- ')'
    _ <- ~'\s+'

So basically, there are two fundamental parts, numbers and names. Each are defined by regular expressions. The `~` denotes a regex in my peg parser. Everything else is pretty simple, aside from the `^` operator. A rule followed by `^` will be consumed from input normally, but will be discarded from the parse tree that is ultimately generated. Note that I use it to explicitly ignore whitespace between items in a list. This is not technically necessary, but it makes the interpreter a little cleaner since we can worry only about the stuff we care about.

In order to evaluate the parse tree we need to transform it into some internal representation we can process easily. Go is strongly typed, so let's define some types to hold our program.
{{% highlight go %}}
    type Atom interface{}
    type List []Atom
    type Number float64
    type Symbol string
    type Bool bool
{{% /highlight %}}
We'll take the easy way out and have only one type of number, `float64`. Javascript has made it this far, so it should do for a weekend project. Note that the Symbol type is not actually a string datatype. Symbol is used for a variable or function identifier, and it's internal representation is a Go string. The lisp does not support actual string values because that would complicate the grammar a bit and I wanted to keep it as simple as possible for the first real test of my peg library. One other interesting result is that `List` is automatically also an `Atom`.

Now the transformation function:
{{% highlight go %}}
	func transformPRGM(p *peg.ParseTree, out chan List) {
		for _, child := range p.Children {
			out &lt;- transform(child).(List)
		}
		close(out)
	}

	func transform(p *peg.ParseTree) Atom {
		switch p.Type {
		case "number":
			val, err := strconv.ParseFloat(string(p.Data), 64)
			if err != nil {
				panic(err)
			}
			return Number(val)
		case "name":
			return Symbol(string(p.Data))
		case "list":
			var resp = make(List, len(p.Children[1].Children))
			for i, child := range p.Children[1].Children {
				resp[i] = transform(child)
			}
			return resp
		default:
			fmt.Println(p)
			panic(fmt.Sprintf("Cannot transform %s", p.Type))
		}
	}
{{% /highlight %}}
We see that the parse tree fills in a Type string on each node based on the rule that it satisfies, so we can just switch on that to determine the proper type to return. Also, we know that any number we encounter is a valid float because it satisfied the regular expression, so we panic on error instead of returning one since it should be a very rare case and I think can only be caused if the number literal is too big for a `float64` to represent. That's huge.

Now that we have an internal representation, all we need are a few built-in functions and an eval function. We'll define the execution environment as follows:
{{% highlight go %}}
    type Env struct {
	    mapping map[Symbol]Atom
	    outer   *Env
    }
    
    func (e *Env) find(s Symbol) map[Symbol]Atom {
	    if _, ok := e.mapping[s]; ok {
		    return e.mapping
	    } else if e.outer != nil {
		    return e.outer.find(s)
	    } else {
		    return nil
	    }
    }
    
    type FuncLit func(List) (Atom, error)
    
    func (f FuncLit) Call(l List) (Atom, error) {
	    return f(l)
    }
    
    type Procedure struct {
	    params List
	    body   Atom
	    env    *Env
    }
    
    func (p *Procedure) Call(l List) (Atom, error) {
	    return nil, fmt.Errorf("procedure call: tail recursion is required")
    }
    
    type Func interface {
	    Call(List) (Atom, error)
    }
{{% /highlight %}}
The purpose of `Env` is to manage function and variable bindings and also provides lexical scoping through the `find` method. We also define types for user-defined functions through Procedure, and Go defined functions through FuncLit. All that's left is eval!
{{% highlight go %}}
    var QUOTE Symbol = "quote"
    var IF Symbol = "if"
    var SET Symbol = "set"
    var DEFINE Symbol = "define"
    var LAMBDA Symbol = "lambda"
    var BEGIN Symbol = "begin"
    
    func eval(a Atom, e *Env) (Atom, error) {
	    var err error
	    for {
		    switch a.(type) {
		    case Number:
			    return a, nil
		    case Symbol:
			    s := a.(Symbol)
			    return e.find(s)[s], nil
		    case List:
			    l := a.(List)
			    switch l[0] {
			    case QUOTE:
				    return l[1], nil
			    case IF:
				    test, conseq, alt := l[1], l[2], l[3]
				    t, err := eval(test, e)
				    if err != nil {
					    return nil, err
				    }
				    if t.(Bool) {
					    a = conseq
				    } else {
					    a = alt
				    }
			    case SET:
				    name, exp := l[1].(Symbol), l[2]
				    e.find(name)[name], err = eval(exp, e)
				    return nil, err
			    case DEFINE:
				    name, exp := l[1].(Symbol), l[2]
				    e.mapping[name], err = eval(exp, e)
				    return nil, err
			    case LAMBDA:
				    vars, exp := l[1].(List), l[2]
				    return &amp;Procedure{
					    vars, exp, e,
				    }, nil
			    case BEGIN:
				    for _, exp := range l[1 : len(l)-1] {
					    _, err = eval(exp, e)
					    if err != nil {
						    return nil, err
					    }
				    }
				    a = l[len(l)-1]
			    default:
				    exps := make([]Atom, len(l))
				    for i, exp := range l {
					    exps[i], err = eval(exp, e)
					    if err != nil {
						    return nil, err
					    }
				    }
				    proc := exps[0].(Func)
				    if p, ok := proc.(*Procedure); ok {
					    a = p.body
					    e = NewEnvFrom(p.params, exps[1:], p.env)
				    } else {
					    x, err := proc.Call(exps[1:])
					    if err != nil {
						    return nil, fmt.Errorf("%s: %s", l[0], err)
					    }
					    return x, nil
				    }
			    }
		    default:
			    panic(fmt.Sprintf("Cannot eval %v", a))
		    }
	    }
	    return nil, nil
    }
{{% /highlight %}}
Here you see the built-in functions quote, if, set, define, lambda, and begin. We've even got tail recursion! We can use these to define others. I've defined arithmetic with Go functions using my [wrapper](https://github.com/Logiraptor/reflect) which makes any function "generic", but that uses Go reflection and is outside the scope of this post.

I'll end with a sample of some code defined in the LISP and a benchmark against Go to show performance. (Hint, it's terrible, but ok for a weekend and my first time ever writing code in a LISP).
{{% highlight go %}}
    (define factorial
      (lambda (n)
        (if (= n 0) 1
            (* n (factorial (- n 1))))))
    (factorial 100)
{{% /highlight %}}
And the benchmark:
{{% highlight go %}}
    PASS
    BenchmarkGoFact	 5000000	       648 ns/op
    BenchmarkCLISPFact	   20000	     96744 ns/op
    ok  	github.com/Logiraptor/chickenLISP	6.821s
{{% /highlight %}}
That's all for now. Full source with tests/benchmark is available [here](https://github.com/Logiraptor/chickenLISP).