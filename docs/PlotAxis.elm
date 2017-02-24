module PlotAxis exposing (plotExample)

import Svg
import Svg.Attributes exposing (..)
import Svg.Plot exposing (..)
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
    "Multiple axis'"


id : String
id =
    "PlotAxis"


plotConfig : PlotConfig msg
plotConfig =
    toPlotConfigFancy
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
        , toRangeLowest = \l -> l - 0.5
        , toRangeHighest = \h -> h + 0.5
        }


xLabelStrings : List String
xLabelStrings =
    [ "Autumn", "Winter", "Spring", "Summer" ]


xLabel : String -> Svg.Svg msg
xLabel =
    label
        [ fill axisColor
        , style "text-anchor: middle;"
        , transform "translate(10, 44) rotate(45) "
        ]


y1Label : Value -> Svg.Svg msg
y1Label =
    toString >> label
      [ fill axisColor
      , style "text-anchor: start;"
      , displace ( 10, 5 )
      ]


y2Label : Value -> Svg.Svg msg
y2Label =
    (*) 100 >> toString >> label
      [ fill axisColor
      , style "text-anchor: end;"
      , displace ( -10, 5 )
      ]


y1Tick : Svg.Svg  msg
y1Tick =
  tick [ stroke axisColor, length 5, style "transform: rotate(-90deg)" ]


y1TickLight : Svg.Svg  msg
y1TickLight =
  tick [ stroke axisColorLight, length 10, style "transform: rotate(-90deg)" ]


y2Tick : Svg.Svg  msg
y2Tick =
  tick [ stroke axisColor, length 5 ]


y2TickLight : Svg.Svg  msg
y2TickLight =
  tick [ stroke axisColorLight, length 10 ]


barsConfig : BarsConfig msg
barsConfig =
    toBarsConfig
        { stackBy = X
        , styles = [ [ fill pinkFill ], [ fill blueFill ] ]
        , labelView =
            .yValue
                >> toString
                >> label
                    [ stroke "#fff"
                    , fill "#fff"
                    , style "text-anchor: middle; font-size: 10px;"
                    , displace ( 0, 15 )
                    ]
        , maxWidth = Fixed 30
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
                [ { values = [ 40, 30 ] }
                , { values = [ 20, 30 ] }
                , { values = [ 40, 20 ] }
                , { values = [ 60, 50 ] }
                ]
            )
        , xAxis atZero
            [ line [ stroke axisColor ]
            , ticks (tick [ stroke axisColor, length 10 ]) (fromDelta 1 1)
            , labelsFromStrings xLabel (fromDelta 1 1) xLabelStrings
            ]
        , yAxis atLowest
            [ line [ stroke axisColor ]
            , ticks y1Tick (fromDelta 0 10)
            , ticks y1TickLight (fromDelta 5 10)
            , labels y1Label (fromDelta 0 10 >> remove 0)
            ]
        , yAxis atHighest
            [ line [ stroke axisColor ]
            , ticks y2Tick (fromDelta 0 10)
            , ticks y2TickLight (fromDelta 5 10)
            , labels y2Label (fromDelta 0 10 >> remove 0)
            ]
        , placeAt
            (fromRangeAndDomain (\xl xh yl yh -> ( xl, yh / 2 )))
            [ label
                [ transform "translate(-10, 0) rotate(-90)"
                , style "text-anchor: middle"
                , fill axisColorLight
                ]
                "Units sold"
            ]
        , placeAt
            (fromRangeAndDomain (\xl xh yl yh -> ( xh, yh / 2 )))
            [ label
                [ transform "translate(10, 0) rotate(90)"
                , style "text-anchor: middle"
                , fill axisColorLight
                ]
                "Ca$h for big big company"
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


lineConfig : AxisLineConfig msg
lineConfig =
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
            [ line lineConfig
            , labels axisLabelConfig (\\_ -> List.indexedMap (\\i v -> { index = i, value = v }) [ 1, 2, 3, 4 ])
            , ticks tickConfig (fromDelta 0 1)
            ]
        , yAxisAt (\\l h -> l)
            [ line lineConfig
            , labels axisLabelY1Config (fromCount 5 >> List.filter (\\v -> v.value /= 0))
            , ticks tickConfig (fromCount 5)
            , positionBy
                (fromAxis (\\p l h -> ( h / 2, p )))
                [ label
                    [ transform "translate(-10, 0) rotate(-90)"
                    , style "text-anchor: middle"
                    , fill axisColorLight
                    ]
                    "Units sold"
                ]
            ]
        , yAxisAt (\\l h -> h)
            [ line lineConfig
            , labels axisLabelY2Config (fromCount 5 >> List.filter (\\v -> v.value /= 0))
            , ticks tickConfig (fromCount 5)
            , positionBy
                (fromAxis (\\p l h -> ( h / 2, p )))
                [ label
                    [ transform "translate(10, 0) rotate(90)"
                    , style "text-anchor: middle"
                    , fill axisColorLight
                    ]
                    "Ca$h for big big company"
                ]
            ]
        ]
    """
