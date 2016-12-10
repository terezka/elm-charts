module Common
    exposing
        ( PlotExample
        , ViewPlot(..)
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

import Svg
import Plot


type alias Id =
    String


type alias PlotExample msg =
    { title : String
    , id : Id
    , view : ViewPlot msg
    , code : String
    }


type ViewPlot msg
    = ViewStatic (Svg.Svg msg)
    | ViewInteractive Id (Plot.State -> Svg.Svg (Plot.Interaction msg))


plotSize : ( Int, Int )
plotSize =
    ( 600, 300 )


axisColor : String
axisColor =
    "#949494"


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
