module Api exposing (Error, fetchLogs, fetchLast)

import Http
import Models exposing (..)


baseUrl : String
baseUrl =
    "http://192.168.0.104:5000"


type Error
    = Error String


fetchLast : (Result Error LogEntry -> msg) -> Cmd msg
fetchLast handler =
    Http.send (transformResultHandler handler) (Http.get (baseUrl ++ "/last") Models.logDecoder)


fetchLogs : Maybe Int -> Maybe Int -> (Result Error (List LogEntry) -> msg) -> Cmd msg
fetchLogs start end handler =
    Http.send (transformResultHandler handler) (fetchLogsGet start end)


fetchLogsGet : Maybe Int -> Maybe Int -> Http.Request (List LogEntry)
fetchLogsGet start end =
    Http.get (baseUrl ++ "/log?start=" ++ (toStringTime start) ++ "&end=" ++ (toStringTime end)) Models.logsDecoder


toStringTime : Maybe Int -> String
toStringTime time =
    (Maybe.withDefault "" (Maybe.map (\t -> toString t) time))


transformResultHandler : (Result Error a -> msg) -> Result Http.Error a -> msg
transformResultHandler toMsg result =
    toMsg <| Result.mapError transformHttpError result


transformHttpError : Http.Error -> Error
transformHttpError httpError =
    case httpError of
        Http.Timeout ->
            Error "Timeout"

        Http.NetworkError ->
            Error "NetworkError"

        Http.BadPayload desc response ->
            Error <| "BadPayload " ++ desc ++ " " ++ response.body

        Http.BadStatus response ->
            Error <| "BadStatus " ++ " " ++ response.body

        Http.BadUrl desc ->
            Error <| "BadUrl " ++ " " ++ desc
