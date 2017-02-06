module TestApi exposing (..)

import Html exposing (Html, div)
import Html.Attributes
import Svg.Attributes exposing (fill, stroke, style, class, transform, strokeWidth)
import Svg.Plot exposing (..)


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


plotConfig : PlotConfig msg
plotConfig =
    toPlotConfig
        { attributes = []
        , id = "my-plot"
        , margin =
            { top = 120
            , left = 120
            , right = 120
            , bottom = 120
            }
        , proportions =
            { x = 600, y = 400 }
        }


areaConfig : AreaConfig msg
areaConfig =
    toAreaConfig
        { attributes = [ stroke "#ccc", fill pinkFill ]
        , interpolation = Bezier
        }


lineConfig : LineConfig msg
lineConfig =
    toLineConfig
        { attributes = [ stroke "red" ]
        , interpolation = NoInterpolation
        }


main : Html msg
main =
    div
        [ Html.Attributes.style [ ( "width", "800px" ) ] ]
        [ plot plotConfig
            [ areaSerie areaConfig [ ( -1, 3 ), ( 0, 2 ), ( 1, 2 ), ( 2, 4 ), ( 3, -3 ), ( 4, 5 ) ]
            , lineSerie lineConfig [ ( -1, 3 ), ( 0, 2 ), ( 1, 2 ), ( 2, 4 ), ( 3, -3 ), ( 4, 5 ) ]
            , xAxis
                closestToZero
                [ axisLine [ stroke "red" ]
                , ticks
                    (tickSimple [ stroke skinStroke, length 15 ])
                    (fromDelta 0.5)
                , ticks
                    (tickSimple [ stroke blueStroke, fill blueStroke, length 10, strokeWidth "2px" ])
                    (fromDelta 1)
                , labels
                    (labelSimple [ fill pinkStroke ] toString)
                    (fromDelta 1 >> remove 0)
                ]
            , yAxis
                lowest
                [ axisLine [ fill blueStroke, stroke skinStroke ]
                , ticks
                    (tickSimple [ stroke blueStroke, length 4, strokeWidth "2px" ])
                    (fromDelta 1)
                , labels
                    (labelSimple [ fill pinkStroke ] toString)
                    (fromDelta 1 >> remove 0)
                ]
            , yAxis
                closestToZero
                [ axisLine [ fill blueStroke, stroke skinStroke ]
                , ticks
                    (tickSimple [ stroke blueStroke, length 4, strokeWidth "2px" ])
                    (fromDelta 1)
                , labels
                    (labelSimple [ fill pinkStroke ] toString)
                    (fromDelta 1 >> remove 0)
                ]
            , verticalGrid [ stroke skinStroke ] (fromDelta 1)
            ]
        ]
