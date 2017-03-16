module PlotSine exposing (plotExample)

import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Svg.Plot exposing (..)
import Common exposing (..)


plotExample : PlotExample msg
plotExample =
  { title = "Sin"
  , code = code
  , view = view
  , id = "PlotSine"
  }


data : List ( Float, Float )
data =
  List.map (\v -> ( toFloat v, sin (degrees <| toFloat v) )) (List.range 0 360)


title : Svg msg
title =
  viewLabel
    [ fill axisColor
    , style "text-anchor: end;"
    ]
    "f(x) = sin x"


customLine : Series (List ( Float, Float )) msg
customLine =
  { axis = verticalAxis
  , interpolation = Monotone Nothing [ stroke pinkStroke ]
  , toDataPoints = List.map (\( x, y ) -> clear x y)
  }


verticalAxis : Axis
verticalAxis =
  customAxis <| \summary ->
    { position = Basics.min
    , axisLine = Just { attributes = [ stroke "grey" ], start = summary.dataMin, end = summary.dataMax }
    , ticks = List.map simpleTick (interval 0 0.5 summary)
    , labels = List.map simpleLabel (interval 0 0.5 summary)
    , flipAnchor = False
    }


horizontalAxis : Axis
horizontalAxis =
  customAxis <| \summary ->
    { position = Basics.min
    , axisLine = Just { attributes = [ stroke "grey" ], start = summary.dataMin, end = summary.dataMax }
    , ticks = List.map simpleTick [ 0, 90, 180, 270, 360 ]
    , labels = List.map simpleLabel [ 0, 90, 180, 270, 360 ]
    , flipAnchor = False
    }


view : Svg.Svg a
view =
  let
    settings =
      { defaultSeriesPlotCustomizations
      | horizontalAxis = horizontalAxis
      , junk = \summary -> [ viewJunk title summary.x.dataMax summary.y.max  ]
      , toDomainLowest = \y -> y - 0.25
      , toRangeLowest = \y -> y - 25
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
