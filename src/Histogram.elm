module Histogram exposing (..)

{-|
@docs Histogram, Bar, view, bar
-}

import Svg exposing (Svg, Attribute, g, svg, text)
import Svg.Attributes as Attributes exposing (class, width, height, fill, stroke)
import Svg.Coordinates exposing (Plane, Point, minimum, maximum)
import Svg.Plot exposing (..)
import Axis exposing (..)
import Internal.Axis exposing
  ( viewHorizontal
  , viewVertical
  , viewGrid
  , viewBunchOfLines
  , compose
  , raport
  , apply
  )



{-| -}
type alias Histogram data msg =
  data -> List (Bar msg)


{-| -}
type alias Bar msg =
  { attributes : List (Attribute msg)
  , y : Float
  }


{-| -}
bar : List (Attribute msg) -> Float -> Bar msg
bar attributes y =
  { attributes = attributes
  , y = y
  }



-- DEPENDENT AXIS


{-| -}
type alias IndependentAxis =
  { line : Maybe (Axis.Raport -> Axis.LineView)
  , mark : IndependentMarkView
  }


{-| -}
type alias IndependentMarkView =
  { label : Float -> Svg Never
  , tick : Maybe Axis.TickView
  }


{-| -}
defaultIndependentAxis : IndependentAxis
defaultIndependentAxis =
  { line = Just simpleLine
  , mark =
      { label = simpleLabel
      , tick = Just simpleTick
      }
  }


-- INDEPENDENT AXIS


{-| -}
type alias DependentAxis =
  { position : Float -> Float -> Float
  , line : Maybe (Raport -> LineView)
  , marks : Raport -> List DependentMark
  , mirror : Bool
  }


{-| -}
type alias DependentMarkView =
  { grid : Maybe (List (Attribute Never))
  , junk : Maybe (Raport -> LineView)
  , label : Maybe (Svg Never)
  , tick : Maybe TickView
  }


{-| -}
type alias DependentMark =
  { position : Float
  , view : DependentMarkView
  }


{-| -}
defaultDependentAxis : DependentAxis
defaultDependentAxis =
  { position = \min max -> min
  , line = Just simpleLine
  , marks = decentPositions >> List.map defaultMark
  , mirror = False
  }


{-| -}
defaultMarkView : Float -> DependentMarkView
defaultMarkView position =
  { grid = Nothing
  , junk = Nothing
  , tick = Just simpleTick
  , label = Just (simpleLabel position)
  }


{-| -}
defaultMark : Float -> DependentMark
defaultMark position =
  { position = position
  , view = defaultMarkView position
  }



-- CONFIG


{-| -}
type alias Config =
  { interval : Float
  , intervalBegin : Float
  , dependentAxis : DependentAxis
  , independentAxis : IndependentAxis
  }



defaultConfig : Config
defaultConfig =
  { interval = 1
  , intervalBegin = 0
  , dependentAxis = defaultDependentAxis
  , independentAxis = defaultIndependentAxis
  }



-- VIEW


{-| -}
view : List (Histogram data msg) -> data -> Svg msg
view =
  viewCustom defaultConfig


{-| -}
viewCustom : Config -> List (Histogram data msg) -> data -> Svg msg
viewCustom config histograms data =
  let
    bars =
      List.map (\h -> h data) histograms

    plane =
      planeFromBars config bars

    mark position =
      { position = position
      , view =
          { grid = Nothing
          , junk = Nothing
          , label = Just (config.independentAxis.mark.label position)
          , tick = config.independentAxis.mark.tick
          }
      }

    independentAxis =
      { position = \_ _ -> 0
      , line = config.independentAxis.line
      , marks = Axis.interval config.intervalBegin config.interval >> List.map mark
      , mirror = False
      }

    yMarks =
      apply plane.y config.dependentAxis.marks
  in
    svg
      [ width (toString plane.x.length)
      , height (toString plane.y.length)
      ]
      [ Svg.map never (viewGrid plane [] yMarks)
      , g [ class "elm-plot__all-histograms" ] (List.map (viewHistogram plane config) bars)
      , Svg.map never (viewHorizontal plane independentAxis)
      , Svg.map never (viewVertical plane config.dependentAxis)
      , Svg.map never (viewBunchOfLines plane [] yMarks)
      ]



-- VIEW HISTOGRAM


viewHistogram : Plane -> Config -> List (Bar msg) -> Svg msg
viewHistogram plane config bars =
  Svg.Plot.histogram plane
    { bars = bars
    , intervalBegin = config.intervalBegin
    , interval = config.interval
    }



-- PLANE


planeFromBars : Config -> List (List (Bar msg)) -> Plane
planeFromBars config bars =
  { x =
    { marginLower = 40
    , marginUpper = 40
    , length = 600
    , min = config.intervalBegin
    , max = config.intervalBegin + config.interval * (numberOfBars bars)
    }
  , y =
    { marginLower = 40
    , marginUpper = 40
    , length = 300
    , min = min 0 (minimum .y (List.concat bars))
    , max = max 0 (maximum .y (List.concat bars))
    }
  }



-- HELPERS


numberOfBars : List (List (Bar msg)) -> Float
numberOfBars =
  List.foldl (List.length >> toFloat >> max) 1
