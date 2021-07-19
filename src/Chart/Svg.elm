module Chart.Svg exposing
  ( Line, line
  , Arrow, arrow
  , Rect, rect
  , Tooltip, tooltip

  , Label, label
  , Tick, xTick, yTick
  , Generator, generate, floats, ints, times, formatTime

  , Bar, bar
  , Interpolation, interpolation, area
  , Dot, dot

  , Legends, legendsAt
  , Legend, lineLegend, barLegend

  , position, positionHtml

  , Plane, Axis, Margin, Position, Point
  , fromSvg, fromCartesian
  , lengthInSvgX, lengthInSvgY
  , lengthInCartesianX, lengthInCartesianY

  , getNearest, getNearestX, getWithin, getWithinX
  )

{-| Render plain SVG chart elements!

If the options in the `Chart` module does not fit your needs, perhaps
you need to render some custom SVG. This is the low level SVG helpers I
use in the library, and you can use them however you'd like too. You can
embed your own SVG into your chart by using the `Chart.svg` and `Chart.svgAt`
functions.

    import Chart as C
    import Chart.Svg as CS
    import Svg as S

    view : Html msg
    view =
      C.chart []
        [ C.svg <| \plane ->
            CS.label plane [] [ S.text "my custom label" ] { x = 5, y = 5 }
        ]

Most of the configuration of these functions are directly parallel to those
of `Chart`, except you need to pass a `Plane` type in the first argument.

You can see what attributes are applicable given their configuration record.

# Line
@docs Line, line

# Rectangels
@docs Rect, rect

# Arrows
@docs Arrow, arrow

# Labels
@docs Label, label

# Ticks
@docs Tick, xTick, yTick

## Generation
@docs Generator, generate, floats, ints, times

## Formatting
@docs formatTime

# Series

## Bars
@docs Bar, bar

## Dots
@docs Dot, dot

## Interpolations
@docs Interpolation, interpolation, area

## Legends
@docs Legends, legendsAt
@docs Legend, lineLegend, barLegend

# Tooltips
@docs Tooltip, tooltip

# Positioning
@docs position, positionHtml

# Working with the coordinate system
@docs Plane, Axis, Margin, Position, Point
@docs fromSvg, fromCartesian
@docs lengthInSvgX, lengthInSvgY
@docs lengthInCartesianX, lengthInCartesianY

# Seaching
@docs getNearest, getNearestX, getWithin, getWithinX

-}

import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Svg.Events as SE
import Internal.Coordinates as Coord
import Internal.Commands as C exposing (..)
import Chart.Attributes as CA
import Internal.Interpolation as Interpolation
import Intervals as I
import Json.Decode as Json
import DOM
import Time
import DateFormat as F
import Dict exposing (Dict)
import Internal.Helpers as Helpers
import Internal.Svg


-- TICK


{-| -}
type alias Tick =
  { color : String
  , width : Float
  , length : Float
  , attrs : List (S.Attribute Never)
  }


{-| -}
xTick : Plane -> List (CA.Attribute Tick) -> Point -> Svg msg
xTick plane edits =
  Internal.Svg.xTick plane (Helpers.apply edits Internal.Svg.defaultTick)


{-| -}
yTick : Plane -> List (CA.Attribute Tick) -> Point -> Svg msg
yTick plane edits =
  Internal.Svg.yTick plane (Helpers.apply edits Internal.Svg.defaultTick)


tick : Plane -> List (CA.Attribute Tick) -> Bool -> Point -> Svg msg
tick plane edits =
  Internal.Svg.tick plane (Helpers.apply edits Internal.Svg.defaultTick)



-- LINE


{-| -}
type alias Line =
  { x1 : Maybe Float
  , x2 : Maybe Float
  , y1 : Maybe Float
  , y2 : Maybe Float
  , x2Svg : Maybe Float
  , y2Svg : Maybe Float
  , xOff : Float
  , yOff : Float
  , tickLength : Float
  , tickDirection : Float
  , color : String
  , width : Float
  , dashed : List Float
  , opacity : Float
  , break : Bool
  , flip : Bool
  , attrs : List (S.Attribute Never)
  }


