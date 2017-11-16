module Quizzs.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Models exposing (Quizz)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Routing exposing (quizzPath)


view : WebData (List Quizz) -> Html Msg
view response =
    div []
        [ nav
        , maybeList response
        ]


nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Quizzs" ] ]


maybeList : WebData (List Quizz) -> Html Msg
maybeList response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success quizzs ->
            list quizzs

        RemoteData.Failure error ->
            text (toString error)


list : List Quizz -> Html Msg
list quizzs =
    div [ class "p2" ]
        [ table []
            [ thead []
                [ tr []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Name" ]
                    , th [] [ text "Level" ]
                    , th [] [ text "Actions" ]
                    ]
                ]
            , tbody [] (List.map quizzRow quizzs)
            ]
        ]


quizzRow : Quizz -> Html Msg
quizzRow quizz =
    tr []
        [ td [] [ text quizz.id ]
        , td [] [ text quizz.name ]
        , td [] [ text (toString quizz.level) ]
        , td []
            [ editBtn quizz ]
        ]


editBtn : Quizz -> Html.Html Msg
editBtn quizz =
    let
        path =
            quizzPath quizz.id
    in
        a
            [ class "btn regular"
            , href path
            ]
            [ i [ class "fa fa-pencil mr1" ] [], text "Show" ]
