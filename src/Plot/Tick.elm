module Plot.Tick exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..), AxisScale, PlotProps, TooltipInfo)
import Helpers exposing (..)
import Round
import Svg
import Svg.Attributes


{-|
 Attributes for altering the values and view of your axis' ticks.

# Styling
@docs view, viewDynamic, viewCustom

## Style attributes
@docs style, classes, length, width

# Values
@docs values, delta

# Definitions
@docs Attribute, StyleAttribute, ToStyleAttributes

-}
type alias Config msg =
    { viewConfig : ViewConfig msg
    , valueConfig : ValueConfig
    , removeZero : Bool
    }


type alias StyleConfig =
    { length : Int
    , width : Int
    , style : Style
    , classes : List String
    }


type ViewConfig msg
    = FromStyle StyleConfig
    | FromStyleDynamic ToStyleAttributes
    | FromCustomView (View msg)


type alias View msg =
    Orientation -> Int -> Float -> Svg.Svg msg


type ValueConfig
    = AutoValues
    | FromDelta Float
    | FromCount Int
    | FromCustom (List Float)


{-| -}
type alias Attribute msg =
    Config msg -> Config msg


{-| -}
type alias StyleAttribute =
    StyleConfig -> StyleConfig


{-| -}
type alias ToStyleAttributes =
    Int -> Float -> List StyleAttribute


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



-- ATTRIBUTES


{-| Set the length of the tick (in pixels).

    main =
        plot
            []
            [ xAxis
                [ Axis.tick
                    [ Tick.view [ Tick.length 8 ] ]
                ]
            ]
-}
length : Int -> StyleAttribute
length length config =
    { config | length = length }


{-| Set the width of the tick (in pixels).

    main =
        plot
            []
            [ xAxis
                [ Axis.tick
                    [ Tick.view [ Tick.width 2 ] ]
                ]
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
                [ Axis.tick
                    [ Tick.view [ Tick.classes [ "my-tick" ] ] ]
                ]
            ]
-}
classes : List String -> StyleAttribute
classes classes config =
    { config | classes = classes }


{-| Add inline-styles to the tick.

    main =
        plot
            []
            [ xAxis
                [ Axis.tick
                    [ Tick.view
                        [ Tick.style [ ( "stroke", "blue" ) ] ]
                    ]
                ]
            ]
-}
style : Style -> StyleAttribute
style style config =
    { config | style = style }


toStyleConfig : List StyleAttribute -> StyleConfig
toStyleConfig attributes =
    List.foldl (<|) defaultStyleConfig attributes


{-| Provide a list of style attributes to alter the view of the tick.

    main =
        plot
            []
            [ xAxis
                [ Axis.tick
                    [ Tick.view
                        [ Tick.style [ ( "stroke", "deeppink" ) ]
                        , Tick.length 5
                        , Tick.width 2
                        ]
                    ]
                ]
            ]

 **Note:** If you add another attribute altering the view like `viewDynamic` or `viewCustom` _after_ this attribute,
 then this attribute will have no effect.
-}
view : List StyleAttribute -> Attribute msg
view styles config =
    { config | viewConfig = FromStyle (toStyleConfig styles) }


{-| Alter the view of the tick based on the tick's value and index (amount of ticks from origin) by
 providing a function returning a list of style attributes.

    toTickConfig : Int -> Float -> List Tick.StyleAttribute
    toTickConfig index value =
        if isOdd index then
            [ Tick.length 7
            , Tick.style [ ( "stroke", "#e4e3e3" ) ]
            ]
        else
            [ Tick.length 10
            , Tick.style [ ( "stroke", "#b9b9b9" ) ]
            ]

    main =
        plot
            []
            [ xAxis
                [ Axis.tick [ Tick.viewDynamic toViewConfig ] ]
            ]

 **Note:** If you add another attribute altering the view like `view` or `viewCustom` _after_ this attribute,
 then this attribute will have no effect.
-}
viewDynamic : ToStyleAttributes -> Attribute msg
viewDynamic toStyles config =
    { config | viewConfig = FromStyleDynamic toStyles }


{-| Define your own view for the labels. Your view will be passed label's value and index (amount of ticks from origin).

    viewTick : Int -> Float -> Svg.Svg a
    viewTick index tick =
        text_
            [ transform "translate(-5, 10)" ]
            [ tspan
                []
                [ text (if isOdd index then "🌟" else "⭐") ]
            ]

    main =
        plot [] [ xAxis [ Axis.tick [ Tick.viewCustom viewTick ] ] ]

 **Note:** If you add another attribute altering the view like `view` or `viewDynamic` _after_ this attribute,
 then this attribute will have no effect.
-}
viewCustom : (Int -> Float -> Svg.Svg msg) -> Attribute msg
viewCustom view config =
    { config | viewConfig = FromCustomView (always view) }



-- Value attributes


{-| Specify what values will be added a tick.

    main =
        plot
            []
            [ xAxis
                [ Axis.tick
                    [ Tick.values [ 0, 1, 2, 4, 8 ] ]
                ]
            ]

 **Note:** If you add another attribute altering the values like `delta` _after_ this attribute,
 then this attribute will have no effect.
-}
values : List Float -> Attribute msg
values values config =
    { config | valueConfig = FromCustom values }


{-| Specify what values will be added a tick by specifying the space between each tick.
 The delta will be added from zero.

    main =
        plot
            []
            [ xAxis [ Axis.tick [ Tick.delta 4 ] ] ]

 **Note:** If you add another attribute altering the values like `values` _after_ this attribute,
 then this attribute will have no effect.
-}
delta : Float -> Attribute msg
delta delta config =
    { config | valueConfig = FromDelta delta }


{-| Remove tick at origin. Useful when two axis' are crossing and you do not
 want the origin the be cluttered with labels.

    main =
        plot
            []
            [ xAxis [ Axis.tick [ Tick.removeZero ] ] ]
-}
removeZero : Attribute msg
removeZero config =
    { config | removeZero = True }



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


getValuesIndexed : Config msg -> AxisScale -> List ( Int, Float )
getValuesIndexed { valueConfig, removeZero } scale =
    getRawValues valueConfig scale
        |> filterValues removeZero
        |> indexValues


getValues : Config msg -> AxisScale -> List Float
getValues { valueConfig, removeZero } scale =
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
filterValues removeZero values =
    if removeZero then
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
