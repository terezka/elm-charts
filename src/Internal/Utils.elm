module Internal.Utils exposing (..)

import Svg exposing (Svg, text)
import Round
import Regex
import Array


-- GENERAL


{-| -}
viewMaybe : Maybe a -> (a -> Svg msg) -> Svg msg
viewMaybe a view =
  Maybe.withDefault (text "") (Maybe.map view a)



-- DOM STUFF


translate : Float -> Float -> String
translate x y =
  "translate(" ++ toString x ++ ", " ++ toString y ++ ")"



-- COLOR STUFF


{-| -}
gradient : Int -> Int -> Int -> Float -> String
gradient r g b opacity =
  "rgba("
    ++ toString r
    ++ ", "
    ++ toString g
    ++ ", "
    ++ toString b
    ++ ", "
    ++ toString opacity
    ++ ")"


{-| -}
chunk : List String -> Float -> String
chunk colors proportion =
  Array.get (chunkColorIndex colors proportion) (Array.fromList colors)
    |> Maybe.withDefault "-- doesn't happen (hopefully) --"


chunkColorIndex : List String -> Float -> Int
chunkColorIndex colors proportion =
  proportion
    * toFloat (List.length colors)
    |> round
    |> max 0
    |> min (List.length colors - 1)



-- NUMBER STUFF


{-| -}
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


firstValue : Float -> Float -> Float -> Float
firstValue delta min intersection =
  min + (intersection - min - offset delta (intersection - min))


offset : Float -> Float -> Float
offset precision value =
  toFloat (floor (value / precision)) * precision


{-| -}
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
