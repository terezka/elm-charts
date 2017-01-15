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
import Plot.Types exposing (Style, Point)
import Internal.Types exposing (Orientation(..), MaxWidth(..), Meta, Value, Edges, Oriented, Scale)
import Internal.Draw exposing (..)
import Internal.Stuff exposing (..)
import Internal.Label as Label


type alias Group =
    { xValue : Value
    , yValues : List Value
    }


type alias Config msg =
    { stackBy : Orientation
    , labelConfig : Label.Config LabelInfo msg
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
    , labelConfig = Label.defaultConfig
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
        width =
            toBarWidth config groups (toAutoWidth meta config styleConfigs groups)
    in
        Svg.g [] (List.map (viewGroup meta config styleConfigs width) groups)


viewGroup : Meta -> Config msg -> List (StyleConfig msg) -> Float -> Group -> Svg.Svg msg
viewGroup meta config styleConfigs width group =
    let
        labelInfos =
            List.indexedMap
                (\i y -> { index = i, xValue = group.xValue, yValue = y })
                group.yValues

        toCoords =
            toStackedCoords meta config styleConfigs width group
    in
        Svg.g []
            [ Svg.g []
                (List.map2
                    (\styleConfig info ->
                        viewBar meta width (toCoords info) config styleConfig info
                    )
                    styleConfigs
                    labelInfos
                )
            , Svg.g []
                (Label.view
                    config.labelConfig
                    (\info -> placeLabel width (toCoords info))
                    labelInfos
                )
            ]


toLength : Meta -> Config msg -> LabelInfo -> Value
toLength meta config bar =
    case config.stackBy of
        X ->
            toLengthTouchingXAxis meta config bar

        Y ->
            if bar.index == 0 then
                toLengthTouchingXAxis meta config bar
            else
                bar.yValue * meta.scale.y.length / meta.scale.y.range


toLengthTouchingXAxis : Meta -> Config msg -> LabelInfo -> Value
toLengthTouchingXAxis { scale } config { yValue, index } =
    (yValue - (clamp scale.y.lowest scale.y.highest 0)) * scale.y.length / scale.y.range


toXStackedOffset : List (StyleConfig msg) -> Float -> LabelInfo -> Value
toXStackedOffset styleConfigs width { index, yValue } =
    let
        offsetGroup =
            toFloat (List.length styleConfigs) * width / 2

        offsetBar =
            toFloat index * width
    in
        offsetBar - offsetGroup


toYStackedOffset : Group -> LabelInfo -> Value
toYStackedOffset { yValues } { index, yValue } =
    List.take index yValues
        |> List.filter (\y -> (y < 0) == (yValue < 0))
        |> List.sum


toStackedCoords : Meta -> Config msg -> List (StyleConfig msg) -> Float -> Group -> LabelInfo -> Point
toStackedCoords meta config styleConfigs width group bar =
    case config.stackBy of
        X ->
            ( bar.xValue, max (min 0 meta.scale.y.highest) bar.yValue )
                |> meta.toSvgCoords
                |> addDisplacement ( toXStackedOffset styleConfigs width bar, 0 )

        Y ->
            ( bar.xValue, bar.yValue )
                |> addDisplacement ( 0, toYStackedOffset group bar )
                |> meta.toSvgCoords
                |> addDisplacement
                    ( -width / 2
                    , min 0 (toLength meta config bar)
                    )


placeLabel : Float -> Point -> List (Svg.Attribute msg)
placeLabel width ( xSvg, ySvg ) =
    [ Svg.Attributes.transform (toTranslate ( xSvg + width / 2, ySvg ))
    , Svg.Attributes.style "text-anchor: middle;"
    ]


viewBar : Meta -> Float -> Point -> Config msg -> StyleConfig msg -> LabelInfo -> Svg.Svg msg
viewBar meta width ( xSvg, ySvg ) config styleConfig info =
    Svg.rect
        ([ Svg.Attributes.x (toString xSvg)
         , Svg.Attributes.y (toString ySvg)
         , Svg.Attributes.width (toString width)
         , Svg.Attributes.height (toString (abs (toLength meta config info)))
         , Svg.Attributes.style (toStyle styleConfig.style)
         ]
            ++ styleConfig.customAttrs
        )
        []



-- Calculate width


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



-- For meta calculations


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
