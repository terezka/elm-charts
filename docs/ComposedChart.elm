module ComposedChart exposing (composedChart)

import Svg
import Svg.Attributes
import Plot exposing (..)
import Debug
import Colors


isOdd : Int -> Bool
isOdd n =
    rem n 2 > 0


type Orientation
    = X
    | Y


getTickLenght : Int -> Int
getTickLenght fromZero =
    if isOdd fromZero then
        7
    else
        10


getTickColor : Int -> String
getTickColor fromZero =
    if isOdd fromZero then
        "#c7c7c7"
    else
        "#b9b9b9"


customTick : Int -> Float -> Svg.Svg a
customTick fromZero tick =
    Svg.line
        [ Svg.Attributes.style ("stroke: " ++ getTickColor fromZero)
        , Svg.Attributes.y2 (toString (getTickLenght fromZero))
        ]
        []


formatTickX : Int -> Float -> String
formatTickX fromZero tick =
    if isOdd fromZero then
        ""
    else
        toString tick ++ " t"


formatTickY : Float -> String
formatTickY tick =
    toString tick ++ " °C"


getLabelStyle : Orientation -> String
getLabelStyle orientation =
    if orientation == X then
        "text-anchor: middle;"
    else
        "text-anchor: end;"


getLabelText : Orientation -> Int -> Float -> String
getLabelText orientation fromZero tick =
    if orientation == X then
        formatTickX fromZero tick
    else
        formatTickY tick


getLabelDisplacement : Orientation -> String
getLabelDisplacement orientation =
    "translate("
        ++ (if orientation == X then
                "0, 27"
            else
                "-10, 5"
           )
        ++ ")"


customLabel : Orientation -> Int -> Float -> Svg.Svg a
customLabel orientation fromZero tick =
    Svg.text'
        [ Svg.Attributes.transform (getLabelDisplacement orientation)
        , Svg.Attributes.style (getLabelStyle orientation ++ " stroke: #969696; font-size: 12px;")
        ]
        [ Svg.tspan [] [ Svg.text (getLabelText orientation fromZero tick) ] ]


data1 : List ( Float, Float )
data1 =
    [ ( -10, 14 ), ( -9, 5 ), ( -8, -9 ), ( -7, -15 ), ( -6, -22 ), ( -5, -12 ), ( -4, -8 ), ( -3, -1 ), ( -2, 6 ), ( -1, 10 ), ( 0, 14 ), ( 1, 16 ), ( 2, 26 ), ( 3, 32 ), ( 4, 28 ), ( 5, 32 ), ( 6, 29 ), ( 7, 46 ), ( 8, 52 ), ( 9, 53 ), ( 10, 59 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( -10, 34 ), ( -9, 38 ), ( -8, 40 ), ( -7, 41 ), ( -6, 50 ), ( -5, 52 ), ( -4, 53 ), ( -3, 49 ), ( -2, 42 ), ( -1, 52 ), ( -0.5, 53 ), ( 0.5, 46 ), ( 1, 40 ), ( 2, 36 ), ( 3, 31 ), ( 4, 25 ), ( 5, 29 ), ( 6, 37 ), ( 7, 43 ), ( 8, 48 ), ( 9, 58 ), ( 10, 64 ) ]


composedChart : Svg.Svg a
composedChart =
    plot
        [ size ( 600, 300 ), padding ( 40, 40 ) ]
        [ verticalGrid [ gridMirrorTicks, gridStyle [ ( "stroke", "#e2e2e2" ) ] ]
        , area
            [ areaStyle
                [ ( "stroke", Colors.skinStroke )
                , ( "fill", Colors.skinFill )
                , ( "opacity", "0.5" )
                ]
            ]
            (List.map (\( x, y ) -> ( x, y * 2.1 )) data1)
        , area
            [ areaStyle
                [ ( "stroke", Colors.blueStroke )
                , ( "fill", Colors.blueFill )
                ]
            ]
            data1
        , line
            [ lineStyle
                [ ( "stroke", Colors.skinStroke )
                , ( "stroke-width", "3px" )
                ]
            ]
            (List.map (\( x, y ) -> ( x, y * 1.2 )) data2)
        , yAxis
            [ axisStyle [ ( "stroke", "#b9b9b9" ) ]
            , tickRemoveZero
            , tickDelta 50
            , labelCustomViewIndexed (customLabel Y)
            ]
        , xAxis
            [ axisStyle [ ( "stroke", "#b9b9b9" ) ]
            , tickRemoveZero
            , tickCustomViewIndexed customTick
            , labelCustomViewIndexed (customLabel X)
            ]
        ]
