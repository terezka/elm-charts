module Series exposing (
  Series
  , viewCustom
  , Interpolation(..)
  , Mark
  , MarkView
  , Dot
  , view
  , dot
  , Axis
  , axis
  , defaultAxisView
  , defaultConfig
  , defaultMark
  , gridMark
  , AxisView
  , sometimesYouDontHaveAnAxis
  , Hint
  , Find(..)
  )

{-|
@docs Series, Interpolation, Dot, view, dot, Axis, axis, defaultAxisView, defaultConfig, gridMark, AxisView, sometimesYouDontHaveAnAxis, defaultMark
@docs Mark, MarkView, viewCustom, Hint, Find
-}

import Svg exposing (Svg, Attribute, g, svg, text)
import Svg.Attributes as Attributes exposing (class, width, height, fill, stroke)
import Html exposing (Html, div)
import Html.Events exposing (on, onMouseLeave)
import Json.Decode as Json
import DOM
import Svg.Coordinates exposing (Plane, Point, minimum, maximum, toCartesianX, toCartesianY)
import Svg.Plot exposing (..)
import Axis exposing (..)
import Colors exposing (..)
import Internal.Axis exposing
  ( viewHorizontal
  , viewVerticals
  , viewGrid
  , viewBunchOfLines
  , compose
  , raport
  , apply
  )



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
  , xMark : Maybe MarkView
  , yMark : Maybe MarkView
  , x : Float
  , y : Float
  }


{-| -}
dot : Svg msg -> Float -> Float -> Dot msg
dot view x y =
  { view = Just view
  , xMark = Nothing
  , yMark = Nothing
  , x = x
  , y = y
  }



-- AXIS


{-| -}
type Axis
  = Axis AxisView
  | SometimesYouDontHaveAnAxis



{-| -}
type alias AxisView =
  { position : Float -> Float -> Float
  , line : Maybe (Raport -> LineView)
  , marks : Raport -> List Mark
  , mirror : Bool
  }


{-| -}
type alias MarkView =
  { grid : Maybe (List (Attribute Never))
  , junk : Maybe (Raport -> LineView)
  , label : Maybe (Svg Never)
  , tick : Maybe TickView
  }


{-| -}
type alias Mark =
  { position : Float
  , view : MarkView
  }


{-| -}
axis : AxisView -> Axis
axis =
  Axis


{-| -}
sometimesYouDontHaveAnAxis : Axis
sometimesYouDontHaveAnAxis =
  SometimesYouDontHaveAnAxis


{-| -}
defaultAxisView : AxisView
defaultAxisView =
  { position = \min max -> min
  , line = Just simpleLine
  , marks = decentPositions >> List.map defaultMark
  , mirror = False
  }


{-| -}
defaultMarkView : Float -> MarkView
defaultMarkView position =
  { grid = Nothing
  , junk = Nothing
  , tick = Just simpleTick
  , label = Just (simpleLabel position)
  }


{-| -}
defaultMark : Float -> Mark
defaultMark position =
  { position = position
  , view = defaultMarkView position
  }


{-| -}
gridMarkView : Float -> MarkView
gridMarkView position =
  { grid = Just [ stroke grey ]
  , junk = Nothing
  , tick = Just simpleTick
  , label = Just (simpleLabel position)
  }


{-| -}
gridMark : Float -> Mark
gridMark position =
  { position = position
  , view = gridMarkView position
  }



-- CONFIG


{-| -}
type alias Config msg =
  { independentAxis : AxisView
  , hint : Maybe (Hint msg)
  }


{-| -}
type Find = Aligned | Single


{-| -}
type alias Hint msg =
  { proximity : Maybe Int
  , find : Find
  , msg : Maybe Point -> msg
  }


{-| -}
defaultConfig : Config msg
defaultConfig =
  { independentAxis = defaultAxisView
  , hint = Nothing
  }



-- VIEW


