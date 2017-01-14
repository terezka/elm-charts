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
        , formatFromList
        )

{-|
 Attributes for altering the view of your labels.

 Before you read any further, please note that when I speak of the label _index_,
 then I'm talking about how many labels that particular label is from the origin.

 Ok, now you can go on!

# Definition
@docs Attribute

# View options
@docs view, viewDynamic, viewCustom

## Style attributes
If these attributes do not fulfill your needs, try out the viewCustom! If you have
a suspicion that I have missed a very common configuration, then please let me know and I'll add it.
@docs StyleAttribute, classes, displace, stroke, strokeWidth, opacity, fill, fontSize, customAttrs

# Value formatting
@docs format, formatFromList

-}

import Svg
import Internal.Label as Internal
import Internal.Draw exposing (..)


{-| -}
type alias Attribute a msg =
    Internal.Config a msg -> Internal.Config a msg


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
displace : ( Int, Int ) -> StyleAttribute msg
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
classes : List String -> StyleAttribute msg
classes classes config =
    { config | classes = classes }


{-| Set the stroke color.
-}
stroke : String -> StyleAttribute msg
stroke stroke config =
    { config | style = ( "stroke", stroke ) :: config.style }


{-| Set the stroke width (in pixels).
-}
strokeWidth : Int -> StyleAttribute msg
strokeWidth strokeWidth config =
    { config | style = ( "stroke-width", toPixelsInt strokeWidth ) :: config.style }


{-| Set the fill color.
-}
fill : String -> StyleAttribute msg
fill fill config =
    { config | style = ( "fill", fill ) :: config.style }


{-| Set the opacity.
-}
opacity : Float -> StyleAttribute msg
opacity opacity config =
    { config | style = ( "opacity", toString opacity ) :: config.style }


{-| Set the font size (in pixels).
-}
fontSize : Int -> StyleAttribute msg
fontSize fontSize config =
    { config | style = ( "font-size", toPixelsInt fontSize ) :: config.style }


{-| Add your own attributes. For events, see [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm)
-}
customAttrs : List (Svg.Attribute msg) -> StyleAttribute msg
customAttrs attrs config =
    { config | customAttrs = attrs }


toStyleConfig : List (StyleAttribute msg) -> Internal.StyleConfig msg
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
view : List (StyleAttribute msg) -> Attribute a msg
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
viewDynamic : (a -> List (StyleAttribute msg)) -> Attribute a msg
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
viewCustom : (a -> Svg.Svg msg) -> Attribute a msg
viewCustom view config =
    { config | viewConfig = Internal.FromCustomView view }


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
                [ Label.format formatter ]
            ]
-}
format : (a -> String) -> Attribute a msg
format format config =
    { config | format = Internal.FromFunc format }


{-| -}
formatFromList : List String -> Attribute a msg
formatFromList format config =
    { config | format = Internal.FromList format }
