module View exposing (..)

import Html exposing (Html, div, text)
import Models exposing (Model, QuizzId)
import Models exposing (Model)
import Msgs exposing (Msg)
import Quizzs.Quizz
import Quizzs.List
import RemoteData


view : Model -> Html Msg
view model =
    div []
        [ page model ]
        

page : Model -> Html Msg
page model =
    case model.route of
        Models.QuizzsRoute ->
            Quizzs.List.view model.quizzs

        Models.QuizzRoute id ->
            quizzQuizzPage model id

        Models.NotFoundRoute ->
            notFoundView


quizzQuizzPage : Model -> QuizzId -> Html Msg
quizzQuizzPage model quizzId =
    case model.quizzs of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading ..."

        RemoteData.Success quizzs ->
            let
                maybeQuizz =
                    quizzs
                        |> List.filter (\quizz -> quizz.id == quizzId)
                        |> List.head
            in
                case maybeQuizz of
                    Just quizz ->
                        Quizzs.Quizz.view quizz

                    Nothing ->
                        notFoundView

        RemoteData.Failure err ->
            text (toString err)


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
