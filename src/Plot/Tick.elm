module Plot.Tick exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..), AxisScale, PlotProps, TooltipInfo)
import Helpers exposing (..)
import Round
import Svg
import Svg.Attributes


-- View config


type alias StyleConfig =
    { length : Int
    , width : Int
    , style : Style
    , classes : List String
    }


type alias StyleAttribute =
    StyleConfig -> StyleConfig


type alias ToStyleAttributes =
    Int -> Float -> List StyleAttribute


type alias View msg =
    Orientation -> Int -> Float -> Svg.Svg msg


type ViewConfig msg
    = FromStyle StyleConfig
    | FromStyleDynamic ToStyleAttributes
    | FromCustomView (View msg)


type ValueConfig
    = AutoValues
    | FromDelta Float
    | FromCount Int
    | FromCustom (List Float)



type alias Config msg =
    { viewConfig : ViewConfig msg
    , valueConfig : ValueConfig
    , removeZero : Bool
    }


type alias Attribute msg =
    Config msg -> Config msg


defaultConfig : Config msg
defaultConfig =
    { viewConfig = FromStyle defaultStyleConfig
    , valueConfig = AutoValues
    , removeZero = False
    }


defaultStyleConfig : StyleConfig
defaultStyleConfig =
    { length = 7
    , width = 1
    , style = []
    , classes = []
    }


{-| Remove tick at origin. Useful when two axis' are crossing and you do not
 want the origin the be cluttered with labels.

    main =
        plot
            []
            [ xAxis [ tickRemoveZero ] ]
-}
removeZero : Attribute msg
removeZero config =
    { config | removeZero = True }


{-| Set the length of the tick.

    main =
        plot
            []
            [ xAxis
                [ tickConfigView [ tickLength 10 ] ]
            ]
-}
length : Int -> StyleAttribute
length length config =
    { config | length = length }


{-| Set the width of the tick.

    main =
        plot
            []
            [ xAxis
                [ tickConfigView [ tickWidth 2 ] ]
            ]
-}
width : Int -> StyleAttribute
width width config =
    { config | width = width }


{-| Add classes to the tick.

    main =
        plot
            []
            [ xAxis
                [ tickConfigView
                    [ tickClasses [ "my-class" ] ]
                ]
            ]
-}
classes : List String -> StyleAttribute
classes classes config =
    { config | classes = classes }


{-| Sets the style of the tick

    main =
        plot
            []
            [ xAxis
                [ tickConfigView
                    [ tickStyle [ ( "stroke", "blue" ) ] ]
                ]
            ]
-}
style : Style -> StyleAttribute
style style config =
    { config | style = style }


toStyleConfig : List StyleAttribute -> StyleConfig
toStyleConfig attributes =
    List.foldl (<|) defaultStyleConfig attributes


{-| Defines how the tick will be displayed by specifying a list of tick view attributes.

    main =
        plot
            []
            [ xAxis
                [ tickConfigView
                    [ tickLength 10
                    , tickWidth 2
                    , tickStyle [ ( "stroke", "red" ) ]
                    ]
                ]
            ]

 If you do not define another view configuration,
 the default will be `[ tickLength 7, tickWidth 1, tickStyle [] ]`

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickCustomView`, `tickConfigViewFunc` or a `tickCustomViewIndexed` attribute,
 then this attribute will have no effect.
-}
viewFromConfig : List StyleAttribute -> Attribute msg
viewFromConfig styles config =
    { config | viewConfig = FromStyle (toStyleConfig styles) }


{-| Defines how the tick will be displayed by specifying a list of tick view attributes.

    toTickConfig : Int -> Float -> List TickViewAttr
    toTickConfig index tick =
        if isOdd index then
            [ tickLength 7
            , tickStyle [ ( "stroke", "#e4e3e3" ) ]
            ]
        else
            [ tickLength 10
            , tickStyle [ ( "stroke", "#b9b9b9" ) ]
            ]

    main =
        plot
            []
            [ xAxis
                [ tickConfigViewFunc toTickConfig ]
            ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickConfigView`, `tickCustomView` or a `tickCustomViewIndexed` attribute,
 then this attribute will have no effect.
-}
viewFromDynamicConfig : ToStyleAttributes -> Attribute msg
viewFromDynamicConfig toStyles config =
    { config | viewConfig = FromStyleDynamic toStyles }


