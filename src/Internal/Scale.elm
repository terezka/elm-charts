module Internal.Scale exposing (..)

import Internal.Types exposing (..)
import Internal.Stuff exposing (..)


getScale : Float -> EdgesAny (Float -> Float) -> ( Value, Value ) -> ( Value, Value ) -> List Value -> Maybe Edges -> Scale
getScale lengthTotal restrictRange ( offsetLeft, offsetRight ) ( paddingBottomPx, paddingTopPx ) values pileEdges =
    let
        length =
            lengthTotal - offsetLeft - offsetRight

        lowest =
            getScaleLowest restrictRange.lower values pileEdges

        highest =
            getScaleHighest restrictRange.upper values pileEdges

        range =
            getRange lowest highest

        paddingTop =
            pixelsToValue length range paddingTopPx

        paddingBottom =
            pixelsToValue length range paddingBottomPx
    in
        { lowest = lowest - paddingBottom
        , highest = highest + paddingTop
        , range = range + paddingBottom + paddingTop
        , length = length
        , offset = offsetLeft
        }


getScaleLowest : (Float -> Float) -> List Value -> Maybe Edges -> Value
getScaleLowest toLowest values pileEdges =
    getAutoLowest pileEdges (getLowest values)
    |> toLowest


getAutoLowest : Maybe Edges -> Value -> Value
getAutoLowest pileEdges lowestFromValues =
    case pileEdges of
        Just { lower } ->
            min lower lowestFromValues

        Nothing ->
            lowestFromValues


getScaleHighest : (Float -> Float) -> List Value -> Maybe Edges -> Value
getScaleHighest toHighest values pileEdges =
    getAutoHighest pileEdges (getHighest values)
    |> toHighest


getAutoHighest : Maybe Edges -> Value -> Value
getAutoHighest pileEdges highestFromValues =
    case pileEdges of
        Just { upper } ->
            max upper highestFromValues

        Nothing ->
            highestFromValues


scaleValue : Scale -> Value -> Value
scaleValue { length, range, offset } v =
    (v * length / range) + offset


unScaleValue : Scale -> Value -> Value
unScaleValue { length, range, offset, lowest } v =
    ((v - offset) * range / length) + lowest


fromSvgCoords : Scale -> Scale -> Point -> Point
fromSvgCoords xScale yScale ( x, y ) =
    ( unScaleValue xScale x
    , unScaleValue yScale (yScale.length - y)
    )


toSvgCoordsX : Scale -> Scale -> Point -> Point
toSvgCoordsX xScale yScale ( x, y ) =
    ( scaleValue xScale (abs xScale.lowest + x)
    , scaleValue yScale (yScale.highest - y)
    )


toSvgCoordsY : Scale -> Scale -> Point -> Point
toSvgCoordsY xScale yScale ( x, y ) =
    toSvgCoordsX xScale yScale ( y, x )