module Svg.Plot
    exposing
        ( view
        , viewCustom
        , defaultPlotCustomizations
        , dots
        , line
        , area
        , custom
        , DataPoint
        , dotWithGlitter
        , dot
        , Series
        , square
        , circle
        , diamond
        , triangle
        , emptyDot
        , Interpolation(..)
        , rangeFrameGlitter
        , emptyAxis
        , normalAxis
        , axisAtMin
        , viewCircle
        , viewSquare
        , viewDiamond
        )

{-|
# Plot

@docs view, viewCustom, defaultPlotCustomizations, dots, line, area, custom, DataPoint, normalAxis, emptyDot
@docs dotWithGlitter, dot, Series, square, circle, diamond, triangle, Interpolation, rangeFrameGlitter, axisAtMin, emptyAxis

## Small helper views
@docs viewCircle, viewSquare, viewDiamond
-}

import Html exposing (Html, div)
import Html.Events
import Svg exposing (Svg, Attribute, svg, text_, tspan, text, g, path, rect)
import Svg.Attributes as Attributes exposing (stroke, fill, class, r, x2, y2, style)
import Svg.Draw as Draw exposing (..)
import Svg.Colors exposing (..)
import Json.Decode as Json
import Round
import Regex
import DOM


-- DATA POINTS


{-| The classic circle never goes out of style.
-}
circle : Float -> Float -> DataPoint msg
circle =
  dot (viewCircle 5 pinkStroke)


{-| A square.
-}
square : Float -> Float -> DataPoint msg
square =
  dot (viewSquare 10 pinkStroke)


{-| If you want to impress a girl with your classy plots.
-}
diamond : Float -> Float -> DataPoint msg
diamond =
  dot (viewDiamond 10 10 pinkStroke)


{-| A nice triangle for fancy academic looking plots.
-}
triangle : Float -> Float -> DataPoint msg
triangle =
  dot (viewSquare 10 pinkStroke)


{-| If you don't want a dot at all.
-}
emptyDot : Float -> Float -> DataPoint msg
emptyDot =
  dot (text "")


{-| The data point customizations. You can:
  - Add the x and y of your data point!
  - Change the view of the dot, if your tired of squares and circles.
  - Add glitter! ✨ Glitter is extra cool stuff for your dot. It can add
    ticks at that exact point, add lines for emphasis or a small label or
    whatever. See the `Glitter` type.
-}
type alias DataPoint msg =
  { view : Maybe (Svg msg)
  , glitter : Glitter
  , x : Float
  , y : Float
  }


