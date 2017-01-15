module Internal.Scale exposing (..)

import Internal.Types exposing (..)
import Internal.Stuff exposing (..)


getScale : Float -> EdgesAny (Float -> Float) -> Maybe Edges -> Edges -> ( Value, Value ) -> List Value -> Scale
getScale lengthTotal restrictRange internalBounds offset ( paddingBottomPx, paddingTopPx ) values =
    let
        length =
            lengthTotal - offset.lower - offset.upper

        boundsNatural =
            Edges (getLowest values) (getHighest values)

        boundsPadded =
            foldBounds internalBounds boundsNatural

        bounds =
            { lower = restrictRange.lower boundsPadded.lower
            , upper = restrictRange.upper boundsPadded.upper
            }

        range =
            getRange bounds.lower bounds.upper

        paddingTop =
            pixelsToValue length range paddingTopPx

        paddingBottom =
            pixelsToValue length range paddingBottomPx
    in
        { lowest = bounds.lower - paddingBottom
        , highest = bounds.upper + paddingTop
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
