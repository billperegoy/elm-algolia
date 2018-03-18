module Main exposing (..)

import Html exposing (..)
import Model exposing (..)
import View
import Subscriptions
import Update


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = Model.init
        , view = View.view
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        }
