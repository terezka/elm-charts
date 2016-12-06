module BarChart exposing (chart, code)

import Svg
import Plot exposing (..)
import Plot.Bars as Bars
import Plot.Pile as Pile
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Line as Line
import Colors


data1 : List ( Float, Float )
data1 =
    [ ( -0.4, -8 ), ( -0.3, -1 ), ( -0.2, 6 ), ( -0.1, 10 ), ( 0.0, 14 ), ( 0.1, 16 ), ( 0.2, 26 ), ( 0.3, 32 ), ( 0.4, 28 ), ( 0.5, 32 ), ( 0.6, 29 ), ( 0.7, 46 ), ( 0.8, 52 ), ( 0.9, 53 ), ( 1, 59 ) ]


data : List ( Float, Float )
data =
    [ ( 0.0, 20 ), ( 0.5, -20 ),( 1, 40 ) ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 300 )
        , margin ( 10, 20, 40, 40 )
        ]
        [ pile
            [ Pile.maxBarWidthPer 85 ]
            [ Pile.bars
                [ Bars.fill Colors.blueFill ]
                (List.map (\(x, y) -> (x, y*2)) data)
            
            , Pile.bars
                [ Bars.fill Colors.skinFill ]
                (List.map (\(x, y) -> (x, y*3)) data)
            , Pile.bars
                [ Bars.fill Colors.pinkFill ]
                data
            ]
        , yAxis []
        , xAxis
            [ Axis.line [ Line.stroke Colors.axisColor ]
            , Axis.tick [ Tick.delta 0.5 ]
            ]
        ]

code : String
code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 250 ) ]
            [ scatter
                [ scatterStyle
                    [ ( "stroke", Colors.pinkStroke )
                    , ( "fill", Colors.pinkFill )
                    ]
                , scatterRadius 8
                ]
                data
            , xAxis [ axisStyle [ ( "stroke", Colors.axisColor ) ] ]
            ]
    """