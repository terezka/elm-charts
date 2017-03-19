module PlotSine exposing (plotExample)

import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Plot exposing (..)
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
    , axisLine = Just (dataLine summary)
    , ticks = List.map simpleTick (interval 0 0.5 summary)
    , labels = List.map simpleLabel (interval 0 0.5 summary)
    , flipAnchor = False
    }


horizontalAxis : Axis
horizontalAxis =
  customAxis <| \summary ->
    { position = Basics.min
    , axisLine = Just (dataLine summary)
    , ticks = List.map simpleTick [ 0, 90, 180, 270, 360 ]
    , labels = List.map simpleLabel [ 0, 90, 180, 270, 360 ]
    , flipAnchor = False
    }


dataLine : AxisSummary -> LineCustomizations
dataLine summary =
  { attributes = [ stroke "grey" ]
  , start = summary.dataMin
  , end = summary.dataMax
  }


title : Svg msg
title =
  viewLabel
    [ fill axisColor
    , style "text-anchor: end; font-style: italic;"
    ]
    "f(x) = sin x"


view : Svg.Svg a
view =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations
    | horizontalAxis = horizontalAxis
    , junk = \summary -> [ junk title summary.x.dataMax summary.y.max  ]
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
    { position = Basics.min
    , axisLine = Just (dataLine summary)
    , ticks = List.map simpleTick (interval 0 0.5 summary)
    , labels = List.map simpleLabel (interval 0 0.5 summary)
    , flipAnchor = False
    }


horizontalAxis : Axis
horizontalAxis =
  customAxis <| \\summary ->
    { position = Basics.min
    , axisLine = Just (dataLine summary)
    , ticks = List.map simpleTick [ 0, 90, 180, 270, 360 ]
    , labels = List.map simpleLabel [ 0, 90, 180, 270, 360 ]
    , flipAnchor = False
    }


dataLine : AxisSummary -> LineCustomizations
dataLine summary =
  { attributes = [ stroke "grey" ]
  , start = summary.dataMin
  , end = summary.dataMax
  }


title : Svg msg
title =
  viewLabel
    [ fill axisColor
    , style "text-anchor: end; font-style: italic;"
    ]
    "f(x) = sin x"


view : Svg.Svg a
view =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations
    | horizontalAxis = horizontalAxis
    , junk = \\summary -> [ junk title summary.x.dataMax summary.y.max  ]
    , toDomainLowest = \\y -> y - 0.25
    , toRangeLowest = \\y -> y - 25
    }
    [ customLine ]
    data
"""
