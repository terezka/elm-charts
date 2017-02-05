module PlotBars exposing (plotExample)

import Svg
import Svg.Attributes exposing (..)
import Array
import Plot exposing (..)
import Common exposing (..)


plotExample : PlotExample msg
plotExample =
    { title = title
    , code = code
    , view = view
    , id = id
    }


title : String
title =
    "Bars"


id : String
id =
    "PlotBars"


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


barsConfig : BarsConfig msg
barsConfig =
    toBarsConfig
        { stackBy = Y
        , maxWidth = Fixed 30
        , barConfigs =
            [ bar1Config
            , bar2Config
            , bar3Config
            ]
        }


bar1Config : BarConfig msg
bar1Config =
    toBarConfig
        { attributes = [ fill pinkStroke ]
        , labelConfig = barLabelConfig
        }


bar2Config : BarConfig msg
bar2Config =
    toBarConfig
        { attributes = [ fill blueFill ]
        , labelConfig = barLabelConfig
        }


bar3Config : BarConfig msg
bar3Config =
    toBarConfig
        { attributes = [ fill skinFill ]
        , labelConfig = barLabelConfig
        }


labelStrings : Array.Array String
labelStrings =
    Array.fromList [ "A", "B", "C" ]


barLabelConfig : LabelConfig BarValueInfo a msg
barLabelConfig =
    toBarLabelConfig
        { attributes =
            [ stroke "#fff"
            , fill "#fff"
            , style "text-anchor: middle; font-size: 10px;"
            , displace ( 0, 15 )
            ]
        , format = \info -> Array.get info.index labelStrings |> Maybe.withDefault ""
        }


axisLabelConfig : LabelConfig (ValueInfo a) AxisMeta msg
axisLabelConfig =
    toAxisLabelConfig
        { attributes =
            [ fill axisColor
            , style "text-anchor: middle;"
            , displace ( 0, 24 )
            ]
        , format = toString << .value
        }


axisLineConfig : AxisLineConfig msg
axisLineConfig =
    toAxisLineConfig
        { attributes = [ stroke axisColor ] }


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
        [ barsSerie
            barsConfig
            (toGroups
                { yValues = .values
                , xValue = Nothing
                }
                [ { values = [ 40, 30, 20 ] }
                , { values = [ 20, 30, 40 ] }
                , { values = [ 40, 20, 10 ] }
                , { values = [ 40, 50, 20 ] }
                ]
            )
        , xAxis
            [ axisLine axisLineConfig
            , labels axisLabelConfig (fromDelta 1)
            , ticks tickConfig (fromDelta 1)
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


barsConfig : BarsConfig msg
barsConfig =
    toBarsConfig
        { stackBy = Y
        , maxWidth = Fixed 30
        , barConfigs =
            [ bar1Config
            , bar2Config
            , bar3Config
            ]
        }


bar1Config : BarConfig msg
bar1Config =
    toBarConfig
        { attributes = [ fill pinkStroke ]
        , labelConfig = barLabelConfig
        }


bar2Config : BarConfig msg
bar2Config =
    toBarConfig
        { attributes = [ fill blueFill ]
        , labelConfig = barLabelConfig
        }


bar3Config : BarConfig msg
bar3Config =
    toBarConfig
        { attributes = [ fill skinFill ]
        , labelConfig = barLabelConfig
        }


labelStrings : Array.Array String
labelStrings =
    Array.fromList [ "A", "B", "C" ]


barLabelConfig : LabelConfig BarValueInfo a msg
barLabelConfig =
    toBarLabelConfig
        { attributes =
            [ stroke "#fff"
            , fill "#fff"
            , style "text-anchor: middle; font-size: 10px;"
            , displace ( 0, 15 )
            ]
        , format = \\info -> Array.get info.index labelStrings |> Maybe.withDefault ""
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
        [ barsSerie
            barsConfig
            (toGroups
                { yValues = .values
                , xValue = Nothing
                }
                [ { values = [ 40, 30, 20 ] }
                , { values = [ 20, 30, 40 ] }
                , { values = [ 40, 20, 10 ] }
                , { values = [ 40, 50, 20 ] }
                ]
            )
        , xAxis
            [ axisLine axisLineConfig
            , labels axisLabelConfig (fromDelta 1)
            , ticks tickConfig (fromDelta 1)
            ]
        ]
    """
