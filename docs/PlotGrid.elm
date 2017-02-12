module PlotGrid exposing (plotExample)

import Svg
import Svg.Attributes exposing (..)
import Svg.Plot exposing (..)
import Common exposing (..)


plotExample : PlotExample msg
plotExample =
    { title = title
    , code = code
    , view = view
    , id = title
    }


title : String
title =
    "Grid"


id : String
id =
    "Grid"


plotConfig : PlotConfig msg
plotConfig =
    toPlotConfigFancy
        { attributes = []
        , id = id
        , margin =
            { top = 20
            , left = 40
            , right = 20
            , bottom = 20
            }
        , proportions =
            { x = 600, y = 400 }
        , toDomainLowest = \l -> l - 0.25
        , toDomainHighest = \h -> h + 0.25
        , toRangeLowest = identity
        , toRangeHighest = identity
        }


lineConfig : LineConfig msg
lineConfig =
    toLineConfig
        { attributes = [ stroke pinkStroke, fill pinkFill, strokeWidth "3px" ]
        , interpolation = Bezier
        }


data : List ( Float, Float )
data =
    List.map (\v -> ( toFloat v, sin (toFloat v * pi / 20) )) (List.range 0 100)


view : Svg.Svg a
view =
    plot plotConfig
        [ axis
            (toAxisConfig Y atLowest)
            [ axisLine [ fill axisColor ]
            , ticks (tick [ stroke axisColor, length 5 ]) (fromDelta 1)
            , labels (label [ fill axisColor, displace ( -10, 5 ), style "text-anchor: end;" ] toString) (fromDelta 1)
            ]
        , verticalGrid [ stroke axisColorLight ] (fromDelta 10)
        , horizontalGrid [ stroke axisColorLight ] (fromDelta 1)
        , axis (toAxisConfig X atZero)
            [ axisLine [ stroke axisColor ] ]
        , positionBy
            (fromRangeAndDomain (\xl xh yl yh -> ( xh, yh )))
            [ viewLabel
                [ style "text-anchor: end; font-family: monospace;"
                , displace ( -10, 15 )
                , fill axisColor
                ]
                "f(x) = sin x"
            ]
        , lineSerie lineConfig data
        ]


code : String
code =
    """
plotConfig : PlotConfig msg
plotConfig =
    toPlotConfigCustom
        { attributes = []
        , id = id
        , margin =
            { top = 20
            , left = 40
            , right = 20
            , bottom = 20
            }
        , proportions =
            { x = 600, y = 400 }
        , toDomainLowest = \\l -> l - 0.25
        , toDomainHighest = \\h -> h + 0.25
        , toRangeLowest = identity
        , toRangeHighest = identity
        }


lineConfig : LineConfig msg
lineConfig =
    toLineConfig
        { attributes = [ stroke pinkStroke, fill pinkFill, strokeWidth "3px" ]
        , interpolation = Bezier
        }


axisLabelConfig : LabelConfig (ValueInfo a) AxisMeta msg
axisLabelConfig =
    toAxisLabelConfig
        { attributes =
            [ stroke axisColor
            , fill axisColor
            , style "text-anchor: end;"
            , displace ( -10, 5 )
            ]
        , format = toString << .value
        }


axisLineConfig : AxisLineConfig msg
axisLineConfig =
    toAxisLineConfig
        { attributes =
            [ stroke axisColor
            , fill axisColor
            ]
        }


gridConfig : GridConfig msg
gridConfig =
    toGridConfig
        { attributes =
            [ stroke axisColorLight
            , fill axisColorLight
            ]
        }


tickConfig : TickConfig msg
tickConfig =
    toTickConfig
        { attributes =
            [ stroke axisColorLight
            , length 10
            ]
        }


data : List ( Float, Float )
data =
    List.map (\\v -> ( toFloat v, sin (toFloat v * pi / 10) )) (List.range 0 100)


view : Svg.Svg a
view =
    plot plotConfig
        [ yAxis
            [ labels axisLabelConfig (fromDelta 0.5)
            , grid gridConfig (fromDelta 0.5)
            ]
        , xAxis
            [ ticks tickConfig (fromDelta 10)
            , grid gridConfig (fromDelta 10)
            , axisLine axisLineConfig
            ]
        , lineSerie lineConfig data
        ]
    """
