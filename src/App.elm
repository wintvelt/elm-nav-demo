module App exposing (..)

import Html exposing (Html, text, div, p, img)
import Html.Attributes exposing (src)
import Navigation exposing (Location)


type alias Model =
    { path : String
    , hash : String
    , search : String
    , logo : String
    }


init : String -> Location -> ( Model, Cmd Msg )
init path location =
    (   { path = location.pathname
        , hash = location.hash
        , search = location.search
        , logo = path 
        }
    , Cmd.none 
    )


type Msg
    = NewUrl Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewUrl newLocation ->
            (   { model 
                | path = newLocation.pathname 
                , hash = newLocation.hash
                , search = newLocation.search
                }
            , Cmd.none 
            )


view : Model -> Html Msg
view model =
    div []
        [ img [ src model.logo ] []
        , p [] [ text <| "path = " ++ model.path ]
        , p [] [ text <| "hash = " ++ model.hash ]
        , p [] [ text <| "search = " ++ model.search ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
