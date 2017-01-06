module Route exposing (..)

import Navigation exposing (Location)
import UrlParser as P exposing ((</>))

{- Page to use in model
This variant stores data too!
-}
type Page =
    HomePage
    | MoviesPage (List MovieSummary)
    | MovieDetailPage Int Movie

type alias Movie = { title : String, year : Int }
type alias MovieSummary = (Int, String)

{- typesafe variant of valid urls -}
type Route =
    Home
    | Movies
    | MovieDetail Int


-- Helpers to turn Location into a Maybe Route
routeParser : P.Parser (Route -> a) a
routeParser =
    P.oneOf
        [ P.map Home (P.top)
        , P.map Movies (P.s "movies")
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
                Home ->
                    "/"

                Movies ->
                    "/movies"

                MovieDetail id ->
                    "/movies/" ++ toString id

    in
        "#" ++ hashPage

-- helper to turn valid Page (with Data) into a Route
toRoute : Page -> Route
toRoute page =
    case page of
        HomePage ->
            Home

        MoviesPage _ ->
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