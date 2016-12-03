module Internal.Bars exposing (..)

import Svg
import Svg.Attributes
import Internal.Types exposing (..)
import Internal.Draw exposing (..)
import Internal.Stuff exposing (..)


type alias Config a =
    { style : Style
    , maxWidth : Maybe Float
    , customAttrs : List (Svg.Attribute a)
    }


defaultConfig : Config a
defaultConfig =
    { style = [ ( "fill", "transparent" ) ]
    , maxWidth = Nothing
    , customAttrs = []
    }


view : Meta -> Config a -> List Point -> Svg.Svg a
view ({ toSvgCoords, scale } as plotProps) ({ style, maxWidth } as config) points =
    let
        svgPoints =
            List.map toSvgCoords points

        (_, originY) =
            toSvgCoords ( 0, 0 )

        width =
            toBarWidth scale config points
    in
        Svg.g
            [ Svg.Attributes.style (toStyle style) ]
            (List.map (toBar width originY) svgPoints)


toBar : Float -> Float -> Point -> Svg.Svg a
toBar width originY ( x, y ) =
    Svg.rect
        [ Svg.Attributes.x (toString <| x - (width / 2) )
        , Svg.Attributes.y (toString <| y)
        , Svg.Attributes.width (toString width)
        , Svg.Attributes.height (toString <| originY - y)
        ]
        []


toBarWidth : Scale -> Config a -> List Point -> Float
toBarWidth { length, range } { maxWidth } points =
    let
        rangeBar =
            List.map Tuple.first points

        ( lowestX, highestX ) =
            ( getLowest rangeBar, getHighest rangeBar )

        widthAuto =
            (length * (highestX - lowestX) / range) / (toFloat (List.length points) - 1) |> Debug.log "here"
    in
        case maxWidth of
            Nothing ->
                widthAuto

            Just max ->
                if widthAuto > max then max else widthAuto
