module Svg.Plot
    exposing
        ( view
        , dots
        , line
        , area
        , custom
        , DataPoint
        , Series
        , square
        , circle
        , diamond
        , viewCircle
        , triangle
        , Interpolation(..)
        , rangeFrameGlitter
        , axisAtMin
        )

{-|
# Plot

@docs view, dots, line, area, custom, DataPoint, Series, square, circle, diamond, triangle, Interpolation, rangeFrameGlitter, viewCircle, axisAtMin
-}

import Html exposing (Html)
import Svg exposing (Svg, Attribute, svg, text_, tspan, text, g, path, rect)
import Svg.Attributes as Attributes exposing (stroke, fill, class, r, x2, y2, style)
import Svg.Draw as Draw exposing (..)
import Svg.Colors exposing (..)
import Round
import Regex


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
custom =
  Series


{-| -}
type alias PlotCustomizations msg =
  { attributes : List (Attribute msg)
  , horizontalAxis : Axis
  , grid :
    { horizontal : Grid
    , vertical : Grid
    }
  , id : String
  , width : Int
  , height : Int
  , margin :
    { top : Int
    , right : Int
    , bottom : Int
    , left : Int
    }
  , bounds : Bounds
  }


type alias Bounds =
  { toDomainLowest : Float -> Float
  , toDomainHighest : Float -> Float
  , toRangeLowest : Float -> Float
  , toRangeHighest : Float -> Float
  }


{-| -}
defaultBounds : Bounds
defaultBounds =
  { toDomainLowest = identity
  , toDomainHighest = identity
  , toRangeLowest = identity
  , toRangeHighest = identity
  }


{-| -}
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
  , bounds = defaultBounds
  }


-- GRID


{-| -}
type Grid
  = Grid (AxisSummary -> GridCustomizations)
  | YeahGridsAreTotallyLame


{-| -}
type alias GridCustomizations =
  { attributes : List (Attribute Never)
  , positions : List Float
  }


grid : (AxisSummary -> GridCustomizations) -> Grid
grid =
  Grid


{-| -}
decentGrid : Grid
decentGrid =
  grid <| \summary ->
    { attributes = [ stroke grey ]
    , positions = decentPositions summary
    }


{-| -}
emptyGrid : Grid
emptyGrid =
  YeahGridsAreTotallyLame



-- AXIS


{-| -}
type Axis
  = Axis (AxisSummary -> AxisCustomizations)
  | SometimesYouDoNotHaveAnAxis


{-| -}
type alias AxisCustomizations =
  { position : Position
  , axisLine : Maybe LineCustomizations
  , ticks : List TickCustomizations
  , labels : List LabelCustomizations
  , whatever : List WhateverCustomizations
  }


{-| -}
type Position
  = Min
  | Max
  | ClosestToZero
  | At Float


{-| -}
type alias LineCustomizations =
  { attributes : List (Attribute Never)
  , start : Float
  , end : Float
  }


{-| -}
type alias TickCustomizations =
  { attributes : List (Attribute Never)
  , length : Float
  , position : Float
  }


{-| -}
type alias LabelCustomizations =
  { view : String -> Svg Never
  , format : Float -> String
  , position : Float
  }


{-| -}
type alias WhateverCustomizations =
  { position : Float
  , view : Svg Never
  }


{-| -}
sometimesYouDoNotHaveAnAxis : Axis
sometimesYouDoNotHaveAnAxis =
  SometimesYouDoNotHaveAnAxis


{-| -}
axis : (AxisSummary -> AxisCustomizations) -> Axis
axis =
  Axis


{-| -}
normalAxis : Axis
normalAxis =
  Axis <| \summary ->
    { position = ClosestToZero
    , axisLine = Just (simpleLine [ stroke darkGrey ] summary)
    , ticks = List.map (simpleTick [ stroke darkGrey ] 5) (decentPositions summary)
    , labels = List.map (simpleLabel [] toString) (decentPositions summary)
    , whatever = []
    }


{-| -}
axisAtMin : Axis
axisAtMin =
  axis <| \summary ->
    { position = Min
    , axisLine = Just (simpleLine [ stroke darkGrey ] summary)
    , ticks = List.map (simpleTick [ stroke darkGrey ] 5) (decentPositions summary)
    , labels = List.map (simpleLabel [] toString) (decentPositions summary)
    , whatever = []
    }


