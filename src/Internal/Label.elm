module Internal.Label
    exposing
        ( ViewConfig(..)
        , Config
        , StyleConfig
        , FormatConfig(..)
        , defaultConfig
        , toDefaultConfig
        , defaultStyleConfig
        , view
        , defaultView
        )

import Plot.Types exposing (Point, Style, HintInfo)
import Internal.Types exposing (Orientation(..), Scale, Meta, Value, IndexedInfo)
import Internal.Draw as Draw exposing (..)
import Svg
import Svg.Attributes


type alias Config a msg =
    { viewConfig : ViewConfig a msg
    , format : FormatConfig a
    }


type alias StyleConfig msg =
    { displace : Maybe ( Int, Int )
    , style : Style
    , classes : List String
    , customAttrs : List (Svg.Attribute msg)
    }


type FormatConfig a
    = FromFunc (a -> String)
    | FromList (List String)


type ViewConfig a msg
    = FromStyle (StyleConfig msg)
    | FromStyleDynamic (a -> StyleConfig msg)
    | FromCustomView (a -> Svg.Svg msg)


defaultConfig : Config a msg
defaultConfig =
    { viewConfig = FromStyle defaultStyleConfig
    , format = FromFunc (always "")
    }


defaultStyleConfig : StyleConfig msg
defaultStyleConfig =
    { displace = Nothing
    , style = []
    , classes = []
    , customAttrs = []
    }


toDefaultConfig : (a -> String) -> Config a msg
toDefaultConfig format =
    { viewConfig = FromStyle defaultStyleConfig
    , format = FromFunc format
    }


view : Config a msg -> (a -> List (Svg.Attribute msg)) -> List a -> List (Svg.Svg msg)
view config toAttributes infos =
    case config.viewConfig of
        FromStyle styles ->
            viewLabels config (\info text -> Svg.g (toAttributes info) [ defaultView styles text ]) infos

        FromStyleDynamic toStyleAttributes ->
            viewLabels config (\info text -> Svg.g (toAttributes info) [ defaultView (toStyleAttributes info) text ]) infos

        FromCustomView view ->
            List.map (\info -> Svg.g (toAttributes info) [ view info ]) infos


viewLabels : Config a msg -> (a -> String -> Svg.Svg msg) -> List a -> List (Svg.Svg msg)
viewLabels config view infos =
    case config.format of
        FromFunc formatter ->
            List.map (\info -> view info (formatter info)) infos

        FromList texts ->
            List.map2 view infos texts


defaultView : StyleConfig msg -> String -> Svg.Svg msg
defaultView { displace, style, classes, customAttrs } text =
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
        Svg.text_ attrs [ Svg.tspan [] [ Svg.text text ] ]
