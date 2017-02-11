module PlotBars exposing (plotExample)

import Svg
import Svg.Attributes exposing (..)
import Svg.Plot exposing (..)
import Array
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
    toPlotConfigCustom
        { attributes = []
        , id = id
        , margin =
            { top = 20
            , left = 30
            , right = 30
            , bottom = 90
            }
        , proportions =
            { x = 600, y = 400 }
        , toDomainLowest = identity
        , toDomainHighest = \h -> h + 5
        , toRangeLowest = identity
        , toRangeHighest = identity
        }


xLabelStrings : Array.Array String
xLabelStrings =
    Array.fromList [ "A", "B", "C", "D" ]


xLabelConfig : LabelView Value msg
xLabelConfig =
    labelSimple
        [ fill axisColor
        , style "text-anchor: middle;"
        , displace ( 0, 25 )
        ]
        (\value -> Array.get (round <| value - 1) xLabelStrings |> Maybe.withDefault "")


view : Svg.Svg a
view =
    plot plotConfig
        [ barsSerie
            { stackBy = Y
            , yValues = .values
            , xValue = Nothing
            , styles = [ [ fill pinkFill ], [ fill blueFill ], [ fill skinFill ] ]
            , labelView =
                labelSimple
                    [ stroke "#fff"
                    , fill "#fff"
                    , style "text-anchor: middle; font-size: 10px;"
                    , displace ( 0, 15 )
                    ]
                    (.yValue >> toString)
            , maxWidth = Fixed 30
            }
            [ { values = [ 40, 30, 20 ] }
            , { values = [ 20, 30, 40 ] }
            , { values = [ 40, 20, 10 ] }
            , { values = [ 40, 50, 20 ] }
            ]
        , xAxis
            closestToZero
            [ axisLine [ stroke axisColor ]
            , ticks (tickSimple [ stroke axisColor, length 10 ]) (fromDelta 1)
            , labels xLabelConfig (fromList [ 1, 2, 3, 4 ])
            ]
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
            , left = 30
            , right = 30
            , bottom = 90
            }
        , proportions =
            { x = 600, y = 400 }
        , toDomainLowest = identity
        , toDomainHighest = identity
        , toRangeLowest = \\l -> l - 0.5
        , toRangeHighest = \\h -> h + 0.5
        }


barsConfig : BarsConfig msg
barsConfig =
    toBarsConfig
        { stackBy = X
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


barLabelConfig : LabelConfig BarValueInfo a msg
barLabelConfig =
    toBarLabelConfig
        { attributes =
            [ stroke "#fff"
            , fill "#fff"
            , style "text-anchor: middle; font-size: 10px;"
            , displace ( 0, 15 )
            ]
        , format = \\info -> toString info.yValue
        }


xLabelStrings : Array.Array String
xLabelStrings =
    Array.fromList [ "Autumn", "Winter", "Spring", "Summer" ]


axisLabelConfig : LabelConfig (ValueInfo { index : Int }) AxisMeta msg
axisLabelConfig =
    toAxisLabelConfig
        { attributes =
            [ fill axisColor
            , style "text-anchor: middle;"
            , transform "translate(10, 44) rotate(45) "
            ]
        , format = \\info -> Array.get info.index xLabelStrings |> Maybe.withDefault ""
        }


axisLabelY1Config : LabelConfig (ValueInfo a) AxisMeta msg
axisLabelY1Config =
    toAxisLabelConfig
        { attributes =
            [ fill axisColor
            , style "text-anchor: start;"
            , displace ( 10, 5 )
            ]
        , format = toString << .value
        }


axisLabelY2Config : LabelConfig (ValueInfo a) AxisMeta msg
axisLabelY2Config =
    toAxisLabelConfig
        { attributes =
            [ fill axisColor
            , style "text-anchor: end;"
            , displace ( -10, 5 )
            ]
        , format = toString << (*) 200 << .value
        }


axisLineConfig : AxisLineConfig msg
axisLineConfig =
    toAxisLineConfig
        { attributes =
            [ stroke axisColor
            ]
        }


tickConfig : TickConfig msg
tickConfig =
    toTickConfig
        { attributes =
            [ length 10
            , stroke axisColor
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
            , labels axisLabelConfig (\\_ -> List.indexedMap (\\i v -> { index = i, value = v }) [ 1, 2, 3, 4 ])
            , ticks tickConfig (fromDelta 1)
            ]
        , yAxisAt (\\l h -> l)
            [ axisLine axisLineConfig
            , labels axisLabelY1Config (fromCount 5 >> List.filter (\\v -> v.value /= 0))
            , ticks tickConfig (fromCount 5)
            , positionBy
                (fromAxis (\\p l h -> ( h / 2, p )))
                [ viewLabel
                    [ transform "translate(-10, 0) rotate(-90)"
                    , style "text-anchor: middle"
                    , fill axisColorLight
                    ]
                    "Units sold"
                ]
            ]
        , yAxisAt (\\l h -> h)
            [ axisLine axisLineConfig
            , labels axisLabelY2Config (fromCount 5 >> List.filter (\\v -> v.value /= 0))
            , ticks tickConfig (fromCount 5)
            , positionBy
                (fromAxis (\\p l h -> ( h / 2, p )))
                [ viewLabel
                    [ transform "translate(10, 0) rotate(90)"
                    , style "text-anchor: middle"
                    , fill axisColorLight
                    ]
                    "Ca$h for big big company"
                ]
            ]
        ]
    """
