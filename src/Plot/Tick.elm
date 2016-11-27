module Plot.Tick exposing (..)

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


import Svg
import Plot.Types exposing (Style)
import Internal.Tick as Internal
    exposing
        ( Config
        , StyleConfig
        , ValueConfig(..)
        , ViewConfig(..)
        , View
        , defaultConfig
        , defaultStyleConfig
        )


{-| -}
type alias Attribute msg =
    Config msg -> Config msg


{-| -}
type alias StyleAttribute =
    StyleConfig -> StyleConfig


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

    toTickConfig : ( Int, Float ) -> List Tick.StyleAttribute
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
viewDynamic : (( Int, Float ) -> List StyleAttribute) -> Attribute msg
viewDynamic toStyles config =
    { config | viewConfig = FromStyleDynamic (toStyleConfig << toStyles) }


{-| Define your own view for the labels. Your view will be passed label's value and index (amount of ticks from origin).

    viewTick : ( Int, Float ) -> Svg.Svg a
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
viewCustom : (( Int, Float ) -> Svg.Svg msg) -> Attribute msg
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
