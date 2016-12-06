module Internal.Bars exposing (Config, defaultConfig, view)

import Svg
import Svg.Attributes
import Internal.Types exposing (..)
import Internal.Draw exposing (..)
import Internal.Stuff exposing (..)


type alias Config a =
    { style : Style
    , customAttrs : List (Svg.Attribute a)
    }


defaultConfig : Config a
defaultConfig =
    { style = [ ( "stroke", "transparent" ) ]
    , customAttrs = []
    }


view : Meta -> PileMeta -> MaxWidth -> Int -> Config a -> List Point -> Svg.Svg a
view ({ toSvgCoords, scale } as meta) pileMeta maxWidth index ({ style } as config) points =
    let
        svgPoints =
            List.map toSvgCoords points

        (_, originY) =
            toSvgCoords ( 0, 0 )

        width =
            toBarWidth meta pileMeta maxWidth points
    in
        Svg.g
            [ Svg.Attributes.style (toStyle style) ]
            (List.map (toBar pileMeta index width originY) svgPoints)


toBar : PileMeta -> Int -> Float -> Float -> Point -> Svg.Svg a
toBar pileMeta index width originY ( x, y ) =
    Svg.rect
        [ Svg.Attributes.x <| toString <| x + barOffset pileMeta index width
        , Svg.Attributes.y <| toString <| min originY y
        , Svg.Attributes.width <| toString <| width
        , Svg.Attributes.height <| toString <| abs <| originY - y
        ]
        []


toBarWidth : Meta -> PileMeta -> MaxWidth -> List Point -> Float
toBarWidth { scale } pileMeta maxWidth points =
    let
        widthAuto =
            barAutoWidth scale pileMeta
    in
        case maxWidth of
            Percentage perc ->
                widthAuto * (toFloat perc) / 100

            Fixed max ->
                if widthAuto > (toFloat max) then toFloat max else widthAuto


barAutoWidth : Scale -> PileMeta -> Float
barAutoWidth { length, range } ({ highest, lowest, pointCount, numOfBarSeries } as pileMeta) =
    (length * (highest - lowest) / range) / (toFloat <| pointCount * numOfBarSeries)


barOffset : PileMeta -> Int -> Float -> Float
barOffset { numOfBarSeries } index width =
    width * (toFloat index - (toFloat numOfBarSeries / 2))

