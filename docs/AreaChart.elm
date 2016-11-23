module AreaChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Plot.Area as Area
import Plot.Grid as Grid
import Plot.Meta as Meta
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 5 ), ( 1, 20 ), ( 2, 10 ), ( 3, 12 ), ( 4, 20 ), ( 5, 25 ), ( 6, 3 ) ]


chart : Plot.State -> Svg.Svg Msg
chart state =
    let
        tooltipView =
            case state.position of
                Nothing ->
                    []

                Just position ->
                    [ tooltip [] position ]
    in
        plot
            "my-id"
            [ Meta.size ( 600, 250 ), Meta.margin ( 10, 10, 30, 10 ), Meta.padding ( 0, 20 ) ] <|
            [ verticalGrid [ Grid.classes [ "dsfdjksh" ] ]
            , area
                [ Area.style [ ( "stroke", Colors.blueStroke ), ( "fill", Colors.blueFill ) ] ] data
            , area
                [ Area.style [ ( "stroke", Colors.skinStroke ), ( "fill", Colors.skinFill ) ] ] data2
            , xAxis [ axisStyle [ ( "stroke", Colors.axisColor ) ] ]
            ] ++ tooltipView


code =
    """
    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 250 ) ]
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
