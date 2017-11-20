module Quizzs.List exposing (..)

import List exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Models exposing (Quizz, QuizzUser, QuizzId, User)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Routing exposing (quizzPath)


view : WebData (List Quizz) -> WebData (User) -> Html Msg
view quizzs_wd user_wd =
    div []
        [ nav
        , maybeQuizzs quizzs_wd user_wd
        ]


nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Quizzs" ] ]


maybeQuizzs : WebData (List Quizz) -> WebData (User) -> Html Msg
maybeQuizzs quizzs_wd user_wd =
    case quizzs_wd of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading Quizz..."

        RemoteData.Success quizzs ->
            displayQuizzs quizzs user_wd

        RemoteData.Failure error ->
            text (toString error)

displayQuizzs : List Quizz -> WebData (User) -> Html Msg
displayQuizzs quizzs user_wd =
    div [ class "p2" ]
        [ table []
            [ thead []
                [ tr []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Name" ]
                    , th [] [ text "Actions" ]
                    ]
                ]
            , tbody [] (List.map (quizzRow user_wd) quizzs)
            ]
        ]


quizzRow : WebData (User) -> Quizz -> Html Msg
quizzRow user_wd quizz  =
    tr []
        [ td [] [ text (toString quizz.id) ]
        , td [] [ text quizz.name ]
        , td []
            [ editBtn quizz user_wd ]
        ]


editBtn : Quizz -> WebData (User) -> Html.Html Msg
editBtn quizz user_wd =
    let
        path =
            quizzPath quizz.id
    in
        a
            [ class "btn regular"
            , href path
            ]
            [ i [ class "fa fa-pencil mr1" ] [], maybeUser quizz user_wd ]

findUserQuizz : User -> Quizz -> Maybe QuizzUser
findUserQuizz user quizz =
    List.foldl (\qu acc -> 
        if (qu.id == quizz.id) 
        then Just qu
        else acc
    )
    Nothing
    user.quizzs

maybeUser : Quizz -> WebData (User) -> Html Msg
maybeUser quizz user_wd =
    case user_wd of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading User..."

        RemoteData.Success user ->
           case findUserQuizz user quizz of
                Nothing ->
                    text "Commencer"
                Just quizz_user ->
                    text "Résultats"

        RemoteData.Failure error ->
            text (toString error)
