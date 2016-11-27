module Plot.Label exposing (..)

{-|
 Attributes for altering the values and view of your axis' labels.

# Styling
@docs view, viewDynamic, viewCustom

## Style attributes
@docs style, classes, displace, format

# Values
@docs values, filter

# Definitions
@docs Attribute, StyleAttribute, ToStyleAttributes

-}

import Svg
import Plot.Types exposing (Style)
import Plot.Tick as Tick
import Internal.Label as Internal


{-| The type representing a label attibute.
-}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| The type representing a label style attibutes.
-}
type alias StyleAttribute =
    Internal.StyleConfig -> Internal.StyleConfig


{-| Displaces the label.

    main =
        plot
            []
            [ xAxis
                [ Axis.label
                    [ Label.view [ Label.displace ( 12, 0 ) ] ]
                ]
            ]
-}
displace : ( Int, Int ) -> StyleAttribute
displace displace config =
    { config | displace = Just displace }


{-| Adds classes to the label.

    main =
        plot
            []
            [ xAxis
                [ Axis.label
                    [ Label.view [ Label.classes [ "my-class" ] ] ]
                ]
            ]
-}
classes : List String -> StyleAttribute
classes classes config =
    { config | classes = classes }


{-| Adds inline-styles to the label.

    main =
        plot
            []
            [ xAxis
                [ Axis.label
                    [ Label.view [ Label.style [ ("stroke", "blue" ) ] ] ]
                ]
            ]
-}
style : Style -> StyleAttribute
style style config =
    { config | style = style }


{-| Format the label based on its value and index (amount of ticks from origin).

    formatter : Int -> Float -> String
    formatter index value =
        if isDivisibleBy5 index then
            formatEveryFifth value
        else
            normalFormat value

    main =
        plot
            []
            [ xAxis
                [ Axis.label
                    [ Label.view
                        [ Label.format formatter ]
                    ]
                ]
            ]
-}
format : (( Int, Float ) -> String) -> StyleAttribute
format format config =
    { config | format = format }


toStyleConfig : List StyleAttribute -> Internal.StyleConfig
toStyleConfig styleAttributes =
    List.foldl (<|) Internal.defaultStyleConfig styleAttributes


{-| Provide a list of style attributes to alter the view of the label.

    main =
        plot
            []
            [ xAxis
                [ Axis.label
                    [ Label.view
                        [ Label.classes [ "label-class" ]
                        , Label.displace ( 12, 0 )
                        ]
                    ]
                ]
            ]

 **Note:** If you add another attribute altering the view like `viewDynamic` or `viewCustom` _after_ this attribute,
 then this attribute will have no effect.
-}
view : List StyleAttribute -> Attribute msg
view styles config =
    { config | viewConfig = Internal.FromStyle (toStyleConfig styles) }


{-| Alter the view of the label based on the label's value and index (amount of ticks from origin) by
 providing a function returning a list of style attributes.

    toViewConfig : Int -> Float -> List Label.StyleAttribute
    toViewConfig index value =
        if isOdd index then
            [ Label.classes [ "label--odd" ]
            , Label.displace ( 12, 0 )
            ]
        else
            [ Label.classes [ "label--even" ]
            , Label.displace ( 16, 0 )
            ]

    main =
        plot
            []
            [ xAxis
                [ Axis.label [ Label.viewDynamic toViewConfig ] ]
            ]

 **Note:** If you add another attribute altering the view like `view` or `viewCustom` _after_ this attribute,
 then this attribute will have no effect.
-}
viewDynamic : (( Int, Float ) -> List StyleAttribute) -> Attribute msg
viewDynamic toStyles config =
    { config | viewConfig = Internal.FromStyleDynamic (toStyleConfig << toStyles) }


{-| Define your own view for the labels. Your view will be passed label's value and index (amount of ticks from origin).

    viewLabel : Int -> Float -> Svg.Svg a
    viewLabel index value =
        let
            attrs =
                if isOdd index then oddAttrs else evenAttrs
        in
            text_ attrs (toString value)

    main =
        plot []
            [ xAxis
                [ Axis.label [ Label.viewCustom viewLabel ] ]
            ]

 **Note:** If you add another attribute altering the view like `view` or `viewDynamic` _after_ this attribute,
 then this attribute will have no effect.
-}
viewCustom : (( Int, Float ) -> Svg.Svg msg) -> Attribute msg
viewCustom view config =
    { config | viewConfig = Internal.FromCustomView (always view) }


{-| Specify the values which you want a label for.

    main =
        plot
            []
            [ xAxis
                [ Axis.label [ Label.values [ 0, 5, 10, 11 ] ] ]
            ]

 **Note:** If you add another attribute altering the values like `filter` _after_ this attribute,
 then this attribute will have no effect.
-}
values : List Float -> Attribute msg
values filter config =
    { config | valueConfig = Internal.CustomValues filter }


{-| Add a filter determining which of the _tick values_ are added a label.
 Your filter will be passed label's value and index (amount of ticks from origin).

    main =
        plot
            []
            [ xAxis
                [ Axis.label [ Label.filter onlyEven ] ]
            ]

 **Note:** If you add another attribute altering the values like `values` _after_ this attribute,
 then this attribute will have no effect.
-}
filter : (( Int, Float ) -> Bool) -> Attribute msg
filter filter config =
    { config | valueConfig = Internal.CustomFilter filter }
