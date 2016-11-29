module Internal.Grid exposing (..)

import Svg
import Svg.Attributes
import Internal.Types exposing (Meta, Point, Style, Orientation(..))
import Internal.Draw as Draw exposing (..)


type Values
    = MirrorTicks
    | CustomValues (List Float)


type alias Config a =
    { values : Values
    , style : Style
    , classes : List String
    , orientation : Orientation
    , customAttrs : List (Svg.Attribute a)
    }


defaultConfigX : Config a
defaultConfigX =
    { values = MirrorTicks
    , style = []
    , classes = []
    , orientation = X
    , customAttrs = []
    }


defaultConfigY : Config a
defaultConfigY =
    { defaultConfigX | orientation = Y }


getValues : List Float -> Values -> List Float
getValues tickValues values =
    case values of
        MirrorTicks ->
            tickValues

        CustomValues customValues ->
            customValues


view : Meta -> Config a -> Svg.Svg a
view meta ({ values, style, classes, orientation } as config) =
    Svg.g
        [ Draw.classAttributeOriented "grid" orientation classes ]
        (viewLines meta config)


viewLines : Meta -> Config a -> List (Svg.Svg a)
viewLines ({ oppositeTicks } as meta) { values, style, customAttrs } =
    List.map (viewLine style customAttrs meta) <| getValues oppositeTicks values


viewLine : Style -> List (Svg.Attribute a) -> Meta -> Float -> Svg.Svg a
viewLine style customAttrs =
    [ Svg.Attributes.style (toStyle style)
    , Svg.Attributes.class "elm-plot__grid__line"
    ] ++ customAttrs |> Draw.fullLine
