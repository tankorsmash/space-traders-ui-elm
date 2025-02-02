module Page.Login exposing
    ( LoginForm
    , Model
    , Msg(..)
    , RegisterForm
    , init
    , subscriptions
    , update
    , view
    , viewModals
    , withSubmitting
    )

import Browser.Events
import Dict exposing (Dict)
import Form
import Form.Field
import Form.Validation
import Html exposing (Html)
import Html.Attributes
import Http
import Port
import Route
import Shared
import SpaceTrader.Agent
import SpaceTrader.Api
import SpaceTrader.Contract
import SpaceTrader.Faction
import SpaceTrader.Point.SystemDict as SystemDict exposing (SystemDict)
import SpaceTrader.Ship
import SpaceTrader.System
import Ui
import Ui.Button
import Ui.Form
import Ui.Form.Field
import Ui.Modal
import Update exposing (Update)


type alias Model =
    { registerFormModel : Form.Model
    , submittingRegistration : Bool
    , registrationToken : Maybe String
    , loginFormModel : Form.Model
    , submittingLogin : Bool
    , loginServerError : Maybe String
    , systems : Maybe (SystemDict SpaceTrader.System.System)
    , backgroundRotation : Float
    }


init :
    { systems : Maybe (SystemDict SpaceTrader.System.System)
    , toMsg : Msg -> msg
    , toModel : Model -> model
    }
    -> Update model msg
init opts =
    { registerFormModel = Form.init
    , submittingRegistration = False
    , registrationToken = Nothing
    , loginFormModel = Form.init
    , submittingLogin = False
    , loginServerError = Nothing
    , systems = opts.systems
    , backgroundRotation = 0
    }
        |> Update.succeed
        |> Update.mapMsg opts.toMsg
        |> Update.mapModel opts.toModel


withSubmitting : Model -> Model
withSubmitting model =
    { model | submittingRegistration = True }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onAnimationFrameDelta Tick


type Msg
    = Tick Float
    | RegistrationFormMsg (Form.Msg Msg)
    | RegistrationFormSubmitted (Ui.Form.Submission String RegisterForm)
    | RegistrationResponded
        (Result
            SpaceTrader.Api.Error
            { agent : SpaceTrader.Agent.Agent
            , contract : SpaceTrader.Contract.Contract
            , faction : SpaceTrader.Faction.Faction
            , ship : SpaceTrader.Ship.Ship
            , token : String
            }
        )
    | TokenCopyAcknowledged
    | LoginFormMsg (Form.Msg Msg)
    | LoginFormSubmitted (Ui.Form.Submission String LoginForm)
    | LoginResponded String (Result Http.Error SpaceTrader.Agent.Agent)


update :
    { shared : Shared.Model
    , msg : Msg
    , model : Model
    , toMsg : Msg -> msg
    , toModel : Model -> model
    }
    -> Update model msg
update ({ model } as opts) =
    Update.mapModel opts.toModel <|
        Update.mapMsg opts.toMsg <|
            case opts.msg of
                Tick detlaMs ->
                    { model | backgroundRotation = model.backgroundRotation + detlaMs }
                        |> Update.succeed

                -- registration
                RegistrationFormMsg msg_ ->
                    let
                        ( registerFormModel, formCmd ) =
                            Form.update msg_ model.registerFormModel
                    in
                    { model
                        | registerFormModel = registerFormModel
                    }
                        |> Update.succeed
                        |> Update.withCmd formCmd

                RegistrationFormSubmitted { parsed } ->
                    case parsed of
                        Form.Valid registerData ->
                            { model
                                | submittingRegistration = True
                            }
                                |> Update.succeed
                                |> Update.withRequest RegistrationResponded
                                    (SpaceTrader.Api.register registerData)

                        Form.Invalid _ _ ->
                            model
                                |> Update.succeed

                RegistrationResponded response ->
                    model
                        |> Update.withResponse response
                            (\data ->
                                { model
                                    | submittingRegistration = False
                                    , registrationToken = Just data.token
                                }
                                    |> Update.succeed
                                    |> Update.withCmd (Port.setToken data.token)
                                    |> Update.withCmd (Port.openModal modalIds.registrationSuccess)
                            )

                TokenCopyAcknowledged ->
                    model
                        |> Update.succeed
                        |> Update.withEffect (Update.RouteChangeRequested (Route.Game { tab = Just Route.Ships }))

                -- login
                LoginFormMsg msg_ ->
                    let
                        ( loginFormModel, formCmd ) =
                            Form.update msg_ model.loginFormModel
                    in
                    { model
                        | loginFormModel = loginFormModel
                    }
                        |> Update.succeed
                        |> Update.withCmd formCmd

                LoginFormSubmitted { parsed } ->
                    case parsed of
                        Form.Valid loginData ->
                            { model | submittingLogin = True }
                                |> Update.succeed
                                |> Update.withCmd
                                    (SpaceTrader.Api.myAgent (LoginResponded loginData.accessToken)
                                        { token = loginData.accessToken
                                        }
                                    )

                        Form.Invalid _ _ ->
                            model
                                |> Update.succeed

                LoginResponded _ (Err err) ->
                    { model
                        | submittingLogin = False

                        -- , loginServerError = Just (Debug.toString err)
                        , loginServerError = Just "There was an error"
                    }
                        |> Update.succeed

                LoginResponded accessToken (Ok agent) ->
                    model
                        |> Update.succeed
                        |> Update.withCmd (Port.setToken accessToken)
                        |> Update.withEffect
                            (Update.Authenticated
                                { accessToken = accessToken
                                , agent = Just agent
                                , systems = model.systems
                                }
                            )


