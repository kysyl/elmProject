module Update exposing (..)

import Commands exposing (saveQuizzCmd)
import Models exposing (Model, Quizz)
import Msgs exposing (Msg)
import Routing exposing (parseLocation)
import RemoteData


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnFetchQuizzs response ->
            ( { model | quizzs = response }, Cmd.none )

        Msgs.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        Msgs.ChangeLevel identity howMuch ->
            let
                updatedQuizz =
                    { identity | age = identity.age + howMuch }
            in
                ( model, saveQuizzCmd updatedQuizz )

        Msgs.OnQuizzSave (Ok quizz) ->
            ( updateQuizz model quizz, Cmd.none )

        Msgs.OnQuizzSave (Err error) ->
            ( model, Cmd.none )


updateQuizz : Model -> Quizz -> Model
updateQuizz model updatedQuizz =
    let
        pick currentQuizz =
            if updatedQuizz.id == currentQuizz.id then
                updatedQuizz
            else
                currentQuizz

        updateQuizzList quizzs =
            List.map pick quizzs

        updatedQuizzs =
            RemoteData.map updateQuizzList model.quizzs
    in
        { model | quizzs = updatedQuizzs }
