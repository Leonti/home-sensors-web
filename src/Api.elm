module Api exposing (Error, fetchLogs)

import Http
import Models exposing (..)

import Task

baseUrl : String
baseUrl = "http://localhost:5000"

type Error = Error String

fetchLogs : Maybe Int -> Maybe Int -> (Error -> msg) -> ((List LogEntry) -> msg) -> Cmd msg
fetchLogs start end fetchFail fetchSucceed =
    Task.perform (handleError transformHttpError fetchFail) fetchSucceed (fetchLogsGet start end)

fetchLogsGet : Maybe Int -> Maybe Int -> Task.Task Http.Error (List LogEntry)
fetchLogsGet start end =
    Http.get Models.logsDecoder (baseUrl ++ "/logs")

handleError : (Http.Error -> Error) -> (Error -> msg) -> Http.Error -> msg
handleError toError toMsg httpError = toMsg <| toError httpError

transformHttpError : Http.Error -> Error
transformHttpError httpError =
    case httpError of
        Http.Timeout -> Error "Timeout"
        Http.NetworkError -> Error "NetworkError"
        Http.UnexpectedPayload desc -> Error <| "UnexpectedPayload " ++ desc
        Http.BadResponse code desc -> Error <| "BadResponse " ++ (toString code) ++ " " ++ desc