{-| Defines how the tick will be displayed by specifying a function which returns your tick html.

    viewTick : Float -> Svg.Svg a
    viewTick tick =
        text_
            [ transform ("translate(-5, 10)") ]
            [ tspan [] [ text "✨" ] ]

    main =
        plot [] [ xAxis [ tickCustomView viewTick ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickConfigView` or a `tickCustomViewIndexed` attribute, then this attribute will have no effect.
-}
viewFromCustomHtml : (Float -> Svg.Svg msg) -> Attribute msg
viewFromCustomHtml view config =
    { config | viewConfig = FromCustomView (\_ _ -> view) }



{-| Same as `tickCustomConfig`, but the functions is also passed a value
 which is how many ticks away the current tick is from the zero tick.

    viewTick : Int -> Float -> Svg.Svg a
    viewTick index tick =
        text_
            [ transform ("translate(-5, 10)") ]
            [ tspan
                []
                [ text (if isOdd index then "🌟" else "⭐") ]
            ]

    main =
        plot [] [ xAxis [ tickCustomViewIndexed viewTick ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickConfigView` or a `tickCustomView` attribute, then this attribute will have no effect.
-}
viewFromCustomHtmlIndexed : (Int -> Float -> Svg.Svg msg) -> Attribute msg
viewFromCustomHtmlIndexed view config =
    { config | viewConfig = FromCustomView (always view) }




-- Value attributes


{-| Defines what ticks will be shown on the axis by specifying a list of values.

    main =
        plot
            []
            [ xAxis [ tickValues [ 0, 1, 2, 4, 8 ] ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickDelta` attribute, then this attribute will have no effect.
-}
values : List Float -> Attribute msg
values values config =
    { config | valueConfig = FromCustom values }


{-| Defines what ticks will be shown on the axis by specifying the delta between the ticks.
 The delta will be added from zero.

    main =
        plot
            []
            [ xAxis [ tickDelta 4 ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickValues` attribute, then this attribute will have no effect.
-}
delta : Float -> Attribute msg
delta delta config =
    { config | valueConfig = FromDelta delta }



-- View


toView : ViewConfig msg -> View msg
toView config =
    case config of
        FromStyle styleConfig ->
            defaultView styleConfig

        FromStyleDynamic toStyles ->
            toViewFromStyleDynamic toStyles

        FromCustomView view ->
            view


toViewFromStyleDynamic : ToStyleAttributes -> View msg
toViewFromStyleDynamic toStyleAttributes orientation index value =
    defaultView (toStyleConfig <| toStyleAttributes index value) orientation index value


defaultView : StyleConfig -> View msg
defaultView { length, width, style, classes } orientation _ _ =
    let
        displacement =
            (?) orientation "" (toRotate 90 0 0)

        styleFinal =
            style ++ [ ( "stroke-width", (toString width) ++ "px" ) ]
    in
        Svg.line
            [ Svg.Attributes.style (toStyle styleFinal)
            , Svg.Attributes.y2 (toString length)
            , Svg.Attributes.transform displacement
            , Svg.Attributes.class (String.join " " classes)
            ]
            []



-- Resolve values


getValues : Config msg -> AxisScale -> List (Int, Float)
getValues { valueConfig, removeZero } scale =
    getRawValues valueConfig scale
    |> filterValues removeZero
    |> indexValues


getValuesPure : Config msg -> AxisScale -> List Float
getValuesPure { valueConfig, removeZero } scale =
    getRawValues valueConfig scale
    |> filterValues removeZero
    

getRawValues : ValueConfig -> AxisScale -> List Float
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
    logBase 10 delta
        |> floor
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


toValuesFromDelta : Float -> AxisScale -> List Float
toValuesFromDelta delta { lowest, range } =
    let
        firstValue =
            getFirstValue delta lowest

        tickCount =
            getCount delta lowest range firstValue
    in
        List.map (toValue delta firstValue) (List.range 0 tickCount)


toValuesFromCount : Int -> AxisScale -> List Float
toValuesFromCount appxCount scale =
    toValuesFromDelta (getDelta scale.range appxCount) scale


toValuesAuto : AxisScale -> List Float
toValuesAuto =
    toValuesFromCount 10



-- Helpers


filterValues : Bool -> List Float -> List Float
filterValues axisCrossing values =
    if axisCrossing then
        List.filter (\p -> p /= 0) values
    else
        values


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
