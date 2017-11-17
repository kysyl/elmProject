module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Msgs exposing (Msg)
import Models exposing (..)
import RemoteData


fetchQuizzs : Cmd Msg
fetchQuizzs =
    Http.get fetchQuizzsUrl quizzsDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchQuizzs


fetchQuizzsUrl : String
fetchQuizzsUrl =
    "http://localhost:4000/quizzs"


saveQuizzUrl : QuizzId -> String
saveQuizzUrl quizzId =
    "http://localhost:4000/quizzs/" ++ toString quizzId


saveQuizzRequest : Quizz -> Http.Request Quizz
saveQuizzRequest quizz =
    Http.request
        { body = quizzEncoder quizz |> Http.jsonBody
        , expect = Http.expectJson quizzDecoder
        , headers = []
        , method = "PATCH"
        , timeout = Nothing
        , url = saveQuizzUrl quizz.id
        , withCredentials = False
        }

saveQuizzCmd : Quizz -> Cmd Msg
saveQuizzCmd quizz =
    saveQuizzRequest quizz
        |> Http.send Msgs.OnQuizzSave

-- DECODERS1

identityDecoder : Decode.Decoder Identity
identityDecoder =
    decode Identity
        |> required "age" Decode.int
        |> required "sex" Decode.string


identityEncoder : Identity -> Encode.Value
identityEncoder identity =
    let
        attributes =
            [ ( "age", Encode.int identity.age )
            , ( "sex", Encode.string identity.sex )
            ]
    in
        Encode.object attributes
-- DECODERS


quizzsDecoder : Decode.Decoder (List Quizz)
quizzsDecoder =
    Decode.list quizzDecoder

quizzDecoder : Decode.Decoder Quizz
quizzDecoder =
    decode Quizz
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "questions" (Decode.list questionDecoder)
        |> required "level" Decode.int
        |> required "identity" identityDecoder


questionDecoder : Decode.Decoder Question
questionDecoder =
    decode Question
        |> required "id" Decode.int
        |> required "questionText" Decode.string
        |> required "questionType" Decode.string
        |> required "answers" (Decode.list Decode.int)
        |> required "responses" (Decode.list responseDecoder)
        

responseDecoder : Decode.Decoder Response
responseDecoder =
    decode Response
        |> required "id" Decode.int
        |> required "content" Decode.string
        |> required "isAnswer" Decode.bool

quizzEncoder : Quizz -> Encode.Value
quizzEncoder quizz =
    let
        attributes =
            [ ( "id", Encode.int quizz.id )
            , ( "name", Encode.string quizz.name )
            , ( "level", Encode.int quizz.level )
            , ( "identity", identityEncoder quizz.identity )
            ]
    in
        Encode.object attributes
