module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Msgs exposing (Msg)
import Models exposing (..)
import RemoteData


fetchQuizzs : Cmd Msg
fetchQuizzs  =
    Http.get fetchQuizzsUrl quizzsDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchQuizzs

fetchUser : Cmd Msg
fetchUser  =
    Http.get fetchUserUrl userDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchUser

fetchQuizzsUrl : String
fetchQuizzsUrl =
    "http://localhost:4000/quizzs"

fetchUserUrl : String
fetchUserUrl =
    "http://localhost:4000/user"


saveQuizzUrl : QuizzId -> String
saveQuizzUrl quizzId =
    "http://localhost:4000/quizzs/" ++ toString quizzId

saveUserUrl : String
saveUserUrl =
    "http://localhost:4000/user"

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

saveUserRequest : User -> Http.Request User
saveUserRequest user =
    Http.request
        { body = userEncoder user |> Http.jsonBody
        , expect = Http.expectJson userDecoder
        , headers = []
        , method = "PATCH"
        , timeout = Nothing
        , url = saveUserUrl
        , withCredentials = False
        }

saveQuizzCmd : Quizz -> Cmd Msg
saveQuizzCmd quizz =
    saveQuizzRequest quizz
        |> Http.send Msgs.OnQuizzSave

saveUserCmd : User -> Cmd Msg
saveUserCmd user =
    saveUserRequest user
        |> Http.send Msgs.OnUserSave

-- DECODERS
    
userDecoder : Decode.Decoder User
userDecoder =
    decode User
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "quizzs" (Decode.list quizzUserDecoder)

userEncoder : User -> Encode.Value
userEncoder user =
    let
        attributes =
            [ ( "id", Encode.int user.id )
            , ( "name", Encode.string user.name )
            , ( "quizzs", (Encode.list <| List.map quizzUserEncoder user.quizzs) )
            ]
    in
        Encode.object attributes

quizzUserDecoder : Decode.Decoder QuizzUser
quizzUserDecoder =
    decode QuizzUser
        |> required "id" Decode.int
        |> required "quizzState" Decode.string
        |> required "questions" (Decode.list questionUserDecoder)

quizzUserEncoder : QuizzUser -> Encode.Value
quizzUserEncoder quizzUser =
    let
        attributes =
            [ ( "id", Encode.int quizzUser.id )
            , ( "quizzState", Encode.string quizzUser.quizzState )
            , ( "questions", (Encode.list <| List.map questionUserEncoder  quizzUser.questions) )
            ]
    in
        Encode.object attributes

questionUserDecoder : Decode.Decoder QuestionUser
questionUserDecoder =
    decode QuestionUser
        |> required "id" Decode.int
        |> required "answers" (Decode.list Decode.int)

questionUserEncoder : QuestionUser -> Encode.Value
questionUserEncoder questionUser =
    let
        attributes =
            [ ( "id", Encode.int questionUser.id )
            , ( "answers", Encode.list <| List.map Encode.int questionUser.answers)
            ]
    in
        Encode.object attributes

quizzsDecoder : Decode.Decoder (List Quizz)
quizzsDecoder =
    Decode.list quizzDecoder

quizzDecoder : Decode.Decoder Quizz
quizzDecoder =
    decode Quizz
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "questions" (Decode.list questionDecoder)

quizzEncoder : Quizz -> Encode.Value
quizzEncoder quizz =
    let
        attributes =
            [ ( "id", Encode.int quizz.id )
            , ( "name", Encode.string quizz.name )
            , ( "questions", (Encode.list <| List.map questionEncoder  quizz.questions) )
            ]
    in
        Encode.object attributes

questionDecoder : Decode.Decoder Question
questionDecoder =
    decode Question
        |> required "id" Decode.int
        |> required "questionText" Decode.string
        |> required "questionType" Decode.string
        |> required "answers" (Decode.list Decode.int)
        |> required "responses" (Decode.list responseDecoder)
        
questionEncoder : Question -> Encode.Value
questionEncoder question =
    let
        attributes =
            [ ( "id", Encode.int question.id )
            , ( "questionText", Encode.string question.questionText )
            , ( "questionType", Encode.string question.questionType )
            , ( "answers", Encode.list <| List.map Encode.int question.answers)
            , ( "responses", Encode.list <| List.map responseEncoder question.responses)
            ]
    in
        Encode.object attributes

responseDecoder : Decode.Decoder Response
responseDecoder =
    decode Response
        |> required "id" Decode.int
        |> required "content" Decode.string
        |> required "isAnswer" Decode.bool

responseEncoder : Response -> Encode.Value
responseEncoder response =
    let
        attributes =
            [ ( "id", Encode.int response.id )
            , ( "content", Encode.string response.content )
            , ( "isAnswer", Encode.bool response.isAnswer)
            ]
    in
        Encode.object attributes