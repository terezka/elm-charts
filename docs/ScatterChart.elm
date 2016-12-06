module ScatterChart exposing (plotExample)

import Svg
import Plot exposing (..)
import Plot.Scatter as Scatter
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Line as Line
import Colors


plotExample =
    { title = title
    , code = code
    , view = view
    , fileName = fileName
    }


title : String
title = "Scatters"


fileName : String
fileName = "ScatterChart"


data : List ( Float, Float )
data =
    [ ( 0, 10 ), ( 2, 12 ), ( 4, 27 ), ( 6, 25 ), ( 8, 46 ) ]


view : Svg.Svg a
view =
    plot
        [ size ( 380, 300 )
        , margin ( 10, 20, 40, 40 )
        , domain ( Just 0, Nothing )
        ]
        [ scatter
            [ Scatter.stroke Colors.pinkStroke
            , Scatter.fill Colors.pinkFill
            , Scatter.radius 8
            ]
            data
        , xAxis
            [ Axis.line
                [ Line.stroke Colors.axisColor ]
            , Axis.tick
                [ Tick.delta 2 ]
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