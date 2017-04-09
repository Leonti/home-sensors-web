port module Main exposing (..)

import Html exposing (..)


--import Html.Events exposing (..)

import Html.Attributes exposing (..)
import Debug
import Current
import Charts
import Models exposing (LogRange(..), stringToRange, rangeToString)


main : Program (Maybe PersistedModel) Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = (\msg model -> withSetStorage (Debug.log "model" (update msg model)))
        , subscriptions = subscriptions
        }


port setStorage : PersistedModel -> Cmd msg


withSetStorage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withSetStorage ( model, cmds ) =
    ( model
    , Cmd.batch
        [ setStorage (persistedModel model), cmds ]
    )



-- MODEL


type alias PersistedModel =
    { range : String
    , end : Maybe Int
    }


type alias Model =
    { currentModel : Current.Model
    , chartsModel : Charts.Model
    }


emptyPersistedModel : PersistedModel
emptyPersistedModel =
    { range = "Hour"
    , end = Nothing
    }


persistedModel : Model -> PersistedModel
persistedModel model =
    { range = rangeToString <| Charts.range model.chartsModel
    , end = Charts.end model.chartsModel
    }


init : Maybe PersistedModel -> ( Model, Cmd Msg )
init maybePersistedModel =
    let
        persistedModel =
            Maybe.withDefault emptyPersistedModel maybePersistedModel

        ( currentModel, currentCmd ) =
            Current.init

        ( chartsModel, chartsCmd ) =
            Charts.init (stringToRange persistedModel.range) persistedModel.end

        model =
            { currentModel = currentModel
            , chartsModel = chartsModel
            }

        cmd =
            Cmd.batch [ (Cmd.map CurrentMsg currentCmd), (Cmd.map ChartsMsg chartsCmd) ]
    in
        ( model, cmd )



-- UPDATE


type Msg
    = CurrentMsg Current.Msg
    | ChartsMsg Charts.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        ChartsMsg message ->
            let
                ( chartsModel, chartsCmd ) =
                    Charts.update message model.chartsModel
            in
                ( { model
                    | chartsModel = chartsModel
                  }
                , Cmd.map ChartsMsg chartsCmd
                )

        CurrentMsg message ->
            let
                ( currentModel, currentCmd ) =
                    Current.update message model.currentModel
            in
                ( { model
                    | currentModel = currentModel
                  }
                , Cmd.map CurrentMsg currentCmd
                )



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "container" ]
        [ Html.map CurrentMsg (Current.view model.currentModel)
        , Html.map ChartsMsg (Charts.view model.chartsModel)
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map CurrentMsg (Current.subscriptions model.currentModel)
        , Sub.map ChartsMsg (Charts.subscriptions model.chartsModel)
        ]
