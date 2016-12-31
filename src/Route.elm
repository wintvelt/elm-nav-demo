module Route exposing (..)

import Navigation exposing (Location)
import UrlParser as P exposing ((</>))

{- Route to use in model
This variant stores data too!
-}
type Route =
    Movies
    | MovieDetail Int Movie

{- typesafe variant of valid urls -}
type UrlRoute =
  MoviesUrl
  | MovieDetailUrl Int


-- Helpers to turn Location into a Maybe UrlRoute
routeParser : P.Parser (UrlRoute -> a) a
routeParser =
    P.oneOf
        [ P.map MoviesUrl (P.top)
        , P.map MovieDetailUrl (P.s "movies" </> P.int) 
        ]


parse : Location -> Maybe UrlRoute
parse location =
    P.parseHash routeParser location


-- Helper to turn UrlRoute into a url for the browser
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

-- helper to turn valid route (with Data) into a UrlRoute
toUrlRoute : Route -> UrlRoute
toUrlRoute route =
    case route of
        Movies ->
            MoviesUrl

        MovieDetail id _ ->
            MovieDetailUrl id

-- helper to match UrlRoute to Route
isEqual : UrlRoute -> Route -> Bool
isEqual urlRoute route =
    urlRoute == toUrlRoute route


{- helper to change browser bar to new url without adding to history
for correcting invalid routes
or for changing a url back to url for current page while data loads
-}
modifyRoute : Route -> Cmd msg
modifyRoute =
    Navigation.modifyUrl << toUrl << toUrlRoute

-- helper to change browser bar to new url, adding to browser history
newRoute : Route -> Cmd msg
newRoute =
    Navigation.newUrl << toUrl << toUrlRoute

type alias Movie = { title : String, year : Int }