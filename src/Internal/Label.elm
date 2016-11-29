module Internal.Label
    exposing
        ( ViewConfig(..)
        , Config
        , StyleConfig
        , ValueConfig(..)
        , View
        , defaultConfig
        , defaultStyleConfig
        , toView
        , getValuesIndexed
        )

import Internal.Types exposing (Point, Style, Orientation(..), Scale, Meta, HintInfo)
import Internal.Draw as Draw exposing (..)
import Internal.Stuff exposing ((?))
import Internal.Tick as Tick
import Svg
import Svg.Attributes


type alias Config msg =
    { viewConfig : ViewConfig msg
    , valueConfig : ValueConfig
    }


type alias StyleConfig msg =
    { displace : Maybe ( Int, Int )
    , format : ( Int, Float ) -> String
    , style : Style
    , classes : List String
    , customAttrs : List (Svg.Attribute msg)
    }


type ViewConfig msg
    = FromStyle (StyleConfig msg)
    | FromStyleDynamic (( Int, Float ) -> StyleConfig msg)
    | FromCustomView (View msg)


type ValueConfig
    = CustomValues (List Float)
    | CustomFilter (( Int, Float ) -> Bool)


type alias View msg =
    Orientation -> ( Int, Float ) -> Svg.Svg msg


defaultConfig : Config msg
defaultConfig =
    { viewConfig = FromStyle defaultStyleConfig
    , valueConfig = CustomFilter (always True)
    }


defaultStyleConfig : StyleConfig msg
defaultStyleConfig =
    { displace = Nothing
    , format = (\( _, v ) -> toString v)
    , style = []
    , classes = []
    , customAttrs = []
    }


toView : ViewConfig msg -> View msg
toView config =
    case config of
        FromStyle styles ->
            defaultView styles

        FromStyleDynamic toConfig ->
            toViewFromStyleDynamic toConfig

        FromCustomView view ->
            view


toViewFromStyleDynamic : (( Int, Float ) -> StyleConfig msg) -> View msg
toViewFromStyleDynamic toStyleAttributes orientation ( index, value ) =
    defaultView (toStyleAttributes ( index, value )) orientation ( index, value )


defaultStyleX : ( Style, ( Int, Int ) )
defaultStyleX =
    ( [ ( "text-anchor", "middle" ) ], ( 0, 24 ) )


defaultStyleY : ( Style, ( Int, Int ) )
defaultStyleY =
    ( [ ( "text-anchor", "end" ) ], ( -10, 5 ) )


defaultView : StyleConfig msg -> View msg
defaultView { displace, format, style, classes, customAttrs } orientation ( index, tick ) =
    let
        ( defaultStyle, defaultDisplacement ) =
            (?) orientation defaultStyleX defaultStyleY

        ( dx, dy ) =
            Maybe.withDefault defaultDisplacement displace

        attrs =
            [ Svg.Attributes.transform (toTranslate ( toFloat dx, toFloat dy ))
            , Svg.Attributes.style (toStyle (defaultStyle ++ style))
            , Svg.Attributes.class <| String.join " " <| "elm-plot__label__default-view" :: classes
            ]
                ++ customAttrs
    in
        Svg.text_ attrs [ Svg.tspan [] [ Svg.text (format ( index, tick )) ] ]



-- resolve values


getValuesIndexed : ValueConfig -> List ( Int, Float ) -> List ( Int, Float )
getValuesIndexed config tickValues =
    case config of
        CustomValues values ->
            Tick.indexValues values

        CustomFilter filter ->
            List.filter filter tickValues
