module GridChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ), ( 8, 31 ), ( 9, 37 ), ( 10, 42 ) ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 250 ), padding ( 0, 40 ) ]
        [ verticalGrid
            [ gridMirrorTicks
            , gridStyle [ ( "stroke", Colors.axisColorLight ) ]
            ]
        , horizontalGrid
            [ gridValues [ 10, 20, 30, 40 ]
            , gridStyle [ ( "stroke", Colors.axisColorLight ) ]
            ]
        , xAxis
            [ axisStyle [ ( "stroke", Colors.axisColor ) ] ]
        , line [ lineStyle [ ( "stroke", Colors.blueStroke ), ( "stroke-width", "2px" ) ] ] data
        ]


code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 250 ), padding ( 0, 40 ) ]
            [ verticalGrid
                [ gridMirrorTicks
                , gridStyle [ ( "stroke", Colors.axisColorLight ) ]
                ]
            , horizontalGrid
                [ gridValues [ 10, 20, 30, 40 ]
                , gridStyle [ ( "stroke", Colors.axisColorLight ) ]
                ]
            , xAxis
                [ axisStyle [ ( "stroke", Colors.axisColor ) ] ]
            , line
                [ lineStyle
                    [ ( "stroke", Colors.blueStroke )
                    , ( "stroke-width", "2px" )
                    ]
                ]
                data
            ]
    """
