module App exposing (..)

import Html exposing (Html, Attribute, text, div, p, input, ul, li, a)
import Html.Attributes exposing (type_, placeholder, class, href)
import Dict exposing (Dict)
import Navigation exposing (Location)
import Route as Route exposing (Route(..), Page(..))
import Task
import Process

type alias Model =
    { movies : Dict Int String
    , currentPage : Page
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
    , currentPage = MoviesPage
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
                        | currentPage = MovieDetailPage id movie
                        , serverRequest = Nothing
                        , message = "" 
                        }
                    ,   Route.newUrl <| MovieDetailPage id movie
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
            , Route.modifyUrl model.currentPage 
            )

        Just validRoute ->
            if Route.isEqual validRoute model.currentPage then
                ( model , Cmd.none )

            else
                case validRoute of
                    Movies ->
                        ( { model | currentPage = MoviesPage }
                        , Cmd.none
                        )

                    MovieDetail id ->
                        (   { model 
                            | serverRequest = Just id 
                            , message = "Loading data for movie : " ++ toString id
                            } 
                        , Cmd.batch [ fetchMovieDetail id, Route.modifyUrl model.currentPage ]
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
        delayedFetchTask =
            Process.sleep 1000
            |> Task.andThen (\_ -> fetchTask)
    in
      Task.attempt processFetch delayedFetchTask
        

processFetch : Result String Movie -> Msg
processFetch result =
    case result of
        Err error ->
            LoadError error

        Ok movie ->
            GotMovieDetail movie

view : Model -> Html Msg
view model =
  case model.currentPage of
    MoviesPage ->
      moviesView model
  
    MovieDetailPage movieId movie ->
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
    , a [ href <| Route.toUrl <| MovieDetail id ]
      [ text "show details" ]
    ]

moviesDetailView : Model -> Int -> Movie -> Html msg
moviesDetailView model movieId movie =
  div [ class "page" ]
    [ div [ class "header" ]
      [ a [ href <| Route.toUrl Movies ] [ text "Back to movies" ]
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
