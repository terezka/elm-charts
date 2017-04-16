module Series exposing (Series, Interpolation(..), Dot, view)

{-|
@docs Series, Interpolation, Dot, view
-}

import Svg exposing (Svg, Attribute, g, svg, text)
import Svg.Attributes as Attributes exposing (class, width, height, fill, stroke)
import Svg.Coordinates exposing (Plane, Point, minimum, maximum)
import Svg.Plot exposing (..)
import Axis exposing (Axis, Axis)



{-| -}
type alias Series data msg =
  { axis : Axis
  , interpolation : Interpolation msg
  , toDots : data -> List (Dot msg)
  }


{-| -}
type Interpolation msg
  = None
  | Linear (List (Attribute msg))
  | Monotone (List (Attribute msg))


{-| -}
type alias Dot msg =
  { view : Maybe (Svg msg)
  , xMark : Maybe (Axis.Report -> Axis.MarkView)
  , yMark : Maybe (Axis.Report -> Axis.MarkView)
  , x : Float
  , y : Float
  }



-- VIEW


{-| -}
view : List (Series data msg) -> data -> Svg msg
view series data =
  let
    plane =
      planeFromDots series data
  in
    svg
      [ width (toString plane.x.length)
      , height (toString plane.y.length)
      ]
      (List.map (viewSeries plane data) series)



-- VIEW SERIES


viewSeries : Plane -> data -> Series data msg -> Svg msg
viewSeries plane data series =
  let
    dots =
     getDots data series
  in
    case series.interpolation of
      None ->
        scatter plane dots

      Linear attributes ->
        linear plane attributes dots

      Monotone attributes ->
        monotone plane attributes dots



-- PLANE


planeFromDots : List (Series data msg) -> data -> Plane
planeFromDots series data =
  let
    dots =
      List.concat (List.map (getDots data) series)
  in
    { x =
      { marginLower = 10
      , marginUpper = 10
      , length = 300
      , min = minimum .x dots
      , max = maximum .x dots
      }
    , y =
      { marginLower = 10
      , marginUpper = 10
      , length = 300
      , min = setAreaDomain series (minimum .y dots)
      , max = maximum .y dots
      }
    }


setAreaDomain : List (Series data msg) -> Float -> Float
setAreaDomain series dataMin =
  if List.any isArea series then 0 else dataMin


isArea : Series data msg -> Bool
isArea series =
  case series.interpolation of
    Linear attributes ->
      hasFill attributes

    Monotone attributes ->
      hasFill attributes

    None ->
      False



-- HELPERS


getDots : data -> Series data msg -> List (Dot msg)
getDots data { toDots } =
  toDots data


{- ... -}
hasFill : List (Attribute msg) -> Bool
hasFill attributes =
  List.any (toString >> String.contains "realKey = \"fill\"") attributes
