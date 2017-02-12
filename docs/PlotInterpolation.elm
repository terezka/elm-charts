module PlotInterpolation exposing (plotExample)

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
    "Interpolation"


id : String
id =
    "Interpolation"


plotConfig : PlotConfig msg
plotConfig =
    toPlotConfig
        { attributes = []
        , id = id
        , margin =
            { top = 20
            , left = 20
            , right = 20
            , bottom = 40
            }
        , proportions =
            { x = 600, y = 400 }
        }


areaConfig : AreaConfig msg
areaConfig =
    toAreaConfig
        { attributes = [ stroke pinkStroke, fill pinkFill ]
        , interpolation = Bezier
        }


data1 : List ( Float, Float )
data1 =
    [ ( 0, 10 ), ( 0.5, 20 ), ( 1, -5 ), ( 1.5, 4 ), ( 2, -7 ), ( 2.5, 5 ), ( 3, 20 ), ( 3.5, 7 ), ( 4, 28 ) ]


view : Svg.Svg a
view =
    plot plotConfig
        [ areaSerie areaConfig data1
        , xAxis
            closestToZero
            [ axisLine
                [ stroke axisColor
                , fill axisColor
                , fill pinkFill
                ]
            , labels
                (label
                    [ fill axisColor
                    , style "text-anchor: middle;"
                    , displace ( 0, 24 )
                    ]
                    toString
                )
                (fromDelta 1)
            , ticks
                (tick
                    [ stroke axisColor
                    , length 10
                    ]
                )
                (fromDelta 1)
            ]
        ]


code : String
code =
    """

plotConfig : PlotConfig msg
plotConfig =
    toPlotConfig
        { attributes = []
        , id = id
        , margin =
            { top = 20
            , left = 20
            , right = 20
            , bottom = 40
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


axisLabelConfig : LabelConfig (ValueInfo a) AxisMeta msg
axisLabelConfig =
    toAxisLabelConfig
        { attributes =
            [ stroke axisColor
            , fill axisColor
            , style "text-anchor: middle;"
            , displace ( 0, 24 )
            ]
        , format = toString << .value
        }


axisLineConfig : AxisLineConfig msg
axisLineConfig =
    toAxisLineConfig
        { attributes =
            [ stroke axisColor
            , fill axisColor
            , fill pinkFill
            ]
        }


tickConfig : TickConfig msg
tickConfig =
    toTickConfig
        { attributes =
            [ stroke axisColor
            , fill pinkFill
            , length 10
            ]
        }


view : Svg.Svg a
view =
    plot plotConfig
        [ areaSerie areaConfig data
        , xAxis
            [ axisLine axisLineConfig
            , labels axisLabelConfig (fromDelta 1)
            , ticks tickConfig (fromDelta 1)
            ]
        ]
    """
