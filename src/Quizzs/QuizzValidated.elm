module Quizzs.QuizzValidated exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, value)
import Html.Events exposing (onClick)
import Models exposing (Quizz, QuizzUser, Question, QuestionUser, Response, User)
import Msgs exposing (Msg)
import Routing exposing (quizzsPath)


view : Quizz -> User -> Html.Html Msg
view quizz user =
    div []
        [ nav quizz
        , content quizz user
        ]


nav : Quizz -> Html.Html Msg
nav quizz =
    div [ class "clearfix mb2 white bg-black p1" ]
        [ listBtn ]


content : Quizz -> User -> Html.Html Msg
content quizz user =
    div [ class "m3 container" ]
        [ h1 [] [ text quizz.name ]
        , div [] (List.map (questionsDisplay user quizz) quizz.questions)
        ]


questionsDisplay : User -> Quizz -> Question -> Html.Html Msg
questionsDisplay user quizz question =
    div
        [ class "clearfix py1 col col-8" ]
        [ div [ class "title" ] [ h2 [] [text question.questionText] ]
        , div [] [ fieldset [] (List.map (responseDisplay quizz user question) question.responses) ]
        ]

responseDisplay : Quizz -> User -> Question -> Response -> Html.Html Msg
responseDisplay quizz user question response =
    let
        message =
            Msgs.UpdateAnswer quizz question response user
        isChecked = isCheckedOrNot quizz question response user 
    in
        label [class "clearfix py1 col col-8"]
                [ input [ Html.Attributes.type_ "radio", Html.Attributes.name "question", onClick message, Html.Attributes.checked isChecked ] []
                , text response.content
                ]

listBtn : Html Msg
listBtn = 
    a
        [
            class "btn regular"
        ,   href quizzsPath
        ]
        [ i [ class "fa fa-chevron-left mr1" ] [], text "Liste des quizzs"]

isCheckedOrNot : Quizz -> Question -> Response -> User -> Bool
isCheckedOrNot quizz question response user =
    let
        maybeUserQuizz = List.foldl (\qu acc -> 
                    if (qu.id == quizz.id) 
                    then Just qu
                    else acc
                )
                Nothing
                user.quizzs
    in
        case maybeUserQuizz of 
            Nothing ->
                False
            Just userQuizz ->
                let
                    maybeQuestionQuizz = List.foldl (\qu acc -> 
                            if (qu.id == question.id) 
                            then Just qu
                            else acc
                        )
                        Nothing
                        userQuizz.questions
                in 
                    case maybeQuestionQuizz of
                        Nothing ->
                            False
                        Just questionQuizz ->
                            List.member response.id questionQuizz.answers