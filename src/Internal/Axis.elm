module Internal.Axis
    exposing
        ( Config
        , PositionOption(..)
        , ValueConfig(..)
        , defaultConfigX
        , defaultConfigY
        , view
        , getAxisPosition
        , getValues
        , getDelta
        )

import Plot.Types exposing (Point, Style)
import Internal.Types exposing (Orientation(..), Scale, Meta, Anchor(..), Value, IndexedInfo)
import Internal.Tick as Tick
import Internal.Label as Label
import Internal.Line as Line
import Internal.Draw as Draw exposing (..)
import Internal.Stuff exposing (..)
import Svg
import Svg.Attributes
import Round
import Regex


type alias Config msg =
    { tickConfig : Tick.Config LabelInfo msg
    , tickValues : ValueConfig
    , labelConfig : Label.Config LabelInfo msg
    , labelValues : Maybe (List Value)
    , lineConfig : Line.Config msg
    , orientation : Orientation
    , anchor : Anchor
    , cleanCrossings : Bool
    , position : PositionOption
    , classes : List String
    }


type PositionOption
    = Lowest
    | Highest
    | AtZero


type ValueConfig
    = AutoValues
    | FromDelta Float
    | FromCount Int
    | FromCustom (List Float)


type alias LabelInfo =
    { value : Float
    , index : Int
    }


defaultConfigX : Config msg
defaultConfigX =
    { tickConfig = Tick.defaultConfig
    , tickValues = AutoValues
    , labelConfig = Label.toDefaultConfig (.value >> toString)
    , labelValues = Nothing
    , lineConfig = Line.defaultConfig
    , orientation = X
    , cleanCrossings = False
    , anchor = Outer
    , position = AtZero
    , classes = []
    }


defaultConfigY : Config msg
defaultConfigY =
    { defaultConfigX | orientation = Y }


view : Meta -> Config msg -> Svg.Svg msg
view ({ scale, toSvgCoords, oppositeAxisCrossings } as meta) ({ lineConfig, tickConfig, labelConfig, orientation, cleanCrossings, position, anchor, classes } as config) =
    let
        tickValues =
            toTickValues meta config

        labelValues =
            toLabelValues config tickValues

        axisPosition =
            getAxisPosition scale.y position
    in
        Svg.g
            [ Draw.classAttributeOriented "axis" orientation classes ]
            [ viewAxisLine lineConfig meta axisPosition
            , Svg.g
                [ Svg.Attributes.class "elm-plot__axis__ticks" ]
                (List.map (placeTick meta config axisPosition (Tick.toView tickConfig orientation)) (toIndexInfo tickValues))
            , Svg.g
                [ Svg.Attributes.class "elm-plot__axis__labels"
                , Svg.Attributes.style <| toAnchorStyle anchor orientation
                ]
                (Label.view labelConfig (placeLabel meta config axisPosition) (toIndexInfo labelValues))
            ]



-- View line


viewAxisLine : Line.Config msg -> Meta -> Float -> Svg.Svg msg
viewAxisLine { style, customAttrs } =
    Draw.fullLine
        ([ Svg.Attributes.style (toStyle style)
         , Svg.Attributes.class "elm-plot__axis__line"
         ]
            ++ customAttrs
        )



-- View labels


placeLabel : Meta -> Config msg -> Float -> LabelInfo -> List (Svg.Attribute msg)
placeLabel { toSvgCoords } ({ orientation, anchor } as config) axisPosition info =
    [ Svg.Attributes.transform <| toTranslate <| addDisplacement (getDisplacement anchor orientation) <| toSvgCoords ( info.value, axisPosition )
    , Svg.Attributes.class "elm-plot__axis__label"
    ]



-- View ticks


placeTick : Meta -> Config msg -> Float -> (LabelInfo -> Svg.Svg msg) -> LabelInfo -> Svg.Svg msg
placeTick { toSvgCoords } ({ orientation, anchor } as config) axisPosition view info =
    Svg.g
        [ Svg.Attributes.transform <| (toTranslate <| toSvgCoords ( info.value, axisPosition )) ++ " " ++ (toRotate anchor orientation)
        , Svg.Attributes.class "elm-plot__axis__tick"
        ]
        [ view info ]


getAxisPosition : Scale -> PositionOption -> Float
getAxisPosition { lowest, highest } position =
    case position of
        AtZero ->
            clamp lowest highest 0

        Lowest ->
            lowest

        Highest ->
            highest


toAnchorStyle : Anchor -> Orientation -> String
toAnchorStyle anchor orientation =
    case orientation of
        X ->
            "text-anchor: middle;"

        Y ->
            "text-anchor:" ++ getYAnchorStyle anchor ++ ";"


