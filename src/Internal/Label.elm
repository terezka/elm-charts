module Internal.Label
    exposing
        ( ViewConfig(..)
        , Config
        , StyleConfig
        , ValueConfig(..)
        , View
        , defaultConfig
        , toDefaultConfig
        , defaultStyleConfig
        , toView
        , defaultView
        , getValues
        )

import Internal.Types exposing (Point, Style, Orientation(..), Scale, Meta, HintInfo, Value, IndexedInfo)
import Internal.Draw as Draw exposing (..)
import Internal.Tick as Tick
import Svg
import Svg.Attributes


type alias Config a msg =
    { viewConfig : ViewConfig a msg
    , valueConfig : ValueConfig a
    }


type alias StyleConfig a msg =
    { displace : Maybe ( Int, Int )
    , format : a -> String
    , style : Style
    , classes : List String
    , customAttrs : List (Svg.Attribute msg)
    }


type ViewConfig a msg
    = FromStyle (StyleConfig a msg)
    | FromStyleDynamic (a -> StyleConfig a msg)
    | FromCustomView (View a msg)


type ValueConfig a
    = CustomValues (List Value)
    | CustomFilter (a -> Bool)


type alias View a msg =
    Orientation -> a -> Svg.Svg msg


defaultConfig : Config a msg
defaultConfig =
    { viewConfig = FromStyle defaultStyleConfig
    , valueConfig = CustomFilter (always True)
    }


defaultStyleConfig : StyleConfig a msg
defaultStyleConfig =
    { displace = Nothing
    , format = always ""
    , style = []
    , classes = []
    , customAttrs = []
    }


toDefaultConfig : (a -> String) -> Config a msg
toDefaultConfig format =
    { viewConfig = FromStyle { defaultStyleConfig | format = format }
    , valueConfig = CustomFilter (always True)
    }


toView : Config a msg -> View a msg
toView { viewConfig } =
    case viewConfig of
        FromStyle styles ->
            defaultView styles

        FromStyleDynamic toConfig ->
            toViewFromStyleDynamic toConfig

        FromCustomView view ->
            view


toViewFromStyleDynamic : (a -> StyleConfig a msg) -> View a msg
toViewFromStyleDynamic toStyleAttributes orientation info =
    defaultView (toStyleAttributes info) orientation info


defaultView : StyleConfig a msg -> View a msg
defaultView { displace, format, style, classes, customAttrs } orientation info =
    let
        ( dx, dy ) =
            Maybe.withDefault ( 0, 0 ) displace

        attrs =
            [ Svg.Attributes.transform (toTranslate ( toFloat dx, toFloat dy ))
            , Svg.Attributes.style (toStyle style)
            , Svg.Attributes.class (String.join " " ("elm-plot__label__default-view" :: classes))
            ]
                ++ customAttrs
    in
        Svg.text_ attrs [ Svg.tspan [] [ Svg.text (format info) ] ]



-- resolve values


getValues : Config (IndexedInfo {}) msg -> List (IndexedInfo {}) -> List (IndexedInfo {})
getValues config tickValues =
    case config.valueConfig of
        CustomValues values ->
            Tick.toIndexInfo values

        CustomFilter filter ->
            List.filter filter tickValues
