module Plot.Label
    exposing
        ( Attribute
        , StyleAttribute
        , view
        , viewDynamic
        , viewCustom
        , stroke
        , strokeWidth
        , opacity
        , fill
        , fontSize
        , classes
        , customAttrs
        , displace
        , format
        , values
        , filter
        )

{-|
 Attributes for altering the values and view of your axis' labels.

 Before you read any further, please note that when I speak of the label _index_,
 then I'm talking about how many labels this label is from the origin.

 Imaging an axis looking like this:

 For the label with the value 4, the index will be 2, because there are two labels
 before it. For the label with the value 6, index will be 3 and so on.

 Ok, now you can go on!

# Definition
@docs Attribute

# Styling
@docs view, viewDynamic, viewCustom

## Style attributes
If these attributes do not forfill your needs, try out the viewCustom! If you have
a suspicion that I have missed a very common configuration, then please let me know and I'll add it.
@docs StyleAttribute, classes, displace, format, stroke, strokeWidth, opacity, fill, fontSize, customAttrs

# Values
@docs values, filter

-}

import Svg
import Internal.Types exposing (Style)
import Internal.Label as Internal
import Internal.Draw exposing (..)


{-| -}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| -}
type alias StyleAttribute msg =
    Internal.StyleConfig msg -> Internal.StyleConfig msg


{-| Displaces the label.

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.label
                [ Label.view
                    [ Label.displace ( 12, 0 ) ]
                ]
            ]
-}
displace : ( Int, Int ) -> StyleAttribute a
displace displace config =
    { config | displace = Just displace }


{-| Adds classes to the label.

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.label
                [ Label.view
                    [ Label.classes [ "my-class" ] ]
                ]
            ]
-}
classes : List String -> StyleAttribute a
classes classes config =
    { config | classes = classes }


{-| Set the stroke color.
-}
stroke : String -> StyleAttribute a
stroke stroke config =
    { config | style = ( "stroke", stroke ) :: config.style }


{-| Set the stroke width (in pixels).
-}
strokeWidth : Int -> StyleAttribute a
strokeWidth strokeWidth config =
    { config | style = ( "stroke-width", toPixelsInt strokeWidth ) :: config.style }


{-| Set the fill color.
-}
fill : String -> StyleAttribute a
fill fill config =
    { config | style = ( "fill", fill ) :: config.style }


{-| Set the opacity.
-}
opacity : Float -> StyleAttribute a
opacity opacity config =
    { config | style = ( "opacity", toString opacity ) :: config.style }


{-| Set the font size (in pixels).
-}
fontSize : Int -> StyleAttribute a
fontSize fontSize config =
    { config | style = ( "font-size", toPixelsInt fontSize ) :: config.style }


{-| Add your own attributes.
-}
customAttrs : List (Svg.Attribute a) -> StyleAttribute a
customAttrs attrs config =
    { config | customAttrs = attrs }


{-| Format the label based on its value and index.

    formatter : Int -> Float -> String
    formatter index value =
        if isDivisibleBy5 index then
            formatEveryFifth value
        else
            normalFormat value

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.label
                [ Label.view
                    [ Label.format formatter ]
                ]
            ]
-}
format : (( Int, Float ) -> String) -> StyleAttribute a
format format config =
    { config | format = format }


toStyleConfig : List (StyleAttribute a) -> Internal.StyleConfig a
toStyleConfig styleAttributes =
    List.foldl (<|) Internal.defaultStyleConfig styleAttributes


{-| Provide a list of style attributes to alter the view of the label.

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.label
                [ Label.view
                    [ Label.classes [ "label-class" ]
                    , Label.displace ( 12, 0 )
                    ]
                ]
            ]

 **Note:** If you add another attribute altering the view like `viewDynamic` or `viewCustom` _after_ this attribute,
 then this attribute will have no effect.
-}
view : List (StyleAttribute msg) -> Attribute msg
view styles config =
    { config | viewConfig = Internal.FromStyle (toStyleConfig styles) }


{-| Alter the view of the label based on the label's value and index (amount of ticks from origin) by
 providing a function returning a list of style attributes.

    toViewStyles : Int -> Float -> List Label.StyleAttribute a
    toViewStyles index value =
        if isOdd index then
            [ Label.classes [ "label--odd" ]
            , Label.displace ( 12, 0 )
            ]
        else
            [ Label.classes [ "label--even" ]
            , Label.displace ( 16, 0 )
            ]

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.label
                [ Label.viewDynamic toViewStyles ]
            ]

 **Note:** If you add another attribute altering the view like `view` or `viewCustom` _after_ this attribute,
 then this attribute will have no effect.
-}
viewDynamic : (( Int, Float ) -> List (StyleAttribute msg)) -> Attribute msg
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

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.label
                [ Label.viewCustom viewLabel ]
            ]

 **Note:** If you add another attribute altering the view like `view` or `viewDynamic` _after_ this attribute,
 then this attribute will have no effect.
-}
viewCustom : (( Int, Float ) -> Svg.Svg msg) -> Attribute msg
viewCustom view config =
    { config | viewConfig = Internal.FromCustomView (always view) }


{-| Specify the values which you want a label for.

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.label
                [ Label.values [ 0, 5, 10, 11 ] ]
            ]

 **Note:** If you add another attribute altering the values like `filter` _after_ this attribute,
 then this attribute will have no effect.
-}
values : List Float -> Attribute msg
values filter config =
    { config | valueConfig = Internal.CustomValues filter }


{-| Add a filter determining which of the _tick values_ are added a label.
 Your filter will be passed label's value and index (amount of ticks from origin).

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.label
                [ Label.filter onlyEven ]
            ]

 **Note:** If you add another attribute altering the values like `values` _after_ this attribute,
 then this attribute will have no effect.
-}
filter : (( Int, Float ) -> Bool) -> Attribute msg
filter filter config =
    { config | valueConfig = Internal.CustomFilter filter }
