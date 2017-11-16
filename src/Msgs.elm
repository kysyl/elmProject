module Msgs exposing (..)

import Http
import Models exposing (Quizz, QuizzId)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnFetchQuizzs (WebData (List Quizz))
    | OnLocationChange Location
    | ChangeLevel Quizz Int
    | OnQuizzSave (Result Http.Error Quizz)
