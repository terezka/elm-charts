module Svg.Plot exposing (view, dots, line, area, custom, Dot, Series, square, circle, diamond, triangle, fancyCustom, left, right, bottom)



-- DATA POINTS


circle : Float -> Float -> DataPoint msg
circle =
  DataPoint (viewCircle 5 pinkFill)


square : Float -> Float -> DataPoint msg
square =
  DataPoint (viewSquare 5 5 pinkFill)


diamond : Float -> Float -> DataPoint msg
diamond =
  DataPoint (viewDiamond 5 pinkFill)


triangle : Float -> Float -> DataPoint msg
triangle =
  DataPoint (viewTriangle 5 pinkFill)


type alias DataPoint msg =
  { dot : Maybe (Svg.Svg msg)
  , x : Float
  , y : Float
  }



-- SERIES


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
  | Linear (Maybe String) (List (Svg.Attribute Never))
  | Curvy (Maybe String) (List (Svg.Attribute Never))
  | Monotone (Maybe String) (List (Svg.Attribute Never))


dots : (data -> List (DataPoint msg)) -> Series data msg
dots toDataPoints =
  { axis = normalAxis
  , interpolation = None
  , toDataPoints = toDataPoints
  }


line : (data -> List (DataPoint msg)) -> Series data msg
line toDataPoints =
  { axis = normalAxis
  , interpolation = Linear False
  , toDataPoints = toDataPoints
  }


area : (data -> List (DataPoint msg)) -> Series data msg
area toDataPoints =
  { axis = normalAxis
  , interpolation = Linear True
  , toDataPoints = toDataPoints
  }



-- CUSTOM SERIES


custom : Axis -> Interpolation -> Bool -> (data -> List (DataPoint msg)) -> Series data msg
custom axis interpolation isArea toDataPoints =
  { axis = axis
  , interpolation = interpolation
  , toDataPoints = toDataPoints
  , isArea = isArea
  }



-- FANCY CUSTOM SERIES


fancyCustom : Axis -> Interpolation -> (data -> List (FancyDataPoint msg)) -> Series data msg


type alias FancyDataPoint msg =
  { x : Float
  , y : Float
  , view : Maybe (Svg.Svg msg)
  , xMark : Maybe Mark
  , yMark : Maybe Mark
  }



-- AXIS


type Axis
  = SometimesYouDoNotHaveAnAxis
  | Axis AxisCustomizations


type alias AxisCustomizations =
  { attributes : List (Svg.Attribute Never)
  , axisPosition : Position
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
  | Custom { position : Float, view : Svg.Svg Never }


type alias TickCustomizations =
  { position : Float
  , length : Float
  , attributes : List (Svg.Attribute Never)
  , gridlineAttributes : Maybe (List (Svg.Attribute Never))
  }


axis : (Summary -> AxisCustomizations) -> Axis
axis =
  Axis


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
    , marks = List.map (tick [] 5 Nothing) (default summary) ++ List.map (label [] toString) (default summary)
    }


tick : List (Svg.Attribute msg) -> Float -> Maybe (List (Svg.Attribute Never)) -> Float -> Mark
tick attributes length gridlineAttributes position =
  Tick
    { position = position
    , length = length
    , attributes = attributes
    , gridlineAttributes = gridlineAttributes
    }


label : List (Svg.Attribute msg) -> (Float -> String) -> Float -> Mark
label attributes format position =
  Custom
    { position = position
    , view = viewLabel (format position)
    }



-- VIEW


type alias PlotCustomizations msg = -- blah blah blah


view : List (Series data msg) -> data -> Html msg
view =
  fancyView defaultPlotCustomizations


fancyView : PlotCustomizations msg -> List (Series data msg) -> data -> Html msg
fancyView customizations series data =
  let
    dataPoints =
      List.map (\{ toDataPoints } -> toDataPoints data) series

    plotSummary =
      toPlotSummary dataPoints

    series =
      List.map2 (viewSeries plotSummary) series dataPoints
  in
    Svg.svg [] (series ++ [ viewHorizontalAxis customizations.horizontalAxis plotSummary ])



-- INSIDE


type PlotSummary =
  { x : Summary
  , y : Summary
  , id : String
  }


type alias Summary =
  { min : Float
  , max : Float
  , all : List Float
  , length : Float
  , offsetLower : Float
  , offsetUpper : Float
  }


toPlotSummary : PlotCustomizations -> List (DataPoint msg) -> PlotSummary
toPlotSummary customizations dataPoints =
  let
    foldSummary summary v =
      { min = min summary.min v
      , max = max summary.max v
      , all = v :: summary.all
      }

    toSummary result { x, y } =
      case result of
        Nothing ->
          { x = { min = x, max = x, all = [ x ] }
          , y = { min = y, max = y, all = [ y ] }
          }

        Just summary ->
          { x = foldSummary summary.x x
          , y = foldSummary summary.y y
          }

    defaultPlotSummary =
      { x = { min = 0, max = 1 }
      , y = { min = 0, max = 1 }
      }

    plotSummary =
      List.foldl getReach Nothing dataPoints
        |> Maybe.withDefault defaultPlotSummary
  in
    { x =
      { min = plotSummary.x.min
      , max = plotSummary.x.max
      , all = plotSummary.x.all
      , length = customizations.width
      , marginLower = customizations.margin.left
      , marginUpper = customizations.margin.right
      }
    , y =
      { min = plotSummary.y.min
      , max = plotSummary.y.max
      , all = plotSummary.y.all
      , length = customizations.height
      , marginLower = customizations.margin.bottom
      , marginUpper = customizations.margin.top
      }
    , id = customizations.id
    }



