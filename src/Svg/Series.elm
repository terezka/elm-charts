module Svg.Series exposing (
  view, dots, line, area, custom,
  DataPoint, Series, square, circle, diamond, viewCircle,
  triangle, Interpolation(..), rangeFrameGlitter
  )

{-|
# Plot

@docs view, dots, line, area, custom, DataPoint, Series, square, circle, diamond, triangle, Interpolation, rangeFrameGlitter, viewCircle
-}

import Html exposing (Html)
import Svg exposing (Svg, Attribute, svg, text_, tspan, text, g, path, rect)
import Svg.Attributes as Attributes exposing (stroke, fill, class, r, x2, y2, style)
import Svg.Plot as Plot exposing (..)
import Svg.Draw as Draw exposing (..)
import Svg.Colors exposing (..)


-- DATA POINTS


{-| -}
circle : Float -> Float -> DataPoint msg
circle =
  dot (viewCircle 5 pinkStroke)


{-| -}
square : Float -> Float -> DataPoint msg
square =
  dot (viewSquare 10 10 pinkStroke)


{-| -}
diamond : Float -> Float -> DataPoint msg
diamond =
  dot (viewSquare 10 10 pinkStroke)


{-| -}
triangle : Float -> Float -> DataPoint msg
triangle =
  dot (viewSquare 10 10 pinkStroke)


{-| -}
type alias DataPoint msg =
  { view : Maybe (Svg msg)
  , glitter : Glitter msg
  , x : Float
  , y : Float
  }


type alias Glitter msg =
  { xLine : Maybe (AxisSummary -> LineCustomizations)
  , yLine : Maybe (AxisSummary -> LineCustomizations)
  , xTick : Maybe TickCustomizations
  , yTick : Maybe TickCustomizations
  , hover : Maybe msg
  }


{-| -}
noGlitter : Glitter msg
noGlitter =
  { xLine = Nothing
  , yLine = Nothing
  , xTick = Nothing
  , yTick = Nothing
  , hover = Nothing
  }


{-| -}
rangeFrameGlitter : Float -> Float -> Glitter msg
rangeFrameGlitter x y =
  { xLine = Just (simpleLine [ stroke darkGrey, Attributes.strokeDasharray "5, 5" ])
  , yLine = Just (simpleLine [ stroke darkGrey, Attributes.strokeDasharray "5, 5" ])
  , xTick = Just (simpleTick [ stroke darkGrey ] 10 x)
  , yTick = Just (simpleTick [ stroke darkGrey ] 10 y)
  , hover = Nothing
  }


{-| -}
dot : Svg msg -> Float -> Float -> DataPoint msg
dot view x y =
  { view = Just view
  , glitter = noGlitter
  , x = x
  , y = y
  }



-- SERIES


{-| -}
type alias Series data msg =
  { axis : Axis
  , interpolation : Interpolation
  , toDataPoints : data -> List (DataPoint msg)
  }


