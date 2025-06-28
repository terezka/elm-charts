module Coordinates exposing (..)

import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import Expect exposing (FloatingPointTolerance(..))
import Fuzz exposing (Fuzzer, list, int, float, niceFloat, string, map)
import Html exposing (Html, div)
import Svg exposing (Svg, svg)
import Svg.Attributes
import Internal.Coordinates as Coordinates exposing (..)
import Internal.Svg as CS
import Shared exposing (..)


coordinates : Test
coordinates =
  describe "Cartesian translation"
    [ test "toSVGX" <|
        \() ->
          expectFloat 11 (toSVGX defaultPlane 1)
    , test "toSVGY" <|
        \() ->
          expectFloat 99 (toSVGY defaultPlane 1)
    --
    , test "toCartesianX" <|
        \() ->
          expectFloat 1 (toCartesianX defaultPlane 11)
    , test "toCartesianY" <|
        \() ->
          expectFloat 1 (toCartesianY defaultPlane 99)
    --
    , test "toSVGX with lower margin" <|
        \() ->
          expectFloat 10 (toSVGX { defaultPlane | x = updateMarginMax defaultPlane.x 10 } 1)
    , test "toSVGX with upper margin" <|
        \() ->
          expectFloat 20 (toSVGX { defaultPlane | x = updateMarginMin defaultPlane.x 10 } 1)
    --
    , test "toSVGY with lower margin" <|
        \() ->
          expectFloat 90 (toSVGY { defaultPlane | y = updateMarginMax defaultPlane.y 10 } 1)
    , test "toSVGY with upper margin" <|
        \() ->
          expectFloat 100 (toSVGY { defaultPlane | y = updateMarginMin defaultPlane.y 10 } 1)
    --
    , test "toCartesianY with lower margin" <|
        \() ->
          expectFloat 1 (toCartesianY { defaultPlane | y = updateMarginMax defaultPlane.y 10 } 90)
    , test "toCartesianY with upper margin" <|
        \() ->
          expectFloat 1 (toCartesianY { defaultPlane | y = updateMarginMin defaultPlane.y 10 } 100)
    --
    , test "toSVGX flipped min" <|
        \() ->
          expectFloat 110 (toSVGX flippedXPlane 0)
    , test "toSVGX flipped max" <|
        \() ->
          expectFloat 0 (toSVGX flippedXPlane 10)
    --
    , test "toSVGY flipped min" <|
        \() ->
          expectFloat 0 (toSVGY flippedYPlane 0)
    , test "toSVGY flipped max" <|
        \() ->
          expectFloat 110 (toSVGY flippedYPlane 10)
    --
    , test "Length should default to 1" <|
        \() ->
          expectFloat 0.9 (toSVGY { defaultPlane | y = updatelength defaultPlane.y 0 } 1)
    , fuzz niceFloat "x-coordinate produced should always be a number" <|
        \number ->
          toSVGX defaultPlane number
            |> isNaN
            |> Expect.equal False
    , fuzz niceFloat "y-coordinate produced should always be a number" <|
        \number ->
          toSVGY defaultPlane number
            |> isNaN
            |> Expect.equal False
    ]


planeToPlane : Test
planeToPlane =
  describe "Plane to plane translation"
    [ test "convertPos" <|
        \() ->
          convertPos otherPlane defaultPlane (toPosition 8 5)
            |> Expect.equal (toPosition 80 50)
    , test "convertPos negative" <|
        \() ->
          convertPos otherPlane defaultPlane (toPosition -8 -5)
            |> Expect.equal (toPosition -80 -50)
    , test "convertPos reverse planes" <|
        \() ->
          convertPos defaultPlane otherPlane (toPosition 8 5)
            |> Expect.equal (toPosition 0.8 0.5)
    , test "convertPoint" <|
        \() ->
          convertPoint otherPlane defaultPlane (Point 8 5)
            |> Expect.equal (Point 80 50)
    ]