{-| -}
line : Plane -> List (CA.Attribute Line) -> Svg msg
line plane edits =
  Internal.Svg.line plane (Helpers.apply edits Internal.Svg.defaultLine)



{-| -}
type alias Rect =
  { x1 : Maybe Float
  , x2 : Maybe Float
  , y1 : Maybe Float
  , y2 : Maybe Float
  , color : String
  , border : String
  , borderWidth : Float
  , opacity : Float
  , attrs : List (S.Attribute Never)
  }


{-| -}
rect : Plane -> List (CA.Attribute Rect) -> Svg msg
rect plane edits =
  Internal.Svg.rect plane (Helpers.apply edits Internal.Svg.defaultRect)



-- LEGEND


{-| -}
type alias Legends msg =
  { alignment : Internal.Svg.Alignment
  , anchor : Maybe Internal.Svg.Anchor
  , xOff : Float
  , yOff : Float
  , spacing : Float
  , background : String
  , border : String
  , borderWidth : Float
  , htmlAttrs : List (H.Attribute msg)
  }


{-| -}
legendsAt : Plane -> Float -> Float -> List (CA.Attribute (Legends msg)) -> List (Html msg) -> Html msg
legendsAt plane x y edits =
  Internal.Svg.legendsAt plane x y (Helpers.apply edits Internal.Svg.defaultLegends)


{-| -}
type alias Legend msg =
  { xOff : Float
  , yOff : Float
  , width : Float
  , height : Float
  , fontSize : Maybe Int
  , color : String
  , spacing : Float
  , title : String
  , htmlAttrs : List (H.Attribute msg)
  }


{-| -}
barLegend : List (CA.Attribute (Legend msg)) -> List (CA.Attribute Bar) ->  Html msg
barLegend edits barAttrs =
  Internal.Svg.barLegend
    (Helpers.apply edits Internal.Svg.defaultBarLegend)
    (Helpers.apply barAttrs Internal.Svg.defaultBar)


{-| -}
lineLegend : List (CA.Attribute (Legend msg)) -> List (CA.Attribute Interpolation) -> List (CA.Attribute Dot) -> Html msg
lineLegend edits interAttrsOrg dotAttrsOrg =
  let interpolationConfigOrg = Helpers.apply interAttrsOrg Internal.Svg.defaultInterpolation
      dotConfigOrg = Helpers.apply dotAttrsOrg Internal.Svg.defaultDot

      ( dotAttrs, interAttrs, lineLegendAttrs ) =
        case ( interpolationConfigOrg.method, dotConfigOrg.shape ) of
          ( Just _, Nothing )  -> ( dotAttrsOrg, interAttrsOrg, CA.width 10 :: edits )
          ( Nothing, Nothing ) -> ( CA.circle :: dotAttrsOrg, CA.linear :: interAttrsOrg, CA.width 10 :: edits )
          ( Nothing, Just _ )  -> ( CA.circle :: dotAttrsOrg, interAttrsOrg, CA.width 10 :: edits )
          _                    -> ( dotAttrsOrg, CA.opacity 0 :: interAttrsOrg, edits )

      adjustWidth config =
        { config | width = 10 }
  in
  Internal.Svg.lineLegend
    (Helpers.apply lineLegendAttrs Internal.Svg.defaultLineLegend)
    (Helpers.apply interAttrs Internal.Svg.defaultInterpolation)
    (Helpers.apply dotAttrs Internal.Svg.defaultDot)



-- LABEL


{-| -}
type alias Label =
  { xOff : Float
  , yOff : Float
  , border : String
  , borderWidth : Float
  , fontSize : Maybe Int
  , color : String
  , anchor : Maybe Internal.Svg.Anchor
  , rotate : Float
  , uppercase : Bool
  , attrs : List (S.Attribute Never)
  }


