module Shared exposing (..) 

import Internal.Coordinates as Coordinates exposing (..)
import Expect exposing (FloatingPointTolerance(..))


toPosition : Float -> Float -> Position
toPosition x y =
  Position x x y y


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


otherPlane : Plane
otherPlane =
  { x = otherAxis
  , y = otherAxis
  }


otherAxis : Axis
otherAxis =
  { defaultAxis
  | dataMin = 0
  , dataMax = 100
  , min = 0
  , max = 100
  }


flippedXPlane : Plane
flippedXPlane =
  { defaultPlane | x = flipAxis defaultPlane.x }


flippedYPlane : Plane
flippedYPlane =
  { defaultPlane | y = flipAxis defaultPlane.y }


updateMarginMax : Axis -> Float -> Axis
updateMarginMax config val =
  { config | marginMax = val }


updateMarginMin : Axis -> Float -> Axis
updateMarginMin config val =
  { config | marginMin = val }


updatelength : Axis -> Float -> Axis
updatelength config length =
  { config | length = length }


flipAxis : Axis -> Axis
flipAxis config =
  { config | flip = not config.flip }


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


expectFloat : Float -> Float -> Expect.Expectation
expectFloat =
  Expect.within (Expect.Absolute 0.0001)