{-| [Interpolation](https://en.wikipedia.org/wiki/Interpolation) is basically the line that goes
  between your data points.
    - None: No line (this is a scatter plot).
    - Linear: A stright line.
    - Curvy: A nice looking curvy line.
    - Monotone: A nice looking curvy line which doesn't extend outside the y values of the two
    points involved (What? Here's an [illustration](https://en.wikipedia.org/wiki/Monotone_cubic_interpolation#/media/File:MonotCubInt.png)).

  All but `None` take a color which determined whether it draws the area below or not +
  list of attributes which you can use for styling of your interpolation.
-}
type Interpolation
  = None
  | Linear (Maybe String) (List (Attribute Never))
  | Curvy (Maybe String) (List (Attribute Never))
  | Monotone (Maybe String) (List (Attribute Never))


{-| -}
dots : (data -> List (DataPoint msg)) -> Series data msg
dots toDataPoints =
  { axis = normalAxis
  , interpolation = None
  , toDataPoints = toDataPoints
  }


{-| -}
line : (data -> List (DataPoint msg)) -> Series data msg
line toDataPoints =
  { axis = normalAxis
  , interpolation = Linear Nothing [ stroke pinkStroke ]
  , toDataPoints = toDataPoints
  }


{-| -}
area : (data -> List (DataPoint msg)) -> Series data msg
area toDataPoints =
  { axis = normalAxis
  , interpolation = Linear (Just pinkFill) [ stroke pinkStroke ]
  , toDataPoints = toDataPoints
  }


{-| -}
custom : Axis -> Interpolation -> (data -> List (DataPoint msg)) -> Series data msg
custom axis interpolation toDataPoints =
  { axis = axis
  , interpolation = interpolation
  , toDataPoints = toDataPoints
  }



-- VIEW


defaultPlotCustomizations : PlotCustomizations msg
defaultPlotCustomizations =
  { attributes = []
  , id = "elm-plot"
  , horizontalAxis = normalAxis
  , grid =
      { horizontal = emptyGrid
      , vertical = emptyGrid
      }
  , margin =
      { top = 20
      , right = 40
      , bottom = 20
      , left = 40
      }
  , width = 1000
  , height = 720
  , toDomainLowest = identity
  , toDomainHighest = identity
  , toRangeLowest = identity
  , toRangeHighest = identity
  }


{-| -}
view : List (Series data msg) -> data -> Html msg
view =
  viewCustom defaultPlotCustomizations


{-| -}
viewCustom : PlotCustomizations msg -> List (Series data msg) -> data -> Html msg
viewCustom customizations series data =
  let
    dataPoints =
      List.map (\{ toDataPoints } -> toDataPoints data) series

    summary =
      toPlotSummary customizations (List.concat dataPoints)

    horizontalGlitterTicks =
        List.filterMap (.glitter >> .xTick) (List.concat dataPoints)

    verticalGlitterTicks =
        List.map (List.filterMap (.glitter >> .yTick)) dataPoints
  in
    Plot.view
      summary
      { customizations = customizations
      , moreHorizontalTicks = horizontalGlitterTicks
      , verticalAxes = List.map2 (.axis >> (,)) series verticalGlitterTicks
      , content = g [ class "elm-plot__series" ] (List.map2 (viewSeries summary) series dataPoints)
      , glitter = List.concatMap (viewGlitter summary) (List.concat dataPoints)
      }



-- SERIES VIEWS


viewSeries : PlotSummary -> Series data msg -> List (DataPoint msg) -> Svg msg
viewSeries plotSummary { axis, interpolation } dataPoints =
  g []
    [ Svg.map never (viewPath plotSummary interpolation dataPoints)
    , viewDataPoints plotSummary dataPoints
    ]


viewPath : PlotSummary -> Interpolation -> List (DataPoint msg) -> Svg Never
viewPath plotSummary interpolation dataPoints =
  case interpolation of
    None ->
      path [] []

    Linear fill attributes ->
      viewInterpolation plotSummary linear linearArea fill attributes dataPoints

    Curvy fill attributes ->
      -- TODO: Should be curvy
      viewInterpolation plotSummary monotoneX monotoneXArea fill attributes dataPoints

    Monotone fill attributes ->
      viewInterpolation plotSummary monotoneX monotoneXArea fill attributes dataPoints


viewInterpolation :
  PlotSummary
  -> (PlotSummary -> List Draw.Point -> List Draw.Command)
  -> (PlotSummary -> List Draw.Point -> List Draw.Command)
  -> Maybe String
  -> List (Attribute Never)
  -> List (DataPoint msg)
  -> Svg Never
viewInterpolation plotSummary toLine toArea area attributes dataPoints =
  case area of
    Nothing ->
      draw
        (fill transparent :: stroke pinkStroke :: attributes)
        (toLine plotSummary (points dataPoints))

    Just color ->
      draw
        (fill color :: fill pinkFill :: stroke pinkStroke :: attributes)
        (toArea plotSummary (points dataPoints))



-- DOT VIEWS


viewDataPoints : PlotSummary -> List (DataPoint msg) -> Svg msg
viewDataPoints plotSummary dataPoints =
  g [] (List.map (viewDataPoint plotSummary) dataPoints)


viewDataPoint : PlotSummary -> DataPoint msg -> Svg msg
viewDataPoint plotSummary { x, y, view } =
  case view of
    Nothing ->
      text ""

    Just svgView ->
      g [ place plotSummary { x = x, y = y } 0 0 ] [ svgView ]


viewSquare : Float -> Float -> String -> Svg msg
viewSquare width height color =
  rect
    [ Attributes.width (toString width)
    , Attributes.height (toString height)
    , Attributes.x (toString (-width / 2))
    , Attributes.y (toString (-height / 2))
    , stroke "transparent"
    , fill color
    ]
    []


{-| -}
viewCircle : Float -> String -> Svg msg
viewCircle radius color =
  Svg.circle
    [ r (toString radius)
    , stroke "transparent"
    , fill color
    ]
    []



-- VIEW GLITTER


viewGlitter : PlotSummary -> DataPoint msg -> List (Svg Never)
viewGlitter summary { glitter, x, y } =
  [ case glitter.xLine of
      Nothing ->
        text ""

      Just this ->
        viewAxisLine summary (\y -> { x = x, y = y }) (Just <| this summary.y)
  , case glitter.yLine of
      Nothing ->
        text ""

      Just this ->
        viewAxisLine summary (\x -> { x = x, y = y }) (Just <| this summary.x)
  ]



-- DRAW HELP


points : List (DataPoint msg) -> List Draw.Point
points =
  List.map point


point : DataPoint msg -> Draw.Point
point { x, y } =
  Point x y
