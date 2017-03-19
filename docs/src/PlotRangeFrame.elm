module PlotRangeFrame exposing (plotExample)

import Svg exposing (Svg)
import Svg.Attributes exposing (stroke, strokeDasharray, r, fill, strokeWidth)
import Svg.Events exposing (onMouseOver, onMouseOut)
import Plot exposing (..)
import Msg exposing (..)
import Common exposing (..)


plotExample : Maybe Point -> PlotExample Msg
plotExample hovered =
    { title = "PlotRangeFrame"
    , code = code
    , view = view hovered
    , id = "PlotRangeFrame"
    }


data : List ( Float, Float )
data =
    [ ( 1.31, 240 )
    , ( 1.310, 238.2 )
    , ( 1.324, 237.4 )
    , ( 1.330, 239.7 )
    , ( 1.347, 238.9 )
    , ( 1.350, 236.5 )
    , ( 1.369, 236.6 )
    , ( 1.370, 238 )
    , ( 1.378, 237 )
    , ( 1.364, 237.6 )
    , ( 1.366, 236.4 )
    , ( 1.330, 238.3 )
    , ( 1.324, 237.4 )
    , ( 1.330, 238.7 )
    , ( 1.347, 236.9 )
    , ( 1.350, 237.5 )
    , ( 1.369, 237.6 )
    , ( 1.370, 238.4 )
    , ( 1.378, 237.3 )
    , ( 1.406, 233.7 )
    , ( 1.364, 236.6 )
    , ( 1.366, 238.4 )
    , ( 1.330, 235.3 )
    , ( 1.395, 233.7 )
    , ( 1.405, 234.7 )
    , ( 1.41, 232.7 )
    ]


scatter : Maybe Point -> Series (List ( Float, Float )) Msg
scatter hovering =
  { axis = rangeFrameAxis hovering .y
  , interpolation = None
  , toDataPoints = List.map (rangeFrameHintDot hovering)
  }


circle : Float -> Float -> Svg Msg
circle x y =
  Svg.circle
    [ r "5"
    , stroke "transparent"
    , strokeWidth "3px"
    , fill pinkStroke
    , onMouseOver (HoverRangeFrame (Just { x = x, y = y }))
    , onMouseOut (HoverRangeFrame Nothing)
    ]
    []


flashyLine : Float -> Float -> Point -> Maybe (AxisSummary -> LineCustomizations)
flashyLine x y hovered =
  if hovered.x == x && hovered.y == y then
    Just (fullLine [ stroke "#a3a3a3", strokeDasharray "2, 10" ])
  else
    Nothing


rangeFrameHintDot : Maybe Point -> ( Float, Float ) -> DataPoint Msg
rangeFrameHintDot hovered ( x, y ) =
  { view = Just (circle x y)
  , xLine = Maybe.andThen (flashyLine x y) hovered
  , yLine = Maybe.andThen (flashyLine x y) hovered
  , xTick = Just (simpleTick x)
  , yTick = Just (simpleTick y)
  , hint = Nothing
  , x = x
  , y = y
  }


rangeFrameAxis : Maybe Point -> (Point -> Float) -> Axis
rangeFrameAxis hovered toValue =
  customAxis <| \summary ->
    { position = closestToZero
    , axisLine = Nothing
    , ticks = List.map simpleTick [ summary.dataMin, summary.dataMax ]
    , labels = List.map simpleLabel [ summary.dataMin, summary.dataMax ]
        ++ hoverLabel hovered toValue
    , flipAnchor = False
    }


hoverLabel : Maybe Point -> (Point -> Float) -> List LabelCustomizations
hoverLabel hovered toValue =
  hovered
    |> Maybe.map (toValue >> simpleLabel >> List.singleton)
    |> Maybe.withDefault []


view : Maybe Point -> Svg.Svg Msg
view hovering =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations
    | horizontalAxis = rangeFrameAxis hovering .x
    , margin = { top = 20, bottom = 20, left = 50, right = 40 }
    , toRangeLowest = \y -> y - 0.01
    , toDomainLowest = \y -> y - 1
    }
    [ scatter hovering ]
    data



code : String
code =
    """
scatter : Maybe Point -> Series (List ( Float, Float )) Msg
scatter hovering =
  { axis = rangeFrameAxis hovering .y
  , interpolation = None
  , toDataPoints = List.map (rangeFrameHintDot hovering)
  }


circle : Float -> Float -> Svg Msg
circle x y =
  Svg.circle
    [ r "5"
    , stroke "transparent"
    , strokeWidth "3px"
    , fill pinkStroke
    , onMouseOver (Hover (Just { x = x, y = y }))
    , onMouseOut (Hover Nothing)
    ]
    []


flashyLine : Float -> Float -> Point -> Maybe (AxisSummary -> LineCustomizations)
flashyLine x y hovered =
  if hovered.x == x && hovered.y == y then
    Just (fullLine [ stroke "#a3a3a3", strokeDasharray "2, 10" ])
  else
    Nothing


rangeFrameHintDot : Maybe Point -> ( Float, Float ) -> DataPoint Msg
rangeFrameHintDot hovered ( x, y ) =
  { view = Just (circle x y)
  , xLine = Maybe.andThen (hoverLine x y) hovered
  , yLine = Maybe.andThen (hoverLine x y) hovered
  , xTick = Just (simpleTick x)
  , yTick = Just (simpleTick y)
  , viewHint = Nothing
  , x = x
  , y = y
  }


rangeFrameAxis : Maybe Point -> (Point -> Float) -> Axis
rangeFrameAxis hovered toValue =
  customAxis <| \\summary ->
    { position = closestToZero
    , axisLine = Nothing
    , ticks = List.map simpleTick [ summary.dataMin, summary.dataMax ]
    , labels = List.map simpleLabel [ summary.dataMin, summary.dataMax ]
        ++ hoverLabel hovered toValue
    , flipAnchor = False
    }


hoverLabel : Maybe Point -> (Point -> Float) -> List LabelCustomizations
hoverLabel hovered toValue =
  hovered
    |> Maybe.map (toValue >> simpleLabel >> List.singleton)
    |> Maybe.withDefault []


view : Maybe Point -> Svg.Svg Msg
view hovering =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations
    | horizontalAxis = rangeFrameAxis hovering .x
    , margin = { top = 20, bottom = 20, left = 50, right = 40 }
    , toRangeLowest = \\y -> y - 0.02
    , toDomainLowest = \\y -> y - 1
    }
    [ scatter hovering ]
    data
"""
