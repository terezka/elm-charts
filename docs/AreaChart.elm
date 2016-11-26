module AreaChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot as Plot
import Plot.Area as Area
import Plot.Grid as Grid
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Base as Base
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 5 ), ( 1, 20 ), ( 2, 10 ), ( 3, 12 ), ( 4, 20 ), ( 5, 25 ), ( 6, 3 ) ]


chart : Plot.State -> Svg.Svg Plot.Msg
chart { position } =
    Plot.base
        [ Base.size ( 600, 250 )
        , Base.margin ( 0, 40, 40, 40 )
        , Base.padding ( 0, 20 )
        , Base.id "elm-plot-area-chart"
        ]
        [ Plot.verticalGrid [ Grid.classes [ "dsfdjksh" ] ]
        , Plot.line [] data
        , Plot.line [] data2
        , Plot.xAxis
            [ Axis.tick [ Tick.delta 0.5 ]
            , Axis.view
                [ Axis.style [ ( "stroke", Colors.axisColor ) ] ]
            ]
        , Plot.tooltip [] position
        ]


code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 300, 300 ) ]
            [ area
                [ areaStyle
                    [ ( "stroke", Colors.blueStroke )
                    , ( "fill", Colors.blueFill )
                    ]
                ]
                data
            , xAxis [ axisStyle [ ( "stroke", Colors.axisColor ) ] ]
            ]
    """
