module Current exposing (Model, Msg, emptyModel, init, update, view)

import Html exposing (..)
--import Html.Attributes exposing (..)
--import Html.Events exposing (..)

import Api
import Models exposing (LogEntry)

type alias Model =
  { entry : Maybe LogEntry
  }

init : (Model, Cmd Msg)
init =
    update Fetch emptyModel

emptyModel : Model
emptyModel =
    { entry = Nothing
    }

type Msg
    = Fetch
    | FetchSucceed LogEntry
    | FetchFail Api.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Fetch ->
        (model, Api.fetchLast FetchFail FetchSucceed)

    FetchSucceed entry ->
        ({ model | entry = Just entry }, Cmd.none)

    FetchFail error ->
        (model, Cmd.none)

view : Model -> Html Msg
view model =
  div []
        [ div []
            [text <| Maybe.withDefault "" <| Maybe.map (\entry -> (toString entry.temperature) ++ " " ++ toString(entry.humidity) ++ " " ++ toString(entry.co2)) model.entry]
        ]
