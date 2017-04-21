module Axis exposing (..)

{-| -}

import Svg exposing (Svg, Attribute, text_, tspan, text)
import Svg.Attributes exposing (style, stroke)
import Colors exposing (..)
import Internal.Utils exposing (..)


{-| -}
type alias Raport =
  { min : Float
  , max : Float
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
  , length : Int
  }



{-| A nice grey line which goes from one side of you plot to the other.
-}
simpleLine : Raport -> LineView
simpleLine =
  fullLine [ stroke darkGrey ]


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
stringLabel : String -> Svg Never
stringLabel string =
  viewLabel [] string


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
