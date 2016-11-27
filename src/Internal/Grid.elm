module Internal.Grid exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..))
import Svg
import Svg.Attributes
import Plot.Types exposing (Meta, Point, Style, Orientation(..))
import Helpers exposing (..)


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
view meta { values, style, classes } =
    let
        { scale, toSvgCoords, oppositeTicks } =
            meta

        positions =
            getValues oppositeTicks values
    in
        Svg.g
            [ Svg.Attributes.class (String.join " " classes) ]
            (List.map (viewLine meta style) positions)


viewLine : Meta -> Style -> Float -> Svg.Svg a
viewLine { toSvgCoords, scale } style position =
    let
        { lowest, highest } =
            scale

        ( x1, y1 ) =
            toSvgCoords ( lowest, position )

        ( x2, y2 ) =
            toSvgCoords ( highest, position )
    in
        Svg.line
            [ Svg.Attributes.x1 (toString x1)
            , Svg.Attributes.y1 (toString y1)
            , Svg.Attributes.x2 (toString x2)
            , Svg.Attributes.y2 (toString y2)
            , Svg.Attributes.style (toStyle style)
            , Svg.Attributes.class "elm-plot__grid__line"
            ]
            []