{-| -}
label : Plane -> List (CA.Attribute Label) -> List (Svg msg) -> Point -> Svg msg
label plane edits =
  Internal.Svg.label plane (Helpers.apply edits Internal.Svg.defaultLabel)



-- ARROW


{-| -}
type alias Arrow =
  { xOff : Float
  , yOff : Float
  , color : String
  , width : Float
  , length : Float
  , rotate : Float
  , attrs : List (S.Attribute Never)
  }


{-| -}
arrow : Plane -> List (CA.Attribute Arrow) -> Point -> Svg msg
arrow plane edits =
  Internal.Svg.arrow plane (Helpers.apply edits Internal.Svg.defaultArrow)



-- BAR


{-| -}
type alias Bar =
  { roundTop : Float
  , roundBottom : Float
  , color : String
  , border : String
  , borderWidth : Float
  , opacity : Float
  , design : Maybe Internal.Svg.Design
  , attrs : List (S.Attribute Never)
  , highlight : Float
  , highlightWidth : Float
  , highlightColor : String
  }


{-| -}
bar : Plane -> List (CA.Attribute Bar) -> Position -> Svg msg
bar plane edits =
  Internal.Svg.bar plane (Helpers.apply edits Internal.Svg.defaultBar)



-- SERIES


{-| -}
type alias Interpolation =
  { method : Maybe Internal.Svg.Method
  , color : String
  , width : Float
  , opacity : Float
  , design : Maybe Internal.Svg.Design
  , dashed : List Float
  , attrs : List (S.Attribute Never)
  }


{-| -}
interpolation : Plane -> (data -> Float) -> (data -> Maybe Float) -> List (CA.Attribute Interpolation) -> List data -> Svg msg
interpolation plane toX toY edits =
  Internal.Svg.interpolation plane toX toY (Helpers.apply edits Internal.Svg.defaultInterpolation)


{-| -}
area : Plane -> (data -> Float) -> Maybe (data -> Maybe Float) -> (data -> Maybe Float) -> List (CA.Attribute Interpolation) -> List data -> Svg msg
area plane toX toY2M toY edits =
  Internal.Svg.area plane toX toY2M toY (Helpers.apply edits Internal.Svg.defaultArea)



-- DOTS


{-| -}
type alias Dot =
  { color : String
  , opacity : Float
  , size : Float
  , border : String
  , borderWidth : Float
  , highlight : Float
  , highlightWidth : Float
  , highlightColor : String
  , shape : Maybe Internal.Svg.Shape
  }


{-| -}
dot : Plane -> (data -> Float) -> (data -> Float) -> List (CA.Attribute Dot) -> data -> Svg msg
dot plane toX toY edits =
  Internal.Svg.dot plane toX toY (Helpers.apply edits Internal.Svg.defaultDot)



-- TOOLTIP


{-| -}
type alias Tooltip =
  { direction : Maybe Internal.Svg.Direction
  , focal : Maybe (Position -> Position)
  , height : Float
  , width : Float
  , offset : Float
  , arrow : Bool
  , border : String
  , background : String
  }


{-| Like `Chart.tooltip`, except in the second argument you give position directly instead of item.

-}
tooltip : Plane -> Position -> List (CA.Attribute Tooltip) -> List (H.Attribute Never) -> List (H.Html Never) -> H.Html msg
tooltip plane pos edits =
  Internal.Svg.tooltip plane pos (Helpers.apply edits Internal.Svg.defaultTooltip)



-- POSITIONING


{-| Postion arbritary SVG.

    S.g [ position plane x y xOff yOff ] [ ... ]

-}
position : Plane -> Float -> Float -> Float -> Float -> Float -> S.Attribute msg
position =
  Internal.Svg.position