{-| -}
axisAtMax : Axis
axisAtMax =
  axis <| \summary ->
    { position = Min
    , axisLine = Just (simpleLine [ stroke darkGrey ] summary)
    , ticks = List.map (simpleTick [ stroke darkGrey ] 5) (decentPositions summary)
    , labels = List.map (simpleLabel [] toString) (decentPositions summary)
    , whatever = []
    }


{-| -}
axisRangeFrame : Axis
axisRangeFrame =
  axis <| \summary ->
    { position = ClosestToZero
    , axisLine = Just (LineCustomizations [ stroke darkGrey ] summary.dataMin summary.dataMax)
    , ticks = List.map (simpleTick [ stroke darkGrey ] 5) (decentPositions summary)
    , labels = List.map (simpleLabel [] toString) (decentPositions summary)
    , whatever = []
    }


{-| -}
simpleLine : List (Attribute Never) -> AxisSummary -> LineCustomizations
simpleLine attributes summary =
  { attributes = attributes
  , start = summary.min
  , end = summary.max
  }


{-| -}
simpleTick : List (Attribute Never) -> Float -> Float -> TickCustomizations
simpleTick attributes length position =
  { position = position
  , length = length
  , attributes = attributes
  }


{-| -}
simpleLabel : List (Attribute Never) -> (Float -> String) -> Float -> LabelCustomizations
simpleLabel attributes format position =
  { position = position
  , format = format
  , view = viewLabel attributes
  }


viewLabel : List (Svg.Attribute msg) -> String -> Svg msg
viewLabel attributes string =
    text_ attributes [ tspan [] [ text string ] ]



-- VIEW


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

    viewHorizontalAxes =
      List.concat dataPoints
        |> List.filterMap (.glitter >> .xTick)
        |> viewHorizontalAxis summary customizations.horizontalAxis

    viewVerticalAxes =
      dataPoints
        |> List.map (List.filterMap (.glitter >> .yTick))
        |> List.map2 (.axis >> viewVerticalAxis summary) series
        |> List.filterMap identity
        |> g [ class "elm-plot__vertical-axes" ]
        |> Just

    viewSeries =
      List.map2 (viewASeries summary) series dataPoints
        |> g [ class "elm-plot__series" ]
        |> Just

    viewGlitter =
      List.concat dataPoints
        |> List.concatMap (viewGlitterLines summary)
        |> g [ class "elm-plot__glitter" ]
        |> Svg.map never
        |> Just

    attributes =
      customizations.attributes ++
        [ Attributes.width (toString customizations.width)
        , Attributes.height (toString customizations.height)
        , Attributes.id customizations.id
        ]

    children =
      List.filterMap identity
        [ viewHorizontalGrid summary customizations.grid.horizontal
        , viewVerticalGrid summary customizations.grid.vertical
        , viewSeries
        , viewHorizontalAxes
        , viewVerticalAxes
        , viewGlitter
        ]
  in
    svg attributes children



-- INSIDE


{-| -}
toPlotSummary : PlotCustomizations msg ->  List { a | x : Float, y : Float } -> PlotSummary
toPlotSummary customizations points =
  let
    foldAxis summary v =
      { min = min summary.min v
      , max = max summary.max v
      , all = v :: summary.all
      }

    foldPlot { x, y } result =
      case result of
        Nothing ->
          Just
            { x = { min = x, max = x, all = [ x ] }
            , y = { min = y, max = y, all = [ y ] }
            }

        Just summary ->
          Just
            { x = foldAxis summary.x x
            , y = foldAxis summary.y y
            }

    defaultPlotSummary =
      { x = { min = 0.0, max = 1.0, all = [] }
      , y = { min = 0.0, max = 1.0, all = [] }
      }

    plotSummary =
      Maybe.withDefault defaultPlotSummary (List.foldl foldPlot Nothing points)
  in
    { x =
      { min = customizations.bounds.toRangeLowest (plotSummary.x.min)
      , max = customizations.bounds.toRangeHighest (plotSummary.x.max)
      , dataMin = plotSummary.x.min
      , dataMax = plotSummary.x.max
      , length = toFloat customizations.width
      , marginLower = toFloat customizations.margin.left
      , marginUpper = toFloat customizations.margin.right
      }
    , y =
      { min = customizations.bounds.toDomainLowest (plotSummary.y.min)
      , max = customizations.bounds.toDomainHighest (plotSummary.y.max)
      , dataMin = plotSummary.y.min
      , dataMax = plotSummary.y.max
      , length = toFloat customizations.height
      , marginLower = toFloat customizations.margin.bottom
      , marginUpper = toFloat customizations.margin.top
      }
    }



