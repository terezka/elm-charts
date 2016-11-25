module ScatterChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 20 ), ( 1, 15 ), ( 2, 20 ), ( 3, 20 ), ( 4, 31 ), ( 5, 36 ), ( 6, 35 ), ( 7, 40 ) ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 250 ) ]
        [ scatter
            [ scatterStyle
                [ (Svg.Attributes.stroke Colors.pinkStroke)
                , (Svg.Attributes.fill Colors.pinkFill)
                ]
            , scatterRadius 8
            ]
            data
        , xAxis [ axisStyle [ (Svg.Attributes.stroke Colors.axisColor) ] ]
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
                    [ ( Svg.Attributes.stroke Colors.pinkStroke )
                    , ( Svg.Attributes.fill Colors.pinkFill )
                    ]
                , scatterRadius 8
                ]
                data
            , xAxis [ axisStyle [ ( Svg.Attributes.stroke Colors.axisColor ) ] ]
            ]
    """
