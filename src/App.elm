module App exposing (..)

import Html exposing (Html, Attribute, text, div, p, input, ul, li, a)
import Html.Attributes exposing (type_, placeholder, class, href)
import Dict exposing (Dict)
import Navigation exposing (Location)
import Route as Route exposing (Route(..), UrlRoute(..))
import Task

type alias Model =
    { movies : Dict Int String
    , currentRoute : Route
    , message : String
    , serverRequest : Maybe Int
    }

type alias Movie = { title : String, year : Int }

mockServerMovies = 
    Dict.fromList 
    [ (0, { title = "Abduction", year = 2011})
    , (1, { title = "Blues Brothers", year = 1980})
    , (2, { title = "Cat People", year = 1982 })
    , (4, { title = "Eagle Eye", year = 2008 })
    ]


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
    , serverRequest = Nothing
    }
    |> urlUpdate location


type Msg
    = UrlChanged Location
    | LoadError String
    | GotMovieDetail Movie


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged newLocation ->
            urlUpdate newLocation model

        LoadError message ->
            (   { model 
                | serverRequest = Nothing
                , message = message 
                }
            , Cmd.none
            )

        GotMovieDetail movie ->
            case model.serverRequest of
                Just id ->
                    (   { model 
                        | currentRoute = MovieDetail id movie
                        , serverRequest = Nothing
                        , message = "" 
                        }
                    ,   Route.newRoute <| MovieDetail id movie
                    )

                Nothing ->
                    (   { model 
                        | message = "got strange stuff" 
                        , serverRequest = Nothing
                        }
                    ,   Cmd.none
                    )


urlUpdate : Location -> Model -> ( Model, Cmd Msg )
urlUpdate newLocation model =
    case Route.parse newLocation of
        Nothing ->
            ( { model | message = "invalid URL: " ++ newLocation.hash }
            , Route.modifyRoute model.currentRoute 
            )

        Just validRequest ->
            if Route.isEqual validRequest model.currentRoute then
                ( model , Cmd.none )

            else
                case validRequest of
                    MoviesUrl ->
                        ( { model | currentRoute = Movies }
                        , Cmd.none
                        )

                    MovieDetailUrl id ->
                        (   { model 
                            | serverRequest = Just id 
                            , message = "Loading data for movie : " ++ toString id
                            } 
                        , Cmd.batch [ fetchMovieDetail id, Route.modifyRoute model.currentRoute ]
                        )

fetchMovieDetail : Int -> Cmd Msg
fetchMovieDetail id =
    let
        fetchTask =
            case Dict.get id mockServerMovies of
                Nothing ->
                    Task.fail <| "No details for movie : " ++ toString id

                Just movie ->
                    Task.succeed movie
    in
        Task.attempt processFetch fetchTask

processFetch : Result String Movie -> Msg
processFetch result =
    case result of
        Err error ->
            LoadError error

        Ok movie ->
            GotMovieDetail movie

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
    , a [ href <| Route.toUrl <| MovieDetailUrl id ]
      [ text "show details" ]
    ]

moviesDetailView : Model -> Int -> Movie -> Html msg
moviesDetailView model movieId movie =
  div [ class "page" ]
    [ div [ class "header" ]
      [ a [ href <| Route.toUrl MoviesUrl ] [ text "Back to movies" ]
      , text "Movie details"
      ]
    , p [] [ text model.message ] 
    , div [ class "movie-details" ]
      [ p [] [ text movie.title ]
      , p [] [ text <| "year : " ++ toString movie.year ]
      ]
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
