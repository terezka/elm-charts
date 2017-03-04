module Svg.Plot exposing (view, dots, line, area, custom, DataPoint, Series, square, circle, diamond, triangle)

{-|
# Plot

@docs view, dots, line, area, custom, DataPoint, Series, square, circle, diamond, triangle
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
  DataPoint (Just <| viewCircle 5 pinkFill) Nothing Nothing


{-| -}
square : Float -> Float -> DataPoint msg
square =
  DataPoint (Just <| viewSquare 5 5 pinkFill) Nothing Nothing


{-| -}
diamond : Float -> Float -> DataPoint msg
diamond =
  DataPoint (Just <| viewSquare 5 5 pinkFill) Nothing Nothing


{-| -}
triangle : Float -> Float -> DataPoint msg
triangle =
  DataPoint (Just <| viewSquare 5 5 pinkFill) Nothing Nothing


{-| -}
type alias DataPoint msg =
  { view : Maybe (Svg msg)
  , xMark : Maybe Mark
  , yMark : Maybe Mark
  , x : Float
  , y : Float
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
  = SometimesYouDoNotHaveAnAxis
  | Axis (AxisSummary -> AxisCustomizations)


type alias AxisCustomizations =
  { attributes : List (Attribute Never)
  , position : Position
  , start : Float
  , end : Float
  , marks : List Mark
  }


type Position
  = Min
  | Max
  | At Float


type Mark
  = Tick TickCustomizations
  | Custom { position : Float, view : Svg Never }


type alias TickCustomizations =
  { position : Float
  , length : Float
  , attributes : List (Attribute Never)
  , gridlineAttributes : Maybe (List (Attribute Never))
  }


axis : (AxisSummary -> AxisCustomizations) -> Axis
axis axis =
  Axis axis


sometimesYouDoNotHaveAnAxis : Axis
sometimesYouDoNotHaveAnAxis =
  SometimesYouDoNotHaveAnAxis


normalAxis : Axis
normalAxis =
  axis <| \summary ->
    { attributes = [ stroke grey ]
    , position = At 0
    , start = summary.min
    , end = summary.max
    , marks =
        List.map (tick [ stroke grey ] 5 Nothing) (defaultTickPositions summary)
        ++ List.map (label [] toString) (defaultTickPositions summary)
    }


tick : List (Attribute Never) -> Float -> Maybe (List (Attribute Never)) -> Float -> Mark
tick attributes length gridlineAttributes position =
  Tick
    { position = position
    , length = length
    , attributes = attributes
    , gridlineAttributes = gridlineAttributes
    }


label : List (Attribute msg) -> (Float -> String) -> Float -> Mark
label attributes format position =
  Custom
    { position = position
    , view = viewLabel [] (format position)
    }



-- VIEW


type alias PlotCustomizations msg =
  { attributes : List (Attribute msg)
  , horizontalAxis : Axis
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

    seriesViews =
      List.map2 (viewSeries plotSummary) series dataPoints

    viewes =
      seriesViews ++ [ Svg.map never <| viewHorizontalAxis plotSummary customizations.horizontalAxis ]
  in
    svg
      [ Attributes.width (toString customizations.width)
      , Attributes.height (toString customizations.height)
      ]
      viewes



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
    [ Svg.map never <| viewVerticalAxis plotSummary axis
    , Svg.map never <| viewPath plotSummary interpolation dataPoints
    , viewDataPoints plotSummary dataPoints
    ]


viewPath : PlotSummary -> Interpolation -> List (DataPoint msg) -> Svg Never
viewPath plotSummary interpolation dataPoints =
  case interpolation of
    None ->
      path [] []

    Linear fill attributes ->
      viewPathInterpolation plotSummary linear linearArea fill attributes dataPoints

    Curvy fill attributes ->
      -- TODO: Should be curvy
      viewPathInterpolation plotSummary monotoneX monotoneXArea fill attributes dataPoints

    Monotone fill attributes ->
      viewPathInterpolation plotSummary monotoneX monotoneXArea fill attributes dataPoints


viewPathInterpolation :
  PlotSummary
  -> (PlotSummary -> List Draw.Point -> List Draw.Command)
  -> (PlotSummary -> List Draw.Point -> List Draw.Command)
  -> Maybe String
  -> List (Attribute Never)
  -> List (DataPoint msg)
  -> Svg Never
viewPathInterpolation plotSummary toLine toArea area attributes dataPoints =
  case area of
    Nothing ->
      draw attributes (toLine plotSummary (toDrawPoints dataPoints))

    Just color ->
      draw (fill color :: attributes) (toArea plotSummary (toDrawPoints dataPoints))



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


-- AXIS VIEWS


resolvePosition : AxisSummary -> Position -> Float
resolvePosition { min, max } position =
  case position of
    Min ->
      min

    Max ->
      max

    At v ->
      v


viewHorizontalAxis : PlotSummary -> Axis -> Svg Never
viewHorizontalAxis summary axis =
  case axis of
    SometimesYouDoNotHaveAnAxis ->
      text ""

    Axis toCustomizations ->
      let
        { attributes, position, start, end, marks } =
          toCustomizations summary.x

        toPoint x =
          { x = x, y = resolvePosition summary.y position }

        axisLine =
          draw attributes (linear summary [ toPoint start, toPoint end ])

        tickLine attributes length x =
          Draw.position summary (toPoint x) [ viewTick attributes 0 length ]

        gridLine attributes x =
          viewGridLine summary attributes [ { x = x, y = summary.y.min }, { x = x, y = summary.y.max } ]

        viewMark mark =
          case mark of
            Tick { attributes, position, length, gridlineAttributes } ->
              [ tickLine attributes length position, gridLine gridlineAttributes position ]

            Custom { position, view } ->
              [ Draw.position summary (toPoint position) [ view ] ]
      in
        g [ class "elm-plot__horizontal-axis" ] (axisLine :: List.concatMap viewMark marks)


viewVerticalAxis : PlotSummary -> Axis -> Svg Never
viewVerticalAxis summary axis =
  case axis of
    SometimesYouDoNotHaveAnAxis ->
      text ""

    Axis toCustomizations ->
      let
        { attributes, position, start, end, marks } =
          toCustomizations summary.x

        toPoint y =
          { x = resolvePosition summary.x position, y = y }

        axisLine =
          draw attributes (linear summary [ toPoint start, toPoint end ])

        tickLine attributes length y =
          Draw.position summary (toPoint y) [ viewTick attributes -length 0 ]

        gridLine attributes y =
          viewGridLine summary attributes [ { x = summary.x.min, y = y }, { x = summary.x.max, y = y } ]

        viewMark mark =
          case mark of
            Tick { attributes, position, length, gridlineAttributes } ->
              [ tickLine attributes length position, gridLine gridlineAttributes position ]

            Custom { position, view } ->
              [ Draw.position summary (toPoint position) [ view ] ]
      in
        g [ class "elm-plot__vertical-axis" ] (axisLine :: List.concatMap viewMark marks)



viewTick : List (Attribute msg) -> Float -> Float -> Svg msg
viewTick attributes width height =
  Svg.line (x2 (toString width) :: y2 (toString height) :: attributes) []


viewGridLine : PlotSummary -> Maybe (List (Attribute msg)) -> List Draw.Point -> Svg msg
viewGridLine plotSummary gridAttributes points =
  case gridAttributes of
    Nothing ->
      text ""

    Just attributes ->
      draw attributes <| linear plotSummary points



-- DRAW HELP


toDrawPoints : List (DataPoint msg) -> List Draw.Point
toDrawPoints =
  List.map toDrawPoint


toDrawPoint : DataPoint msg -> Draw.Point
toDrawPoint { x, y } =
  Point x y


-- TICK HELP


defaultTickPositions : AxisSummary -> List Float
defaultTickPositions summary =
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


grey : String
grey =
  "#a3a3a3"
