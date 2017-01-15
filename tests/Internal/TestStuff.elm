module Internal.TestStuff exposing (all)

import Test exposing (..)
import Expect
import Internal.Stuff exposing (..)
import Internal.Types exposing (Orientation(..))

all : Test
all =
    describe "Internal Stuff"
        [ testGetHeighest
        , testGetLowest
        , testGetRange
        , testFoldBounds
        , testGetEdgesX
        , testGetEdgesY
        , testGetEdges
        , testPixelsToValue
        , testCeilToNeirest
        , testGetDifference
        , testGetClosest
        , testToNearest
        , testGetValues
        , testFlipOriented
        , testFoldOriented
        ]

testGetHeighest : Test
testGetHeighest =
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
                Expect.equal (getLowest [ 2, 10, 11 ]) 2
        , test "should return 0 in case of an empty list" <|
            \() ->
                Expect.equal (getLowest []) 0
        , test "should return -3 when passing in [-1, -2, -3]" <|
            \() ->
                Expect.equal (getLowest [ -1, -2, -3 ]) -3
        ]


testGetRange : Test
testGetRange =
    describe "getRange"
        [ test "should return 100 when input is 0 and 100" <|
            \() ->
                Expect.equal
                    (getRange 0 100)
                    100
        ]


testFoldBounds : Test
testFoldBounds =
    describe "foldBounds"
        [ test "should return min and max for old and new bounds"  <|
            \() ->
                Expect.equal
                    (foldBounds (Just { lower = 100, upper = 1000 }) { lower = 10, upper = 500 })
                    { lower = 10, upper = 1000 }
        , test "should return new bounds when no old bounds supplied"  <|
            \() ->
                Expect.equal
                    (foldBounds Nothing { lower = 10, upper = 500 })
                    { lower = 10, upper = 500 }
        ]


testGetEdgesX : Test
testGetEdgesX =
  describe "getEdgesX"
      [ test "should return the highest and lowest x coordinates" <|
          \() ->
              Expect.equal
                  (getEdgesX [ ( 300, 400 ), ( 200, 100 ), ( 500, 1000 ), ( 5, 10 ) ])
                  ( 5, 500 )
      ]


testGetEdgesY : Test
testGetEdgesY =
  describe "getEdgesY"
      [ test "should return the highest and lowest y coordinate" <|
          \() ->
              Expect.equal
                  (getEdgesY [( 300, 400 ), ( 200, 100 ), ( 500, 1000 ), ( 5, 10 )])
                  ( 10, 1000 )
      ]


testGetEdges : Test
testGetEdges =
  describe "getEdges"
      [ test "should return the highest and lowest value from given list" <|
          \() ->
              Expect.equal
                  (getEdges [ 200, 1, 1000, 500, 2, 10000 ])
                  ( 1, 10000 )
      ]


testPixelsToValue : Test
testPixelsToValue =
    describe "pixelsToValue"
        [ test "should return 500 for a length of 2, range of 10 and 100 pixels" <|
            \() ->
                Expect.equal
                    (pixelsToValue 2 10 100)
                    500
        , test "should return 200 for a length of 10, range of 5 and 400 pixels" <|
            \() ->
                Expect.equal
                    (pixelsToValue 10 5 400)
                    200
        ]

testCeilToNeirest : Test
testCeilToNeirest =
    describe "ceilToNearest"
        [ test "should return 45 for a precesion of 5 and a value of 40.80" <|
            \() ->
                Expect.equal
                    (ceilToNearest 5 40.80)
                    45
        , test "should return 42 for a precesion of 2 and a value of 40.80" <|
            \() ->
                Expect.equal
                    (ceilToNearest 2 40.80)
                    42
        ]

testGetDifference : Test
testGetDifference =
    describe "getDifference"
        [ test "should return 20.2 for inputs 40.4 20.2" <|
            \() ->
                Expect.equal
                    (getDifference 40.4 20.2)
                    20.2
        , test "should return 20.2 for inputs -40.4 and -20.2" <|
            \() ->
                Expect.equal
                    (getDifference -40.4 -20.2)
                    20.2
        ]

testGetClosest : Test
testGetClosest =
    describe "getClosest"
        [ test "should return 30 when value is 30 and the closest is 5" <|
            \() ->
                Expect.equal
                    (getClosest 100 30 (Just 5))
                    (Just 30)
        , test "should return 110 when value is 100 and the closest is 110" <|
            \() ->
                Expect.equal
                    (getClosest 100 30 (Just 110))
                    (Just 110)
        , test "should return 30 when closest is Nothing" <|
            \() ->
                Expect.equal
                    (getClosest 100 30 Nothing)
                    (Just 30)
        ]


testToNearest : Test
testToNearest =
    describe "toNearest"
        [ test "should return 40 when input is [ 400, 20, 40 ] and searching closest to 100" <|
            \() ->
                Expect.equal
                    (toNearest [ 400, 20, 40 ] 100)
                    (Just 40)
        , test "should return 400 when input is [ 400, 20, 40 ] and searching closest to 300" <|
            \() ->
                Expect.equal
                    (toNearest [ 400, 20, 40 ] 300)
                    (Just 400)
        , test "should return 20 when input is [ 400, 20, 40 ] and searching closest to 10" <|
            \() ->
                Expect.equal
                    (toNearest [ 400, 20, 40 ] 10)
                    (Just 20)
        ]


testGetValues : Test
testGetValues =
    describe "getValues"
        [ test "should return all x values from given list" <|
            \() ->
                Expect.equal
                    (getValues X [( 2, 3 ), ( 3.5, 4.5 ), ( 5, 10 )])
                    [ 2, 3.5, 5 ]
        , test "should return all y values from given list" <|
            \() ->
                Expect.equal
                    (getValues Y [( 2, 3 ), ( 3.5, 4.5 ), ( 5, 10 )])
                    [ 3, 4.5, 10 ]
        ]


testFlipOriented : Test
testFlipOriented =
    describe "flipOriented"
        [ test "should flip x and y values" <|
            \() ->
                Expect.equal
                    (flipOriented { x = 400, y = 200 })
                    { x = 200, y = 400 }
        ]


fakeFn : Float -> Float
fakeFn a = a * 3

testFoldOriented : Test
testFoldOriented =
    describe "foldOriented"
        [ test "should multiply the x value" <|
            \() ->
                Expect.equal
                    (foldOriented fakeFn X { x = 200, y = 200 })
                    { x = 600, y = 200 }
        , test "should multiply the y value" <|
            \() ->
                Expect.equal
                    (foldOriented fakeFn Y { x = 200, y = 200 })
                    { x = 200, y = 600 }
        ]
