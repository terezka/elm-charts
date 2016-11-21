module HelperTests exposing (all)

import Test exposing (..)
import Expect
import String
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Helpers exposing (..)


all : Test
all =
    describe "Helpers"
        [ testGetGreatest
        , testGetLowest
        , testCoordToInstruction
        , testToInstruction
        , testStartPath
        , testToPositionAttr
        , testToTranslate
        , testToRotate
        , testToStyle
        , testCalculateStep
        ]


testGetGreatest : Test
testGetGreatest =
    describe "getHighest"
        [ test "should return 11 when passing in [2, 10, 11]" <|
            \() ->
                Expect.equal (getHighest [ 2, 10, 11 ]) 11
        , test "should return 1 in case of an empty list" <|
            \() ->
                Expect.equal (getHighest []) 10
        , test "should return -1 when passing in [-1, -2, -3]" <|
            \() ->
                Expect.equal (getHighest [ -1, -2, -3 ]) -1
        ]


testGetLowest : Test
testGetLowest =
    describe "getLowest"
        [ test "should return 0 passing in [2, 10, 11]" <|
            \() ->
                Expect.equal (getLowest [ 2, 10, 11 ]) 0
        , test "should return 0 in case of an empty list" <|
            \() ->
                Expect.equal (getLowest []) 0
        , test "should return -3 when passing in [-1, -2, -3]" <|
            \() ->
                Expect.equal (getLowest [ -1, -2, -3 ]) -3
        ]


testCoordToInstruction : Test
testCoordToInstruction =
    describe "coordToInstruction"
        [ test "should return \"random 0,0\" when passing in \"random\" [(0,0)]" <|
            \() ->
                Expect.equal (coordToInstruction "random" [ ( 0, 0 ) ]) "random 0,0"
        , test "should return \"random 0,0random 1,1\" when passing in \"random\"  [(0,0), (1,1)]" <|
            \() ->
                Expect.equal (coordToInstruction "random" [ ( 0, 0 ), ( 1, 1 ) ]) "random 0,0random 1,1"
        ]


testToInstruction : Test
testToInstruction =
    describe ("toInstruction")
        [ test "should return \"2 \" when in passing in \"2\" []" <|
            \() ->
                Expect.equal (toInstruction "2" []) "2 "
        , test "should return \"-2 \" when in passing in \"-2\" []" <|
            \() ->
                Expect.equal (toInstruction "-2" []) "-2 "
        , test "should return \"2 2,3\" when in passing in \"2\" [2, 3]" <|
            \() ->
                Expect.equal (toInstruction "2" [ 2, 3 ]) "2 2,3"
        , test "should return \"2 -2,-3,-4\" when in passing in \"2\" [-2, -3, -4] " <|
            \() ->
                Expect.equal (toInstruction "2" [ -2, -3, -4 ]) "2 -2,-3,-4"
        ]


testStartPath : Test
testStartPath =
    describe "startPath"
        [ test "should return (\"M 0,0\", []) when passing in [(0,0)]" <|
            \() ->
                Expect.equal (startPath [ ( 0, 0 ) ]) ( "M 0,0", [] )
        , test "should return (\"M -1,2\", [(3,4), (-5,-6)]) when passing [(-1,2), (3,4), (-5,-6)]" <|
            \() ->
                Expect.equal (startPath [ ( -1, 2 ), ( 3, 4 ), ( -5, -6 ) ]) ( "M -1,2", [ ( 3, 4 ), ( -5, -6 ) ] )
        ]


testToPositionAttr : Test
testToPositionAttr =
    describe ("toPositionAttr")
        [ test "should return a List with Svg x1 y1 x2 y2 Attributes" <|
            \() ->
                Expect.equal (toPositionAttr 2 3 4 5) [ x1 "2", y1 "3", x2 "4", y2 "5" ]
        ]


testToTranslate : Test
testToTranslate =
    describe "toTranslate"
        [ test "should return \"translate(0,0)\" when passing in (0,0)" <|
            \() ->
                Expect.equal (toTranslate ( 0, 0 )) "translate(0,0)"
        , test "should return \"translate(-90,90)\" when passing in (-90,90)" <|
            \() ->
                Expect.equal (toTranslate ( -90, 90 )) "translate(-90,90)"
        ]


testToRotate : Test
testToRotate =
    describe "toRotate"
        [ test "should return rotate(0 0 100) when passing in 0 0 100" <|
            \() ->
                Expect.equal (toRotate 0 0 100) "rotate(0 0 100)"
        , test "should return rotate(90 -90 100) when passing 90 -90 100" <|
            \() ->
                Expect.equal (toRotate 90 -90 100) "rotate(90 -90 100)"
        ]


testToStyle : Test
testToStyle =
    describe "toStyle"
        [ test "should return a string containg the style definition" <|
            \() ->
                Expect.equal
                    (toStyle
                        [ ( "color", "green" )
                        , ( "padding", "10px" )
                        , ( "border", "2px" )
                        ]
                    )
                    "border:2px; padding:10px; color:green; "
        ]



-- No finished


testCalculateStep : Test
testCalculateStep =
    describe "getTickDeltaTest"
        [ test "should return Infinity if the distance is 10 and want to get 0 ticks" <|
            \() ->
                Expect.equal (getTickDelta 10 0) (1 / 0)
        , test "should return 1 if the distance is 10 and want to get 10 ticks" <|
            \() ->
                Expect.equal (getTickDelta 10 10) 1
        , test "should return 5 if the distance is 10 and want to get 2 ticks" <|
            \() ->
                Expect.equal (getTickDelta 10 2) 5
        , test "should return 5 if the distance is 10 and want to get 3 ticks" <|
            \() ->
                Expect.equal (getTickDelta 10 3) 5
        , test "should return 10 if the distance is 100 and want to get 10 ticks" <|
            \() ->
                Expect.equal (getTickDelta 100 10) 10
        , test "should return 10 if the distance is 1000 and want to get 100 ticks" <|
            \() ->
                Expect.equal (getTickDelta 1000 100) 10
        , test "should return 1 if the distance is 150 and want to get 150 ticks" <|
            \() ->
                Expect.equal (getTickDelta 150 150) 1
        ]
