module Axis exposing (..)

{-| -}

import Svg exposing (Svg, Attribute, text_, tspan, text)
import Svg.Attributes exposing (style, stroke)
import Colors exposing (..)
import Round
import Regex


{-| -}
type Axis
  = Axis (Raport -> View)
  | SometimesYouDontHaveAnAxis


{-| -}
type alias Raport =
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
  { gridBelow : Maybe (Raport -> LineView)
  , gridAbove : Maybe (Raport -> LineView)
  , label : Maybe (Svg Never)
  , tick : Maybe TickView
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


axis : (Raport -> View) -> Axis
axis =
  Axis


{-| -}
defaultAxis : Raport -> View
defaultAxis raport =
  { position = \min max -> min
  , axisLine = Just (simpleLine raport)
  , marks = List.map gridyMark (decentPositions raport)
  , mirror = False
  }


{-| -}
defaultMarkView : Float -> MarkView
defaultMarkView position =
  { gridBelow = Nothing
  , gridAbove = Nothing
  , tick = Just simpleTick
  , label = Just (simpleLabel position)
  }


{-| -}
defaultMark : Float -> Mark
defaultMark position =
  { position = position
  , view = defaultMarkView position
  }


{-| -}
gridyMarkView : Float -> MarkView
gridyMarkView position =
  { gridBelow = Just simpleLine
  , gridAbove = Nothing
  , tick = Just simpleTick
  , label = Just (simpleLabel position)
  }


{-| -}
gridyMark : Float -> Mark
gridyMark position =
  { position = position
  , view = gridyMarkView position
  }



{-| A nice grey line which goes from one side of you plot to the other.
-}
simpleLine : Raport -> LineView
simpleLine raport =
  fullLine [ stroke darkGrey ] raport


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
fullLine : List (Attribute Never) -> Raport -> LineView
fullLine attributes raport =
  { attributes = style "pointer-events: none;" :: attributes
  , start = raport.min
  , end = raport.max
  }


{-| -}
closestToZero : Float -> Float -> Float
closestToZero min max =
  clamp min max 0


{-| For decently spaces positions. Useful in tick/label and grid configurations.
-}
decentPositions : Raport -> List Float
decentPositions raport =
  interval 0 (niceInterval raport.min raport.max 10) raport


{-| For ticks with a particular interval. The first value passed if the offset,
  and the second value is actual interval. The offset in useful when you want
   two sets of ticks with different views. For example if you want a long ticks
   at every 2 * x and a small ticks at every 2 * x + 1.
-}
interval : Float -> Float -> Raport -> List Float
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
      axis <| \raport ->
        { position = ClosestToZero
        , axisLine = Just (simpleLine raport)
        , ticks = List.map simpleTick (decentPositions raport |> remove 0)
        , labels = List.map simpleLabel (decentPositions raport |> remove 0)
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
