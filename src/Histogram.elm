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


{-| -}
type alias DependentAxis =
  { line : Maybe (Axis.Raport -> Axis.LineView)
  , mark : DependentMark
  }


{-| -}
type alias DependentMark =
  { label : Float -> Svg Never
  , tick : Maybe Axis.TickView
  }


{-| -}
type alias IndependentAxis =
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
type alias Config =
  { interval : Float
  , intervalBegin : Float
  , independentAxis : IndependentAxis
  , dependentAxis : DependentAxis
  }


{-| -}
defaultAxis : IndependentAxis
defaultAxis =
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


-- VIEW


{-| -}
view : Config -> List (Histogram data msg) -> data -> Svg msg
view config histograms data =
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
          , label = Just (config.dependentAxis.mark.label position)
          , tick = config.dependentAxis.mark.tick
          }
      }

    dependentAxis =
      { position = \_ _ -> 0
      , line = config.dependentAxis.line
      , marks = Axis.interval 0 config.interval >> List.map mark
      , mirror = False
      }

    yMarks =
      apply plane.x config.independentAxis.marks
  in
    svg
      [ width (toString plane.x.length)
      , height (toString plane.y.length)
      ]
      [ Svg.map never (viewGrid plane [] yMarks)
      , g [ class "elm-plot__all-histograms" ] (List.map (viewHistogram plane config) bars)
      , Svg.map never (viewHorizontal plane dependentAxis)
      , Svg.map never (viewVertical plane config.independentAxis)
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
