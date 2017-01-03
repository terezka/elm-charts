module Internal.Bars
    exposing
        ( Config
        , StyleConfig
        , Group
        , LabelInfo
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
import Internal.Label as Label


type alias Group =
    { xValue : Value
    , yValues : List Value
    }


type alias Config msg =
    { stackBy : Orientation
    , labelConfig : Label.StyleConfig LabelInfo msg
    , maxWidth : MaxWidth
    }


type alias StyleConfig msg =
    { style : Style
    , customAttrs : List (Svg.Attribute msg)
    }


type alias LabelInfo =
    { index : Int
    , xValue : Value
    , yValue : Value
    }


defaultConfig : Config msg
defaultConfig =
    { stackBy = X
    , labelConfig = defaultStyleConfigLabel
    , maxWidth = Percentage 100
    }


defaultStyleConfig : StyleConfig msg
defaultStyleConfig =
    { style = [ ( "stroke", "transparent" ) ]
    , customAttrs = []
    }


defaultStyleConfigLabel : Label.StyleConfig LabelInfo msg
defaultStyleConfigLabel =
    let
        config =
            Label.defaultStyleConfig
    in
        { config | format = always "" }



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
        Svg.g [] (List.map (viewGroup meta config styleConfigs width) groups)


viewGroupStackedX : Meta -> Config msg -> List (StyleConfig msg) -> Float -> Group -> Svg.Svg msg
viewGroupStackedX meta config styleConfigs width { xValue, yValues } =
    let
        props =
            List.indexedMap (getPropsStackedX meta config styleConfigs width xValue) yValues
    in
        Svg.g [] (List.map2 viewBar props styleConfigs)


getPropsStackedX : Meta -> Config msg -> List (StyleConfig msg) -> Float -> Value -> Int -> Value -> ( Float, Float, Point, Svg.Svg msg )
getPropsStackedX meta config styleConfigs width xValue index yValue =
    let
        ( _, originY ) =
            meta.toSvgCoords ( 0, 0 )

        offsetGroup =
            toFloat (List.length styleConfigs) * width / 2

        offsetBar =
            toFloat index * width

        ( xSvgPure, ySvg ) =
            meta.toSvgCoords ( xValue, yValue )

        xSvg =
            xSvgPure - offsetGroup + offsetBar

        label =
            Label.defaultView config.labelConfig X { index = index, yValue = yValue, xValue = xValue }

        height =
            abs (originY - ySvg)
    in
        ( width, height, ( xSvg, min originY ySvg ), label )


viewGroupStackedY : Meta -> Config msg -> List (StyleConfig msg) -> Float -> Group -> Svg.Svg msg
viewGroupStackedY meta config styleConfigs width { xValue, yValues } =
    let
        props =
            List.indexedMap
                (getPropsStackedY meta config styleConfigs width xValue yValues)
                yValues
    in
        Svg.g [] (List.map2 viewBar props styleConfigs |> List.reverse)


getPropsStackedY : Meta -> Config msg -> List (StyleConfig msg) -> Float -> Value -> List Value -> Int -> Value -> ( Float, Float, Point, Svg.Svg msg )
getPropsStackedY meta config styleConfigs width xValue yValues index yValue =
    let
        offsetGroup =
            width / 2

        offsetBar =
            List.take index yValues
                |> List.filter (\y -> (y < 0) == (yValue < 0))
                |> List.sum

        ( xSvgPure, ySvg ) =
            meta.toSvgCoords ( xValue, yValue + offsetBar )

        xSvg =
            xSvgPure - offsetGroup

        label =
            Label.defaultView config.labelConfig X { index = index, yValue = yValue, xValue = xValue }

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
        [ viewRect styleConfig ( xSvg, ySvg ) width height
        , Svg.g
            [ Svg.Attributes.transform (toTranslate ( xSvg + width / 2, ySvg + 5 ))
            , Svg.Attributes.style "text-anchor: middle;"
            ]
            [ label ]
        ]


viewRect : StyleConfig msg -> Point -> Float -> Float -> Svg.Svg msg
viewRect styleConfig ( xSvg, ySvg ) width height =
    Svg.rect
        ([ Svg.Attributes.x (toString xSvg)
         , Svg.Attributes.y (toString ySvg)
         , Svg.Attributes.width (toString width)
         , Svg.Attributes.height (toString height)
         , Svg.Attributes.style (toStyle styleConfig.style)
         ]
            ++ styleConfig.customAttrs
        )
        []


toAutoWidth : Meta -> Config msg -> List (StyleConfig msg) -> List Group -> Float
toAutoWidth { scale, toSvgCoords } { maxWidth, stackBy } styleConfigs groups =
    let
        width =
            case stackBy of
                X ->
                    1 / toFloat (List.length styleConfigs)

                Y ->
                    1
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
    List.foldl (foldPoints config) [] groups


foldPoints : Config msg -> Group -> List Point -> List Point
foldPoints { stackBy } { xValue, yValues } points =
    if stackBy == X then
        points ++ [ ( xValue, getLowest yValues ), ( xValue, getHighest yValues ) ]
    else
        let
            ( positive, negative ) =
                List.partition (\y -> y >= 0) yValues
        in
            points ++ [ ( xValue, List.sum positive ), ( xValue, List.sum negative ) ]


getYValues : Value -> List Group -> Maybe (List Value)
getYValues xValue groups =
    List.map (\{ xValue, yValues } -> ( xValue, Just yValues )) groups
        |> List.filter (\( x, _ ) -> x == xValue)
        |> List.head
        |> Maybe.withDefault ( 0, Nothing )
        |> Tuple.second
