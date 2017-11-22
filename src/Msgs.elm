module Msgs exposing (..)

import Http
import Models exposing (Quizz, QuizzId, User, QuizzUser, Response, Question)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnFetchQuizzs (WebData (List Quizz))
    | OnFetchUser (WebData User)
    | OnLocationChange Location
    | OnQuizzSave (Result Http.Error Quizz)
    | OnUserSave (Result Http.Error User)
    | UpdateAnswer Quizz Question Response User