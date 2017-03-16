module PlotRangeFrame exposing (plotExample)

import Svg exposing (Svg)
import Svg.Plot exposing (..)
import Common exposing (..)


plotExample : PlotExample msg
plotExample =
    { title = "PlotRangeFrame"
    , code = code
    , view = view
    , id = "PlotRangeFrame"
    }


data : List ( Float, Float )
data =
    [ ( -2, 10 ), ( -1, 20 ), ( -0.5, -5 ),( 0, 10 ), ( 0.5, 20 ), ( 1, -5 )
    , ( 3, 4 ), ( 5, -7 ), ( 4.5, 5 ), ( 3.3, 20 ), ( 3.4, 7 ), ( 1, 28 )
    , ( 1.5, 4 ), ( 2, -7 ), ( 2.5, 5 ), ( 3, 20 ), ( 3.5, 7 ), ( 4, 28 )
    ]


scatter : Series (List ( Float, Float )) msg
scatter =
  { axis = rangeFrameAxis
  , interpolation = None
  , toDataPoints = List.map (\( x, y ) -> rangeFrameDot (viewCircle 5 pinkFill) x y)
  }


rangeFrameAxis : Axis
rangeFrameAxis =
  customAxis <| \summary ->
    { position = closestToZero
    , axisLine = Nothing
    , ticks = List.map simpleTick [ summary.dataMin, summary.dataMax ]
    , labels = List.map simpleLabel [ summary.dataMin, summary.dataMax ]
    , flipAnchor = False
    }


view : Svg.Svg a
view =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations | horizontalAxis = rangeFrameAxis }
    [ scatter ]
    data



code : String
code =
    """
scatter : Series (List ( Float, Float )) msg
scatter =
  { axis = rangeFrameAxis
  , interpolation = None
  , toDataPoints = List.map (\\( x, y ) -> rangeFrameDot (viewCircle 5 pinkFill) x y)
  }


rangeFrameAxis : Axis
rangeFrameAxis =
  customAxis <| \\summary ->
    { position = closestToZero
    , axisLine = Nothing
    , ticks = List.map simpleTick [ summary.dataMin, summary.dataMax ]
    , labels = List.map simpleLabel [ summary.dataMin, summary.dataMax ]
    , flipAnchor = False
    }


view : Svg.Svg a
view =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations | horizontalAxis = rangeFrameAxis }
    [ scatter ]
    data
"""
