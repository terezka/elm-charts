module Plot.TestLine exposing (all)

import Test exposing (..)
import Expect
import Svg.Attributes
import Internal.Types exposing (Smoothing(..))
import Plot.Line exposing (..)


all : Test
all =
    describe "Plot.Line"
        [ testStroke
        , testStrokeWidth
        , testOpacity
        , testSmoothingBezier
        , testCustomAttrs
        ]


testConfig =
    { style = [ ( "fill", "transparent" ) ]
    , smoothing = None
    , customAttrs = []
    }


testStroke : Test
testStroke =
    describe "stroke"
        [ test "should update Config with new stroke value" <|
            \() ->
                Expect.equal
                    (.style (stroke "green" testConfig))
                    [ ( "stroke", "green" ), ( "fill", "transparent" ) ]
        ]


testStrokeWidth : Test
testStrokeWidth =
    describe "strokeWidth"
        [ test "should update Config with new stroke-width value" <|
            \() ->
                Expect.equal
                    (.style (strokeWidth 2 testConfig))
                    [ ( "stroke-width", "2px" ), ( "fill", "transparent" ) ]
        ]


testOpacity : Test
testOpacity =
    describe "opacity"
        [ test "should update Config with new opacity value" <|
            \() ->
                Expect.equal
                    (.style (opacity 0.6 testConfig))
                    [ ( "opacity", "0.6" ), ( "fill", "transparent" ) ]
        ]


testSmoothingBezier : Test
testSmoothingBezier =
    describe "smoothingBezier"
        [ test "should upated Config with smoothing Bezier value" <|
            \() ->
                Expect.equal
                    (.smoothing (smoothingBezier testConfig))
                    Bezier

        ]


testCustomAttrs : Test
testCustomAttrs =
    describe "customAttrs"
        [ test "" <|
            \() ->
                Expect.equal
                    (.customAttrs (customAttrs [Svg.Attributes.style "cursor: pointer;"] testConfig))
                    [Svg.Attributes.style "cursor: pointer;"]
        ]
