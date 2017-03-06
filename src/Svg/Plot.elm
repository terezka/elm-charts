module Svg.Plot exposing (view, dots, line, area, custom, grid, DataPoint, Series, square, circle, diamond, triangle, normalAxis, Interpolation(..))

{-|
# Plot

@docs view, dots, line, area, custom, DataPoint, Series, square, circle, diamond, triangle, normalAxis, Interpolation, grid
-}

import Html exposing (Html)
import Svg exposing (Svg, Attribute, svg, text_, tspan, text, g, path, rect)
import Svg.Attributes as Attributes exposing (stroke, fill, class, r, x2, y2)
import Svg.Draw as Draw exposing (PlotSummary, AxisSummary, Point, draw, linear, linearArea, monotoneX, monotoneXArea)
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
  dot (viewSquare 5 5 pinkStroke)


{-| -}
diamond : Float -> Float -> DataPoint msg
diamond =
  dot (viewSquare 5 5 pinkStroke)


{-| -}
triangle : Float -> Float -> DataPoint msg
triangle =
  dot (viewSquare 5 5 pinkStroke)


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


noGlitter : Glitter msg
noGlitter =
  { xLine = Nothing
  , yLine = Nothing
  , xTick = Nothing
  , yTick = Nothing
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



-- CUSTOM SERIES


{-| -}
custom : Axis -> Interpolation -> (data -> List (DataPoint msg)) -> Series data msg
custom axis interpolation toDataPoints =
  { axis = axis
  , interpolation = interpolation
  , toDataPoints = toDataPoints
  }



-- AXIS


type Axis
  = Axis (AxisSummary -> AxisCustomizations)
  | SometimesYouDoNotHaveAnAxis


type alias AxisCustomizations =
  { position : Position
  , axisLine : LineCustomizations
  , ticks : List TickCustomizations
  , labels : List LabelCustomizations
  , whatever : List WhateverCustomizations
  }


type Position
  = Min
  | Max
  | At Float


type alias LineCustomizations =
  { attributes : List (Attribute Never)
  , start : Float
  , end : Float
  }


type alias TickCustomizations =
  { attributes : List (Attribute Never)
  , length : Float
  , position : Float
  }


type alias LabelCustomizations =
  { view : String -> Svg Never
  , format : Float -> String
  , position : Float
  }


type alias WhateverCustomizations =
  { position : Float, view : Svg Never }



{-| -}
normalAxis : Axis
normalAxis =
  Axis <|
    \summary ->
      { position = At 0
      , axisLine =
          { attributes = [ stroke grey ]
          , start = summary.min
          , end = summary.max
          }
      , ticks = List.map (simpleTick [ stroke grey ] 5) (decentPositions summary)
      , labels = List.map (simpleLabel [] toString) (decentPositions summary)
      , whatever = []
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



-- VIEW


type Grid
  = Grid (AxisSummary -> List Float -> GridCustomizations)
  | YeahGridsAreTotallyNotWorthIt


type alias GridCustomizations =
  { attributes : List (Attribute Never)
  , positions : List Float
  }


{-| -}
grid : (AxisSummary -> List Float -> GridCustomizations) -> Grid
grid =
  Grid


decentGrid : Grid
decentGrid =
  grid <|
    \summary tickPositions ->
      { attributes = [ stroke grey ]
      , positions = decentPositions summary
      }


gridThatMirrorsTicks : List (Attribute Never) -> Grid
gridThatMirrorsTicks attributes =
  grid <|
    \summary tickPositions ->
      { attributes = attributes
      , positions = tickPositions
      }


emptyGrid : Grid
emptyGrid =
  YeahGridsAreTotallyNotWorthIt


type alias PlotCustomizations msg =
  { attributes : List (Attribute msg)
  , horizontalAxis : Axis
  , grid :
    { horizontal : Grid
    , vertical : Grid
    }
  , id : String
  , margin :
    { top : Int
    , right : Int
    , bottom : Int
    , left : Int
    }
  , width : Int
  , height : Int
  , toDomainLowest : Float -> Float
  , toDomainHighest : Float -> Float
  , toRangeLowest : Float -> Float
  , toRangeHighest : Float -> Float
  }


defaultPlotCustomizations : PlotCustomizations msg
defaultPlotCustomizations =
  { attributes = []
  , id = "elm-plot"
  , horizontalAxis = normalAxis
  , grid =
      { horizontal = decentGrid
      , vertical = decentGrid
      }
  , margin =
      { top = 20
      , right = 20
      , bottom = 20
      , left = 20
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

    plotSummary =
      toPlotSummary customizations (List.concat dataPoints)
  in
    svg
      [ Attributes.width (toString customizations.width)
      , Attributes.height (toString customizations.height)
      ]
      [ Svg.map never <| ifActualGrid (viewHorizontalGrid plotSummary) customizations.grid.horizontal
      , Svg.map never <| ifActualGrid (viewVerticalGrid plotSummary) customizations.grid.vertical
      , g [ class "elm-plot__series" ] (List.map2 (viewSeries plotSummary) series dataPoints)
      , Svg.map never <| ifAxis (viewHorizontalAxis plotSummary) customizations.horizontalAxis
      , Svg.map never <| g [ class "elm-plot__vertical-axes" ] (List.map (.axis >> ifAxis (viewVerticalAxis plotSummary)) series)
      , Svg.map never <| g [ class "elm-plot__glitter" ] (List.map (viewGlitter plotSummary) (List.concat dataPoints))
      ]



-- INSIDE


toPlotSummary : PlotCustomizations msg -> List (DataPoint msg) -> PlotSummary
toPlotSummary customizations dataPoints =
  let
    foldAxis summary v =
      { min = min summary.min v
      , max = max summary.max v
      }

    foldPlot { x, y } result =
      case result of
        Nothing ->
          Just
            { x = { min = x, max = x }
            , y = { min = y, max = y }
            }

        Just summary ->
          Just
            { x = foldAxis summary.x x
            , y = foldAxis summary.y y
            }

    defaultPlotSummary =
      { x = { min = 0.0, max = 1.0 }
      , y = { min = 0.0, max = 1.0 }
      }

    plotSummary =
      Maybe.withDefault defaultPlotSummary (List.foldl foldPlot Nothing dataPoints)
  in
    { x =
      { min = plotSummary.x.min
      , max = plotSummary.x.max
      , length = toFloat customizations.width
      , marginLower = toFloat customizations.margin.left
      , marginUpper = toFloat customizations.margin.right
      }
    , y =
      { min = plotSummary.y.min
      , max = plotSummary.y.max
      , length = toFloat customizations.height
      , marginLower = toFloat customizations.margin.bottom
      , marginUpper = toFloat customizations.margin.top
      }
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
        (toLine plotSummary (toDrawPoints dataPoints))

    Just color ->
      draw
        (fill color :: fill pinkFill :: stroke pinkStroke :: attributes)
        (toArea plotSummary (toDrawPoints dataPoints))



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
      Draw.position plotSummary { x = x, y = y } [ svgView ]


viewSquare : Float -> Float -> String -> Svg msg
viewSquare width height color =
  rect
    [ Attributes.width (toString width)
    , Attributes.height (toString height)
    , stroke "transparent"
    , fill color
    ]
    []


viewCircle : Float -> String -> Svg msg
viewCircle radius color =
  Svg.circle
    [ r (toString radius)
    , stroke "transparent"
    , fill color
    ]
    []


viewLabel : List (Svg.Attribute msg) -> String -> Svg msg
viewLabel attributes string =
    text_ attributes [ tspan [] [ text string ] ]



-- GRID VIEW


ifActualGrid : ((AxisSummary -> List Float -> GridCustomizations) -> Svg Never) -> Grid -> Svg Never
ifActualGrid viewGrid grid =
  case grid of
    Grid toCustomizations ->
      viewGrid toCustomizations

    YeahGridsAreTotallyNotWorthIt ->
      text "" -- no


viewHorizontalGrid : PlotSummary -> (AxisSummary -> List Float -> GridCustomizations) -> Svg Never
viewHorizontalGrid summary toCustomizations =
  let
    { attributes, positions } =
      toCustomizations summary.x []

    viewGridLine x =
      draw attributes (linear summary [ { x = x, y = summary.y.min }, { x = x, y = summary.y.max } ])
  in
    g [ class "elm-plot__horizontal-grid" ] (List.map viewGridLine positions)


viewVerticalGrid : PlotSummary -> (AxisSummary -> List Float -> GridCustomizations) -> Svg Never
viewVerticalGrid summary toCustomizations =
  let
    { attributes, positions } =
      toCustomizations summary.y []

    viewGridLine y =
      draw attributes (linear summary [ { x = summary.x.min, y = y }, { x = summary.x.max, y = y } ])

  in
    g [ class "elm-plot__vertical-grid" ] (List.map viewGridLine positions)




-- AXIS VIEWS


ifAxis : ((AxisSummary -> AxisCustomizations) -> Svg Never) -> Axis -> Svg Never
ifAxis viewAxis axis =
  case axis of
    Axis toCustomizations ->
      viewAxis toCustomizations

    SometimesYouDoNotHaveAnAxis ->
      text "" -- no


viewHorizontalAxis : PlotSummary -> (AxisSummary -> AxisCustomizations) -> Svg Never
viewHorizontalAxis summary toCustomizations =
    let
      { position, axisLine, ticks, labels, whatever } =
        toCustomizations summary.x

      toPoint x =
        { x = x, y = resolvePosition summary.y position }

      viewTickLine { attributes, length, position } =
        Draw.position summary (toPoint position) [ viewTickInner attributes 0 length ]

      viewLabel { format, position, view } =
        Draw.position summary (toPoint position) [ view (format position) ]

      viewWhatever { position, view } =
        Draw.position summary (toPoint position) [ view ]
    in
      g [ class "elm-plot__horizontal-axis" ] <|
        viewLine summary toPoint axisLine
        :: List.map viewTickLine ticks
        ++ List.map viewLabel labels
        ++ List.map viewWhatever whatever


viewVerticalAxis : PlotSummary -> (AxisSummary -> AxisCustomizations) -> Svg Never
viewVerticalAxis summary toCustomizations =
    let
      { position, axisLine, ticks, labels, whatever } =
        toCustomizations summary.y

      toPoint y =
        { x = resolvePosition summary.x position, y = y }

      viewTickLine { attributes, length, position } =
        Draw.position summary (toPoint position) [ viewTickInner attributes -length 0 ]

      viewLabel { format, position, view } =
        Draw.position summary (toPoint position) [ view (format position) ]

      viewWhatever { position, view } =
        Draw.position summary (toPoint position) [ view ]
    in
      g [ class "elm-plot__vertical-axis" ] <|
        viewLine summary toPoint axisLine
        :: List.map viewTickLine ticks
        ++ List.map viewLabel labels
        ++ List.map viewWhatever whatever


viewLine : PlotSummary -> (Float -> Draw.Point) -> LineCustomizations -> Svg Never
viewLine summary toPoint { attributes, start, end } =
  draw attributes (linear summary [ toPoint start, toPoint end ])


viewTickInner : List (Attribute msg) -> Float -> Float -> Svg msg
viewTickInner attributes width height =
  Svg.line (x2 (toString width) :: y2 (toString height) :: attributes) []


resolvePosition : AxisSummary -> Position -> Float
resolvePosition { min, max } position =
  case position of
    Min ->
      min

    Max ->
      max

    At v ->
      v



-- VIEW GLITTER


viewGlitter : PlotSummary -> DataPoint msg -> Svg Never
viewGlitter _ _ =
  text ""


-- DRAW HELP


toDrawPoints : List (DataPoint msg) -> List Draw.Point
toDrawPoints =
  List.map toDrawPoint


toDrawPoint : DataPoint msg -> Draw.Point
toDrawPoint { x, y } =
  Point x y


-- TICK HELP


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



-- COLORS


pinkFill : String
pinkFill =
    "#fdb9e7"


pinkStroke : String
pinkStroke =
    "#ff9edf"


transparent : String
transparent =
  "transparent"


grey : String
grey =
  "#a3a3a3"
