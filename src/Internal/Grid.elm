module Internal.Grid exposing (..)

import Svg
import Svg.Attributes
import Internal.Types exposing (Meta, Point, Style, Orientation(..))
import Internal.Draw as Draw exposing (..)


type Values
    = MirrorTicks
    | CustomValues (List Float)


type alias Config =
    { values : Values
    , style : Style
    , classes : List String
    , orientation : Orientation
    }


defaultConfigX : Config
defaultConfigX =
    { values = MirrorTicks
    , style = []
    , classes = []
    , orientation = X
    }


defaultConfigY : Config
defaultConfigY =
    { defaultConfigX | orientation = Y }


getValues : List Float -> Values -> List Float
getValues tickValues values =
    case values of
        MirrorTicks ->
            tickValues

        CustomValues customValues ->
            customValues


view : Meta -> Config -> Svg.Svg a
view meta ({ values, style, classes, orientation } as config) =
    Svg.g
        [ Draw.classAttributeOriented "grid" orientation classes ]
        (viewLines meta config)


viewLines : Meta -> Config -> List (Svg.Svg a)
viewLines ({ oppositeTicks } as meta) { values, style } =
    List.map (viewLine style meta) <| getValues oppositeTicks values


viewLine : Style -> Meta -> Float -> Svg.Svg a
viewLine style =
    Draw.fullLine
        [ Svg.Attributes.style (toStyle style)
        , Svg.Attributes.class "elm-plot__grid__line"
        ]
