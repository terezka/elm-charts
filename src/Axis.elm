module Axis exposing (..)

{-| -}

import Svg exposing (Svg, Attribute, text_, tspan, text)
import Svg.Attributes exposing (style, stroke)
import Colors exposing (..)
import Round
import Regex


{-| -}
type Axis
  = Axis (Report -> View)
  | SometimesYouDontHaveAnAxis


{-| -}
type alias Report =
  { min : Float
  , max : Float
  }


{-| -}
type alias View =
  { position : Float -> Float -> Float
  , axisLine : Maybe LineView
  , marks : List Mark
  , mirror : Bool
  }


{-| -}
type alias MarkView =
  { gridBelow : Maybe LineView
  , gridAbove : Maybe LineView
  , tick : Maybe TickView
  , view : Maybe (Svg Never)
  }


{-| -}
type alias Mark =
  { position : Float
  , view : MarkView
  }


{-| -}
type alias LineView =
  { attributes : List (Attribute Never)
  , start : Float
  , end : Float
  }


{-| -}
type alias TickView =
  { attributes : List (Attribute Never)
  , length : Float
  }


{-| -}
defaultMarkView : Report -> Float -> MarkView
defaultMarkView summary position =
  { gridBelow = Nothing
  , gridAbove = Nothing
  , tick = Just simpleTick
  , view = Just (simpleLabel position)
  }


{-| -}
defaultMark : Report -> Float -> Mark
defaultMark summary position =
  { position = position
  , view = defaultMarkView summary position
  }


{-| A nice grey line which goes from one side of you plot to the other.
-}
simpleLine : Report -> LineView
simpleLine summary =
  fullLine [ stroke darkGrey ] summary


{-| -}
simpleTick : TickView
simpleTick =
  { length = 5
  , attributes = [ stroke darkGrey ]
  }


{-| -}
simpleLabel : Float -> Svg Never
simpleLabel position =
  viewLabel [] (toString position)


{-| -}
viewLabel : List (Svg.Attribute msg) -> String -> Svg msg
viewLabel attributes string =
  text_ attributes [ tspan [] [ text string ] ]


{-| A line which goes from one end of the plot to the other.
-}
fullLine : List (Attribute Never) -> Report -> LineView
fullLine attributes summary =
  { attributes = style "pointer-events: none;" :: attributes
  , start = summary.min
  , end = summary.max
  }


{-| -}
closestToZero : Float -> Float -> Float
closestToZero min max =
  clamp min max 0


{-| For decently spaces positions. Useful in tick/label and grid configurations.
-}
decentPositions : Report -> List Float
decentPositions summary =
  interval 0 (niceInterval summary.min summary.max 10) summary


{-| For ticks with a particular interval. The first value passed if the offset,
  and the second value is actual interval. The offset in useful when you want
   two sets of ticks with different views. For example if you want a long ticks
   at every 2 * x and a small ticks at every 2 * x + 1.
-}
interval : Float -> Float -> Report -> List Float
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



-- UTILS


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
