module Common
    exposing
        ( PlotExample
        , Id
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


type alias Id =
    String


type alias PlotExample msg =
    { title : String
    , id : Id
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


pinkFill : String
pinkFill =
    "#fdb9e7"


pinkStroke : String
pinkStroke =
    "#ff9edf"
