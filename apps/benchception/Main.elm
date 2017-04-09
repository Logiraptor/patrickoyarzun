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
