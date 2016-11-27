module ComposedChart exposing (chart, code)

import Svg
import Svg.Attributes exposing (stroke, strokeWidth, fill, fontSize, opacity)
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
        [ tickLength 7, tickAttributes [ stroke "#c7c7c7" ] ]
    else
        [ tickLength 10, tickAttributes [ stroke "#b9b9b9" ] ]


customLabelAttributes : List (Svg.Attribute msg)
customLabelAttributes =
    [ stroke "#969696", fontSize "12px" ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 350 ), padding ( 40, 40 ) ]
        [ horizontalGrid [ gridMirrorTicks, gridAttributes [ stroke "#f2f2f2" ] ]
        , area
            [ areaAttributes
                [ stroke Colors.skinStroke
                , fill Colors.skinFill
                , opacity "0.5"
                ]
            ]
            (List.map (\( x, y ) -> ( x, y * 2.1 )) data1)
        , area
            [ areaAttributes
                [ stroke Colors.blueStroke
                , fill Colors.blueFill
                ]
            ]
            data1
        , line
            [ lineAttributes
                [ stroke Colors.pinkStroke
                , strokeWidth "2px"
                ]
            ]
            (List.map (\( x, y ) -> ( x, y * 3 )) data1)
        , yAxis
            [ axisAttributes [ stroke "#b9b9b9" ]
            , tickRemoveZero
            , tickDelta 50
            , labelConfigView
                [ labelFormat (\l -> toString l ++ " °C")
                , labelAttributes customLabelAttributes
                ]
            ]
        , xAxis
            [ axisAttributes [ stroke "#b9b9b9" ]
            , tickRemoveZero
            , tickConfigViewFunc toTickConfig
            , labelConfigView
                [ labelFormat (\l -> toString l ++ " t")
                , labelAttributes customLabelAttributes
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
            [ tickLength 7, tickAttributes [ stroke "#c7c7c7" ] ]
        else
            [ tickLength 10, tickAttributes [ stroke "#b9b9b9" ] ]


    customLabelAttributes : List ( String, String )
    customLabelAttributes =
        [ stroke "#969696", fontSize "12px" ]


    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 350 ), padding ( 40, 40 ) ]
            [ horizontalGrid
                [ gridMirrorTicks
                , gridAttributes [ stroke "#f2f2f2" ]
                ]
            , area
                [ areaAttributes
                    [ stroke Colors.skinStroke
                    , fill Colors.skinFill
                    , opacity "0.5"
                    ]
                ]
                data1
            , area
                [ areaAttributes
                    [ stroke Colors.blueStroke
                    , fill Colors.blueFill
                    ]
                ]
                data2
            , line
                [ lineAttributes
                    [ stroke Colors.pinkStroke
                    , strokeWidth "2px"
                    ]
                ]
                data3
            , yAxis
                [ axisAttributes [ stroke "#b9b9b9" ]
                , tickRemoveZero
                , tickDelta 50
                , labelConfigView
                    [ labelFormat (\\l -> toString l ++ " °C")
                    , labelAttributes customLabelAttributes
                    ]
                ]
            , xAxis
                [ axisAttributes [ stroke "#b9b9b9" ]
                , tickRemoveZero
                , tickConfigViewFunc toTickConfig
                , labelConfigView
                    [ labelFormat (\\l -> toString l ++ " t")
                    , labelAttributes customLabelAttributes
                    ]
                , labelFilter filterLabels
                ]
            ]
    """
