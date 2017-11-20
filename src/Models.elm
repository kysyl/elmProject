module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { quizzs : WebData (List Quizz)
    , user : WebData User
    , route : Route
    }


initialModel : Route -> Model
initialModel route =
    { quizzs = RemoteData.Loading
    , user = RemoteData.Loading
    , route = route
    }


type alias QuizzId =
    Int


type alias Quizz =
    { id : QuizzId
    , name : String
    , questions : List Question
    , level : Int
    , identity : Identity
    }


type alias Question =
    { id : QuestionId
    , questionText : String
    , questionType : QuestionType
    , answers : List AnswerId
    , responses : List Response
    }


type alias QuestionId =
    Int


type alias QuestionType =
    String


type alias AnswerId =
    Int


type alias Response =
    { id : AnswerId
    , content : String
    , isAnswer : Bool
    }


type alias UserId =
    Int


type alias Identity =
    { age : Int
    , sex : String
    }


type alias User =
    { id : UserId
    , name : String
    , quizzs : List QuizzUser
    }


type alias QuizzUser =
    { id : QuizzId
    , quizzState : String
    , questions : List QuestionUser
    }


type alias QuestionUser =
    { id : QuestionId
    , answers : List AnswerId
    , responses : List AnswerUser
    }


type alias AnswerUser =
    { id : AnswerId
    , isChosen : Bool
    }


type Route
    = QuizzsRoute
    | QuizzRoute QuizzId
    | NotFoundRoute
