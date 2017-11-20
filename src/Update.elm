module Update exposing (..)

import Commands exposing (saveQuizzCmd, fetchUser)
import Models exposing (Model, Quizz, Identity, User)
import Msgs exposing (Msg)
import Routing exposing (parseLocation)
import RemoteData


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnFetchQuizzs response ->
            ( { model | quizzs = response }, fetchUser )

        Msgs.OnFetchUser response ->
            ( { model | user = response }, Cmd.none )

        Msgs.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        Msgs.ChangeLevel quizz howMuch ->
            let
                iden = quizz.identity
                updatedIdent =
                    { iden | age = iden.age + howMuch }
            in
                ( model, saveQuizzCmd (updateIdentityInQuizz quizz updatedIdent)  )

        Msgs.OnQuizzSave (Ok quizz) ->
            ( updateQuizz model quizz, Cmd.none )
        
        Msgs.OnQuizzSave (Err error) ->
            ( model, Cmd.none )

        Msgs.OnUserSave (Ok user) ->
            ( updateUser model user, Cmd.none )

        Msgs.OnUserSave (Err error) ->
            ( model, Cmd.none )

        
updateIdentityInQuizz : Quizz -> Identity -> Quizz
updateIdentityInQuizz quizz iden =
    { quizz | identity = iden }


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

updateUser : Model -> User -> Model
updateUser model user =
    let
        updatedUser =
            RemoteData.Success user
    in
         { model | user = updatedUser }