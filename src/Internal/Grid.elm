module Internal.Grid exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..))
import Svg
import Svg.Attributes
import Plot.Types exposing (Meta, Point, Style, Orientation(..))
import Helpers exposing (..)
import Internal.Draw as Draw


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
view meta { values, style, classes, orientation } =
    let
        { scale, toSvgCoords, oppositeTicks } =
            meta

        positions =
            getValues oppositeTicks values
    in
        Svg.g
            [ Draw.classAttributeOriented "grid" orientation classes ]
            (List.map (viewLine style meta) positions)



viewLine : Style -> Meta -> Float -> Svg.Svg a
viewLine style =
    Draw.fullLine
        [ Svg.Attributes.style (toStyle style)
        , Svg.Attributes.class "elm-plot__grid__line"
        ]
