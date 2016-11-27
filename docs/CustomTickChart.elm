module CustomTickChart exposing (chart, code)

import Svg
import Svg.Attributes exposing (..)
import Plot exposing (..)
import Colors


data : List ( Float, Float )
data =
    [ ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


toTickConfig : Int -> Float -> List (TickViewAttr msg)
toTickConfig index tick =
    if isOdd index then
        [ tickLength 7, tickAttributes [ stroke "#e4e3e3" ] ]
    else
        [ tickLength 10, tickAttributes [ stroke "#b9b9b9" ] ]


toLabelConfig : Int -> Float -> List (LabelViewAttr msg)
toLabelConfig index tick =
    if isOdd index then
        [ labelFormat (always "") ]
    else
        [ labelFormat (\l -> toString l ++ " s")
        , labelAttributes [ stroke "#969696" ]
        , labelDisplace ( 0, 27 )
        ]


chart : Svg.Svg a
chart =
    plot
        [ size ( 600, 250 ) ]
        [ line
            [ lineAttributes
                [ stroke Colors.pinkStroke
                , strokeWidth "2px"
                ]
            ]
            data
        , xAxis
            [ axisAttributes [ stroke Colors.axisColor ]
            , tickConfigViewFunc toTickConfig
            , labelConfigViewFunc toLabelConfig
            ]
        ]


code =
    """
    isOdd : Int -> Bool
    isOdd n =
        rem n 2 > 0


    toTickConfig : Int -> Float -> List TickViewAttr
    toTickConfig index tick =
        if isOdd index then
            [ tickLength 7, tickAttributes [ stroke "#e4e3e3" ] ]
        else
            [ tickLength 10, tickAttributes [ stroke "#b9b9b9" ] ]


    toLabelConfig : Int -> Float -> List LabelViewAttr
    toLabelConfig index tick =
        if isOdd index then
            [ labelFormat (always "") ]
        else
            [ labelFormat (\\l -> toString l ++ " s")
            , labelAttributes [ stroke "#969696" ]
            , labelDisplace ( 0, 27 )
            ]


    chart : Svg.Svg a
    chart =
        plot
            [ size ( 600, 250 ) ]
            [ line
                [ lineAttributes
                    [ stroke Colors.pinkStroke
                    , strokeWidth "2px"
                    ]
                ]
                data
            , xAxis
                [ axisAttributes [ stroke Colors.axisColor ]
                , tickConfigViewFunc toTickConfig
                , labelConfigViewFunc toLabelConfig
                ]
            ]
    """