-- VIEW HORIZONTAL GRID


{-| -}
viewHorizontalGrid : PlotSummary -> Grid -> Maybe (Svg msg)
viewHorizontalGrid summary grid =
  case grid of
    Grid toCustomizations ->
      Just (Svg.map never (viewActualHorizontalGrid summary (toCustomizations summary.x)))

    YeahGridsAreTotallyLame ->
      Nothing


viewActualHorizontalGrid : PlotSummary -> GridCustomizations -> Svg Never
viewActualHorizontalGrid summary { attributes, positions } =
  let
    viewGridLine x =
      draw attributes (linear summary [ { x = x, y = summary.y.min }, { x = x, y = summary.y.max } ])
  in
    g [ class "elm-plot__horizontal-grid" ] (List.map viewGridLine positions)



-- VIEW VERTICAL GRID


{-| -}
viewVerticalGrid : PlotSummary -> Grid -> Maybe (Svg msg)
viewVerticalGrid summary grid =
  case grid of
    Grid toCustomizations ->
      Just (Svg.map never (viewActualVerticalGrid summary (toCustomizations summary.y)))

    YeahGridsAreTotallyLame ->
      Nothing


viewActualVerticalGrid : PlotSummary -> GridCustomizations -> Svg Never
viewActualVerticalGrid summary { attributes, positions } =
  let
    viewGridLine y =
      draw attributes (linear summary [ { x = summary.x.min, y = y }, { x = summary.x.max, y = y } ])
  in
    g [ class "elm-plot__vertical-grid" ] (List.map viewGridLine positions)



-- SERIES VIEWS


viewASeries : PlotSummary -> Series data msg -> List (DataPoint msg) -> Svg msg
viewASeries plotSummary { axis, interpolation } dataPoints =
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
  -> (PlotSummary -> List Point -> List Command)
  -> (PlotSummary -> List Point -> List Command)
  -> Maybe String
  -> List (Attribute Never)
  -> List (DataPoint msg)
  -> Svg Never
viewInterpolation plotSummary toLine toArea area attributes dataPoints =
  case area of
    Nothing ->
      draw (fill transparent :: stroke pinkStroke :: attributes)
        (toLine plotSummary (points dataPoints))

    Just color ->
      draw (fill color :: fill pinkFill :: stroke pinkStroke :: attributes)
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



-- VIEW HORIZONTAL AXIS


{-| -}
viewHorizontalAxis : PlotSummary -> Axis -> List TickCustomizations -> Maybe (Svg msg)
viewHorizontalAxis summary axis moreTicks =
  case axis of
    Axis toCustomizations ->
      Just (Svg.map never (viewActualHorizontalAxis summary (toCustomizations summary.x) moreTicks))

    SometimesYouDoNotHaveAnAxis ->
      Nothing


viewActualHorizontalAxis : PlotSummary -> AxisCustomizations -> List TickCustomizations -> Svg Never
viewActualHorizontalAxis summary { position, axisLine, ticks, labels, whatever } glitterTicks =
    let
      at x =
        { x = x, y = resolvePosition summary.y position }

      viewTickLine { attributes, length, position } =
        g [ place summary (at position) 0 0 ] [ viewTickInner attributes 0 length ]

      viewLabel { format, position, view } =
        g [ place summary (at position) 0 20, style "text-anchor: middle;" ]
          [ view (format position) ]

      viewWhatever { position, view } =
        g [ place summary (at position) 0 0 ] [ view ]
    in
      g [ class "elm-plot__horizontal-axis" ]
        [ viewAxisLine summary at axisLine
        , g [ class "elm-plot__ticks" ] (List.map viewTickLine (ticks ++ glitterTicks))
        , g [ class "elm-plot__labels" ] (List.map viewLabel labels)
        , g [ class "elm-plot__whatever" ] (List.map viewWhatever whatever)
        ]



-- VIEW VERTICAL AXIS


{-| -}
viewVerticalAxis : PlotSummary -> Axis -> List TickCustomizations -> Maybe (Svg msg)
viewVerticalAxis summary axis moreTicks =
  case axis of
    Axis toCustomizations ->
      Just (Svg.map never (viewActualVerticalAxis summary (toCustomizations summary.y) moreTicks))

    SometimesYouDoNotHaveAnAxis ->
      Nothing


