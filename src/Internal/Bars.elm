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


defaultLabelView : Int -> Float -> Svg.Svg msg
defaultLabelView _ _ =
    Svg.text ""



-- VIEW


view : Meta -> Config msg -> List (StyleConfig msg) -> List Group -> Svg.Svg msg
view meta config styleConfigs groups =
    let
        width =
            toBarWidth config groups (toAutoWidth meta config styleConfigs groups)

        viewGroup =
            case config.stackBy of
                X ->
                    viewGroupStackedX

                Y ->
                    viewGroupStackedY
    in
        Svg.g [] (List.indexedMap (viewGroup meta config styleConfigs width) groups)


viewGroupStackedX : Meta -> Config msg -> List (StyleConfig msg) -> Float -> Int -> Group -> Svg.Svg msg
viewGroupStackedX ({ toSvgCoords, scale } as meta) config styleConfigs width groupIndex group =
    let
        props =
            List.indexedMap (getPropsStackedX meta config styleConfigs width groupIndex) group
    in
        Svg.g [] (List.map2 viewBar props styleConfigs)


getPropsStackedX : Meta -> Config msg -> List (StyleConfig msg) -> Float -> Int -> Int -> Value -> ( Float, Float, Point, Svg.Svg msg )
getPropsStackedX meta config styleConfigs width groupIndex index yValue =
    let
        ( _, originY ) =
            meta.toSvgCoords ( 0, 0 )

        offsetGroup =
            toFloat (List.length styleConfigs) * width / 2

        offsetBar =
            toFloat index * width

        ( xSvgPure, ySvg ) =
            meta.toSvgCoords ( toFloat groupIndex, yValue )

        xSvg =
            xSvgPure - offsetGroup + offsetBar

        label =
            config.labelView index yValue

        height =
            abs (originY - ySvg)
    in
        ( width, height, ( xSvg, min originY ySvg ), label )


viewGroupStackedY : Meta -> Config msg -> List (StyleConfig msg) -> Float -> Int -> Group -> Svg.Svg msg
viewGroupStackedY meta config styleConfigs width groupIndex group =
    let
        props =
            List.indexedMap
                (getPropsStackedY meta config styleConfigs width groupIndex group)
                group
    in
        Svg.g [] (List.map2 viewBar props styleConfigs)


getPropsStackedY : Meta -> Config msg -> List (StyleConfig msg) -> Float -> Int -> Group -> Int -> Value -> ( Float, Float, Point, Svg.Svg msg )
getPropsStackedY meta config styleConfigs width groupIndex group index yValue =
    let
        offsetGroup =
            width / 2

        offsetBar =
            List.take index group
                |> List.filter (\y -> (y < 0) == (yValue < 0))
                |> List.sum

        ( xSvgPure, ySvg ) =
            meta.toSvgCoords ( toFloat groupIndex, yValue + offsetBar )

        xSvg =
            xSvgPure - offsetGroup

        label =
            config.labelView index yValue

        height =
            yValue * meta.scale.y.length / meta.scale.y.range

        heightOffset =
            if height < 0 then
                height
            else
                0
    in
        ( width, abs height, ( xSvg, ySvg + heightOffset ), label )


viewBar : ( Float, Float, Point, Svg.Svg msg ) -> StyleConfig msg -> Svg.Svg msg
viewBar ( width, height, ( xSvg, ySvg ), label ) styleConfig =
    Svg.g
        []
        [ Svg.g
            [ Svg.Attributes.transform (toTranslate ( xSvg + width / 2, ySvg - 5 ))
            , Svg.Attributes.style "text-anchor: middle;"
            ]
            [ label ]
        , viewRect styleConfig ( xSvg, ySvg ) width height
        ]


viewRect : StyleConfig msg -> Point -> Float -> Float -> Svg.Svg msg
viewRect styleConfig ( xSvg, ySvg ) width height =
    Svg.rect
        [ Svg.Attributes.x (toString xSvg)
        , Svg.Attributes.y (toString ySvg)
        , Svg.Attributes.width (toString width)
        , Svg.Attributes.height (toString height)
        , Svg.Attributes.style (toStyle styleConfig.style)
        ]
        []


toAutoWidth : Meta -> Config msg -> List (StyleConfig msg) -> List Group -> Float
toAutoWidth { scale, toSvgCoords } { maxWidth } styleConfigs groups =
    let
        width =
            1 / toFloat (List.length styleConfigs)
    in
        width * scale.x.length / scale.x.range


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
    List.indexedMap (toPoint config) groups


toPoint : Config msg -> Int -> Group -> Point
toPoint { stackBy } index group =
    if stackBy == X then
        ( toFloat index, getHighest group )
    else
        ( toFloat index, List.sum group )


getYValues : Value -> List Group -> Maybe (List Value)
getYValues xValue groups =
    List.indexedMap (\i group -> ( i, Just group )) groups
        |> List.filter (\( i, g ) -> toFloat i == xValue)
        |> List.head
        |> Maybe.withDefault ( 0, Nothing )
        |> Tuple.second
