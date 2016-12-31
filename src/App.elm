module App exposing (..)

import Html exposing (Html, Attribute, text, div, p, input, ul, li, a)
import Html.Attributes exposing (type_, placeholder, class, href)
import Dict exposing (Dict)
import Navigation exposing (Location)
import Route as Route exposing (Route(..), UrlRoute(..))

type alias Model =
    { movies : Dict Int String
    , currentRoute : Route
    , message : String
    }


init : Location -> ( Model, Cmd Msg )
init location =
    { movies = 
        Dict.fromList 
            [ (0, "Abduction")
            , (1, "Blues Brothers")
            , (2, "Cat People")
            , (3, "Da Vinci Code")
            , (4, "Eagle Eye")
            ]
    , currentRoute = Movies
    , message = ""
    }
    |> urlUpdate location


type Msg
    = UrlChanged Location
    | Nav String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged newLocation ->
            urlUpdate newLocation model

        Nav newUrl ->
            ( model 
            , Navigation.newUrl newUrl
            )


urlUpdate : Location -> Model -> ( Model, Cmd Msg )
urlUpdate newLocation model =
    case Route.parse newLocation of
        Nothing ->
            ( { model | message = "invalid URL: " ++ newLocation.hash }
            , Route.modifyRoute Movies 
            )

        Just validRequest ->
            if Route.isEqual validRequest model.currentRoute then
                ( model , Cmd.none )

            else
                case validRequest of
                    UrlMovies ->
                        ( { model | currentRoute = Movies }
                        , Cmd.none
                        )

                    UrlMovieDetail id ->
                        case Dict.get id model.movies of
                            Just movie ->  
                                (   { model
                                    | currentRoute = MovieDetail id movie
                                    }
                                , Cmd.none
                                )
              
                            Nothing ->
                                ( { model | message = "unknown movie: " ++ toString id }
                                , Route.modifyRoute model.currentRoute
                                )


view : Model -> Html Msg
view model =
  case model.currentRoute of
    Movies ->
      moviesView model
  
    MovieDetail movieId movie ->
      moviesDetailView model movieId movie


moviesView model =
  div [ class "page" ]
    [ div [ class "header" ] [ text "Movies page" ]
    , p [] [ text model.message ]
    , ul [ class "movielist" ]
      <| List.map viewMovie <| Dict.toList model.movies  
    ]

viewMovie (id, movie) =
  li [ class "movie-list-item" ]  
    [ text movie
    , a [ href <| Route.toUrl <| UrlMovieDetail id ]
      [ text "show details" ]
    ]


moviesDetailView model movieId movie =
  div [ class "page" ]
    [ div [ class "header" ]
      [ a [ href <| Route.toUrl UrlMovies ] [ text "Back to movies" ]
      , text "Movie details"
      ]
    , p [] [ text model.message ] 
    , div [ class "movie-details" ]
      [ p [] [ text movie ]
      ]
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
