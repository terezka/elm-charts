module Internal.Stuff exposing (..)

import Internal.Types exposing (..)
import Svg
import Svg.Attributes


{-| ...Sorry for the bad filename

    This is where I put all the functions which
    are like "ugh, why do I have to express this"
-}
getHighest : List Float -> Float
getHighest values =
    Maybe.withDefault 10 (List.maximum values)


getLowest : List Float -> Float
getLowest values =
    Maybe.withDefault 0 (List.minimum values)


getRange : Float -> Float -> Float
getRange lowest highest =
    highest - lowest


getEdgesX : List Point -> ( Float, Float )
getEdgesX points =
    getEdges <| List.map Tuple.first points


getEdgesY : List Point -> ( Float, Float )
getEdgesY points =
    getEdges <| List.map Tuple.second points


getEdges : List Float -> ( Float, Float )
getEdges range =
    ( getLowest range, getHighest range )


pixelsToValue : Float -> Float -> Float -> Float
pixelsToValue length range pixels =
    range * pixels / length


ceilToNearest : Float -> Float -> Float
ceilToNearest precision value =
    toFloat (ceiling (value / precision)) * precision


getDifference : Float -> Float -> Float
getDifference a b =
    abs <| a - b


getClosest : Float -> Float -> Float -> Float
getClosest value candidate closest =
    if getDifference value candidate < getDifference value closest then
        candidate
    else
        closest


toNearest : List Float -> Float -> Float
toNearest values value =
    List.foldr (getClosest value) 0 values


(?) : Orientation -> a -> a -> a
(?) orientation x y =
    case orientation of
        X ->
            x

        Y ->
            y


getValues : Orientation -> List Point -> List Float
getValues orientation =
    let
        toValue =
            (?) orientation Tuple.first Tuple.second
    in
        List.map toValue


flipOriented : Oriented a -> Oriented a
flipOriented { x, y } =
    { x = y, y = x }


foldOriented : (a -> a) -> Orientation -> Oriented a -> Oriented a
foldOriented fold orientation old =
    case orientation of
        X ->
            { old | x = fold old.x }

        Y ->
            { old | y = fold old.y }