{-| All this glitter! You can:
  - Add lines (nice if you're hovering the dot!).
  - Add ticks which will show up the your axis.
  - Add labels or whatever else you can come up with.
-}
type alias Glitter =
  { xLine : Maybe (AxisSummary -> LineCustomizations)
  , yLine : Maybe (AxisSummary -> LineCustomizations)
  , xTick : Maybe TickCustomizations
  , yTick : Maybe TickCustomizations
  , whatever : List WhateverCustomizations
  }


{-| Makes a dot given a view and a x and an y.
-}
dot : Svg msg -> Float -> Float -> DataPoint msg
dot view x y =
  { view = Just view
  , glitter = noGlitter
  , x = x
  , y = y
  }


{-| Makes a dot given a view and a x and an y.
-}
dotWithGlitter : Svg msg -> Float -> Float -> DataPoint msg
dotWithGlitter view x y =
  { view = Just view
  , glitter = hoverGlitter x y
  , x = x
  , y = y
  }


{-| No glitter! No fun!
-}
noGlitter : Glitter
noGlitter =
  { xLine = Nothing
  , yLine = Nothing
  , xTick = Nothing
  , yTick = Nothing
  , whatever = []
  }


{-| This is glitter for a special plot in Tuftes book, called the rangeframe plot.
  It basically just adds ticks to your axis where your data points are! You might want
  to use `emptyAxis` to remove all the other useless axis stuff, now that your have all
  these nice ticks.
-}
rangeFrameGlitter : Float -> Float -> Glitter
rangeFrameGlitter x y =
  { xLine = Nothing
  , yLine = Nothing
  , xTick = Just (simpleTick x)
  , yTick = Just (simpleTick y)
  , whatever = []
  }


{-| Neat glitter for when you hover the dot. There is an example of this which I need to
  reference here. Let me know if I forgot.
-}
hoverGlitter : Float -> Float -> Glitter
hoverGlitter x y =
  { xLine = Just (fullLine [ stroke darkGrey, Attributes.strokeDasharray "5, 5" ])
  , yLine = Just (fullLine [ stroke darkGrey, Attributes.strokeDasharray "5, 5" ])
  , xTick = Nothing
  , yTick = Nothing
  , whatever = []
  }


{-| Make your own dot!
-}
customDot : Maybe (Svg msg) -> Glitter -> Float -> Float -> DataPoint msg
customDot =
  DataPoint



-- SERIES


{-| The line customizations. You can:
    - Add your own vertical axis.
    - Add the interpolation you'd like.
    - Add your own data transformer.
-}
type alias Series data msg =
  { axis : Axis
  , interpolation : Interpolation
  , toDataPoints : data -> List (DataPoint msg)
  }


{-| A scatter series.
-}
dots : (data -> List (DataPoint msg)) -> Series data msg
dots toDataPoints =
  { axis = normalAxis
  , interpolation = None
  , toDataPoints = toDataPoints
  }


{-| A line series.
-}
line : (data -> List (DataPoint msg)) -> Series data msg
line toDataPoints =
  { axis = normalAxis
  , interpolation = Linear Nothing [ stroke pinkStroke ]
  , toDataPoints = toDataPoints
  }


{-| An area series.
-}
area : (data -> List (DataPoint msg)) -> Series data msg
area toDataPoints =
  { axis = normalAxis
  , interpolation = Linear (Just pinkFill) [ stroke pinkStroke ]
  , toDataPoints = toDataPoints
  }


{-| Make your own series! The standard line series looks like this on the inside:

  line : (data -> List (DataPoint msg)) -> Series data msg
  line toDataPoints =
    { axis = normalAxis
    , interpolation = Linear Nothing [ stroke pinkStroke ]
    , toDataPoints = toDataPoints
    }

  Maybe pink isn't really your color and your want to make it green. No problem! You
  just add some different attributes to the interpolation.

  If you want a different interpolation or want an area, look at the 'Interpolation' type
  for more info.
-}
custom : Axis -> Interpolation -> (data -> List (DataPoint msg)) -> Series data msg
custom =
  Series


{-| [Interpolation](https://en.wikipedia.org/wiki/Interpolation) is basically the line that goes
  between your data points.
    - None: No line (this is a scatter plot).
    - Linear: A stright line.
    - Curvy: A nice looking curvy line.
    - Monotone: A nice looking curvy line which doesn't extend outside the y values of the two
      points involved (Huh? Here's an [illustration](https://en.wikipedia.org/wiki/Monotone_cubic_interpolation#/media/File:MonotCubInt.png)).

  All but `None` take a color which determined whether it draws the area below or not +
  list of attributes which you can use for styling of your interpolation.
-}
type Interpolation
  = None
  | Linear (Maybe String) (List (Attribute Never))
  | Curvy (Maybe String) (List (Attribute Never))
  | Monotone (Maybe String) (List (Attribute Never))


{-| The plot customizations. You can:

  - Add attributes to your whole plot (Useful when you want to do events).
  - Add an id (the id in here will overrule an id attribute you add in `.attributes`).
  - Change the margin (useful when you can't see your ticks!).
  - Change the width or height of your plot. I recommend anything with the golden ratio!
  - Add a message which will be sent when your hover over a point on your plot!
  - Add a more exciting axis. Maybe try `axisAtMin` or make your own?
  - Add a grid, but do consider whether that will actually improve the readability of your plot.
  - Change the bounds of your plot. For example, if you want your plot to start
    atleast at 0 on the y-axis, then add `toDomainLowest = min 0`.

  _Note:_ The id is particularily important when you have
  several plots in your dom.
-}
type alias PlotCustomizations msg =
  { attributes : List (Attribute msg)
  , id : String
  , width : Int
  , height : Int
  , margin :
    { top : Int
    , right : Int
    , bottom : Int
    , left : Int
    }
  , onHover : Maybe (Maybe Point -> msg)
  , horizontalAxis : Axis
  , grid :
    { horizontal : Grid
    , vertical : Grid
    }
  , toDomainLowest : Float -> Float
  , toDomainHighest : Float -> Float
  , toRangeLowest : Float -> Float
  , toRangeHighest : Float -> Float
  }



{-| The default plot customizations.
-}
defaultPlotCustomizations : PlotCustomizations msg
defaultPlotCustomizations =
  { attributes = []
  , id = "elm-plot"
  , width = 1000
  , height = 720
  , margin =
      { top = 20
      , right = 40
      , bottom = 20
      , left = 40
      }
  , onHover = Nothing
  , horizontalAxis = normalAxis
  , grid =
      { horizontal = emptyGrid
      , vertical = emptyGrid
      }
  , toDomainLowest = identity
  , toDomainHighest = identity
  , toRangeLowest = identity
  , toRangeHighest = identity
  }



-- GRID


{-| -}
type Grid
  = Grid (AxisSummary -> GridCustomizations)
  | YeahGridsAreTotallyLame


{-| The grid customizations. Attributes are put on all gridlines
  and the positions decide where the grid lines will be placed.
-}
type alias GridCustomizations =
  { attributes : List (Attribute Never)
  , positions : List Float
  }


{-| A grid with decent spacing. Uses the `decentPositions` function to calculate
  the positions of the grid lines. This also means that if you use `decentPositions`
  to calculate your tick positions, then they will match.
-}
decentGrid : Grid
decentGrid =
  grid <| \summary ->
    { attributes = [ stroke grey ]
    , positions = decentPositions summary
    }


{-| No grid (default). Tufte would be proud of you.
-}
emptyGrid : Grid
emptyGrid =
  YeahGridsAreTotallyLame


{-| Make your own grid! -}
grid : (AxisSummary -> GridCustomizations) -> Grid
grid =
  Grid



-- AXIS


{-| -}
type Axis
  = Axis (AxisSummary -> AxisCustomizations)
  | SometimesYouDoNotHaveAnAxis


{-| The axis customizations. You can:
  - Change the position of you axis. This is what the `axisAtMin` does!
  - Change the look and feel of the axis line.
  - Add a variation of ticks.
  - Add a variation of labels.
  - Add a title or whatever.
-}
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


{-| When you don't have an axis. -}
sometimesYouDoNotHaveAnAxis : Axis
sometimesYouDoNotHaveAnAxis =
  SometimesYouDoNotHaveAnAxis


{-| When you want to make your own axis. This is where the fun starts! The
  `normalAxis` looks like this on the inside:

    normalAxis : Axis
    normalAxis =
      axis <| \summary ->
        { position = ClosestToZero
        , axisLine = Just (fullLine summary)
        , ticks = List.map simpleTick (decentPositions summary)
        , labels = List.map simpleLabel (decentPositions summary)
        , whatever = []
        }

  But the special snowflake you are, you might want something different.
-}
axis : (AxisSummary -> AxisCustomizations) -> Axis
axis =
  Axis


{-| A super regular axis.
-}
normalAxis : Axis
normalAxis =
  axis <| \summary ->
    { position = ClosestToZero
    , axisLine = Just (simpleLine summary)
    , ticks = List.map simpleTick (decentPositions summary |> remove 0)
    , labels = List.map simpleLabel (decentPositions summary |> remove 0)
    , whatever = []
    }


{-| An axis closest to zero, but doesn't look like much unless you use the `rangeFrame` glitter.
-}
emptyAxis : Axis
emptyAxis =
  Axis <| \summary ->
    { position = ClosestToZero
    , axisLine = Nothing
    , ticks = []
    , labels = []
    , whatever = []
    }


{-| An axis which is placed at the minimum of your axis! Meaning if you use it as
  a vertical axis, then it will end up to the far left, and if you use it as
  a horizontal axis, then it will end up in the bottom.
-}
axisAtMin : Axis
axisAtMin =
  axis <| \summary ->
    { position = Min
    , axisLine = Just (simpleLine summary)
    , ticks = List.map simpleTick (decentPositions summary)
    , labels = List.map simpleLabel (decentPositions summary)
    , whatever = []
    }


{-| Like `axisAtMin`, but opposite.
-}
axisAtMax : Axis
axisAtMax =
  axis <| \summary ->
    { position = Min
    , axisLine = Just (simpleLine summary)
    , ticks = List.map simpleTick (decentPositions summary)
    , labels = List.map simpleLabel (decentPositions summary)
    , whatever = []
    }


{-| A simple line which goes from one side to the other.
-}
simpleLine : AxisSummary -> LineCustomizations
simpleLine summary =
  fullLine [ stroke darkGrey ] summary


{-| A simple but powerful tick.
-}
simpleTick : Float -> TickCustomizations
simpleTick position =
  { position = position
  , length = 5
  , attributes = [ stroke darkGrey ]
  }


{-| A simple label. You might want to try an make your own!
-}
simpleLabel : Float -> LabelCustomizations
simpleLabel position =
  { position = position
  , format = toString
  , view = viewLabel []
  }


{-| A line which goes from one end of the plot to the other.
-}
fullLine : List (Attribute Never) -> AxisSummary -> LineCustomizations
fullLine attributes summary =
  { attributes = attributes
  , start = summary.min
  , end = summary.max
  }



-- VIEW


{-| View you plot!
-}
view : List (Series data msg) -> data -> Html msg
view =
  viewCustom defaultPlotCustomizations


{-| View your plot with special needs!
-}
viewCustom : PlotCustomizations msg -> List (Series data msg) -> data -> Html msg
viewCustom customizations series data =
  let
    dataPoints =
      List.map (\{ toDataPoints } -> toDataPoints data) series

    allDataPoints =
      List.concat dataPoints

    summary =
      toPlotSummary customizations allDataPoints

    viewHorizontalAxes =
      allDataPoints
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
        |> g [ class "elm-plot__all-series" ]
        |> Just

    viewGlitter =
      allDataPoints
        |> List.concatMap (viewGlitterLines summary)
        |> g [ class "elm-plot__glitter" ]
        |> Svg.map never
        |> Just

    hoverEventAttributes =
      case customizations.onHover of
          Just toMsg ->
            [ Html.Events.on "mousemove" (handleHint summary toMsg)
            , Html.Events.onMouseLeave (toMsg Nothing)
            , Attributes.id customizations.id
            ]

          Nothing ->
            [ Attributes.id customizations.id ]

    attributes =
      customizations.attributes ++
        [ Attributes.width (toString customizations.width)
        , Attributes.height (toString customizations.height)
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
    div hoverEventAttributes [ svg attributes children ]



-- HINT HANDLER


handleHint : PlotSummary -> (Maybe Point -> msg) -> Json.Decoder msg
handleHint summary toMsg =
    Json.map3
        (\x y r -> toMsg (unScalePoint summary x y r))
        (Json.field "clientX" Json.float)
        (Json.field "clientY" Json.float)
        (DOM.target plotPosition)


plotPosition : Json.Decoder DOM.Rectangle
plotPosition =
    Json.oneOf
        [ DOM.boundingClientRect
        , Json.lazy (\_ -> DOM.parentElement plotPosition)
        ]


unScalePoint : PlotSummary -> Float -> Float -> DOM.Rectangle -> Maybe Point
unScalePoint summary mouseX mouseY { left, top } =
    Just
      { x = toNearestX summary <| unScaleValue summary.x (mouseX - left)
      , y = clamp summary.y.min summary.y.max <| unScaleValue summary.y (summary.y.length - mouseY - top)
      }


toNearestX : PlotSummary -> Float -> Float
toNearestX summary exactX =
  let
    default =
      Maybe.withDefault 0 (List.head summary.x.all)

    updateIfCloser closest x =
      if diff x exactX > diff closest exactX then
        closest
      else
        x
  in
    List.foldl updateIfCloser default summary.x.all


diff : Float -> Float -> Float
diff a b =
  abs (a - b)



-- INSIDE


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
      { min = customizations.toRangeLowest (plotSummary.x.min)
      , max = customizations.toRangeHighest (plotSummary.x.max)
      , dataMin = plotSummary.x.min
      , dataMax = plotSummary.x.max
      , length = toFloat customizations.width
      , marginLower = toFloat customizations.margin.left
      , marginUpper = toFloat customizations.margin.right
      , all = List.sort plotSummary.x.all
      }
    , y =
      { min = customizations.toDomainLowest (plotSummary.y.min)
      , max = customizations.toDomainHighest (plotSummary.y.max)
      , dataMin = plotSummary.y.min
      , dataMax = plotSummary.y.max
      , length = toFloat customizations.height
      , marginLower = toFloat customizations.margin.bottom
      , marginUpper = toFloat customizations.margin.top
      , all = plotSummary.y.all
      }
    }



-- VIEW HORIZONTAL GRID


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
  g [ class "elm-plot__series" ]
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
      draw (fill transparent :: stroke pinkStroke :: class "elm-plot__series__interpolation" :: attributes)
        (toLine plotSummary (points dataPoints))

    Just color ->
      draw (fill color :: fill pinkFill :: stroke pinkStroke :: class "elm-plot__series__interpolation" :: attributes)
        (toArea plotSummary (points dataPoints))



-- DOT VIEWS


viewDataPoints : PlotSummary -> List (DataPoint msg) -> Svg msg
viewDataPoints plotSummary dataPoints =
  dataPoints
    |> List.map (viewDataPoint plotSummary)
    |> List.filterMap identity
    |> g [ class "elm-plot__series__points" ]


viewDataPoint : PlotSummary -> DataPoint msg -> Maybe (Svg msg)
viewDataPoint plotSummary { x, y, view } =
  case view of
    Nothing ->
      Nothing

    Just svgView ->
      Just <| g [ place plotSummary { x = x, y = y } 0 0 ] [ svgView ]


{-| Pass radius and color to make a circle!
-}
viewCircle : Float -> String -> Svg msg
viewCircle radius color =
  Svg.circle
    [ r (toString radius)
    , stroke "transparent"
    , fill color
    ]
    []


{-| Pass width and color to make a square!
-}
viewSquare : Float -> String -> Svg msg
viewSquare width color =
  rect
    [ Attributes.width (toString width)
    , Attributes.height (toString width)
    , Attributes.x (toString (-width / 2))
    , Attributes.y (toString (-width / 2))
    , stroke "transparent"
    , fill color
    ]
    []


{-| Pass width, height and color to make a diamond!
-}
viewDiamond : Float -> Float -> String -> Svg msg
viewDiamond width height color =
  rect
    [ Attributes.width (toString width)
    , Attributes.height (toString height)
    , Attributes.transform "rotate(90)"
    , Attributes.x (toString (-width / 2))
    , Attributes.y (toString (-height / 2))
    , stroke "transparent"
    , fill color
    ]
    []



-- VIEW HORIZONTAL AXIS


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


viewAxisLine : PlotSummary -> (Float -> Point) -> Maybe LineCustomizations -> Svg Never
viewAxisLine summary at axisLine =
  case axisLine of
    Just { attributes, start, end } ->
      draw attributes (linear summary [ at start, at end ])

    Nothing ->
      text ""


viewTickInner : List (Attribute msg) -> Float -> Float -> Svg msg
viewTickInner attributes width height =
  Svg.line (x2 (toString width) :: y2 (toString height) :: attributes) []


viewLabel : List (Svg.Attribute msg) -> String -> Svg msg
viewLabel attributes string =
  text_ attributes [ tspan [] [ text string ] ]



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


{-| For decently spaces positions. Useful in tick/label and grid configurations.
-}
decentPositions : AxisSummary -> List Float
decentPositions summary =
  if summary.length > 600 then
    interval 0 (niceInterval summary.min summary.max 10) summary
  else
    interval 0 (niceInterval summary.min summary.max 5) summary


{-| For ticks with a particular interval. The first value passed if the offset,
  and the second value is actual interval. The offset in useful when you want
   two sets of ticks with different views. For example if you want a long ticks
   at every 2 * x and a small ticks at every 2 * x + 1.
-}
interval : Float -> Float -> AxisSummary -> List Float
interval offset delta { min, max } =
  let
      range = abs (min - max)
      value = firstValue delta min + offset
      indexes = List.range 0 <| count delta min range value
  in
      List.map (tickPosition delta value) indexes


{-| If you regret a particular position. Typically used for removing the label
  at the origin. Use like this:

    normalAxis : Axis
    normalAxis =
      axis <| \summary ->
        { position = ClosestToZero
        , axisLine = Just (simpleLine summary)
        , ticks = List.map simpleTick (decentPositions summary |> remove 0)
        , labels = List.map simpleLabel (decentPositions summary |> remove 0)
        , whatever = []
        }

  See how in the normal axis we make a bunch of ticks, but then remove then one we don't
  want. You can do the same!
-}
remove : Float -> List Float -> List Float
remove banned values =
  List.filter (\v -> v /= banned) values


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
