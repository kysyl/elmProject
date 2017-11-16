module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { 
        quizzs : WebData (List Quizz),
        user : WebData (User),
        route : Route
    }


initialModel : Route -> Model
initialModel route =
    { 
        quizzs = RemoteData.Loading,
        user = RemoteData.Loading,
        route = route
    }


type alias QuizzId =
    String


type alias Quizz =
    { 
        id : QuizzId, 
        name : String,
        level : Int,
        identity : Identity
    }

type alias UserId =
    String

type alias Identity =
    {
        age : Int,
        sex : String
    }

type alias User =
    {
        id : UserId,
        name : String,
        identity : Identity
    }


type Route
    = QuizzsRoute
    | QuizzRoute QuizzId
    | NotFoundRoute
