module Internal.Grid exposing (..)

import Svg
import Svg.Attributes
import Plot.Types exposing (..)
import Internal.Types exposing (..)
import Internal.Draw as Draw exposing (..)
import Internal.Axis as Axis
import Internal.Line as Line


type alias Config a =
    { values : ValueOption
    , linesConfig : Line.Config a
    , classes : List String
    , orientation : Orientation
    , customAttrs : List (Svg.Attribute a)
    }


defaultConfigX : Config a
defaultConfigX =
    { values = FromDefault
    , linesConfig = Line.defaultConfig
    , classes = []
    , orientation = X
    , customAttrs = []
    }


defaultConfigY : Config a
defaultConfigY =
    { defaultConfigX | orientation = Y }


getValues : Meta -> Config msg -> List Float
getValues meta config =
    case config.values of
        FromDefault ->
            meta.oppositeTicks

        FromDelta delta ->
            Axis.toValuesFromDelta delta meta.scale.y

        FromBounds toValues ->
            toValues meta.scale.y.lowest meta.scale.y.highest

        FromList values ->
            values


view : Meta -> Config a -> Svg.Svg a
view meta ({ values, classes, orientation } as config) =
    Svg.g
        [ Draw.classAttributeOriented "grid" orientation classes ]
        (viewLines meta config)


viewLines : Meta -> Config a -> List (Svg.Svg a)
viewLines meta config =
    List.map (viewLine config.linesConfig meta) <| getValues meta config


viewLine : Line.Config a -> Meta -> Float -> Svg.Svg a
viewLine { style, customAttrs } =
    [ Svg.Attributes.style (toStyle style)
    , Svg.Attributes.class "elm-plot__grid__line"
    ]
        ++ customAttrs
        |> Draw.fullLine
