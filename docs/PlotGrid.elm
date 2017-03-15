module PlotGrid exposing (plotExample)

import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Svg.Plot exposing (..)
import Common exposing (..)


plotExample : PlotExample msg
plotExample =
  { title = "Grid"
  , code = code
  , view = view
  , id = "Grid"
  }


data : List ( Float, Float )
data =
  List.map (\v -> ( toFloat v, sin (toFloat v * pi / 20) )) (List.range 0 100)


title : Svg msg
title =
  viewLabel
    [ fill axisColor
    , style "text-anchor: end;"
    , displace -10 35
    ]
    "f(x) = sin ( x * π / 20 )"


customLine : Series (List ( Float, Float )) msg
customLine =
  { axis = verticalAxis
  , interpolation = Monotone Nothing [ stroke pinkStroke ]
  , toDataPoints = List.map (\( x, y ) -> clear x y)
  }


verticalAxis : Axis
verticalAxis =
  customAxis <| \summary ->
    { position = closestToZero
    , axisLine = Just (simpleLine summary)
    , ticks = List.map simpleTick (interval 0 0.5 summary)
    , labels = List.map simpleLabel (interval 0 0.5 summary)
    , flipAnchor = False
    }


horizontalAxis : Axis
horizontalAxis =
  customAxis <| \summary ->
    { position = closestToZero
    , axisLine = Just (simpleLine summary)
    , ticks = List.map simpleTick (interval 0 10 summary)
    , labels = []
    , flipAnchor = False
    }


view : Svg.Svg a
view =
  let
    settings =
      { defaultSeriesPlotCustomizations
      | horizontalAxis = horizontalAxis
      , grid = { horizontal = decentGrid, vertical = emptyGrid }
      , margin = { top = 20, bottom = 20, left = 40, right = 160 }
      , junk = \xMin yMin xMax yMax -> [ viewJunk title xMax yMax ]
      , toDomainHighest = \y -> y + 0.25
      , toDomainLowest = \y -> y - 0.25
      }
  in
    viewSeriesCustom settings [ customLine ] data


code : String
code =
    """
title : Svg msg
title =
  viewLabel
    [ fill axisColor
    , style "text-anchor: end;"
    , displace -10 35
    ]
    "f(x) = sin ( x * π / 20 )"


customLine : Series (List ( Float, Float )) msg
customLine =
  { axis = verticalAxis
  , interpolation = Monotone Nothing [ stroke pinkStroke ]
  , toDataPoints = List.map (\\( x, y ) -> clear x y)
  }


verticalAxis : Axis
verticalAxis =
  customAxis <| \\summary ->
    { position = closestToZero
    , axisLine = Just (simpleLine summary)
    , ticks = List.map simpleTick (interval 0 0.5 summary)
    , labels = List.map simpleLabel (interval 0 0.5 summary)
    }


horizontalAxis : Axis
horizontalAxis =
  customAxis <| \\summary ->
    { position = closestToZero
    , axisLine = Just (simpleLine summary)
    , ticks = List.map simpleTick (interval 0 10 summary)
    , labels = []
    }


view : Svg.Svg a
view =
  let
    settings =
      { defaultSeriesPlotCustomizations
      | horizontalAxis = horizontalAxis
      , grid = { horizontal = decentGrid, vertical = emptyGrid }
      , margin = { top = 20, bottom = 20, left = 160, right = 160 }
      , junk = \\xMin yMin xMax yMax -> [ viewJunk title xMax yMax ]
      , toDomainHighest = \\y -> y + 0.25
      , toDomainLowest = \\y -> y - 0.25
      }
  in
    viewSeriesCustom settings [ customLine ] data
"""
