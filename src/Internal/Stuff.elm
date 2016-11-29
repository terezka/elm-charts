module Internal.Stuff exposing (..)

import Internal.Types exposing (..)
import Svg
import Svg.Attributes


{-| ...Sorry for the bad filename
    
    This is where I put all the functions which
    are like "ugh, why do I have to express this
-} 


getHighest : List Float -> Float
getHighest values =
    Maybe.withDefault 10 (List.maximum values)


getLowest : List Float -> Float
getLowest values =
    min 0 (Maybe.withDefault 0 (List.minimum values))


getRange : Float -> Float -> Float
getRange lowest highest =
    abs lowest + abs highest


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


(?) : Orientation -> a -> a -> a
(?) orientation x y =
    case orientation of
        X ->
            x

        Y ->
            y
