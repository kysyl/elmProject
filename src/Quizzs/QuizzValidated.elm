module Quizzs.QuizzValidated exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, href)
import Html.Events exposing (onClick)
import Models exposing (Quizz, QuizzUser)
import Msgs exposing (Msg)
import Routing exposing (quizzsPath)


view : Quizz -> QuizzUser -> Html.Html Msg
view quizz userQuizz =
    div []
        [ nav quizz
        , form quizz userQuizz
        ]


nav : Quizz -> Html.Html Msg
nav quizz =
    div [ class "clearfix mb2 white bg-black p1" ]
        [ listBtn ]


form : Quizz  -> QuizzUser -> Html.Html Msg
form quizz userQuizz =
    div [ class "m3" ]
        [ h1 [] [ text quizz.name ]
        , formLevel quizz userQuizz
        ]


formLevel : Quizz  -> QuizzUser -> Html.Html Msg
formLevel quizz userQuizz =
    div
        [ class "clearfix py1"
        ]
        [ div [ class "col col-5" ] [ text userQuizz.quizzState ]
        , div [ class "col col-7" ]
            [ span [ class "h2 bold" ] [ text (toString quizz.identity.age) ]
            , btnLevelDecrease quizz
            , btnLevelIncrease quizz
            ]
        ]   


btnLevelDecrease : Quizz -> Html.Html Msg
btnLevelDecrease quizz =
    let
        message =
            Msgs.ChangeLevel quizz -1
    in
        a [ class "btn ml1 h1", onClick message ]
            [ i [ class "fa fa-minus-circle" ] [] ]


btnLevelIncrease : Quizz -> Html.Html Msg
btnLevelIncrease quizz =
    let
        message =
            Msgs.ChangeLevel quizz 1
    in
        a [ class "btn ml1 h1", onClick message ]
            [ i [ class "fa fa-plus-circle" ] [] ]


listBtn : Html Msg
listBtn =
    a
        [ class "btn regular"
        , href quizzsPath
        ]
        [ i [ class "fa fa-chevron-left mr1" ] [], text "List" ]
