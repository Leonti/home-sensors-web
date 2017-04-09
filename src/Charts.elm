port module Charts exposing (Model, Msg, init, update, view, subscriptions, range, end)

import Html exposing (..)
import Html.Attributes exposing (..)


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


init : LogRange -> Maybe Int -> ( Model, Cmd Msg )
init range end =
    let
        model =
            { entries = []
            , range = range
            , end = end
            }

        cmd =
            Task.perform CurrentTime Time.now
    in
        ( model, cmd )


range : Model -> LogRange
range model =
    model.range


end : Model -> Maybe Int
end model =
    model.end


rangeToSeconds : LogRange -> Int
rangeToSeconds range =
    case range of
        Hour ->
            3600

        Day ->
            3600 * 24


start : Model -> Maybe Int
start model =
    Maybe.map (\end -> end - (rangeToSeconds model.range)) model.end


type Msg
    = Fetch
    | FetchResult (Result Api.Error (List LogEntry))
    | CurrentTime Time.Time
    | TimeFail String
    | DrawCharts


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetch ->
            ( model, Api.fetchLogs (start model) model.end FetchResult )

        FetchResult (Ok entries) ->
            update DrawCharts { model | entries = entries }

        FetchResult (Err error) ->
            ( model, Cmd.none )

        CurrentTime time ->
            let
                modelWithTime =
                    { model
                        | end = Just <| round <| Time.inSeconds time
                    }
            in
                update Fetch modelWithTime

        TimeFail error ->
            ( model, Cmd.none )

        DrawCharts ->
            let
                cmd =
                    drawChart
                        { entries = (List.map (\e -> ChartValue e.temperature e.timestamp) <| List.reverse model.entries)
                        , canvasId = "temperature"
                        }

                cmd2 =
                    drawChart
                        { entries = (List.map (\e -> ChartValue e.humidity e.timestamp) <| List.reverse model.entries)
                        , canvasId = "humidity"
                        }

                cmd3 =
                    drawChart
                        { entries = (List.map (\e -> ChartValue (toFloat e.co2) e.timestamp) <| List.reverse model.entries)
                        , canvasId = "co2"
                        }
            in
                ( model, Cmd.batch [ cmd, cmd2, cmd3 ] )


view : Model -> Html Msg
view model =
    div []
        [ div [ class "row" ]
            [ div [ class "browser-default col s12" ]
                [ select []
                    [ option [ value "hour" ] [ text "Last hour" ]
                    , option [ value "day" ] [ text "Last 24h" ]
                    ]
                ]
            ]
        , div [ class "row" ]
            [ div [ class "col s12" ]
                [ chartView "Temperature" "temperature"
                , chartView "Humidity" "humidity"
                , chartView "CO2" "co2"
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every (20 * Time.second) CurrentTime


type alias ChartValue =
    { value : Float
    , timestamp : Int
    }


type alias ChartData =
    { entries : List ChartValue
    , canvasId : String
    }


port drawChart : ChartData -> Cmd msg


chartView : String -> String -> Html Msg
chartView caption canvasId =
    div [ class "card-panel" ]
        [ h3 [] [ text caption ]
        , div [ class "chart-container" ]
            [ canvas [ id canvasId, class "chart" ] []
            ]
        ]
