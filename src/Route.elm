module Route exposing (..)

import Navigation exposing (Location)
import UrlParser as P exposing ((</>))

{- Page to use in model
This variant stores data too!
-}
type Page =
    MoviesPage
    | MovieDetailPage Int Movie

{- typesafe variant of valid urls -}
type Route =
  Movies
  | MovieDetail Int


-- Helpers to turn Location into a Maybe Route
routeParser : P.Parser (Route -> a) a
routeParser =
    P.oneOf
        [ P.map Movies (P.top)
        , P.map MovieDetail (P.s "movies" </> P.int) 
        ]


parse : Location -> Maybe Route
parse location =
    P.parseHash routeParser location


-- Helper to turn Route into a url for the browser
toUrl : Route -> String
toUrl route =
    let
        hashPage =
            case route of
                Movies ->
                    "/"

                MovieDetail id ->
                    "/movies/" ++ toString id

    in
        "#" ++ hashPage

-- helper to turn valid Page (with Data) into a Route
toRoute : Page -> Route
toRoute page =
    case page of
        MoviesPage ->
            Movies

        MovieDetailPage id _ ->
            MovieDetail id

-- helper to match Route to Page
isEqual : Route -> Page -> Bool
isEqual urlPage page =
    urlPage == toRoute page


{- helper to change browser bar to new url without adding to history
for correcting invalid routes
or for changing a url back to url for current page while data loads
-}
modifyUrl : Page -> Cmd msg
modifyUrl =
    Navigation.modifyUrl << toUrl << toRoute

-- helper to change browser bar to new url, adding to browser history
newUrl : Page -> Cmd msg
newUrl =
    Navigation.newUrl << toUrl << toRoute

type alias Movie = { title : String, year : Int }