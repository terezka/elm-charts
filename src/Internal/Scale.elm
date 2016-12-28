module Internal.Scale exposing (..)

import Internal.Types exposing (..)
import Internal.Stuff exposing (..)


getScale : Float -> EdgesAny (Float -> Float) -> Edges -> ( Value, Value ) -> List Value -> Scale
getScale lengthTotal restrictRange offset ( paddingBottomPx, paddingTopPx ) values =
    let
        length =
            lengthTotal - offset.lower - offset.upper

        lowest =
            restrictRange.lower (getLowest values)

        highest =
            restrictRange.upper (getHighest values)

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
        , offset = offset
        }


scaleValue : Scale -> Value -> Value
scaleValue { length, range, offset } v =
    (v * length / range) + offset.lower


unScaleValue : Scale -> Value -> Value
unScaleValue { length, range, offset, lowest } v =
    ((v - offset.lower) * range / length) + lowest


fromSvgCoords : Scale -> Scale -> Point -> Point
fromSvgCoords xScale yScale ( x, y ) =
    ( unScaleValue xScale x
    , unScaleValue yScale (yScale.length - y)
    )


toSvgCoordsX : Scale -> Scale -> Point -> Point
toSvgCoordsX xScale yScale ( x, y ) =
    ( scaleValue xScale (x - xScale.lowest)
    , scaleValue yScale (yScale.highest - y)
    )


toSvgCoordsY : Scale -> Scale -> Point -> Point
toSvgCoordsY xScale yScale ( x, y ) =
    toSvgCoordsX xScale yScale ( y, x )
