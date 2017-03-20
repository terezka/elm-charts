module PlotAxis exposing (plotExample)

import Svg exposing (Svg)
import Svg.Attributes exposing (stroke)
import Plot exposing (..)
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
  { axis = rightAxis
  , interpolation = Monotone Nothing [ stroke pinkStroke ]
  , toDataPoints = List.map (\( x, y ) -> triangle x y)
  }


customLine : Series (List ( Float, Float )) msg
customLine =
  { axis = axisAtMin
  , interpolation = Monotone Nothing [ stroke blueStroke ]
  , toDataPoints = List.map blueCircle
  }


blueCircle : ( Float, Float ) -> DataPoint msg
blueCircle ( x, y ) =
  dot (viewCircle 5 blueStroke) x (y * 1.2)


rightAxis : Axis
rightAxis =
  customAxis <| \summary ->
    { position = Basics.max
    , axisLine = Nothing
    , ticks = List.map simpleTick (decentPositions summary)
    , labels = List.map label (decentPositions summary)
    , flipAnchor = True
    }


label : Float -> LabelCustomizations
label v =
  { position = v
  , view = viewLabel [] (toString (v * 27))
  }


horizontalAxis : Axis
horizontalAxis =
  customAxis <| \summary ->
    { position = closestToZero
    , axisLine = Just (fullLine [ stroke "grey" ] summary)
    , ticks = List.map simpleTick (decentPositions summary)
    , labels = List.map simpleLabel (decentPositions summary |> remove -2)
    , flipAnchor = False
    }


view : Svg.Svg a
view =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations
    | horizontalAxis = horizontalAxis
    }
    [ customLine, customArea ]
    data



code : String
code =
    """
customArea : Series (List ( Float, Float )) msg
customArea =
  { axis = rightAxis
  , interpolation = Monotone Nothing [ stroke pinkStroke ]
  , toDataPoints = List.map (\\( x, y ) -> triangle x y)
  }


customLine : Series (List ( Float, Float )) msg
customLine =
  { axis = axisAtMin
  , interpolation = Monotone Nothing [ stroke blueStroke ]
  , toDataPoints = List.map blueCircle
  }


blueCircle : ( Float, Float ) -> DataPoint msg
blueCircle ( x, y ) =
  dot (viewCircle 5 blueStroke) x (y * 1.2)


rightAxis : Axis
rightAxis =
  customAxis <| \\summary ->
    { position = Basics.max
    , axisLine = Nothing
    , ticks = List.map simpleTick (decentPositions summary)
    , labels = List.map label (decentPositions summary)
    , flipAnchor = True
    }


label : Float -> LabelCustomizations
label v =
  { position = v
  , view = viewLabel [] (toString (v * 27))
  }


horizontalAxis : Axis
horizontalAxis =
  customAxis <| \\summary ->
    { position = closestToZero
    , axisLine = Just (fullLine [ stroke "grey" ] summary)
    , ticks = List.map simpleTick (decentPositions summary)
    , labels = List.map simpleLabel (decentPositions summary |> remove -2)
    , flipAnchor = False
    }


view : Svg.Svg a
view =
  viewSeriesCustom
    { defaultSeriesPlotCustomizations
    | horizontalAxis = horizontalAxis
    }
    [ customLine, customArea ]
    data
"""