{-| -}
view : List (Series data msg) -> data -> Html msg
view =
  viewCustom defaultConfig


{-| -}
viewCustom : Config msg -> List (Series data msg) -> data -> Html msg
viewCustom config series data =
  let
    dots =
      List.map (getDots data) series

    allDots =
      List.concat dots

    plane =
      planeFromDots series allDots

    independentAxis =
      compose config.independentAxis (List.filterMap (xMark plane) allDots)

    dependentAxis series dots =
      maybeCompose series.axis (List.filterMap (yMark plane) dots)

    independentAxes =
      List.filterMap identity (List.map2 dependentAxis series dots)

    xMarks =
      apply plane.x independentAxis.marks

    yMarks =
      List.concatMap (.marks >> apply plane.y) independentAxes
  in
    container plane config
      [ svg
        [ width (toString plane.x.length)
        , height (toString plane.y.length)
        ]
        [ Svg.map never (viewGrid plane xMarks yMarks)
        , g [ class "elm-plot__all-series" ] (List.map2 (viewSeries plane) series dots)
        , Svg.map never (viewHorizontal plane independentAxis)
        , Svg.map never (viewVerticals plane independentAxes)
        , Svg.map never (viewBunchOfLines plane xMarks yMarks)
        ]
      ]


container : Plane -> Config msg -> List (Svg msg) -> Html msg
container plane config =
  case config.hint of
    Just hint ->
        div
          [ on "mousemove" (handleHint plane hint)
          , onMouseLeave (hint.msg Nothing)
          ]

    Nothing ->
      div []


xMark : Plane -> Dot msg -> Maybe Mark
xMark plane { x, xMark } =
  Maybe.map (\view -> Mark x view) xMark


yMark : Plane -> Dot msg -> Maybe Mark
yMark plane { y, yMark } =
  Maybe.map (\view -> Mark y view) yMark



-- VIEW SERIES


viewSeries : Plane -> Series data msg -> List (Dot msg) -> Svg msg
viewSeries plane series dots =
  case series.interpolation of
    None ->
      scatter plane (svgDots dots)

    Linear attributes ->
      linear plane attributes (svgDots dots)

    Monotone attributes ->
      monotone plane attributes (svgDots dots)


svgDots : List (Dot msg) -> List (Svg.Plot.Dot msg)
svgDots =
  List.map <| \dot -> { x = dot.x, y = dot.y, view = dot.view }



-- PLANE


planeFromDots : List (Series data msg) -> List (Dot msg) -> Plane
planeFromDots series dots =
  { x =
    { marginLower = 40
    , marginUpper = 40
    , length = 600
    , min = minimum .x dots
    , max = maximum .x dots
    }
  , y =
    { marginLower = 40
    , marginUpper = 40
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


maybeCompose : Axis -> List Mark -> Maybe AxisView
maybeCompose sometimesAnAxis marks =
  case sometimesAnAxis of
    Axis axisView ->
      Just (compose axisView marks)

    SometimesYouDontHaveAnAxis ->
      Nothing



-- HINT DECODER


handleHint : Plane -> Hint msg -> Json.Decoder msg
handleHint plane hint =
    Json.map3
        (hintMessage plane hint)
        (Json.field "clientX" Json.float)
        (Json.field "clientY" Json.float)
        (DOM.target plotPosition)


plotPosition : Json.Decoder DOM.Rectangle
plotPosition =
    Json.oneOf
        [ DOM.boundingClientRect
        , Json.lazy (\_ -> DOM.parentElement plotPosition)
        ]


hintMessage : Plane -> Hint msg -> Float -> Float -> DOM.Rectangle -> msg
hintMessage plane hint mouseX mouseY { left, top } =
  hint.msg <|
    Just
      { x = clamp plane.x.min plane.x.max <| toCartesianX plane (mouseX - left)
      , y = clamp plane.y.min plane.y.max <| toCartesianY plane (mouseY - top)
      }
