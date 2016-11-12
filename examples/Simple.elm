module Simple exposing (..)

import Plot exposing (..)
import Svg
import Svg.Attributes


lineData : List ( Float, Float )
lineData =
    [ ( -52, 34 ), ( -30, 32 ), ( -20, 5 ), ( 2, -46 ), ( 10, -20 ), ( 30, 10 ), ( 40, 136 ), ( 90, 167 ), ( 125, 120 ) ]


lineData2 =
    [ ( -1, 2 ), ( 0, 3 ), ( 4, 5 ), ( 5, 3 ) ]


isEven : Int -> Bool
isEven index =
    rem index 2 == 0


customTick : Int -> Float -> Svg.Svg a
customTick fromZero tick =
    Svg.line
        [ Svg.Attributes.style ("stroke: red")
        , Svg.Attributes.y2 (toString 5)
        ]
        []


plot1 =
    plot
        [ padding ( 40, 40 ) ]
        [ verticalGrid [ gridMirrorTicks, gridStyle [ ( "stroke", "#ddd" ) ] ]
        , horizontalGrid [ gridMirrorTicks, gridStyle [ ( "stroke", "#ddd" ) ] ]
        , line [ lineStyle [ ( "stroke", "mediumvioletred" ) ] ] lineData
        , yAxis [ tickRemoveZero ] 
        , xAxis
            [ tickRemoveZero
            , tickValues [ 20, 30, 40 ]
            , tickConfigView
                [ tickLength 7
                , tickWidth 2
                , tickStyle [ ( "stroke", "red" ) ]
                ]
            , tickConfigViewFunc (\i _ -> if isEven i then [ tickLength 20 ] else [ tickLength 40 ])
            , tickCustomViewIndexed customTick
            , labelConfigView [ labelDisplace ( 0, 20 ), labelFormat (\t -> toString t ++ "ms"), labelStyle [ ("stroke", "blue")] ]
            ]
        ]


main =
    plot1
