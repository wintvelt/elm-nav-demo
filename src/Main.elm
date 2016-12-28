module Main exposing (..)

import App exposing (..)
import Navigation exposing (programWithFlags)


main : Program String Model Msg
main =
    programWithFlags 
    NewUrl
    { view = view, init = init, update = update, subscriptions = subscriptions }
