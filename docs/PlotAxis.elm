module PlotAxis exposing (plotExample)

import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Svg.Plot exposing (..)
import Common exposing (..)


plotExample : PlotExample msg
plotExample =
    { title = "Multiple axis"
    , code = code
    , view = view
    , id = "Axis"
    }


data : List ( Float, Float )
data =
    [ ( -2, 10 ), ( -1, 20 ), ( -0.5, -5 ),( 0, 10 ), ( 0.5, 20 ), ( 1, -5 ), ( 1.5, 4 ), ( 2, -7 ), ( 2.5, 5 ), ( 3, 20 ), ( 3.5, 7 ), ( 4, 28 ) ]


customArea : Series (List ( Float, Float )) msg
customArea =
  { axis = axisAtMax
  , interpolation = Monotone (Just pinkFill) [ stroke pinkStroke ]
  , toDataPoints = List.map (\( x, y ) -> diamond x y)
  }


customLine : Series (List ( Float, Float )) msg
customLine =
  { axis = axisAtMin
  , interpolation = Monotone Nothing [ stroke blueStroke ]
  , toDataPoints = List.map (\( x, y ) -> dot (viewSquare 10 blueStroke) x (y * 1.2))
  }


{-| A super regular axis.
-}
horizontalAxis : Axis
horizontalAxis =
  customAxis <| \summary ->
    { position = closestToZero
    , axisLine = Just (simpleLine summary)
    , ticks = List.map simpleTick (decentPositions summary)
    , labels = List.map simpleLabel (decentPositions summary |> remove -2 |> remove 4)
    , flipAnchor = False
    }



view : Svg.Svg a
view =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations | horizontalAxis = horizontalAxis }
    [ customArea, customLine ]
    data



code : String
code =
    """
customArea : Series (List ( Float, Float )) msg
customArea =
  { axis = normalAxis
  , interpolation = Monotone (Just pinkFill) [ stroke pinkStroke ]
  , toDataPoints = List.map (\\( x, y ) -> diamond x y)
  }


customLine : Series (List ( Float, Float )) msg
customLine =
  { axis = normalAxis
  , interpolation = Monotone Nothing [ stroke blueStroke ]
  , toDataPoints = List.map (\\( x, y ) -> dot (viewSquare 10 blueStroke) x (y * 1.2))
  }


view : Svg.Svg a
view =
  viewSeries [ customArea, customLine ] data

"""
