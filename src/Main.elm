module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode exposing (..)


type alias Model =
    { error : Maybe String
    , joke : Maybe Joke
    }


type alias Joke =
    { value : String
    , url : String
    }


initModel : Model
initModel =
    { error = Nothing
    , joke = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )


type Msg
    = GetJoke
    | JokeResponse (Result Http.Error Joke)


jokeDecoder : Decoder Joke
jokeDecoder =
    map2 Joke
        (field "value" string)
        (field "url" string)


apiUrl : String
apiUrl =
    "https://api.chucknorris.io/jokes/random"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetJoke ->
            let
                req =
                    Http.get apiUrl jokeDecoder
            in
                ( model, Http.send JokeResponse req )

        JokeResponse res ->
            case res of
                Ok joke ->
                    ( { model | joke = Just joke }, Cmd.none )

                Err _ ->
                    ( { model | error = Just "error calling api" }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Chuck's API" ]
        , hr [] []
        , renderJoke model.joke
        , hr [] []
        , button [ class "btn btn-primary", onClick GetJoke ] [ text "Get Joke" ]
        ]


renderJoke : Maybe Joke -> Html Msg
renderJoke joke =
    case joke of
        Just j ->
            text j.value

        Nothing ->
            text ""


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
