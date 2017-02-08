module Internal.TestScale exposing (all)

import Test exposing (..)
import Expect
import Internal.Scale exposing (..)
import Internal.Types exposing (..)


all : Test
all =
    describe "Internal.Scale"
        [ testGetScale
        , testScaleValue
        , testUnScaleValue
        , testFromSvgCoords
        , testToSvgCoordsX
        , testToSvgCoordsY
        ]


testScale : Scale
testScale =
    { range = 3
    , lowest = 2
    , highest = 10
    , length = 6
    , offset = { lower = 1, upper = 8 }
    }


-- Predefined Values

edges =
    { lower = (\val -> val)
    , upper = (\val -> val)
    }
offset = { lower = 2, upper = 5 }
paddings = (3, 3)
values = [1, 2, 3, 4, 5, 6, 7, 8, 9]


testGetScale : Test
testGetScale =
    describe "getScale"
        [ test "should return length 3 if lengthTotal is 10 and offset is { lower = 2, upper = 5 }" <|
            \() ->
                let
                    result = (getScale 10 edges Nothing offset paddings values)
                in
                Expect.equal result.length 3
        , test "should never change offset" <|
            \() ->
                let
                    result = (getScale 10 edges Nothing offset paddings values)
                in
                Expect.equal result.offset offset
        , test "should return range 24" <|
            \() ->
                let
                  result = (getScale 10 edges Nothing offset paddings values)
                in
                Expect.equal result.range 24
        , test "should return lower -7" <|
            \() ->
                let
                    result = (getScale 10 edges Nothing offset paddings values)
                in
                Expect.equal result.lowest -7
        , test "should return highest 17" <|
            \() ->
                let
                    result = (getScale 10 edges Nothing offset paddings values)
                in
                Expect.equal result.highest 17
        ]


testScaleValue : Test
testScaleValue =
    describe "scaleValue"
        [ test ("should return Value 11 for " ++ (toString testScale) ++ " and Value 5")  <|
            \() ->
                Expect.equal (scaleValue testScale 5) 11
        ]


testUnScaleValue : Test
testUnScaleValue =
    describe "unScaleValue"
        [ test ("should return Value 4 for " ++ (toString testScale) ++ " and Value 5") <|
            \() ->
                Expect.equal (unScaleValue testScale 5) 4
        ]


testFromSvgCoords : Test
testFromSvgCoords =
    describe "fromSvgCoords"
        [ test ("should return Point (4, 2) for " ++ (toString testScale) ++ " and Point (5, 5)") <|
            \() ->
                Expect.equal (fromSvgCoords testScale testScale (5, 5)) (4, 2)
        ]


testToSvgCoordsX : Test
testToSvgCoordsX =
    describe "toSvgCoordsX"
        [ test ("should return Point (7, 11) for " ++ (toString testScale) ++ " and Point (5, 5)") <|
            \() ->
                Expect.equal (toSvgCoordsX testScale testScale (5, 5)) (7, 11)
        ]


testToSvgCoordsY : Test
testToSvgCoordsY =
    describe "toSvgCoordsY"
        [ test ("should return Point (7, 11) for " ++ (toString testScale) ++ " and Point (5, 5)") <|
            \() ->
                Expect.equal (toSvgCoordsY testScale testScale (5, 5)) (7, 11)
        ]
