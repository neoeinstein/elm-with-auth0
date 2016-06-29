module Authentication
    exposing
        ( Msg(..)
        , Model
        , init
        , update
        , handleAuthResult
        , tryGetUserProfile
        , isLoggedIn
        )

import Auth0


type Msg
    = AuthenticationResult Auth0.AuthenticationResult
    | ShowLogIn
    | LogOut


type alias Model =
    { state : Auth0.AuthenticationState
    , lastError : Maybe Auth0.AuthenticationError
    , showLock : Auth0.Options -> Cmd Msg
    }


init : (Auth0.Options -> Cmd Msg) -> Model
init showLock =
    { state = Auth0.LoggedOut
    , lastError = Nothing
    , showLock = showLock
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AuthenticationResult result ->
            let
                ( newState, error ) =
                    case result of
                        Ok user ->
                            ( Auth0.LoggedIn user, Nothing )

                        Err err ->
                            ( model.state, Just err )
            in
                ( { model | state = newState, lastError = error }, Cmd.none )

        ShowLogIn ->
            ( model, model.showLock Auth0.defaultOpts )

        LogOut ->
            ( { model | state = Auth0.LoggedOut }, Cmd.none )


handleAuthResult : Auth0.RawAuthenticationResult -> Msg
handleAuthResult = Auth0.mapResult >> AuthenticationResult


tryGetUserProfile : Model -> Maybe Auth0.UserProfile
tryGetUserProfile model =
    case model.state of
        Auth0.LoggedIn user -> Just user.profile
        Auth0.LoggedOut -> Nothing

isLoggedIn : Model -> Bool
isLoggedIn model =
    case model.state of
        Auth0.LoggedIn _ -> True
        Auth0.LoggedOut -> False
