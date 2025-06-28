module Tests exposing (..)

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
    , testEventFilters
    ]


testEventFilters : Test
testEventFilters =
  let plane =
        { defaultPlane
          | x = updatelength defaultPlane.x 100
          , y = updatelength defaultPlane.y 100
        }
  in
  describe "Event filters"
    [ test "distanceSquaredPos: x diff" <|
        \() ->
          CS.distanceSquaredPos plane (toPosition 5 5) (toPosition 6 5)
            |> expectFloat 10
    , test "distanceSquaredPos: y diff" <|
        \() ->
          CS.distanceSquaredPos plane (toPosition 5 5) (toPosition 5 6)
            |> expectFloat 10
    , test "distanceSquaredPos: x and y diff" <|
        \() ->
          CS.distanceSquaredPos plane (toPosition 5 5) (toPosition 6 6)
            |> expectFloat 14.14213

    , test "distanceSquaredPos: x and y diff 2" <|
        \() ->
          CS.distanceSquaredPos plane (toPosition 5.5 5) (toPosition 6.5 5.5)
            |> expectFloat 11.18033
    ]


toPosition : Float -> Float -> Position
toPosition x y =
  Position x x y y


-- HELPERS


planeFromPoints : List Point -> Plane
planeFromPoints points =
  { x =
    { length = 300
    , marginMin = 10
    , marginMax = 10
    , dataMin = Maybe.withDefault 0 (List.minimum <| List.map .x points)
    , dataMax = Maybe.withDefault 10 (List.maximum <| List.map .x points)
    , min = Maybe.withDefault 0 (List.minimum <| List.map .x points)
    , max = Maybe.withDefault 10 (List.maximum <| List.map .x points)
    }
  , y =
    { length = 300
    , marginMin = 10
    , marginMax = 10
    , dataMin = Maybe.withDefault 0 (List.minimum <| List.map .y points)
    , dataMax = Maybe.withDefault 10 (List.maximum <| List.map .y points)
    , min = Maybe.withDefault 0 (List.minimum <| List.map .y points)
    , max = Maybe.withDefault 10 (List.maximum <| List.map .y points)
    }
  }


defaultPlane : Plane
defaultPlane =
  { x = defaultAxis
  , y = defaultAxis
  }


defaultAxis : Axis
defaultAxis =
  { length = 110
  , marginMin = 0
  , marginMax = 0
  , dataMin = 0
  , dataMax = 10
  , min = 0
  , max = 10
  }


updateMarginMax : Axis -> Float -> Axis
updateMarginMax config val =
  { config | marginMax = val }


updateMarginMin : Axis -> Float -> Axis
updateMarginMin config val =
  { config | marginMin = val }


updatelength : Axis -> Float -> Axis
updatelength config length =
  { config | length = length }


type alias Point =
  { x : Float, y : Float }


expectFloat : Float -> Float -> Expect.Expectation
expectFloat =
  Expect.within (Expect.Absolute 0.0001)
