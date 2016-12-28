module Route exposing (..)

import Navigation exposing (Location)
import UrlParser exposing ((</>))

type Route =
  Movies
  | MovieDetail Int
  | InValidRoute