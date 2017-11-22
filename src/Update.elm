module Update exposing (..)

import Commands exposing (saveQuizzCmd, fetchUser, saveUserCmd)
import Models exposing (Model, Quizz, User, Question, QuestionUser, Response, QuizzId, QuizzUser)
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

        Msgs.UpdateAnswer quizz question response user ->
            let 
                updatedUser =
                    findUserQuizz quizz user question response
            in
                ( model, saveUserCmd (updatedUser)  )

        Msgs.OnQuizzSave (Ok quizz) ->
            ( updateQuizz model quizz, Cmd.none )
        
        Msgs.OnQuizzSave (Err error) ->
            ( model, Cmd.none )

        Msgs.OnUserSave (Ok user) ->
            ( updateUser model user, Cmd.none )

        Msgs.OnUserSave (Err error) ->
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

updateUser : Model -> User -> Model
updateUser model user =
    let
        updatedUser =
            RemoteData.Success user
    in
         { model | user = updatedUser }


findUserQuizz : Quizz -> User -> Question -> Response -> User
findUserQuizz quizz user question response =
    let
        quizzId = quizz.id
        maybeUserQuizz =
            user.quizzs
                |> List.filter (\user -> user.id == quizzId)
                |> List.head
    in
        case maybeUserQuizz of
            Just userQuizz ->

                let
                    questionId = question.id
                    maybeUserQuestion =
                        userQuizz.questions
                            |> List.filter (\qu -> qu.id == questionId)
                            |> List.head
                in
                    case maybeUserQuestion of
                        Just userQuestion ->
                            let
                                newUserQuestion = {userQuestion | answers = [response.id]}
                                pick qu =
                                    if newUserQuestion.id == qu.id then
                                        newUserQuestion
                                    else
                                        qu

                                updateUserQuestionList questions =
                                    List.map pick questions

                                updatedUserQuestionList =
                                    updateUserQuestionList userQuizz.questions
                                updatedUserQuizz = {userQuizz | questions = updatedUserQuestionList}

                                pick2 qu =
                                    if updatedUserQuizz.id == qu.id then
                                        updatedUserQuizz
                                    else
                                        qu

                                updateUserQuizzs quizzs =
                                    List.map pick2 quizzs

                                updatedQuizzs =
                                    updateUserQuizzs user.quizzs

                            in
                                 {user | quizzs = updatedQuizzs}
                        Nothing ->
                            let
                                newQuestionUser =
                                    createQuestionUser response question
                                updatedUserQuizz = 
                                    {userQuizz | questions = newQuestionUser :: userQuizz.questions}

                                pick2 qu =
                                    if updatedUserQuizz.id == qu.id then
                                        updatedUserQuizz
                                    else
                                        qu

                                updateUserQuizzs quizzs =
                                    List.map pick2 quizzs

                                updatedQuizzs =
                                    updateUserQuizzs user.quizzs
                                
                            in
                               {user | quizzs = updatedQuizzs}

            Nothing ->
                let
                    newUserQuizz =
                        createUserQuizz user quizz quizz.id response
                in
                    {user | quizzs = newUserQuizz :: user.quizzs}
  
createUserQuizz : User -> Quizz -> QuizzId -> Response -> QuizzUser
createUserQuizz user quizz quizzId response =
    QuizzUser quizz.id "started" (createQuestionsUser quizz.questions response)              

createQuestionsUser : List Question -> Response -> List QuestionUser
createQuestionsUser questions response =
    List.map (createQuestionUser response) questions

createQuestionUser : Response -> Question -> QuestionUser
createQuestionUser response question =
    QuestionUser question.id [response.id]

