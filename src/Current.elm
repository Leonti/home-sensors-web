module Current exposing (Model, Msg, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)


--import Html.Events exposing (..)

import Time
import Api
import Models exposing (LogEntry)


type alias Model =
    { entry : Maybe LogEntry
    }


emptyModel : Model
emptyModel =
    { entry = Nothing
    }


init : ( Model, Cmd Msg )
init =
    update Fetch emptyModel


type Msg
    = Fetch
    | FetchResult (Result Api.Error LogEntry)
    | CurrentTime Time.Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetch ->
            ( model, Api.fetchLast FetchResult )

        FetchResult (Ok entry) ->
            ( { model | entry = Just entry }, Cmd.none )

        FetchResult (Err error) ->
            ( model, Cmd.none )

        CurrentTime time ->
            update Fetch model


view : Model -> Html Msg
view model =
    div [ class "row" ]
        [ div [ class "col s12" ]
            [ infoView model.entry ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.minute CurrentTime


infoView : Maybe LogEntry -> Html Msg
infoView maybeEntry =
    case maybeEntry of
        Just entry ->
            div [ class "card-panel" ]
                [ h3 [] [ text <| "Temperature: " ++ (toString entry.temperature) ++ "C" ]
                , h3 [] [ text <| "Humidity: " ++ (toString entry.humidity) ++ "%" ]
                , h3 [] [ text <| "CO2: " ++ (toString entry.co2) ++ "ppm" ]
                ]

        Nothing ->
            div [] []
