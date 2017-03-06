module Svg.Plot exposing (
  Axis(..), AxisCustomizations, Position(..), LineCustomizations,
  TickCustomizations, LabelCustomizations, WhateverCustomizations,
  Grid(..), GridCustomizations,
  normalAxis, sometimesYouDoNotHaveAnAxis, simpleLine, simpleTick, simpleLabel, viewHorizontalAxis, viewVerticalAxis, remove,
  viewHorizontalGrid, viewVerticalGrid, decentGrid, viewAxisLine, emptyGrid, PlotCustomizations, Plot, view, toPlotSummary, axis, decentPositions
  )

{-|

@docs Axis, AxisCustomizations, Position, LineCustomizations,TickCustomizations, LabelCustomizations, WhateverCustomizations, axis, decentPositions

@docs normalAxis, simpleLine, simpleTick, simpleLabel, viewHorizontalAxis, viewVerticalAxis, viewHorizontalGrid, viewVerticalGrid, remove

@docs Grid, GridCustomizations, emptyGrid, viewAxisLine, sometimesYouDoNotHaveAnAxis, decentGrid, PlotCustomizations, Plot, view, toPlotSummary
-}

import Html exposing (Html)
import Svg exposing (Svg, Attribute, svg, g, text_, tspan, text)
import Svg.Attributes as Attributes exposing (stroke, style, class, x2, y2)
import Svg.Draw exposing (..)
import Svg.Colors exposing (..)
import Round
import Regex


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
  , toDomainLowest : Float -> Float
  , toDomainHighest : Float -> Float
  , toRangeLowest : Float -> Float
  , toRangeHighest : Float -> Float
  }


{-| -}
type alias Plot msg =
  { customizations : PlotCustomizations msg
  , moreHorizontalTicks : List TickCustomizations
  , verticalAxes : List ( Axis, List TickCustomizations )
  , content : Svg msg
  , glitter : List (Svg Never)
  }


{-| -}
view : PlotSummary -> Plot msg -> Html msg
view summary { customizations, moreHorizontalTicks, verticalAxes, content, glitter } =
  svg
    [ Attributes.width (toString customizations.width)
    , Attributes.height (toString customizations.height)
    ] <|
      List.filterMap identity
        [ viewHorizontalGrid summary customizations.grid.horizontal
        , viewVerticalGrid summary customizations.grid.vertical
        , Just content
        , viewHorizontalAxis summary customizations.horizontalAxis moreHorizontalTicks
        , Just <| g [ class "elm-plot__vertical-axes" ] (List.map (viewVerticalAxis summary) verticalAxes |> List.filterMap identity)
        , Just <| Svg.map never <| g [ class "elm-plot__glitter" ] glitter
        ]


-- INSIDE


{-| -}
toPlotSummary : PlotCustomizations msg -> List { a | x : Float, y : Float } -> PlotSummary
toPlotSummary customizations points =
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
      }
    , y =
      { min = customizations.toDomainLowest (plotSummary.y.min)
      , max = customizations.toDomainHighest (plotSummary.y.max)
      , dataMin = plotSummary.y.min
      , dataMax = plotSummary.y.max
      , length = toFloat customizations.height
      , marginLower = toFloat customizations.margin.bottom
      , marginUpper = toFloat customizations.margin.top
      }
    }



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
    { position = At 0
    , axisLine = Just (simpleLine [ stroke darkGrey ] summary)
    , ticks = List.map (simpleTick [ stroke darkGrey ] 5) (decentPositions summary |> remove 0)
    , labels = List.map (simpleLabel [] toString) (decentPositions summary |> remove 0)
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
viewVerticalAxis : PlotSummary -> ( Axis, List TickCustomizations ) -> Maybe (Svg msg)
viewVerticalAxis summary ( axis, moreTicks ) =
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



-- HELPERS


resolvePosition : AxisSummary -> Position -> Float
resolvePosition { min, max } position =
  case position of
    Min ->
      min

    Max ->
      max

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
