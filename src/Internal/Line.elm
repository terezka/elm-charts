module Internal.Line exposing (Config, Smoothing(..), defaultConfig, view)

import Svg
import Svg.Attributes
import Plot.Types exposing (..)
import Internal.Types exposing (..)
import Internal.Draw exposing (..)


type alias Config a =
    { style : Style
    , smoothing : Smoothing
    , customAttrs : List (Svg.Attribute a)
    }


type Smoothing
    = None
    | Bezier


defaultConfig : Config a
defaultConfig =
    { style = [ ( "fill", "transparent" ) ]
    , smoothing = None
    , customAttrs = []
    }


view : Meta -> Config a -> List Point -> Svg.Svg a
view { toSvgCoords } { style, smoothing, customAttrs } points =
    let
        svgPoints =
            List.map toSvgCoords points

        ( startInstruction, _ ) =
            startPath svgPoints

        instructions =
            case smoothing of
                None ->
                    coordsToInstruction "L" svgPoints

                Bezier ->
                    coordsListToInstruction "S" (coordsToSmoothBezierCoords svgPoints)

        attrs =
            (stdAttributes (startInstruction ++ instructions) style) ++ customAttrs
    in
        Svg.path attrs []


coordsToSmoothBezierCoords : List Point -> List (List Point)
coordsToSmoothBezierCoords coords =
    let
        last =
            List.reverse coords |> List.head |> Maybe.withDefault ( 0, 0 )

        lefts =
            coords ++ [ last ]

        middles =
            Maybe.withDefault [] (List.tail lefts)

        rights =
            Maybe.withDefault [] (List.tail middles)
    in
        -- calculate a guide point for the bezier
        -- that creates a guideline paralel to the line connecting the previous and next point
        List.map3 toBezierPoints lefts middles rights


magnitude : Float
magnitude =
    0.5


toBezierPoints : Point -> Point -> Point -> List Point
toBezierPoints ( x0, y0 ) ( x, y ) ( x1, y1 ) =
    let
        dx =
            x1 - x0

        dy =
            y1 - y0
    in
        [ ( x - (dx / 2 * magnitude), y - (dy / 2 * magnitude) ), ( x, y ) ]


stdAttributes : String -> Style -> List (Svg.Attribute a)
stdAttributes d style =
    [ Svg.Attributes.d d
    , Svg.Attributes.style (toStyle style)
    , Svg.Attributes.class "elm-plot__serie--line"
    ]
