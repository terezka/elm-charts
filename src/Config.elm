module Config exposing (..)

import Types exposing (DataSet)

type alias Model =
    { color : String
    , height : Int
    , width : Int
    }


init : Model 
init =
    { color = "red"
    , height = 300
    , width = 450
    }
