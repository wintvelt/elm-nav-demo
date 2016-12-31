module Route exposing (..)

import Navigation exposing (Location)
import UrlParser as P exposing ((</>))

type UrlRoute =
  MoviesUrl
  | MovieDetailUrl Int

type Route =
    Movies
    | MovieDetail Int String


routeParser : P.Parser (UrlRoute -> a) a
routeParser =
    P.oneOf
        [ P.map MoviesUrl (P.top)
        , P.map MovieDetailUrl (P.s "movies" </> P.int) 
        ]


parse : Location -> Maybe UrlRoute
parse location =
    P.parseHash routeParser location


toUrl : UrlRoute -> String
toUrl urlRoute =
    let
        hashRoute =
            case urlRoute of
                MoviesUrl ->
                    "/"

                MovieDetailUrl id ->
                    "/movies/" ++ toString id

    in
        "#" ++ hashRoute

toUrlRoute : Route -> UrlRoute
toUrlRoute route =
    case route of
        Movies ->
            MoviesUrl

        MovieDetail id _ ->
            MovieDetailUrl id


isEqual : UrlRoute -> Route -> Bool
isEqual urlRoute route =
    urlRoute == toUrlRoute route


modifyRoute : Route -> Cmd msg
modifyRoute =
    Navigation.modifyUrl << toUrl << toUrlRoute