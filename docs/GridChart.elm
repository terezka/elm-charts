module GridChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Grid as Grid
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ), ( 8, 31 ), ( 9, 37 ), ( 10, 42 ) ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 300 )
        , padding ( 0, 40 )
        , margin ( 10, 20, 40, 20 )
        ]
        [ verticalGrid
            [ Grid.stroke Colors.axisColorLight ]
        , horizontalGrid
            [ Grid.values [ 10, 20, 30, 40 ]
            , Grid.stroke Colors.axisColorLight
            ]
        , xAxis
            [ Axis.view
                [ Axis.style [ ( "stroke", Colors.axisColor ) ] ]
            ]
        , line
            [ Line.stroke Colors.blueStroke
            , Line.strokeWidth 2
            ]
            data
        ]


code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 300 ), padding ( 0, 40 ) ]
            [ verticalGrid
                [ Grid.style [ ( "stroke", Colors.axisColorLight ) ] ]
            , horizontalGrid
                [ Grid.values [ 10, 20, 30, 40 ]
                , Grid.style [ ( "stroke", Colors.axisColorLight ) ]
                ]
            , xAxis
                [ Axis.view
                    [ Axis.style [ ( "stroke", Colors.axisColor ) ] ]
                ]
            , line
                [ Lne.style
                    [ ( "stroke", Colors.blueStroke )
                    , ( "stroke-width", "2px" )
                    ]
                ]
                data
            ]
    """
