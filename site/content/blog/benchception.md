+++
tags = [
  "elm",
  "performance",
]
title = "Benchmarking (Benchmarking Elm Functions)"
date = "2016-10-26T20:03:39-04:00"
slug = ""

+++

In [my last post][elmbench], I released a benchmarking package for elm. I got some interesting feedback on reddit
from user ianmackenzie. What if my benchmarking package is adding significant overhead to the things it's trying to benchmark?
I hadn't made any particular effort to make it fast, so this is a great opportunity to try. As a matter of fact, I can use my
benchmark package to benchmark the new implementation. Let's try it out.

Here's a complete demo app that uses the library to benchmark a new implementation of the `repeat` function.
It essentially tries to benchmark the function `\() -> ()`, which is the simplest possible function I could think of. 
With any luck, the performance of the benchmarking tool should dominate.

```
module Bootstrap exposing (..)

import Bench
import Html
import Html.App as App
import Time
import Task
import Process


type alias Model =
    { benchmarks : List ( String, Bench.Timing ) }


type Msg
    = BenchmarkDone String Bench.Timing
    | Noop


testFunc : () -> ()
testFunc () =
    ()


newRepeat : (() -> b) -> Int -> ()
newRepeat f n =
    if n <= 0 then
        ()
    else
        let
            _ =
                f ()
        in
            newRepeat f (n - 1)


main : Program Never
main =
    App.program
        { init =
            ( { benchmarks = [] }
            , Task.perform (\_ -> Noop) (\_ -> Noop) (Process.sleep (Time.millisecond * 1000))
            )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


view : Model -> Html.Html Msg
view model =
    let
        viewTiming ( name, timing ) =
            Html.div []
                [ Html.h1 [] [ Html.text name ]
                , Html.text (toString timing)
                ]
    in
        Html.div [] ((Html.text "Benchmarks will appear here:") :: (List.map viewTiming model.benchmarks))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BenchmarkDone name timing ->
            ( { model | benchmarks = ( name, timing ) :: model.benchmarks }, Cmd.none )

        Noop ->
            ( model
            , Cmd.batch
                [ Bench.benchmark (BenchmarkDone "Current Implementation") (Bench.repeat testFunc)
                , Bench.benchmark (BenchmarkDone "Proposed Implementation") (newRepeat testFunc)
                ]
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

```


If you run this app (and make sure to pin the version of elm-bench at 1.0.0), you should see that the
proposed implementation is around an order of magnitude faster! You can also check out the [live demo][demo]. As of now, the new implementation has
been merged in as the default. I've also added the benchmarking app as a sub module so you can easily
run small tests like this one. The [documentation is available on package.elm-lang.org][docs]

Thanks for reading!




[elmbench]: /blog/elm-bench/
[docs]: http://package.elm-lang.org/packages/Logiraptor/elm-bench/latest
[demo]: /apps/benchception