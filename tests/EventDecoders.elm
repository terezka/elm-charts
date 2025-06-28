module EventDecoders exposing (..)

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


tests : Test
tests =
  let plane =
        { defaultPlane
          | x = updatelength defaultPlane.x 100
          , y = updatelength defaultPlane.y 100
        }
  in
  describe "Event decoders"
    [ test "distancePositions: x diff" <|
        \() ->
          CS.distancePositions plane (toPosition 5 5) (toPosition 6 5)
            |> expectFloat (10 ^ 2 + 0 ^ 2)
    , test "distancePositions: y diff" <|
        \() ->
          CS.distancePositions plane (toPosition 5 5) (toPosition 5 6)
            |> expectFloat (0 ^ 2 + 10 ^ 2)
    , test "distancePositions: x and y diff" <|
        \() ->
          CS.distancePositions plane (toPosition 5 5) (toPosition 6 6)
            |> expectFloat (10 ^ 2 + 10 ^ 2)

    , test "distancePositions: x and y diff 2" <|
        \() ->
          CS.distancePositions plane (toPosition 5.5 5) (toPosition 6.5 5.5)
            |> expectFloat (10 ^ 2 + 5 ^ 2)
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
