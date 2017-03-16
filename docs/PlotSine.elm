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


title : Svg msg
title =
  viewLabel
    [ fill axisColor
    , style "text-anchor: end;"
    ]
    "f(x) = sin x"


view : Svg.Svg a
view =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations
    | horizontalAxis = horizontalAxis
    , junk = \summary -> [ viewJunk title summary.x.dataMax summary.y.max  ]
    , toDomainLowest = \y -> y - 0.25
    , toRangeLowest = \y -> y - 25
    }
    [ customLine ]
    data


code : String
code =
    """
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


title : Svg msg
title =
  viewLabel
    [ fill axisColor
    , style "text-anchor: end;"
    , displace -10 35
    ]
    "f(x) = sin ( x * π / 20 )"


view : Svg.Svg a
view =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations
    | horizontalAxis = horizontalAxis
    , junk = \\summary -> [ viewJunk title summary.x.dataMax summary.y.max  ]
    , toDomainLowest = \\y -> y - 0.25
    , toRangeLowest = \\y -> y - 25
    }
    [ customLine ]
    data
"""
