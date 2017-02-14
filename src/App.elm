module App exposing (..)

import Html exposing (Html, Attribute, text, div, p, span, ul, li, a, i, h3, h4, button)
import Html.Attributes exposing (type_, placeholder, class, href, attribute)
import Html.Events exposing (onClick, onWithOptions)
import Json.Decode exposing (succeed)
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
    , currentPage = HomePage
    , message = ""
    , serverRequest = Nothing
    }
    |> urlUpdate location


type Msg
    = UrlChanged Location
    | LoadError String
    | GotMovieDetail Movie
    | TryUrl String


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

        TryUrl hashLess ->
            model ! [ Navigation.newUrl hashLess ]


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
                    Home ->
                        ( { model | currentPage = HomePage}
                        , Cmd.none
                        )


                    Movies ->
                        ( { model | currentPage = MoviesPage (Dict.toList model.movies)}
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
    HomePage ->
        homeView model

    MoviesPage movies ->
        moviesView model movies
  
    MovieDetailPage movieId movie ->
        moviesDetailView model movieId movie

homeView : Model -> Html Msg
homeView model =
  div [ class "mdl-layout mdl-layout--fixed-header" ]
    [ div 
        [ class "mdl-layout__header mdl-layout__header-row" ]
        [ span [ class "mdl-layout__title" ] [ text "Homepage" ] 
        ]
    , p [ class "message" ] [ text model.message ]
    , a 
        [ href <| Route.toUrl Movies 
        , class "mdl-button"
        ] 
        [ text "Show movielist"
        , i [ class "material-icons" ] [ text "chevron_right" ]
        ]
    , button [ onClick <| TryUrl "/users" ] [ text "Try hashLess" ]
    , a [ href "/users" ] [ text "Try hashLess link" ]
    , div [ attribute "onclick" "history.pushState({},'check','/users');"] [ text "try hashless hack"]
    , a [ href "/users", onClickPrevent <| TryUrl "/users/whatever" ] [ text "Try hashLess link with different msg" ]
    ]

onClickPrevent : msg -> Attribute msg
onClickPrevent msg =
    onWithOptions "click" { preventDefault = True, stopPropagation = False} (succeed msg)


moviesView model movies =
  div [ class "mdl-layout mdl-layout--fixed-header" ]
    [ div [ class "mdl-layout__header mdl-layout__header-row" ]
      [ a 
        [ href <| Route.toUrl Home 
        , class "mdl-navigation__link"
        ] 
        [ i [ class "material-icons" ] [ text "chevron_left" ]
        , text "HomePage" 
        ]
      , span [ class "mdl-layout__title" ] [ text "Movie List" ]
      ]
    , p [ class "message" ] [ text model.message ]
    , ul [ class "mdl-list" ]
      <| List.map viewMovie movies
    ]

viewMovie (id, movie) =
  li [ class "mdl-list__item" ]  
    [ span [ class "mdl-list__item-primary-content" ] [ text movie ]
    , a 
        [ href <| Route.toUrl <| MovieDetail id 
        , class "mdl-list__item-secondary-action mdl-button mdl-button--accent"
        ]
        [ text "details" 
        , i [ class "material-icons"] [ text "chevron_right" ]
        ]
    ]

moviesDetailView : Model -> Int -> Movie -> Html msg
moviesDetailView model movieId movie =
  div [ class "mdl-layout mdl-layout--fixed-header" ]
    [ div [ class "mdl-layout__header mdl-layout__header-row" ]
      [ a 
        [ href <| Route.toUrl Movies
        , class "mdl-navigation__link"
        ]
        [ i [ class "material-icons" ] [ text "chevron_left" ]
        , text "Movies" 
        ]
      , span [ class "mdl-layout__title" ] [ text "Movie details" ]
      ]
    , p [ class "message" ] [ text model.message ] 
    , div [ class "movie-details" ]
      [ h3 [] [ text movie.title ]
      , h4 [] [ text <| "year : " ++ toString movie.year ]
      ]
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
