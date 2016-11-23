module Plot.Label exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..), AxisScale, PlotProps, TooltipInfo)
import Plot.Tick as Tick
import Helpers exposing (..)
import Svg
import Svg.Attributes


type alias StyleConfig =
    { displace : Maybe ( Int, Int )
    , format : Int -> Float -> String
    , style : Style
    , classes : List String
    }


type alias View msg =
    Orientation -> Int -> Float -> Svg.Svg msg


type alias StyleAttribute =
    StyleConfig -> StyleConfig


type alias ToStyleAttributes =
    Int -> Float -> List StyleAttribute


type ViewConfig msg
    = FromStyle StyleConfig
    | FromStyleDynamic ToStyleAttributes
    | FromCustomView (View msg)


type ValueConfig
    = CustomValues (List Float)
    | CustomFilter (Int -> Float -> Bool)


type alias Config msg =
    { viewConfig : ViewConfig msg
    , valueConfig : ValueConfig
    }


type alias Attribute msg =
    Config msg -> Config msg


type alias ToAttributes msg =
    Int -> Float -> List (Attribute msg)


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



{-| Move the position of the label.

    main =
        plot
            []
            [ xAxis
                [ labelConfigView [ labelDisplace ( 0, 27 ) ] ]
            ]
-}
displace : ( Int, Int ) -> StyleAttribute
displace displace config =
    { config | displace = Just displace }


{-| Add classes to the label.

    main =
        plot
            []
            [ xAxis
                [ labelConfigView
                    [ labelClasses [ "my-class" ] ]
                ]
            ]
-}
classes : List String -> StyleAttribute
classes classes config =
    { config | classes = classes }




{-| Move the position of the label.

    main =
        plot
            []
            [ xAxis
                [ labelConfigView
                    [ labelStyle [ ("stroke", "blue" ) ] ]
                ]
            ]
-}
style : Style -> StyleAttribute
style style config =
    { config | style = style }



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
view : List StyleAttribute -> Attribute msg
view styles config =
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
viewDynamic : ToStyleAttributes -> Attribute msg
viewDynamic toStyles config =
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
viewCustom : (Float -> Svg.Svg msg) -> Attribute msg
viewCustom view config =
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
viewCustomIndexed : (Int -> Float -> Svg.Svg msg) -> Attribute msg
viewCustomIndexed view config =
    { config | viewConfig = FromCustomView (always view) }




{-| Format the label based on its value.

    main =
        plot
            []
            [ xAxis
                [ labelConfigView
                    [ labelFormat (\l -> toString l ++ " DKK") ]
                ]
            ]
-}
format : (Float -> String) -> StyleAttribute
format format config =
    { config | format = always format }
    


toStyleConfig : List StyleAttribute -> StyleConfig
toStyleConfig styleAttributes =
    List.foldl (<|) defaultStyleConfig styleAttributes


{-| Format the label based on its value and/or index.

    formatter : Int -> Float -> String
    formatter index value =
        if isOdd index then
            toString l ++ " DKK"
        else
            ""

    main =
        plot
            []
            [ xAxis
                [ labelConfigView [ labelFormat formatter ] ]
            ]
-}
formatIndexed : (Int -> Float -> String) -> StyleAttribute
formatIndexed format config =
    { config | format = format }




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


getValues : ValueConfig -> List (Int, Float) -> List (Int, Float)
getValues config tickValues =
    case config of
        CustomValues values ->
            Tick.indexValues values

        CustomFilter filter ->
            List.filter (\( a, b ) -> filter a b) tickValues

