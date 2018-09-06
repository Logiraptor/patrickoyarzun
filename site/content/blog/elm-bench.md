+++
draft = false
date = "2016-10-23T20:38:55-04:00"
title = "Benchmarking Elm Functions"
highlight = true

+++

> Update: 9/5/2018 - See [elm-benchmark](https://www.brianthicks.com/post/2017/02/27/introducing-elm-benchmark/) for a more up to date package.

## Background

I come from a background of mostly Go development. One thing I've missed since starting 
to write Elm code is the lack of a good benchmarking tool like the one in Go's standard library.
Porting the core of it to Elm was a good opportunity to learn about Elm's Task system. 
You can find [docs for the latest version of the code](http://package.elm-lang.org/packages/Logiraptor/elm-bench/latest) in the elm package repository.

## Usage

The core API of the package is a single function:

``` 

benchmark : (Timing -> msg) -> (Int -> a) -> Cmd msg

```

The arguments, in order, are: 

1. a message constructor so benchmark can dispatch a Msg back to your app when the benchmark is finished.
2. the function to be profiled.

You're probably wondering why the type for your function must be `Int -> a`.
In order to reliably time a function which we know nothing about, we need to execute it many times. If the function is slow, maybe once is enough.
If the function is fast, we need to execute it lots and lots of times in order to get a reliable result. 
So, in order to execute an arbitrary computation N times, it's best to just pass N to the caller and let 
them decide what's best. This gives the user of the library the most control in deciding how their code 
gets scaled up for performance testing. However, many times you won't want to do anything special, 
you just want to execute the same code over and over until the benchmark is reliable. In that case, there is a second function:

```

repeat : (() -> a) -> Int -> ()

```

The repeat function takes and arbirary function and converts it into a form that benchmark can use. This way, if you just want to take the easy path, 
all you have to do is wrap your function in `repeat` and you're good to go. 

With just these basic building blocks, we can write the following:

```
module Main exposing(..)

...
import Bench

type Msg = 
    BenchmarkComplete Bench.Timing

type alias Model =
    { benchmark : Bench.Timing }

update : Msg -> Model -> Model
update msg model =
    case msg of
        BenchmarkComplete timing ->
            { model | benchmark = timing }

startBenchmark : Cmd Msg
startBenchmark =
    Bench.benchmark BenchmarkComplete (Bench.repeat (\() -> "a" + "b"))

```

Now if we return startBenchmark to the system as a command, we will receive the results in our 
update function when it's complete. In this case, we are benchmarking the time taken to append
two strings. In reality, the compiler will likely optimize the concatenation into a noop, but this is the general idea.

This is the first elm package I've published publicly, so I'd love to hear your feedback!

Update: [I benchmarked elm-bench using elm-bench!][benchception]

[benchception]: /blog/benchception
