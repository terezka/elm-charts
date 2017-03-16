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


scatter : Series (List ( Float, Float )) msg
scatter =
  { axis = rangeFrameAxis
  , interpolation = None
  , toDataPoints = List.map dot
  }


dot : ( Float, Float ) -> DataPoint msg
dot ( x, y ) =
  rangeFrameDot (viewCircle 5 pinkStroke) x y


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
    { defaultSeriesPlotCustomizations
    | horizontalAxis = rangeFrameAxis
    , margin = { top = 20, bottom = 20, left = 50, right = 40 }
    , toRangeLowest = \y -> y - 0.02
    , toDomainLowest = \y -> y - 1
    }
    [ scatter ]
    data



code : String
code =
    """
scatter : Series (List ( Float, Float )) msg
scatter =
  { axis = rangeFrameAxis
  , interpolation = None
  , toDataPoints = List.map dot
  }


dot : ( Float, Float ) -> DataPoint msg
dot ( x, y ) =
  rangeFrameDot (viewCircle 5 pinkStroke) x y


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
    { defaultSeriesPlotCustomizations
    | horizontalAxis = rangeFrameAxis
    , margin = { top = 20, bottom = 20, left = 50, right = 40 }
    , toRangeLowest = \\y -> y - 0.02
    , toRangeLowest = \\y -> y - 1
    }
    [ scatter ]
    data
"""