{-| Postion arbritary HTML.

    positionHtml plane x y xOff yOff [] [ .. ]

-}
positionHtml : Plane -> Float -> Float -> Float -> Float -> List (H.Attribute msg) -> List (H.Html msg) -> H.Html msg
positionHtml =
  Internal.Svg.positionHtml



-- SEARCHERS


{-| Search a list for the nearest item. Example use:

    C.withBars <| \plane bars ->
      let closest = CS.getNearest (CE.getPosition plane) bars plane { x = 2, y = 4 } in
      [ C.each closest <| \_ bar -> [ C.label [] [ S.text "nearest" ] (CE.getBottom plane bar) ]
      ]

-}
getNearest : (a -> Position) -> List a -> Plane -> Point -> List a
getNearest =
  Internal.Svg.getNearest


{-| Like `getNearest`, but include searched radius in first argument.

-}
getWithin : Float -> (a -> Position) -> List a -> Plane -> Point -> List a
getWithin =
  Internal.Svg.getWithin


{-| Like `getNearest`, but only searches x coordinates.

-}
getNearestX : (a -> Position) -> List a -> Plane -> Point -> List a
getNearestX =
  Internal.Svg.getNearestX


{-| Like `getWithin`, but only searches x coordinates.

-}
getWithinX : Float -> (a -> Position) -> List a -> Plane -> Point -> List a
getWithinX =
  Internal.Svg.getWithinX



-- INTERVALS


{-| -}
type alias Generator a
  = Internal.Svg.Generator a


{-| -}
floats : Generator Float
floats =
  Internal.Svg.floats


{-| -}
ints : Generator Int
ints =
  Internal.Svg.ints


{-| -}
times : Time.Zone -> Generator I.Time
times =
  Internal.Svg.times


{-| Generate a "nice" set of type `a`.

-}
generate : Int -> Generator a -> Axis -> List a
generate =
  Internal.Svg.generate



-- FORMATTING


{-| -}
formatTime : Time.Zone -> I.Time -> String
formatTime =
  Internal.Svg.formatTime



-- SYSTEM


{-| This is the key information about the coordinate system of your chart.
Using this you'll be able to translate cartesian coordinates into SVG ones and back.

-}
type alias Plane =
  { width : Float
  , height : Float
  , margin : Margin
  , x : Axis
  , y : Axis
  }


{-| -}
type alias Margin =
  { top : Float
  , right : Float
  , left : Float
  , bottom : Float
  }


{-| Information about your range or domain.

 - *dataMin* is the lowest value of your data
 - *dataMax* is the highest value of your data
 - *min* is the lowest value of your axis
 - *max* is the highest value of your axis

-}
type alias Axis =
  { dataMin : Float
  , dataMax : Float
  , min : Float
  , max : Float
  }


{-| -}
type alias Point =
  { x : Float
  , y : Float
  }


{-| -}
type alias Position =
  { x1 : Float
  , x2 : Float
  , y1 : Float
  , y2 : Float
  }


{-| Translate a SVG coordinate to cartesian.

-}
fromSvg : Plane -> Point -> Point
fromSvg =
  Internal.Svg.fromSvg


{-| Translate a cartesian coordinate to SVG.

-}
fromCartesian : Plane -> Point -> Point
fromCartesian =
  Internal.Svg.fromCartesian


{-| How long is a cartesian x length in SVG units?

-}
lengthInSvgX : Plane -> Float -> Float
lengthInSvgX =
  Internal.Svg.lengthInSvgX


{-| How long is a cartesian y length in SVG units?

-}
lengthInSvgY : Plane -> Float -> Float
lengthInSvgY =
  Internal.Svg.lengthInSvgY


{-| How long is a SVG x length in cartesian units?

-}
lengthInCartesianX : Plane -> Float -> Float
lengthInCartesianX =
  Internal.Svg.lengthInCartesianX


{-| How long is a SVG y length in cartesian units?

-}
lengthInCartesianY : Plane -> Float -> Float
lengthInCartesianY =
  Internal.Svg.lengthInCartesianY
