module Plot.Tick exposing (Attribute, StyleAttribute, view, viewDynamic, viewCustom, style, classes, length, width, values, delta, removeZero)

{-|
 Attributes for altering the values and view of your axis' ticks.

 Before you read any further, please note that when I speak of the tick _index_,
 then I'm talking about how many ticks this tick is from the origin.

 Imaging an axis looking like this:


 For the tick with the value 4, the index will be 2, because there are two ticks
 before it. For the tick with the value 6, index will be 3 and so on.

 Ok, now you can go on!

# Definition
@docs Attribute

# Styling
@docs view, viewDynamic, viewCustom

## Style attributes
@docs StyleAttribute, style, classes, length, width

# Values
@docs values, delta

# Others
@docs removeZero

-}

import Svg
import Internal.Types exposing (Style)
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

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.tick
                [ Tick.view
                    [ Tick.length 8 ]
                ]
            ]
-}
length : Int -> StyleAttribute
length length config =
    { config | length = length }


{-| Set the width of the tick (in pixels).

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.tick
                [ Tick.view
                    [ Tick.width 2 ]
                ]
            ]
-}
width : Int -> StyleAttribute
width width config =
    { config | width = width }


{-| Add classes to the tick.

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.tick
                [ Tick.view
                    [ Tick.classes [ "my-tick" ] ]
                ]
            ]
-}
classes : List String -> StyleAttribute
classes classes config =
    { config | classes = classes }


{-| Add inline-styles to the tick.

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.tick
                [ Tick.view
                    [ Tick.style [ ( "stroke", "blue" ) ] ]
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

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.tick
                [ Tick.view
                    [ Tick.style
                        [ ( "stroke", "deeppink" ) ]
                    , Tick.length 5
                    , Tick.width 2
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

    toTickStyles : ( Int, Float ) -> List Tick.StyleAttribute
    toTickStyles ( index, value ) =
        if isOdd index then
            [ Tick.length 7
            , Tick.style [ ( "stroke", "#e4e3e3" ) ]
            ]
        else
            [ Tick.length 10
            , Tick.style [ ( "stroke", "#b9b9b9" ) ]
            ]

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.tick
                [ Tick.viewDynamic toTickStyles ]
            ]

 **Note:** If you add another attribute altering the view like `view` or `viewCustom` _after_ this attribute,
 then this attribute will have no effect.
-}
viewDynamic : (( Int, Float ) -> List StyleAttribute) -> Attribute msg
viewDynamic toStyles config =
    { config | viewConfig = FromStyleDynamic (toStyleConfig << toStyles) }


{-| Define your own view for the labels. Your view will be passed label's value and index (amount of ticks from origin).

    viewTick : ( Int, Float ) -> Svg.Svg a
    viewTick ( index, tick ) =
        text_
            [ transform "translate(-5, 10)"
            , Svg.Events.onClick (Custom MyTickClickMsg)
            ]
            [ tspan
                []
                [ text (if isOdd index then "🌟" else "⭐") ]
            ]

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.tick
                [ Tick.viewCustom viewTick ]
            ]

 **Note:** If you add another attribute altering the view like `view` or `viewDynamic` _after_ this attribute,
 then this attribute will have no effect.
-}
viewCustom : (( Int, Float ) -> Svg.Svg msg) -> Attribute msg
viewCustom view config =
    { config | viewConfig = FromCustomView (always view) }


{-| Specify what values will be added a tick.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.tick
                [ Tick.values [ 0, 1, 2, 4, 8 ] ]
            ]

 **Note:** If you add another attribute altering the values like `delta` _after_ this attribute,
 then this attribute will have no effect.
-}
values : List Float -> Attribute msg
values values config =
    { config | valueConfig = FromCustom values }


{-| Specify what values will be added a tick by specifying the space between each tick.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.tick
                [ Tick.delta 4 ]
            ]

 **Note:** If you add another attribute altering the values like `values` _after_ this attribute,
 then this attribute will have no effect.
-}
delta : Float -> Attribute msg
delta delta config =
    { config | valueConfig = FromDelta delta }


{-| Remove tick at origin. Useful when two axis' are crossing and you do not
 want the origin the be cluttered with labels.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.tick
                [ Tick.removeZero ]
            ]
-}
removeZero : Attribute msg
removeZero config =
    { config | removeZero = True }
