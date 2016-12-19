module Internal.Bars exposing (Config, defaultConfig, view)

import Svg
import Svg.Attributes
import Internal.Types exposing (..)
import Internal.Draw exposing (..)


type alias Config a =
    { labelView : Float -> Svg.Svg a
    , style : Style
    , customAttrs : List (Svg.Attribute a)
    }


defaultConfig : Config a
defaultConfig =
    { labelView = defaultLabelView
    , style = [ ( "stroke", "transparent" ) ]
    , customAttrs = []
    }


view : Meta -> PileMeta -> MaxWidth -> Int -> Config a -> List Point -> Svg.Svg a
view ({ toSvgCoords } as meta) pileMeta maxWidth index ({ style, labelView } as config) points =
    let
        svgPoints =
            List.map toSvgCoords points

        ( _, originY ) =
            toSvgCoords ( 0, 0 )

        width =
            toBarWidth meta pileMeta maxWidth points
    in
        Svg.g [] (List.map (viewBar pileMeta index config width originY) svgPoints)


defaultLabelView : Float -> Svg.Svg msg
defaultLabelView _ =
    Svg.text ""


viewBar : PileMeta -> Int -> Config msg -> Float -> Float -> Point -> Svg.Svg msg
viewBar pileMeta index ({ style, labelView } as config) width originY ( x, y ) =
    let
        xPos =
            x + barOffset pileMeta index width

        yPos =
            min originY y
    in
        Svg.g
            []
            [ Svg.g
                [ Svg.Attributes.transform (toTranslate ( xPos + width / 2, yPos - 5 ))
                , Svg.Attributes.style "text-anchor: middle;"
                ]
                [ labelView y ]
            , Svg.rect
                [ Svg.Attributes.x (toString xPos)
                , Svg.Attributes.y (toString yPos)
                , Svg.Attributes.width (toString width)
                , Svg.Attributes.height (toString (abs originY - y))
                , Svg.Attributes.style (toStyle style)
                ]
                []
            ]


toBarWidth : Meta -> PileMeta -> MaxWidth -> List Point -> Float
toBarWidth { scale } pileMeta maxWidth points =
    let
        widthAuto =
            barAutoWidth scale.x pileMeta
    in
        case maxWidth of
            Percentage perc ->
                widthAuto * (toFloat perc) / 100

            Fixed max ->
                if widthAuto > (toFloat max) then
                    toFloat max
                else
                    widthAuto


barAutoWidth : Scale -> PileMeta -> Float
barAutoWidth { length, range } ({ highest, lowest, pointCount, numOfBarSeries } as pileMeta) =
    (length * (highest - lowest) / range) / (toFloat <| pointCount * numOfBarSeries)


barOffset : PileMeta -> Int -> Float -> Float
barOffset { numOfBarSeries } index width =
    width * (toFloat index - (toFloat numOfBarSeries / 2))
