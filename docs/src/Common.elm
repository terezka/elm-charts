module Common
    exposing
        ( PlotExample
        , plotSize
        , axisColor
        , axisColorLight
        , blueFill
        , blueStroke
        , pinkFill
        , pinkStroke
        , skinFill
        , skinStroke
        )

import Svg exposing (Svg)


type alias PlotExample msg =
    { title : String
    , id : String
    , view : Svg msg
    , code : String
    }


plotSize : ( Int, Int )
plotSize =
    ( 600, 300 )


axisColor : String
axisColor =
    "#afafaf"


axisColorLight : String
axisColorLight =
    "#e4e4e4"


pinkFill : String
pinkFill =
    "rgba(253, 185, 231, 0.5)"


pinkStroke : String
pinkStroke =
    "#ff9edf"


blueFill : String
blueFill =
    "#e4eeff"


blueStroke : String
blueStroke =
    "#cfd8ea"


skinFill : String
skinFill =
    "#feefe5"


skinStroke : String
skinStroke =
    "#f7e0d2"