view : Model -> Html Msg
view model =
    Html.div
        [ Ui.grid
        , Html.Attributes.style "align-content" "start"
        , Html.Attributes.style "height" "100vh"
        , Html.Attributes.style "width" "100vw"
        , Html.Attributes.class "sunburst"
        , Html.Attributes.style "background" ("""repeating-conic-gradient(
            from """ ++ String.fromFloat (model.backgroundRotation / 100) ++ """deg at 50% 102%,
            transparent 0deg 5deg,
            transparent 27deg 32deg,
            var(--blue-light) 35deg 37deg,
            transparent 40deg 45deg,
            transparent 47deg 50deg
        ), repeating-conic-gradient(
            from """ ++ String.fromFloat (model.backgroundRotation / 200) ++ """deg at 50% 102%,
            var(--blue-dark) 0deg 5deg,
            var(--blue) 27deg 32deg,
            var(--blue-light) 35deg 37deg,
            var(--blue) 40deg 45deg,
            var(--blue-dark) 47deg 50deg
        )""")
        ]
        [ Html.div
            [ Html.Attributes.style "color" "var(--red)"
            , Html.Attributes.style "font-size" "8rem"
            , Html.Attributes.style "font-weight" "bold"
            , Html.Attributes.style "text-align" "center"
            , Html.Attributes.style "-webkit-text-stroke" "0.3rem var(--yellow)"
            ]
            [ Html.text "SpaceTraders" ]
        , Html.div
            [ Ui.grid
            , Ui.gap 1
            , Ui.justify.center
            ]
            [ Ui.Form.view
                { submitting = model.submittingRegistration
                , title = "Register"
                , model = model.registerFormModel
                , toMsg = RegistrationFormMsg
                , id = "registration-form"
                , onSubmit = RegistrationFormSubmitted
                , serverSideErrors = Nothing
                }
                registrationForm
            , Ui.Form.view
                { submitting = model.submittingLogin
                , title = "Login"
                , model = model.loginFormModel
                , toMsg = LoginFormMsg
                , id = "login-form"
                , onSubmit = LoginFormSubmitted
                , serverSideErrors = Nothing
                }
                loginForm
            ]
        ]


type alias RegisterForm =
    { callsign : String
    , faction : SpaceTrader.Faction.Group
    }


registrationForm : Form.HtmlForm String RegisterForm input Msg
registrationForm =
    (\callsign faction ->
        { combine =
            Form.Validation.succeed RegisterForm
                |> Form.Validation.andMap
                    (Form.Validation.map
                        (\callsignValue ->
                            Form.Validation.succeed callsignValue
                                |> Form.Validation.withErrorIf (String.length callsignValue < 3) callsign "Must be at least 3 characters"
                                |> Form.Validation.withErrorIf (String.length callsignValue > 14) callsign "Must can't be more than 14 characters"
                        )
                        callsign
                        |> Form.Validation.andThen identity
                    )
                |> Form.Validation.andMap faction
        , view =
            \formState ->
                List.concat
                    [ Ui.Form.Field.text
                        { formState = formState
                        , label = "Callsign"
                        , hint = Nothing
                        , field = callsign
                        }
                    , Ui.Form.Field.select
                        { toString = SpaceTrader.Faction.groupToPrettyString }
                        formState
                        "Faction"
                        faction
                    , Ui.Form.Field.submit
                        { label =
                            if formState.submitting then
                                "Registering..."

                            else
                                "Register"
                        , disabled = formState.submitting
                        }
                    ]
        }
    )
        |> Form.form
        |> Form.field "callsign"
            (Form.Field.text
                |> Form.Field.required "Required"
            )
        |> Form.field "faction"
            (Form.Field.select
                (SpaceTrader.Faction.groups
                    |> List.map (\group -> ( SpaceTrader.Faction.groupToPrettyString group, group ))
                )
                identity
                |> Form.Field.required "Required"
            )


type alias LoginForm =
    { accessToken : String
    }


loginForm : Form.HtmlForm String LoginForm input Msg
loginForm =
    (\accessToken ->
        { combine =
            Form.Validation.succeed LoginForm
                |> Form.Validation.andMap accessToken
        , view =
            \formState ->
                List.concat
                    [ Ui.Form.Field.text
                        { formState = formState
                        , label = "Access Token"
                        , hint = Nothing
                        , field = accessToken
                        }
                    , Ui.Form.Field.submit
                        { label =
                            if formState.submitting then
                                "Logging in..."

                            else
                                "Login"
                        , disabled = formState.submitting
                        }
                    ]
        }
    )
        |> Form.form
        |> Form.field "accessToken"
            (Form.Field.text
                |> Form.Field.required "Required"
                |> Form.Field.password
            )



-- MODALS


modalIds : { registrationSuccess : String }
modalIds =
    { registrationSuccess = "registrationSuccess" }


viewModals : Shared.Model -> Model -> List (Html Msg)
viewModals shared model =
    [ Ui.Modal.view modalIds.registrationSuccess
        []
        [ Ui.column
            [ Ui.gap 1 ]
            [ Ui.header.one [] [ Html.text "IMPORTANT!" ]
            , Html.p [] [ Html.text "This access token is your password and is the only way to access your account. If you lose it, you will lose your account. Make sure you copy it somewhere safe." ]
            , Ui.header.three
                [ Html.Attributes.style "max-width" "90vw"
                , Html.Attributes.style "overflow-wrap" "break-word"
                ]
                [ Html.text "Access Token: "
                , Html.span []
                    [ Html.text (Maybe.withDefault "" model.registrationToken)
                    ]
                ]
            , Ui.Button.default
                [ Ui.justify.end
                , Ui.align.end
                ]
                { label = Html.text "I've copied my token"
                , onClick = Just TokenCopyAcknowledged
                }
            ]
        ]
    ]
