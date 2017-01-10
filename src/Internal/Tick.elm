module Internal.Tick
    exposing
        ( Config
        , StyleConfig
        , ViewConfig(..)
        , View
        , defaultConfig
        , defaultStyleConfig
        , toView
        )

import Plot.Types exposing (Point, Style)
import Internal.Types exposing (Orientation(..), Scale, Meta, IndexedInfo, Value)
import Internal.Draw as Draw exposing (..)
import Svg
import Svg.Attributes


type alias Config a msg =
    { viewConfig : ViewConfig a msg }


type alias StyleConfig msg =
    { length : Int
    , width : Int
    , style : Style
    , classes : List String
    , customAttrs : List (Svg.Attribute msg)
    }


type ViewConfig a msg
    = FromStyle (StyleConfig msg)
    | FromStyleDynamic (a -> StyleConfig msg)
    | FromCustomView (View a msg)


type alias View a msg =
    Orientation -> a -> Svg.Svg msg


defaultConfig : Config a msg
defaultConfig =
    { viewConfig = FromStyle defaultStyleConfig }


defaultStyleConfig : StyleConfig msg
defaultStyleConfig =
    { length = 7
    , width = 1
    , style = []
    , classes = []
    , customAttrs = []
    }


toView : Config a msg -> View a msg
toView { viewConfig } =
    case viewConfig of
        FromStyle styleConfig ->
            defaultView styleConfig

        FromStyleDynamic toConfig ->
            toViewFromStyleDynamic toConfig

        FromCustomView view ->
            view


toViewFromStyleDynamic : (a -> StyleConfig msg) -> View a msg
toViewFromStyleDynamic toStyleConfig orientation info =
    defaultView (toStyleConfig info) orientation info


defaultView : StyleConfig msg -> View a msg
defaultView { length, width, style, classes, customAttrs } orientation _ =
    let
        styleFinal =
            style ++ [ ( "stroke-width", toPixelsInt width ) ]

        attrs =
            [ Svg.Attributes.style (toStyle styleFinal)
            , Svg.Attributes.y2 (toString length)
            , Svg.Attributes.class <| String.join " " <| "elm-plot__tick__default-view" :: classes
            ]
                ++ customAttrs
    in
        Svg.line attrs []
