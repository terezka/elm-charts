module Plot.Grid.Config exposing (Config, Values(..), defaultConfigX, defaultConfigY)

import Plot.Types exposing (Point, Style, Orientation(..))


type Values
    = MirrorTicks
    | CustomValues (List Float)


type alias Config =
    { values : Values
    , style : Style
    , classes : List String
    , orientation : Orientation
    }


defaultConfigX : Config
defaultConfigX =
    { values = MirrorTicks
    , style = []
    , classes = []
    , orientation = X
    }


defaultConfigY : Config
defaultConfigY =
    { defaultConfigX | orientation = Y }
