module Plot.Label exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..), AxisScale, PlotProps, TooltipInfo)
import Plot.Tick as Tick
import Helpers exposing (..)
import Svg
import Svg.Attributes


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
type alias Config msg =
    { viewConfig : ViewConfig msg
    , valueConfig : ValueConfig
    }


type alias StyleConfig =
    { displace : Maybe ( Int, Int )
    , format : Int -> Float -> String
    , style : Style
    , classes : List String
    }


type ViewConfig msg
    = FromStyle StyleConfig
    | FromStyleDynamic ToStyleAttributes
    | FromCustomView (View msg)


type ValueConfig
    = CustomValues (List Float)
    | CustomFilter (Int -> Float -> Bool)


type alias View msg =
    Orientation -> Int -> Float -> Svg.Svg msg


{-| The type representing a label attibute.
-}
type alias Attribute msg =
    Config msg -> Config msg


{-| The type representing a label style attibutes.
-}
type alias StyleAttribute =
    StyleConfig -> StyleConfig


{-| The type representing function returning a list of style attibutes.
-}
type alias ToStyleAttributes =
    Int -> Float -> List StyleAttribute


defaultConfig : Config msg
defaultConfig =
    { viewConfig = FromStyle defaultStyleConfig
    , valueConfig = CustomFilter (\_ _ -> True)
    }


defaultStyleConfig : StyleConfig
defaultStyleConfig =
    { displace = Nothing
    , format = (\_ -> toString)
    , style = []
    , classes = []
    }


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
format : (Int -> Float -> String) -> StyleAttribute
format format config =
    { config | format = format }


toStyleConfig : List StyleAttribute -> StyleConfig
toStyleConfig styleAttributes =
    List.foldl (<|) defaultStyleConfig styleAttributes


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
    { config | viewConfig = FromStyle (toStyleConfig styles) }


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
viewDynamic : ToStyleAttributes -> Attribute msg
viewDynamic toStyles config =
    { config | viewConfig = FromStyleDynamic toStyles }


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
viewCustom : (Int -> Float -> Svg.Svg msg) -> Attribute msg
viewCustom view config =
    { config | viewConfig = FromCustomView (always view) }


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
    { config | valueConfig = CustomValues filter }


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
filter : (Int -> Float -> Bool) -> Attribute msg
filter filter config =
    { config | valueConfig = CustomFilter filter }



-- VIEW


toView : ViewConfig msg -> View msg
toView config =
    case config of
        FromStyle styles ->
            defaultView styles

        FromStyleDynamic toStyles ->
            toViewFromStyleDynamic toStyles

        FromCustomView view ->
            view


toViewFromStyleDynamic : ToStyleAttributes -> View msg
toViewFromStyleDynamic toStyleAttributes orientation index value =
    defaultView (toStyleConfig <| toStyleAttributes index value) orientation index value


defaultStyleX : ( Style, ( Int, Int ) )
defaultStyleX =
    ( [ ( "text-anchor", "middle" ) ], ( 0, 24 ) )


defaultStyleY : ( Style, ( Int, Int ) )
defaultStyleY =
    ( [ ( "text-anchor", "end" ) ], ( -10, 5 ) )


defaultView : StyleConfig -> View msg
defaultView { displace, format, style, classes } orientation index tick =
    let
        ( defaultStyle, defaultDisplacement ) =
            (?) orientation defaultStyleX defaultStyleY

        ( dx, dy ) =
            Maybe.withDefault defaultDisplacement displace
    in
        Svg.text_
            [ Svg.Attributes.transform (toTranslate ( toFloat dx, toFloat dy ))
            , Svg.Attributes.style (toStyle (defaultStyle ++ style))
            , Svg.Attributes.class (String.join " " classes)
            ]
            [ Svg.tspan [] [ Svg.text (format index tick) ] ]



-- resolve values


getValuesIndexed : ValueConfig -> List ( Int, Float ) -> List ( Int, Float )
getValuesIndexed config tickValues =
    case config of
        CustomValues values ->
            Tick.indexValues values

        CustomFilter filter ->
            List.filter (\( a, b ) -> filter a b) tickValues
