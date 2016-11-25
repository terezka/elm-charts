module ComposedChart exposing (chart, code)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Debug
import Colors


data1 : List ( Float, Float )
data1 =
    [ ( -10, 14 ), ( -9, 5 ), ( -8, -9 ), ( -7, -15 ), ( -6, -22 ), ( -5, -12 ), ( -4, -8 ), ( -3, -1 ), ( -2, 6 ), ( -1, 10 ), ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


filterLabels : Int -> Float -> Bool
filterLabels index _ =
    not (isOdd index)


toTickConfig : Int -> Float -> List (TickViewAttr msg)
toTickConfig index tick =
    if isOdd index then
        [ tickLength 7, tickStyle [ (Svg.Attributes.stroke "#c7c7c7") ] ]
    else
        [ tickLength 10, tickStyle [ (Svg.Attributes.stroke "#b9b9b9") ] ]


customLabelStyle : List (Svg.Attribute msg)
customLabelStyle =
    [ (Svg.Attributes.stroke "#969696"), (Svg.Attributes.fontSize "12px") ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 350 ), padding ( 40, 40 ) ]
        [ horizontalGrid [ gridMirrorTicks, gridStyle [ (Svg.Attributes.stroke "#f2f2f2") ] ]
        , area
            [ areaStyle
                [ (Svg.Attributes.stroke Colors.skinStroke)
                , (Svg.Attributes.fill Colors.skinFill)
                , (Svg.Attributes.opacity "0.5")
                ]
            ]
            (List.map (\( x, y ) -> ( x, y * 2.1 )) data1)
        , area
            [ areaStyle
                [ (Svg.Attributes.stroke Colors.blueStroke)
                , (Svg.Attributes.fill Colors.blueFill)
                ]
            ]
            data1
        , line
            [ lineStyle
                [ (Svg.Attributes.stroke Colors.pinkStroke)
                , (Svg.Attributes.strokeWidth "2px")
                ]
            ]
            (List.map (\( x, y ) -> ( x, y * 3 )) data1)
        , yAxis
            [ axisStyle [ (Svg.Attributes.stroke "#b9b9b9") ]
            , tickRemoveZero
            , tickDelta 50
            , labelConfigView
                [ labelFormat (\l -> toString l ++ " °C")
                , labelStyle customLabelStyle
                ]
            ]
        , xAxis
            [ axisStyle [ (Svg.Attributes.stroke "#b9b9b9") ]
            , tickRemoveZero
            , tickConfigViewFunc toTickConfig
            , labelConfigView
                [ labelFormat (\l -> toString l ++ " t")
                , labelStyle customLabelStyle
                ]
            , labelFilter filterLabels
            ]
        ]


code =
    """
    isOdd : Int -> Bool
    isOdd n =
        rem n 2 > 0


    filterLabels : Int -> Float -> Bool
    filterLabels index _ =
        not (isOdd index)


    toTickConfig : Int -> Float -> List TickViewAttr
    toTickConfig index tick =
        if isOdd index then
            [ tickLength 7, tickStyle [ ( Svg.Attributes.stroke "#c7c7c7" ) ] ]
        else
            [ tickLength 10, tickStyle [ ( Svg.Attributes.stroke "#b9b9b9" ) ] ]


    customLabelStyle : List ( String, String )
    customLabelStyle =
        [ ( Svg.Attributes.stroke "#969696" ), ( Svg.Attributes.fontSize "12px" ) ]


    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 350 ), padding ( 40, 40 ) ]
            [ horizontalGrid
                [ gridMirrorTicks
                , gridStyle [ ( Svg.Attributes.stroke "#f2f2f2" ) ]
                ]
            , area
                [ areaStyle
                    [ ( Svg.Attributes.stroke Colors.skinStroke )
                    , ( Svg.Attributes.fill Colors.skinFill )
                    , ( Svg.Attributes.opacity "0.5" )
                    ]
                ]
                data1
            , area
                [ areaStyle
                    [ ( Svg.Attributes.stroke Colors.blueStroke )
                    , ( Svg.Attributes.fill Colors.blueFill )
                    ]
                ]
                data2
            , line
                [ lineStyle
                    [ ( Svg.Attributes.stroke Colors.pinkStroke )
                    , ( Svg.Attributes.strokeWidth "2px" )
                    ]
                ]
                data3
            , yAxis
                [ axisStyle [ ( Svg.Attributes.stroke "#b9b9b9" ) ]
                , tickRemoveZero
                , tickDelta 50
                , labelConfigView
                    [ labelFormat (\\l -> toString l ++ " °C")
                    , labelStyle customLabelStyle
                    ]
                ]
            , xAxis
                [ axisStyle [ ( Svg.Attributes.stroke "#b9b9b9" ) ]
                , tickRemoveZero
                , tickConfigViewFunc toTickConfig
                , labelConfigView
                    [ labelFormat (\\l -> toString l ++ " t")
                    , labelStyle customLabelStyle
                    ]
                , labelFilter filterLabels
                ]
            ]
    """
