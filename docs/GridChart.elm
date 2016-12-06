module GridChart exposing (plotExample)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Grid as Grid
import Plot.Line as Line
import Colors


plotExample =
    { title = title
    , code = code
    , view = view
    , fileName = fileName
    }


title : String
title = "Grids"


fileName : String
fileName = "GridChart"


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 0 ), ( 2, 14 ) ]


view : Svg.Svg a
view =
    plot
        [ size ( 380, 300 )
        , margin ( 10, 20, 40, 20 )
        , domain ( Just 0, Nothing )
        ]
        [ verticalGrid
            [ Grid.lines
                [ Line.stroke Colors.axisColorLight ]
            ]
        , horizontalGrid
            [ Grid.lines
                [ Line.stroke Colors.axisColorLight ]
            , Grid.values [ 4, 8, 12 ]
            ]
        , xAxis
            [ Axis.line [ Line.stroke Colors.axisColor ]
            , Axis.tick [ Tick.delta 0.5 ]
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
