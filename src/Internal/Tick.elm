module Internal.Tick
    exposing
        ( Config
        , StyleConfig
        , ValueConfig(..)
        , ViewConfig(..)
        , View
        , defaultConfig
        , defaultStyleConfig
        , toView
        , toIndexInfo
        , getValues
        , getDelta
        )

import Internal.Types exposing (Point, Style, Orientation(..), Scale, Meta, IndexedInfo, Value)
import Internal.Draw as Draw exposing (..)
import Internal.Stuff exposing (..)
import Round
import Regex
import Svg
import Svg.Attributes


type alias Config a msg =
    { viewConfig : ViewConfig a msg
    , valueConfig : ValueConfig
    }


type alias StyleConfig msg =
    { length : Int
    , width : Int
    , style : Style
    , classes : List String
    , customAttrs : List (Svg.Attribute msg)
    }


type ViewConfig a msg
    = FromStyle (StyleConfig msg)
    | FromStyleDynamic (a -> StyleConfig msg)
    | FromCustomView (View a msg)


type alias View a msg =
    Orientation -> a -> Svg.Svg msg


type ValueConfig
    = AutoValues
    | FromDelta Float
    | FromCount Int
    | FromCustom (List Float)


defaultConfig : Config a msg
defaultConfig =
    { viewConfig = FromStyle defaultStyleConfig
    , valueConfig = AutoValues
    }


defaultStyleConfig : StyleConfig msg
defaultStyleConfig =
    { length = 7
    , width = 1
    , style = []
    , classes = []
    , customAttrs = []
    }


toView : Config a msg -> View a msg
toView { viewConfig } =
    case viewConfig of
        FromStyle styleConfig ->
            defaultView styleConfig

        FromStyleDynamic toConfig ->
            toViewFromStyleDynamic toConfig

        FromCustomView view ->
            view


toViewFromStyleDynamic : (a -> StyleConfig msg) -> View a msg
toViewFromStyleDynamic toStyleConfig orientation info =
    defaultView (toStyleConfig info) orientation info


defaultView : StyleConfig msg -> View a msg
defaultView { length, width, style, classes, customAttrs } orientation _ =
    let
        styleFinal =
            style ++ [ ( "stroke-width", toPixelsInt width ) ]

        attrs =
            [ Svg.Attributes.style (toStyle styleFinal)
            , Svg.Attributes.y2 (toString length)
            , Svg.Attributes.class <| String.join " " <| "elm-plot__tick__default-view" :: classes
            ]
                ++ customAttrs
    in
        Svg.line attrs []



-- Resolve values


getValues : Config a msg -> Scale -> List Value
getValues config =
    case config.valueConfig of
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
