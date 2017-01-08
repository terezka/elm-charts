module Plot.TestArea exposing (all)

import Test exposing (..)
import Expect
import Svg.Attributes
import Plot.Area exposing (..)

all : Test
all =
  describe "Plot.Area"
      [ testStroke
      , testStrokeWidth
      , testFill
      , testOpacity
      , testCustomAttrs
      ]


testConfig =
    { style = [ ( "color", "green" ) ], customAttrs = [] }


testStroke : Test
testStroke =
    describe "stroke"
        [ test "should update the conifg with the new stroke color" <|
            \() ->
                Expect.equal
                    (stroke "black" testConfig)
                    { style = [ ( "stroke", "black" ), ( "color", "green" ) ], customAttrs = [] }
        ]

testStrokeWidth : Test
testStrokeWidth =
    describe "strokeWidth"
        [ test "should update the config with the new stroke width" <|
            \() ->
                Expect.equal
                    (strokeWidth 2 testConfig)
                    { style = [ ( "stroke-width", "2px" ), ( "color", "green" ) ], customAttrs = [] }
        ]


testFill : Test
testFill =
    describe "fill"
        [ test "should update the config with the new fill color" <|
              \() ->
                  Expect.equal
                      (fill "red" testConfig)
                        { style = [ ( "fill", "red" ), ( "color", "green" ) ], customAttrs = [] }
        ]


testOpacity : Test
testOpacity =
    describe "opacity"
        [ test "should update the config with new opacity value" <|
              \() ->
                  Expect.equal
                      (opacity 0.8 testConfig)
                      { style = [ ( "opacity", "0.8" ), ( "color", "green" ) ], customAttrs = [] }
        ]


testCustomAttrs : Test
testCustomAttrs =
    describe "customAttrs"
        [ test "should update config with the new custom attributes" <|
              \() ->
                  Expect.equal
                      (customAttrs [ Svg.Attributes.dx "10px" ] testConfig )
                      { style = [ ( "color", "green" ) ], customAttrs = [ Svg.Attributes.dx "10px" ] }
        ]
