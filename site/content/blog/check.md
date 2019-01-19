+++
date = "2015-02-09T20:29:22-05:00"
draft = false
title = "Check: Experimental type checker for reflection heavy Go programs"

+++


Before getting into the content of this post, I'd like to make something clear. Don't use this in production. I'm not even sure this is a good idea, but it's an idea I've had for a while. 

# Introduction

Go doesn't have a lot of things. It's very spartan in that way. I think it's a good thing, but when reading about Go you will unavoidably find people who disagree. I'm not going to talk about that because there are tons of articles and blog posts which discuss the issue at great length. The goal here is to see what is possible with Go in its current state. 

So, how do I write the classic map function in Go? If you ask someone who has embraced Go's style, the answer will probably be "use a for loop". For example, if you want the equivalent of Python's `map(lambda x: x*x, [1,2,3])`, you might write:

```Go
var input = []int {1, 2, 3}
var output = make([]int, len(input))

for i, x := range input {
	output[i] = x * x
}
```

It's that simple. There is no question of what this code does, and anyone with a decent understanding of programming can immediately read and understand it. But what if we don't care and we want to be able to write this:

```Go
output := Map(func(i int) int {
	return i * i
}, []int{1, 2, 3})
```

Well, we can. Define Map like so:

```Go
func Map(fn func(int)int, in []int) []int {
	out := make([]int, len(in))
	for i, x := range in {
		out[i] = fn(x)
	}
	return out
}
```

This feels like cheating though, because we can't use that function with anything but ints. We can achieve a fully "generic" solution with reflection like so:


```Go
import "github.com/Logiraptor/fun"

func Map(fn interface{}, arr interface{}) interface{} {
	types := fun.Check(func(func(fun.A) fun.B, []fun.A) {}, fn, arr)
	outType := types[fun.BKey]

	output := reflect.New(reflect.SliceOf(outType)).Elem()
	funV := reflect.ValueOf(fn)
	slice := reflect.ValueOf(arr)
	length := slice.Len()
	for i := 0; i < length; i++ {
		x := funV.Call([]reflect.Value{slice.Index(i)})[0]
		output = reflect.Append(output, x)
	}

	return output.Interface()
}
```

It's a bit longer, and we've thrown type safety out the window, but we can almost write the code we wanted. The call to `fun.Check` is another bit of reflection code that does simple template-style type checking at runtime. These will all compile just fine now:

```Go
// => [1, 4, 9]
output := Map(func(i int) int {
	return i * i
}, []int{1, 2, 3}).([]int)

// => [0, 3, 2]
output := Map(func(s string) int {
	return len(s)
}, []string{"", "foo", "go"}).([]int)

// uh-oh...
output := Map(func(s string) int {
	return len(s)
}, []int{1, 2, 3}).([]int)

Map(true, "panic")
Map("no type checking", 78)
```

Notice that by using reflection, we've lost the ability to check types statically. The last 3 invocations will panic at runtime with a less than readable error. For me, static typing is a __huge__ reason why I'm productive in Go. The task before us is to get back some static verification without changing the Go language at all. So that's what I did. I have a toy program called check which can look at that program and tell me statically that the `func(string) int` doesn't match the `[]int`. It's ~200 lines of Go apart from the standard library + tools. It makes extensive use of `go/types` for the actual work, and it's actually surprisingly general. To use it, you just run `check "Map(func(A)B, []A)"`. Or, if you want to be hip, you can use `go generate` like so:

```
//go:generate check "Map(func(A)B, []A)"

// We can check reduce too!
//go:generate check "Reduce(func(A, B) A, A, []B)"
```

Check will parse "Map(func(A)B, []A)" and treat A and B as type variables which can be unified with any other type. Of course, all instances of a specific type variable must unify with the same type. 


# Limitations

I feel the need to repeat: this is just a toy program to experiment with writing my first static analysis tool. It's probably a terrible idea in the first place. These are the problems I see with it:

1. The function (e.g. Map) must be defined locally.
2. It doesn't verify the result type so a nested Map call will not type check properly.
3. The function name must be unique among all call expressions in the entire program. So, you can't call `other.Map` without it trying to type check that as well.
4. Since it's not part of the compiler, it's not guaranteed to run before compilation.
5. This is classic overuse of reflection.
6. check is not a very creative name.

# Conclusion

I think the coolest part of all this is that I was able to write this whole thing while taking notes at my university in 3 days. I see it as a testament to the standard library that it's so short and so easy to do.