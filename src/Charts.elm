module Charts exposing (Model, Msg, init, update, view, start, end)

import Html exposing (..)
--import Html.Attributes exposing (..)
--import Html.Events exposing (..)

import Api
import Models exposing (LogEntry)

type alias Model =
  { entries : List LogEntry
  , start : Maybe Int
  , end : Maybe Int
  }

init : Maybe Int -> Maybe Int -> (Model, Cmd Msg)
init start end =
    update Fetch
        { entries = []
        , start = start
        , end = end
        }

start : Model -> Maybe Int
start model =
    model.start

end : Model -> Maybe Int
end model =
    model.end

type Msg
    = Fetch
    | FetchSucceed (List LogEntry)
    | FetchFail Api.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Fetch ->
            (model, Api.fetchLogs model.start model.end FetchFail FetchSucceed)

        FetchSucceed entries ->
            ({model | entries = entries}, Cmd.none)

        FetchFail error ->
            (model, Cmd.none)

view : Model -> Html Msg
view model =
  div []
        [ div [] (List.map (\entry -> entryRow entry) model.entries)
        ]

entryRow : LogEntry -> Html Msg
entryRow entry =
    div []
        [ text ((toString entry.temperature) ++ " " ++ toString(entry.humidity) ++ " " ++ toString(entry.co2))
        ]
