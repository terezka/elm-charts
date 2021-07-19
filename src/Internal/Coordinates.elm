module Internal.Coordinates
  exposing
    ( Plane, Limit, Margin
    , scaleSVGX, scaleSVGY
    , toSVGX, toSVGY
    , scaleCartesianX, scaleCartesianY
    , toCartesianX, toCartesianY
    , Point, Position

    , fromProps, Axis
    , foldPosition

    , top, right, bottom, left, center
    , topLeft, topRight, bottomLeft, bottomRight
    , pointToPosition
    )

{-| This module contains helpers for cartesian/SVG coordinate translation.

# Plane
@docs Plane, Axis

# Plane from data

You may want to produce a plane which fits all your data. For that you need
to find the minimum and maximum values withing your data in order to calculate
the domain and range.

@docs minimum, maximum

    planeFromPoints : List Point -> Plane
    planeFromPoints points =
      { x =
        { marginLower = 10
        , marginUpper = 10
        , length = 300
        , min = minimum .x points
        , max = maximum .x points
        }
      , y =
        { marginLower = 10
        , marginUpper = 10
        , length = 300
        , min = minimum .y points
        , max = maximum .y points
        }
      }

# Cartesian to SVG
@docs toSVGX, toSVGY, scaleSVG

# SVG to cartesian
@docs toCartesianX, toCartesianY, scaleCartesian

# Helpers
@docs place, placeWithOffset

-}



type alias Point =
  { x : Float
  , y : Float
  }


type alias Position =
  { x1 : Float
  , x2 : Float
  , y1 : Float
  , y2 : Float
  }


{-| -}
center : Position -> Point
center pos =
  { x = pos.x1 + (pos.x2 - pos.x1) / 2, y = pos.y1 + (pos.y2 - pos.y1) / 2 }


{-| -}
top : Position -> Point
top pos =
  { x = pos.x1 + (pos.x2 - pos.x1) / 2, y = pos.y2 }


{-| -}
bottom : Position -> Point
bottom pos =
  { x = pos.x1 + (pos.x2 - pos.x1) / 2, y = pos.y1 }


{-| -}
left : Position -> Point
left pos =
  { x = pos.x1, y = pos.y1 + (pos.y2 - pos.y1) / 2 }


{-| -}
right : Position -> Point
right pos =
  { x = pos.x2, y = pos.y1 + (pos.y2 - pos.y1) / 2 }


{-| -}
topLeft : Position -> Point
topLeft pos =
  { x = pos.x1, y = pos.y2 }


{-| -}
topRight : Position -> Point
topRight pos =
  { x = pos.x2, y = pos.y2 }


{-| -}
bottomLeft : Position -> Point
bottomLeft pos =
  { x = pos.x1, y = pos.y1 }


{-| -}
bottomRight : Position -> Point
bottomRight pos =
  { x = pos.x2, y = pos.y1 }


pointToPosition : Point -> Position
pointToPosition point =
  { x1 = point.x, x2 = point.x, y1 = point.y, y2 = point.y }


{-| -}
foldPosition : (a -> Position) -> List a -> Position
foldPosition func data =
  let fold datum posM =
        case posM of
          Just pos ->
            Just
              { x1 = min (func datum).x1 pos.x1
              , x2 = max (func datum).x2 pos.x2
              , y1 = min (func datum).y1 pos.y1
              , y2 = max (func datum).y2 pos.y2
              }

          Nothing ->
            Just (func datum)
  in
  List.foldl fold Nothing data
    |> Maybe.withDefault (Position 0 0 0 0) -- TODO


{-| -}
fromProps : List (a -> Maybe Float) -> List (a -> Maybe Float) -> List a -> Position
fromProps xs ys data =
  let toPosition datum =
        let vsX = getValues xs datum
            vsY = getValues ys datum
        in
        { x1 = getMin vsX
        , x2 = getMax vsX
        , y1 = getMin vsY
        , y2 = getMax vsY
        }

      getMin = Maybe.withDefault 0 << List.minimum
      getMax = Maybe.withDefault 1 << List.maximum
      getValues vs datum = List.filterMap (\v -> v datum) vs
  in
  foldPosition toPosition data



-- PLANE


{-| -}
type alias Plane =
  { width : Float
  , height : Float
  , margin : Margin
  , x : Axis
  , y : Axis
  }


{-| -}
type alias Margin =
  { top : Float
  , right : Float
  , left : Float
  , bottom : Float
  }


{-| -}
type alias Axis =
  { dataMin : Float
  , dataMax : Float
  , min : Float
  , max : Float
  }


{-| -}
type alias Limit =
  { min : Float
  , max : Float
  }



-- TRANSLATION


{-| For scaling a cartesian value to a SVG value. Note that this will _not_
  return a coordinate on the plane, but the scaled value.
-}
scaleSVGX : Plane -> Float -> Float
scaleSVGX plane value =
  value * (innerWidth plane) / (range plane.x)


scaleSVGY : Plane -> Float -> Float
scaleSVGY plane value =
  value * (innerHeight plane) / (range plane.y)


{-| Translate a SVG x-coordinate to its cartesian x-coordinate.
-}
toSVGX : Plane -> Float -> Float
toSVGX plane value =
  scaleSVGX plane (value - plane.x.min) + plane.margin.left


{-| Translate a SVG y-coordinate to its cartesian y-coordinate.
-}
toSVGY : Plane -> Float -> Float
toSVGY plane value =
  scaleSVGY plane (plane.y.max - value) + plane.margin.top


{-| For scaling a SVG value to a cartesian value. Note that this will _not_
  return a coordinate on the plane, but the scaled value.
-}
scaleCartesianX : Plane -> Float -> Float
scaleCartesianX plane value =
  value * (range plane.x) / (innerWidth plane)


scaleCartesianY : Plane -> Float -> Float
scaleCartesianY plane value =
  value * (range plane.y) / (innerHeight plane)


{-| Translate a cartesian x-coordinate to its SVG x-coordinate.
-}
toCartesianX : Plane -> Float -> Float
toCartesianX plane value =
  scaleCartesianX plane (value - plane.margin.left) + plane.x.min


{-| Translate a cartesian y-coordinate to its SVG y-coordinate.
-}
toCartesianY : Plane -> Float -> Float
toCartesianY plane value =
  range plane.y - scaleCartesianY plane (value - plane.margin.top) + plane.y.min



-- INTERNAL HELPERS


range : Axis -> Float
range limits =
  let diff = limits.max - limits.min in
  if diff > 0 then diff else 1


innerWidth : Plane -> Float
innerWidth plane =
  max 1 (plane.width - plane.margin.left - plane.margin.right)


innerHeight : Plane -> Float
innerHeight plane =
  max 1 (plane.height - plane.margin.top - plane.margin.bottom)

