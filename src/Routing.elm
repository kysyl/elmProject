module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (QuizzId, Route(..))
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map QuizzsRoute top
        , map QuizzRoute (s "quizzs" </> int)
        , map QuizzsRoute (s "quizzs")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


quizzsPath : String
quizzsPath =
    "#quizzs"


quizzPath : QuizzId -> String
quizzPath id =
    "#quizzs/" ++ toString id
