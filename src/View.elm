module View exposing (..)

import Html exposing (Html, div, text)
import Commands exposing (saveUserCmd)
import Models exposing (Model, QuizzId, Quizz, QuizzUser, User, QuestionUser, Question, Response, AnswerUser)
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
            Quizzs.List.view model.quizzs model.user

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
            text "Loading Quizz..."

        RemoteData.Success quizzs ->
            let
                maybeQuizz =
                    quizzs
                        |> List.filter (\quizz -> quizz.id == quizzId)
                        |> List.head
            in
                case maybeQuizz of
                    Just quizz ->
                        userQuizzPage model quizz quizzId

                    Nothing ->
                        notFoundView

        RemoteData.Failure err ->
            text (toString err)

userQuizzPage : Model -> Quizz -> QuizzId -> Html Msg
userQuizzPage model quizz quizzId =
    case model.user of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading User Quizz..."

        RemoteData.Success user ->
            let
                maybeUserQuizz =
                    user.quizzs
                        |> List.filter (\user -> user.id == quizzId)
                        |> List.head
            in
                case maybeUserQuizz of
                    Just userQuizz ->
                        Quizzs.Quizz.view quizz userQuizz

                    Nothing ->
                        createUserQuizz user quizz quizzId

        RemoteData.Failure err ->
            text (toString err)


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found Quizz"
        ]

notFoundViewUser : Html msg
notFoundViewUser =
    div []
        [ text "Not found USER Quizz"
        ]

createQuestionsUser : List Question -> List QuestionUser
createQuestionsUser questions =
    List.map createQuestionUser questions

createQuestionUser : Question -> QuestionUser
createQuestionUser question = 
    QuestionUser question.id [] (createResponsesUser question.responses)

createResponsesUser : List Response -> List AnswerUser
createResponsesUser responses =
    List.map createResponseUser responses

createResponseUser : Response -> AnswerUser
createResponseUser reponse =
    AnswerUser reponse.id False

createUserQuizz : User -> Quizz -> QuizzId -> Html Msg
createUserQuizz user quizz quizzId =
    let
        quizzUser : QuizzUser
        quizzUser = 
        {
            id = quizz.id
        ,   quizzState = "started"
        ,   questions = createQuestionsUser quizz.questions

        }
        updatedUser =
             { user | quizzs = quizzUser :: user.quizzs }
        message = saveUserCmd updatedUser
    in
        Quizzs.Quizz.view quizz quizzUser