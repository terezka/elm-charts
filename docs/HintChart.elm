module HintChart exposing (plotExample)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Hint as Hint
import Colors


plotExample =
    { title = title
    , code = code
    , view = view
    , fileName = fileName
    }


title : String
title = "Hints"


fileName : String
fileName = "HintChart"


data1 : List ( Float, Float )
data1 =
    [ ( 0, 2 ), ( 1, 4 ), ( 2, 5 ), ( 3, 10 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 0 ), ( 1, 5 ), ( 2, 7 ), ( 3, 15 ) ]



view : State -> Svg.Svg (Interaction c)
view state =
    plotInteractive
        [ size ( 380, 300 )
        , margin ( 10, 20, 40, 20 )
        , domain ( Just 0, Nothing )
        , id "HintChart"
        ]
        [ line
            [ Line.stroke Colors.blueStroke
            , Line.strokeWidth 2
            ]
            data1
        , line
            [ Line.stroke Colors.pinkStroke
            , Line.strokeWidth 2
            ]
            data2
        , xAxis
            [ Axis.line
                [ Line.stroke Colors.axisColor ]
            , Axis.tick
                [ Tick.delta 1 ]
            ]
        , hint
            [ Hint.lineStyle [ ( "background", "#b9b9b9") ] ]
            (getHoveredValue state) 
        ]


code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 300 ) ]
            [ line
                [ Line.style
                    [ ( "stroke", Colors.blueStroke )
                    , ( "stroke-width", "2px" )
                    ]
                ]
                data2
            , line
                [ Line.style
                    [ ( "stroke", Colors.pinkStroke )
                    , ( "stroke-width", "2px" )
                    ]
                ]
                data1
            , xAxis
                [ Axis.view
                    [ Axis.style [ ( "stroke", Colors.axisColor ) ] ]
                ]
            ]
    """
