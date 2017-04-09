module Models exposing (LogEntry, LogRange(..), logDecoder, logsDecoder, rangeToString, stringToRange)

import Json.Decode exposing (field)
import Json.Decode as Json


type LogRange
    = Hour
    | Day


rangeToString : LogRange -> String
rangeToString range =
    case range of
        Hour ->
            "Hour"

        Day ->
            "Day"


stringToRange : String -> LogRange
stringToRange range =
    case range of
        "Hour" ->
            Hour

        "Day" ->
            Day

        _ ->
            Hour


type alias LogEntry =
    { temperature : Float
    , humidity : Float
    , co2 : Int
    , timestamp : Int
    }


logDecoder : Json.Decoder LogEntry
logDecoder =
    Json.map4 LogEntry
        (field "temperature" Json.float)
        (field "humidity" Json.float)
        (field "co2" Json.int)
        (field "timestamp" Json.int)


logsDecoder : Json.Decoder (List LogEntry)
logsDecoder =
    Json.list logDecoder
