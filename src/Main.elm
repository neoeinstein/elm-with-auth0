port module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Auth0
import Authentication

main : Program Never
main = 
    Html.program 
        { init = init 
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
    
{- 
    MODEL
-}

type alias Model =
    { authModel : Authentication.Model
    }

{-
    INIT
-}

init : ( Model, Cmd Msg)  
init =
    ( Model (Authentication.init auth0showLock), Cmd.none )
       
{-
    UPDATE
    * Messages
    * Update case
-}

-- Messages

type Msg 
    = AuthenticationMsg Authentication.Msg 

-- Ports

port auth0showLock : Auth0.Options -> Cmd msg
port auth0authResult : (Auth0.RawAuthenticationResult -> msg) -> Sub msg
-- port logout : Model -> Cmd msg

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        AuthenticationMsg authMsg ->
            let
                ( authModel, cmd ) = Authentication.update authMsg model.authModel
            in
                ( { model | authModel = authModel }, Cmd.map AuthenticationMsg cmd )

{-
    SUBSCRIPTIONS
-}

subscriptions : a -> Sub Msg
subscriptions model = 
    auth0authResult (Authentication.handleAuthResult >> AuthenticationMsg)                
                       
{-
    VIEW
-}

view : Model -> Html Msg
view model =
    div [ class "container" ] [
        div [ class "row" ] [
            div [ class "jumbotron text-center" ]
                [ p []
                    ( case Authentication.tryGetUserProfile model.authModel of
                        Nothing -> [ text "Please log in" ]
                        Just user ->
                            [ p [] [ img [ src user.picture ] [] ]
                            , p [] [ text ("Hello, " ++ user.name ++ "!") ]
                            ]
                    )
                , p [] [
                    button
                        [ class "btn btn-primary", onClick (AuthenticationMsg (if Authentication.isLoggedIn model.authModel then Authentication.LogOut else Authentication.ShowLogIn)) ]
                        [ text (if Authentication.isLoggedIn model.authModel then "Logout" else "Login")]
                    ]    
                ]
        ] 
    ]       