module Plot.Grid exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..), AxisScale, PlotProps, TooltipInfo)
import Helpers exposing (..)
import Svg
import Svg.Attributes


--## Grid configuration
--@docs verticalGrid, horizontalGrid, gridMirrorTicks, gridValues, gridClasses, gridStyle


type Values
    = MirrorTicks
    | CustomValues (List Float)


type alias Config =
    { values : Values
    , style : Style
    , classes : List String
    , orientation : Orientation
    }


{-| The type representing an grid configuration.
-}
type alias Attribute =
    Config -> Config


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


{-| Adds grid lines where the ticks on the corresponding axis are.

    main =
        plot
            []
            [ vertical [ gridMirrorTicks ]
            , xAxis []
            ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `gridValues` attribute, then this attribute will have no effect.
-}
mirrorTicks : Attribute
mirrorTicks config =
    { config | values = MirrorTicks }


{-| Specify a list of ticks where you want grid lines drawn.

    plot [] [ vertical [ gridValues [ 1, 2, 4, 8 ] ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `gridMirrorTicks` attribute, then this attribute will have no effect.
-}
values : List Float -> Attribute
values values config =
    { config | values = CustomValues values }


{-| Specify styles for the gridlines.

    plot
        []
        [ vertical
            [ gridMirrorTicks
            , gridStyle myStyles
            ]
        ]

 Remember that if you do not specify either `gridMirrorTicks`
 or `gridValues`, then we will default to not showing any grid lines.
-}
style : Style -> Attribute
style style config =
    { config | style = style }


{-| Specify classes for the grid.

    plot
        []
        [ vertical
            [ gridMirrorTicks
            , gridClasses [ "my-class" ]
            ]
        ]

 Remember that if you do not specify either `gridMirrorTicks`
 or `gridValues`, then we will default to not showing any grid lines.
-}
classes : List String -> Attribute
classes classes config =
    { config | classes = classes }


toConfigX : List Attribute -> Config
toConfigX attrs =
    List.foldr (<|) defaultConfigX attrs


toConfigY : List Attribute -> Config
toConfigY attrs =
    List.foldr (<|) defaultConfigY attrs


getPositions : List Float -> Values -> List Float
getPositions tickValues values =
    case values of
        MirrorTicks ->
            tickValues

        CustomValues customValues ->
            customValues


view : PlotProps -> Config -> Svg.Svg a
view plotProps { values, style, classes } =
    let
        { scale, toSvgCoords, oppositeTicks } =
            plotProps

        positions =
            getPositions oppositeTicks values
    in
        Svg.g
            [ Svg.Attributes.class (String.join " " classes) ]
            (List.map (viewLine plotProps style) positions)


viewLine : PlotProps -> Style -> Float -> Svg.Svg a
viewLine { toSvgCoords, scale } style position =
    let
        { lowest, highest } =
            scale

        ( x1, y1 ) =
            toSvgCoords ( lowest, position )

        ( x2, y2 ) =
            toSvgCoords ( highest, position )

        attrs =
            Svg.Attributes.style (toStyle style) :: (toPositionAttr x1 y1 x2 y2)
    in
        Svg.line attrs []
