module Models exposing (LogEntry, LogRange(..), logDecoder, logsDecoder, rangeToString, stringToRange)

import Json.Decode exposing ((:=))
import Json.Decode as Json

type LogRange
    = Hour
    | Day

rangeToString : LogRange -> String
rangeToString range =
    case range of
        Hour -> "Hour"
        Day -> "Day"

stringToRange : String -> LogRange
stringToRange range =
    case range of
        "Hour" -> Hour
        "Day" -> Day
        _ -> Hour

type alias LogEntry =
    { temperature : Float
    , humidity : Float
    , co2 : Int
    , timestamp : Int
    }

logDecoder : Json.Decoder LogEntry
logDecoder =
    Json.object4 LogEntry
        ("temperature" := Json.float)
        ("humidity" := Json.float)
        ("co2" := Json.int)
        ("timestamp" := Json.int)

logsDecoder : Json.Decoder (List LogEntry)
logsDecoder = Json.list logDecoder
