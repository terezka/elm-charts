module Internal.Bars exposing (..)

import Svg
import Svg.Attributes
import Internal.Types exposing (..)
import Internal.Draw exposing (..)
import Internal.Stuff exposing (..)


type alias Config a =
    { style : Style
    , maxWidth : Maybe Float
    , points : List Point
    , customAttrs : List (Svg.Attribute a)
    }


defaultConfig : Config a
defaultConfig =
    { style = [ ( "fill", "transparent" ) ]
    , maxWidth = Nothing
    , points = []
    , customAttrs = []
    }


view : Meta -> Int -> Config a -> List Point -> Svg.Svg a
view ({ toSvgCoords, scale, barsMeta } as meta) index ({ style, maxWidth } as config) points =
    let
        svgPoints =
            List.map toSvgCoords points

        (_, originY) =
            toSvgCoords ( 0, 0 )

        width =
            toBarWidth meta config points
    in
        Svg.g
            [ Svg.Attributes.style (toStyle style) ]
            (List.map (toBar barsMeta index width originY) svgPoints)


toBar : BarsMeta -> Int -> Float -> Float -> Point -> Svg.Svg a
toBar barsMeta index width originY ( x, y ) =
    Svg.rect
        [ Svg.Attributes.x (toString <| x + barOffset barsMeta index width )
        , Svg.Attributes.y (toString <| y)
        , Svg.Attributes.width (toString width)
        , Svg.Attributes.height (toString <| originY - y)
        ]
        []


toBarWidth : Meta -> Config a -> List Point -> Float
toBarWidth { barsMeta, scale } { maxWidth } points =
    let
        widthAuto =
            barAutoWidth scale barsMeta
    in
        case maxWidth of
            Nothing ->
                widthAuto

            Just max ->
                if widthAuto > max then max else widthAuto


barAutoWidth : Scale -> BarsMeta -> Float
barAutoWidth { length, range } ({ highest, lowest, pointCount, amount } as barsMeta) =
    (length * (highest - lowest) / range) / (toFloat <| pointCount * amount)


barOffset : BarsMeta -> Int -> Float -> Float
barOffset { amount } index width =
    width * (toFloat index - (toFloat amount / 2))
