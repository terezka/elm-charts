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
        , indexValues
        , getValuesIndexed
        , getValues
        , getDelta
        )

import Internal.Types exposing (Point, Style, Orientation(..), Scale, Meta, HintInfo)
import Internal.Draw as Draw exposing (..)
import Internal.Stuff exposing (..)
import Round
import Regex
import Svg
import Svg.Attributes


type alias Config msg =
    { viewConfig : ViewConfig msg
    , valueConfig : ValueConfig
    }


type alias StyleConfig a =
    { length : Int
    , width : Int
    , style : Style
    , classes : List String
    , customAttrs : List (Svg.Attribute a)
    }


type ViewConfig msg
    = FromStyle (StyleConfig msg)
    | FromStyleDynamic (( Int, Float ) -> StyleConfig msg)
    | FromCustomView (View msg)


type alias View msg =
    Orientation -> ( Int, Float ) -> Svg.Svg msg


type ValueConfig
    = AutoValues
    | FromDelta Float
    | FromCount Int
    | FromCustom (List Float)


defaultConfig : Config msg
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


toView : Config msg -> View msg
toView { viewConfig } =
    case viewConfig of
        FromStyle styleConfig ->
            defaultView styleConfig

        FromStyleDynamic toConfig ->
            toViewFromStyleDynamic toConfig

        FromCustomView view ->
            view


toViewFromStyleDynamic : (( Int, Float ) -> StyleConfig msg) -> View msg
toViewFromStyleDynamic toStyleConfig orientation ( index, value ) =
    defaultView (toStyleConfig ( index, value )) orientation ( index, value )


defaultView : StyleConfig msg -> View msg
defaultView { length, width, style, classes, customAttrs } orientation ( _, _ ) =
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


getValuesIndexed : Config msg -> Scale -> List ( Int, Float )
getValuesIndexed { valueConfig } scale =
    getRawValues valueConfig scale |> indexValues


getValues : Config msg -> Scale -> List Float
getValues { valueConfig } scale =
    getRawValues valueConfig scale


getRawValues : ValueConfig -> Scale -> List Float
getRawValues config =
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


indexValues : List Float -> List ( Int, Float )
indexValues values =
    let
        lowerThanZero =
            List.length (List.filter (\i -> i < 0) values)

        hasZero =
            List.any (\t -> t == 0) values
    in
        List.indexedMap (zipWithDistance hasZero lowerThanZero) values


zipWithDistance : Bool -> Int -> Int -> Float -> ( Int, Float )
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
        ( distance, value )