-- MORE VIEWS


viewSeries : PlotSummary -> Series data msg -> List (DataPoint msg) -> Svg msg
viewSeries summary { axis, interpolation } dataPoints =
  g []
    [ viewVerticalAxis summary axis
    , viewPath summary interpolation dataPoints
    , viewDataPoints summary dataPoints
    ]


viewPath : PlotSummary -> Interpolation -> List (DataPoint msg) -> Svg msg
viewPath summary interpolation dataPoints =
  case interpolation of
    None ->
      path [] []

    Linear fill attributes ->
      linearPath summary fill attributes dataPoints

    Curvy fill attributes ->
      curvyPath summary fill attributes dataPoints

    Monotone fill attributes ->
      monotonePath summary fill attributes dataPoints


viewDataPoints : PlotSummary -> List (DataPoint msg) -> Svg msg
viewDataPoints summary dataPoints =
  g [] (List.map (viewDataPoint summary) dataPoints)


viewDataPoint : PlotSummary -> DataPoint msg -> Svg msg
viewDataPoint summary { x, y, view } =
  g [ position summary x y ] [ view ]


viewSquare : Float -> Float -> String -> Svg msg
viewSquare width height color =
  rect
    [ Svg.Attributes.width (toString width)
    , Svg.Attributes.height (toString height)
    , stroke "transparent"
    , fill color
    ]
    []


viewCircle : Float -> String -> Svg msg
viewCircle radius color =
  circle
    [ r (toString radius)
    , stroke "transparent"
    , fill color
    ]
    []


viewHorizontalAxis : PlotSummary -> Axis -> Svg msg
viewHorizontalAxis summary { attributes, axisPosition, start, end, marks } =
  let
    y =
      toSVGY summary (resolvePosition axisPosition summary.y)

    axisLine =
      line attributes (toSVGX summary start) y (toSVGX summary end) y

    tickLine attributes length position =
      let
        x =
          toSVGX summary position
      in
        line attributes x y (x + length) y

    gridLine attributes position =
      case attributes of
        Nothing ->
          text ""

        Just actualAttrs ->
          line actualAttrs
            (toSVGX summary position)
            (toSVGY summary summary.y.min)
            (toSVGX summary position)
            (toSVGY summary summary.y.max)

    viewMark mark =
      case mark of
        Tick { attributes, position, length, gridlineAttributes } ->
          g [] [ tickLine attributes length position, gridLine gridlineAttributes position ]

        Custom { position, view } ->
          g [ translateAttribute x (toSVGX summary y) ] [ view ]
  in
    g [ class "elm-plot__vertical-axis" ] (axisLine :: List.map viewMark marks)


viewVerticalAxis : PlotSummary -> Axis -> Svg msg
viewVerticalAxis summary { attributes, axisPosition, start, end, marks } =
  let
    x =
      toSVGX summary (resolvePosition axisPosition summary.x)

    axisLine =
      line attributes x (toSVGY summary start) x (toSVGY summary end)

    tickLine attributes length position =
      let
        y =
          toSVGY summary position
      in
        line attributes x y x (y + length)

    gridLine attributes y =
      case attributes of
        Nothing ->
          text ""

        Just actualAttrs ->
          line actualAttrs
            (toSVGX summary summary.x.min)
            (toSVGY summary y)
            (toSVGX summary summary.x.max)
            (toSVGY summary y)

    viewMark mark =
      case mark of
        Tick { attributes, position, length, gridlineAttributes } ->
          g [] [ tickLine attributes length position, gridLine gridlineAttributes position ]

        Custom { position, view } ->
          g [ translateAttribute x (toSVGY summary y) ] [ view ]
  in
    g [ class "elm-plot__vertical-axis" ] (axisLine :: List.map viewMark marks)



-- HELP


positionAttribute : PlotSummary -> Float -> Float -> Attribute Never
positionAttribute summary x y =
  translateAttribute (toSVGX summary x) (toSVGY summary y)


translateAttribute : Float -> Float -> Attribute Never
translateAttribute x y =
  transform <| "translate(" ++ toString x ++ ",  " ++ toString y ++ ")"


line : List (Attribute msg) -> Float -> Float -> Float -> Float -> Svg msg
line attributes x1 y1 x2 y2 =
  line <|
    attributes ++
    [ Attributes.x1 (toString x1)
    , Attributes.y1 (toString y1)
    , Attributes.x2 (toString x2)
    , Attributes.y2 (toString y2)
    ]




-- COLORS


pinkFill : String
pinkFill =
    "#fdb9e7"


pinkStroke : String
pinkStroke =
    "#ff9edf"
