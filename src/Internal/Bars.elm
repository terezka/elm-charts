module Internal.Bars
    exposing
        ( Config
        , StyleConfig
        , defaultConfig
        , defaultStyleConfig
        , view
        , toPoints
        , getYValues
        )

import Svg
import Svg.Attributes
import Internal.Types exposing (Style, Orientation(..), MaxWidth(..), Meta, Value, Point, Edges, Oriented, Scale)
import Internal.Draw exposing (..)
import Internal.Stuff exposing (..)


type alias Group =
    List Value


type alias Config msg =
    { stackBy : Orientation
    , labelView : Int -> Float -> Svg.Svg msg
    , maxWidth : MaxWidth
    }


type alias StyleConfig msg =
    { style : Style
    , customAttrs : List (Svg.Attribute msg)
    }


defaultConfig : Config msg
defaultConfig =
    { stackBy = X
    , labelView = defaultLabelView
    , maxWidth = Percentage 100
    }


defaultStyleConfig : StyleConfig msg
defaultStyleConfig =
    { style = [ ( "stroke", "transparent" ) ]
    , customAttrs = []
    }



-- VIEW


view : Meta -> Config msg -> List (StyleConfig msg) -> List Group -> Svg.Svg msg
view meta config styleConfigs groups =
    let
        groupDelta =
            meta.scale.x.range / toFloat (List.length groups)

        width =
            toBarWidth config groups (toAutoWidth meta config styleConfigs groups)
    in
        Svg.g [] (List.indexedMap (viewGroup meta config styleConfigs groupDelta width) groups)


viewGroup : Meta -> Config msg -> List (StyleConfig msg) -> Float -> Float -> Int -> Group -> Svg.Svg msg
viewGroup ({ toSvgCoords, scale } as meta) config styleConfigs groupDelta width groupIndex group =
    let
        ( _, originY ) =
            toSvgCoords ( 0, 0 )

        svgPoints =
            List.indexedMap
                (\i y ->
                    let
                        ( xSvg, ySvg ) =
                            toSvgCoords ( toFloat groupIndex, y )
                    in
                        ( xSvg + toFloat i * width, ySvg )
                )
                group

        labels =
            List.indexedMap config.labelView group

        offset =
            toFloat (List.length styleConfigs) * width / 2
    in
        Svg.g [] (List.map3 (viewBar width originY offset) styleConfigs svgPoints labels)


defaultLabelView : Int -> Float -> Svg.Svg msg
defaultLabelView _ _ =
    Svg.text ""


viewBar : Float -> Float -> Float -> StyleConfig msg -> Point -> Svg.Svg msg -> Svg.Svg msg
viewBar width originY offset styleConfig ( x, y ) label =
    let
        xPos =
            x - offset

        yPos =
            min originY y
    in
        Svg.g
            []
            [ Svg.g
                [ Svg.Attributes.transform (toTranslate ( xPos + width / 2, yPos - 5 ))
                , Svg.Attributes.style "text-anchor: middle;"
                ]
                [ label ]
            , Svg.rect
                [ Svg.Attributes.x (toString xPos)
                , Svg.Attributes.y (toString yPos)
                , Svg.Attributes.width (toString width)
                , Svg.Attributes.height (toString (abs originY - y))
                , Svg.Attributes.style (toStyle styleConfig.style)
                ]
                []
            ]


toAutoWidth : Meta -> Config msg -> List (StyleConfig msg) -> List Group -> Float
toAutoWidth { scale, toSvgCoords } { maxWidth } styleConfigs groups =
    let
        width =
            1 / toFloat (List.length styleConfigs)
    in
        (width * scale.x.length / scale.x.range)


toBarWidth : Config msg -> List Group -> Float -> Float
toBarWidth { maxWidth } groups default =
    case maxWidth of
        Percentage perc ->
            default * (toFloat perc) / 100

        Fixed max ->
            if default > (toFloat max) then
                toFloat max
            else
                default


toPoints : Config msg -> List Group -> List Point
toPoints config groups =
    List.indexedMap (\i group -> ( toFloat i, getHighest group )) groups


getYValues : Value -> List Group -> Maybe (List Value)
getYValues xValue groups =
    List.indexedMap (\i group -> ( i, Just group )) groups
        |> List.filter (\( i, g ) -> toFloat i == xValue)
        |> List.head
        |> Maybe.withDefault ( 0, Nothing )
        |> Tuple.second