getYAnchorStyle : Anchor -> String
getYAnchorStyle anchor =
    case anchor of
        Inner ->
            "start"

        Outer ->
            "end"


{-| The displacements are just magic numbers, so no science. (Just defaults)
-}
getDisplacement : Anchor -> Orientation -> Point
getDisplacement anchor orientation =
    case orientation of
        X ->
            case anchor of
                Inner ->
                    ( 0, -15 )

                Outer ->
                    ( 0, 25 )

        Y ->
            case anchor of
                Inner ->
                    ( 10, 5 )

                Outer ->
                    ( -10, 5 )


toRotate : Anchor -> Orientation -> String
toRotate anchor orientation =
    case orientation of
        X ->
            case anchor of
                Inner ->
                    "rotate(180 0 0)"

                Outer ->
                    "rotate(0 0 0)"

        Y ->
            case anchor of
                Inner ->
                    "rotate(-90 0 0)"

                Outer ->
                    "rotate(90 0 0)"


filterValues : Meta -> Config msg -> List Float -> List Float
filterValues meta config values =
    if config.cleanCrossings then
        List.filter (isCrossing meta.oppositeAxisCrossings) values
    else
        values


isCrossing : List Float -> Float -> Bool
isCrossing crossings value =
    not <| List.member value crossings



-- Remember we always assume we're working with the x-axis. scale.x is therefore
-- just the scale we work with. It will also be the right one for the y-axis.


toTickValues : Meta -> Config msg -> List Value
toTickValues meta config =
    getValues config.tickValues meta.scale.x
        |> filterValues meta config


toLabelValues : Config msg -> List Value -> List Value
toLabelValues config tickValues =
    Maybe.withDefault tickValues config.labelValues



-- Resolve values


getValues : ValueConfig -> Scale -> List Value
getValues config =
    case config of
        AutoValues ->
            toValuesAuto

        FromDelta delta ->
            toValuesFromDelta delta

        FromCount count ->
            toValuesFromCount count

        FromCustom values ->
            always values


getFirstValue : Float -> Float -> Float
getFirstValue delta lowest =
    ceilToNearest delta lowest


getCount : Float -> Float -> Float -> Float -> Int
getCount delta lowest range firstValue =
    floor ((range - (abs lowest - abs firstValue)) / delta)


getDeltaPrecision : Float -> Int
getDeltaPrecision delta =
    delta
        |> toString
        |> Regex.find (Regex.AtMost 1) (Regex.regex "\\.[0-9]*")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
        |> String.length
        |> (-) 1
        |> min 0
        |> abs


getDelta : Float -> Int -> Float
getDelta range totalTicks =
    let
        -- calculate an initial guess at step size
        delta0 =
            range / (toFloat totalTicks)

        -- get the magnitude of the step size
        mag =
            floor (logBase 10 delta0)

        magPow =
            toFloat (10 ^ mag)

        -- calculate most significant digit of the new step size
        magMsd =
            round (delta0 / magPow)

        -- promote the MSD to either 1, 2, or 5
        magMsdFinal =
            if magMsd > 5 then
                10
            else if magMsd > 2 then
                5
            else if magMsd > 1 then
                1
            else
                magMsd
    in
        (toFloat magMsdFinal) * magPow


toValue : Float -> Float -> Int -> Float
toValue delta firstValue index =
    firstValue
        + (toFloat index)
        * delta
        |> Round.round (getDeltaPrecision delta)
        |> String.toFloat
        |> Result.withDefault 0


toValuesFromDelta : Float -> Scale -> List Float
toValuesFromDelta delta { lowest, range } =
    let
        firstValue =
            getFirstValue delta lowest

        tickCount =
            getCount delta lowest range firstValue
    in
        List.map (toValue delta firstValue) (List.range 0 tickCount)


toValuesFromCount : Int -> Scale -> List Float
toValuesFromCount appxCount scale =
    toValuesFromDelta (getDelta scale.range appxCount) scale


toValuesAuto : Scale -> List Float
toValuesAuto =
    toValuesFromCount 10



-- Helpers


toIndexInfo : List Value -> List (IndexedInfo {})
toIndexInfo values =
    let
        lowerThanZero =
            List.length (List.filter (\v -> v < 0) values)

        hasZero =
            List.any (\v -> v == 0) values
    in
        List.indexedMap (zipWithDistance hasZero lowerThanZero) values


zipWithDistance : Bool -> Int -> Int -> Value -> IndexedInfo {}
zipWithDistance hasZero lowerThanZero index value =
    let
        distance =
            if value == 0 then
                0
            else if value > 0 && hasZero then
                index - lowerThanZero
            else if value > 0 then
                index - lowerThanZero + 1
            else
                lowerThanZero - index
    in
        { index = distance, value = value }
