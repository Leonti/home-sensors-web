port module Main exposing (..)

import Html exposing (..)
import Html.App as App
--import Html.Events exposing (..)
--import Html.Attributes
import Api
import Debug

import Models exposing (LogEntry)

import Current

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
    , currentModel : Current.Model
    }

emptyModel : Model
emptyModel =
    { start = Nothing
    , end = Nothing
    , entries = []
    , currentModel = Current.emptyModel
    }

persistedModel : Model -> PersistedModel
persistedModel model =
    { start = model.start
    , end = model.end
    }

init : Maybe PersistedModel -> ( Model, Cmd Msg )
init maybePersistedModel =
    let model =
        Maybe.withDefault emptyModel (Maybe.map fromPersistedModel maybePersistedModel)
    in
        let (updatedModel, cmd) =
            update FetchLog model
            (model, newCmd) =
            initCurrent updatedModel
        in
            (model, Cmd.batch [cmd, newCmd])

initCharts : Model -> ( Model, Cmd Msg)
initCharts model =
    update FetchLog model

initCurrent : Model -> ( Model, Cmd Msg )
initCurrent model =
      let ( currentModel, currentCmd ) =
        Current.init
      in
        ({ model
            | currentModel = currentModel
         }
         , Cmd.map CurrentMsg currentCmd
        )

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
    | CurrentMsg Current.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case (Debug.log "msg" msg) of
        FetchLog ->
            (model, Api.fetchLogs model.start model.end FetchLogFail FetchLogSucceed)

        FetchLogSucceed entries ->
            ({model | entries = entries}, Cmd.none)

        FetchLogFail error ->
            (model, Cmd.none)

        CurrentMsg message ->
          let ( currentModelModel, currentCmd ) =
            Current.update message model.currentModel
          in
            ({ model
                | currentModel = currentModelModel
             }
             , Cmd.map CurrentMsg currentCmd
            )

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ App.map CurrentMsg (Current.view model.currentModel)
        , div [] [text "LOG:"]       
        , div [] (List.map (\entry -> entryRow entry) model.entries)
        ]

entryRow : LogEntry -> Html Msg
entryRow entry =
    div []
        [ text ((toString entry.temperature) ++ " " ++ toString(entry.humidity) ++ " " ++ toString(entry.co2))
        ]

--subscriptions : Model -> Sub Msg
--subscriptions model =
--  Sub.map ReceiptListMsg (ReceiptList.subscriptions model.receiptList)
