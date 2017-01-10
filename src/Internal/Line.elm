module Internal.Line exposing (..)

import Array
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
                Cosmetic ->
                    coordsListToInstruction "S" (coordsToSmoothBezierCoords svgPoints)

        attrs =
            (stdAttributes (startInstruction ++ instructions) style) ++ customAttrs
    in
        Svg.path attrs []


coordsToSmoothBezierCoords : List Point -> List ( List ( Point ) )
coordsToSmoothBezierCoords coords =
    let
        coordsArray = Array.fromList coords
        last = Array.length coordsArray - 1
    in
        Array.indexedMap (\i (x, y) ->
            if i==0 || i==last then
                [ (x, y), (x, y) ]

            else
                let
                    -- calculate a guide point for the bezier
                    -- that creates a guideline paralel to the line connecting the previous and next point
                    (previousX, previousY) = Maybe.withDefault (0, 0) (Array.get (i-1) coordsArray)
                    (nextX, nextY) = Maybe.withDefault (0, 0) (Array.get (i+1) coordsArray)

                    dx = nextX-previousX
                    dy = nextY-previousY
                    magnitude = 0.5
                in
                    [ (x-(dx/2*magnitude), y-(dy/2*magnitude)), (x, y) ]
        ) coordsArray |> Array.toList


stdAttributes : String -> Style -> List (Svg.Attribute a)
stdAttributes d style =
    [ Svg.Attributes.d d
    , Svg.Attributes.style (toStyle style)
    , Svg.Attributes.class "elm-plot__serie--line"
    ]
