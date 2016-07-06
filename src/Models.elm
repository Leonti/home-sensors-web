module Models exposing (LogEntry, logsDecoder)

import Json.Decode exposing ((:=))
import Json.Decode as Json

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
