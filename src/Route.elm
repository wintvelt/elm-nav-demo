module Route exposing (..)

import Navigation exposing (Location)
import UrlParser as P exposing ((</>))

type Route =
  Movies
  | MovieDetail Int
  | InValidRoute


route : P.Parser (Route -> a) a
route =
    P.oneOf
        [ P.map Movies (P.top)
        , P.map Movies (P.s "movies")
        , P.map MovieDetail (P.s "movies" </> P.int) 
        ]

parse : Location -> Route
parse location =
    P.parseHash route location
    |> Maybe.withDefault InValidRoute