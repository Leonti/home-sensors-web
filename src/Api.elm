module Api exposing (Error, fetchLogs, fetchLast)

import Http
import Models exposing (..)

import Task

baseUrl : String
baseUrl = "http://192.168.0.106:5000"
--baseUrl = ""

type Error = Error String

fetchLast : (Error -> msg) -> (LogEntry -> msg) -> Cmd msg
fetchLast fetchFail fetchSucceed =
    Task.perform (handleError transformHttpError fetchFail) fetchSucceed (Http.get Models.logDecoder (baseUrl ++ "/last"))

fetchLogs : Maybe Int -> Maybe Int -> (Error -> msg) -> ((List LogEntry) -> msg) -> Cmd msg
fetchLogs start end fetchFail fetchSucceed =
    Task.perform (handleError transformHttpError fetchFail) fetchSucceed (fetchLogsGet start end)

fetchLogsGet : Maybe Int -> Maybe Int -> Task.Task Http.Error (List LogEntry)
fetchLogsGet start end =
    Http.get Models.logsDecoder (baseUrl ++ "/log?start=" ++ (toStringTime start) ++ "&end=" ++ (toStringTime end))

toStringTime : Maybe Int -> String
toStringTime time = (Maybe.withDefault "" (Maybe.map (\t -> toString t) time))

handleError : (Http.Error -> Error) -> (Error -> msg) -> Http.Error -> msg
handleError toError toMsg httpError = toMsg <| toError httpError

transformHttpError : Http.Error -> Error
transformHttpError httpError =
    case httpError of
        Http.Timeout -> Error "Timeout"
        Http.NetworkError -> Error "NetworkError"
        Http.UnexpectedPayload desc -> Error <| "UnexpectedPayload " ++ desc
        Http.BadResponse code desc -> Error <| "BadResponse " ++ (toString code) ++ " " ++ desc
