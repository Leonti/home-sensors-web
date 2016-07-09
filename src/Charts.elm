module Charts exposing (Model, Msg, init, update, view, range, end)

import Html exposing (..)
--import Html.Attributes exposing (..)
--import Html.Events exposing (..)

import Task
import Time

import Api
import Models exposing (LogEntry, LogRange(..))

type alias Model =
  { entries : List LogEntry
  , range : LogRange
  , end : Maybe Int
  }

init : LogRange -> Maybe Int -> (Model, Cmd Msg)
init range end =
    let
        model =
            { entries = []
            , range = range
            , end = end
            }
        cmd = Task.perform TimeFail CurrentTime Time.now
    in
        (model, cmd)

range : Model -> LogRange
range model =
    model.range

end : Model -> Maybe Int
end model =
    model.end

rangeToSeconds : LogRange -> Int
rangeToSeconds range =
    case range of
        Hour -> 3600
        Day -> 3600 * 24

start : Model -> Maybe Int
start model =
    Maybe.map (\end -> end - (rangeToSeconds model.range)) model.end

type Msg
    = Fetch
    | FetchSucceed (List LogEntry)
    | FetchFail Api.Error
    | CurrentTime Time.Time
    | TimeFail String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Fetch ->
            (model, Api.fetchLogs (start model) model.end FetchFail FetchSucceed)

        FetchSucceed entries ->
            ({model | entries = entries}, Cmd.none)

        FetchFail error ->
            (model, Cmd.none)

        CurrentTime time ->
            let
                modelWithTime =
                    { model
                        | end = Just <| round <| Time.inSeconds time
                    }
            in
                update Fetch modelWithTime

        TimeFail error ->
            (model, Cmd.none)

view : Model -> Html Msg
view model =
  div []
        [ div [] (List.map (\entry -> entryRow entry) model.entries)
        , text <| toString <| model.end
        ]

entryRow : LogEntry -> Html Msg
entryRow entry =
    div []
        [ text ((toString entry.temperature) ++ " " ++ toString(entry.humidity) ++ " " ++ toString(entry.co2))
        ]