viewActualVerticalAxis : PlotSummary -> AxisCustomizations -> List TickCustomizations -> Svg Never
viewActualVerticalAxis summary { position, axisLine, ticks, labels, whatever } glitterTicks =
    let
      at y =
        { x = resolvePosition summary.x position, y = y }

      viewTickLine { attributes, length, position } =
        g [ place summary (at position) 0 0 ]
          [ viewTickInner attributes -length 0 ]

      viewLabel { format, position, view } =
        g [ place summary (at position) -10 5, style "text-anchor: end;" ]
          [ view (format position) ]

      viewWhatever { position, view } =
        g [ place summary (at position) 0 0 ] [ view ]
    in
      g [ class "elm-plot__vertical-axis" ]
        [ viewAxisLine summary at axisLine
        , g [ class "elm-plot__ticks" ] (List.map viewTickLine (ticks ++ glitterTicks))
        , g [ class "elm-plot__labels" ] (List.map viewLabel labels)
        , g [ class "elm-plot__whatever" ] (List.map viewWhatever whatever)
        ]



-- AXIS HELP


{-| -}
viewAxisLine : PlotSummary -> (Float -> Point) -> Maybe LineCustomizations -> Svg Never
viewAxisLine summary at axisLine =
  case axisLine of
    Just { attributes, start, end } ->
      draw attributes (linear summary [ at start, at end ])

    Nothing ->
      text "<!- Your imaginary axis line ->"


viewTickInner : List (Attribute msg) -> Float -> Float -> Svg msg
viewTickInner attributes width height =
  Svg.line (x2 (toString width) :: y2 (toString height) :: attributes) []



-- VIEW GLITTER


viewGlitterLines : PlotSummary -> DataPoint msg -> List (Svg Never)
viewGlitterLines summary { glitter, x, y } =
  [ viewAxisLine summary (\y -> { x = x, y = y }) (Maybe.map (\toLine -> toLine summary.y) glitter.xLine)
  , viewAxisLine summary (\x -> { x = x, y = y }) (Maybe.map (\toLine -> toLine summary.x) glitter.yLine)
  ]



-- HELPERS


resolvePosition : AxisSummary -> Position -> Float
resolvePosition { min, max } position =
  case position of
    Min ->
      min

    Max ->
      max

    ClosestToZero ->
      clamp min max 0

    At v ->
      v



-- TICK HELP


{-| -}
remove : Float -> List Float -> List Float
remove banned values =
  List.filter (\v -> v /= banned) values


{-| -}
decentPositions : AxisSummary -> List Float
decentPositions summary =
  if summary.length > 600 then
    interval 0 (niceInterval summary.min summary.max 10) summary
  else
    interval 0 (niceInterval summary.min summary.max 5) summary


interval : Float -> Float -> AxisSummary -> List Float
interval offset delta { min, max } =
  let
      range = abs (min - max)
      value = firstValue delta min + offset
      indexes = List.range 0 <| count delta min range value
  in
      List.map (tickPosition delta value) indexes


tickPosition : Float -> Float -> Int -> Float
tickPosition delta firstValue index =
    firstValue
        + (toFloat index)
        * delta
        |> Round.round (deltaPrecision delta)
        |> String.toFloat
        |> Result.withDefault 0


deltaPrecision : Float -> Int
deltaPrecision delta =
    delta
        |> toString
        |> Regex.find (Regex.AtMost 1) (Regex.regex "\\.[0-9]*")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
        |> String.length
        |> (-) 1
        |> min 0
        |> abs


firstValue : Float -> Float -> Float
firstValue delta lowest =
    ceilToNearest delta lowest


ceilToNearest : Float -> Float -> Float
ceilToNearest precision value =
    toFloat (ceiling (value / precision)) * precision


count : Float -> Float -> Float -> Float -> Int
count delta lowest range firstValue =
    floor ((range - (abs lowest - abs firstValue)) / delta)


niceInterval : Float -> Float -> Int -> Float
niceInterval min max total =
    let
      range = abs (max - min)
      -- calculate an initial guess at step size
      delta0 = range / (toFloat total)
      -- get the magnitude of the step size
      mag = floor (logBase 10 delta0)
      magPow = toFloat (10 ^ mag)
      -- calculate most significant digit of the new step size
      magMsd = round (delta0 / magPow)
      -- promote the MSD to either 1, 2, or 5
      magMsdFinal =
        if magMsd > 5 then 10
        else if magMsd > 2 then 5
        else if magMsd > 1 then 1
        else magMsd
    in
      toFloat magMsdFinal * magPow


-- DRAW HELP


points : List (DataPoint msg) -> List Point
points =
  List.map point


point : DataPoint msg -> Point
point { x, y } =
  Point x y
