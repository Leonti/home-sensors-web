port module Main exposing (..)

import Html exposing (..)
import Html.App as App
--import Html.Events exposing (..)
--import Html.Attributes
import Api
import Debug

import Models exposing (LogEntry)

main : Program (Maybe PersistedModel)
main =
  App.programWithFlags
    { init = init
    , view = view
    , update = (\msg model -> withSetStorage (Debug.log "model" (update msg model)) )
    , subscriptions = \_ -> Sub.none
    }

port setStorage : PersistedModel -> Cmd msg

withSetStorage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withSetStorage (model, cmds) =
  ( model, Cmd.batch
    [ setStorage (persistedModel model), cmds ] )

-- MODEL
type alias PersistedModel =
    { start : Maybe Int
    , end : Maybe Int
    }

type alias Model =
    { start : Maybe Int
    , end : Maybe Int
    , entries : List LogEntry
    }

emptyModel : Model
emptyModel =
    { start = Nothing
    , end = Nothing
    , entries = []
    }

persistedModel : Model -> PersistedModel
persistedModel model =
    { start = model.start
    , end = model.end
    }

init : Maybe PersistedModel -> ( Model, Cmd Msg )
init maybePersistedModel =
    (Maybe.withDefault emptyModel (Maybe.map fromPersistedModel maybePersistedModel), Cmd.none)


fromPersistedModel : PersistedModel -> Model
fromPersistedModel persistedModel =
    { emptyModel
        | start = persistedModel.start
        , end = persistedModel.end
    }

-- UPDATE

type Msg
    = FetchLog
    | FetchLogSucceed (List LogEntry)
    | FetchLogFail Api.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case (Debug.log "msg" msg) of
        FetchLog ->
            (model, Api.fetchLogs model.start model.end FetchLogFail FetchLogSucceed)

        FetchLogSucceed entries ->
            ({model | entries = entries}, Cmd.none)

        FetchLogFail error ->
            (model, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ div []
            [ span [] [text <| toString model]
            ]
        ]

--subscriptions : Model -> Sub Msg
--subscriptions model =
--  Sub.map ReceiptListMsg (ReceiptList.subscriptions model.receiptList)
