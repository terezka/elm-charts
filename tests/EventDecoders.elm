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


getNearest : Test
getNearest =
  describe "getNearest" <|
    checkDistortedPlanes (CS.getNearest identity dataPositions) { x = 3.5, y = 4.5 } [ toPosition 3 4, toPosition 3 4 ]


getNearestX : Test
getNearestX =
  describe "getNearestX" <|
    checkDistortedPlanes (CS.getNearestX identity dataPositions) { x = 5, y = 8 } [ toPosition 5 2, toPosition 5 8 ]


getAllWithin : Test
getAllWithin =
  describe "getAllWithin" <|
    checkDistortedPlanes (CS.getAllWithin 10 identity dataPositions) { x = 8, y = 5 }
      [ toPosition 7 5, toPosition 8 6, toPosition 8 5, toPosition 9 5 ]


getNearestWithin : Test
getNearestWithin =
  describe "getNearestWithin" <|
    checkDistortedPlanes (CS.getNearestWithin 10 identity dataPositions) { x = 8.5, y = 5 }
      [ toPosition 8 5 ]


getNearestAndNearby : Test
getNearestAndNearby =
  describe "getNearestAndNearby" <|
    checkDistortedPlanes (CS.getNearestAndNearby 10 identity dataPositions) { x = 8.5, y = 5 }
      ([ toPosition 8 5 ], [ toPosition 9 5, toPosition 8 6, toPosition 7 5 ])



type alias Datum =
  { x : Float
  , y : Float
  , z : Float
  , v : Float
  , w : Float
  , p : Float
  , q : Float
  }



dataPositions : List Position
dataPositions =
  List.map (\d -> toPosition d.x d.y) data


data : List Datum
data =
  [ Datum 0  0 1 4.6 6.9 7.3 8.0
  , Datum 1  2 1 4.6 6.9 7.3 8.0
  , Datum 2  3 2 5.2 6.2 7.0 8.7
  , Datum 3  4 3 5.5 5.2 7.2 8.1
  , Datum 3  4 3 5.5 5.2 7.2 8.1
  , Datum 4  3 4 5.3 5.7 6.2 7.8
  , Datum 5  2 3 4.9 5.9 6.7 8.2
  , Datum 5  8 3 4.9 5.9 6.7 8.2
  , Datum 6  4 1 4.8 5.4 7.2 8.3
  , Datum 7  5 2 5.3 5.1 7.8 7.1
  , Datum 8  6 3 5.4 3.9 7.6 8.5
  , Datum 8  5 4 5.8 4.6 6.5 6.9
  , Datum 9  5 4 5.8 4.6 6.5 6.9
  , Datum 10 4 3 4.5 5.3 6.3 7.0
  , Datum 10 10 3 4.5 5.3 6.3 7.0
  ]


checkDistortedPlanes : (Plane -> Plane -> Point -> x) -> Point -> x -> List Test
checkDistortedPlanes func point result =
  [ test "undistorted plane" <|
        \() ->
          func plane plane point
            |> Expect.equal result
  , test "within smaller plane" <|
        \() ->
          func plane smallerPlane point
            |> Expect.equal result
  , test "within larger plane" <|
        \() ->
          func plane largerPlane point
            |> Expect.equal result
  ]


-- HELPERS


toPosition : Float -> Float -> Position
toPosition x y =
  Position x x y y


plane : Plane
plane =
  { defaultPlane
    | x = updatelength defaultPlane.x 100
    , y = updatelength defaultPlane.y 100
  }


largerPlane : Plane
largerPlane =
  { defaultPlane
    | x = updatelength defaultPlane.x 200
    , y = updatelength defaultPlane.y 200
  }


smallerPlane : Plane
smallerPlane =
  { defaultPlane
    | x = updatelength defaultPlane.x 50
    , y = updatelength defaultPlane.y 50
  }


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
    , flip = False
    }
  , y =
    { length = 300
    , marginMin = 10
    , marginMax = 10
    , dataMin = Maybe.withDefault 0 (List.minimum <| List.map .y points)
    , dataMax = Maybe.withDefault 10 (List.maximum <| List.map .y points)
    , min = Maybe.withDefault 0 (List.minimum <| List.map .y points)
    , max = Maybe.withDefault 10 (List.maximum <| List.map .y points)
    , flip = False
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
  , flip = False
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
