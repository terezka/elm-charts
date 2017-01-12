module Internal.Line exposing (..)

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
        first = List.head coords |> Maybe.withDefault (0, 0)
        last = List.reverse coords |> List.head |> Maybe.withDefault (0, 0)
        paddedCoords = [first] ++ coords ++ [last]

        lefts = paddedCoords
        middles = Maybe.withDefault [] (List.tail lefts)
        rights = Maybe.withDefault [] (List.tail middles)

        pointsWithNeighbours =
            List.map3
                (\(x1, y1) (x2, y2) (x3, y3) -> {left={x=x1, y=y1}, point={x=x2, y=y2}, right={x=x3, y=y3}})
                lefts
                middles
                rights
    in
        List.map (\ pointWithNeighbours ->
            let
                -- calculate a guide point for the bezier
                -- that creates a guideline paralel to the line connecting the previous and next point
                x = pointWithNeighbours.point.x
                y = pointWithNeighbours.point.y
                dx = pointWithNeighbours.right.x - pointWithNeighbours.left.x
                dy = pointWithNeighbours.right.y - pointWithNeighbours.left.y
                magnitude = 0.5
            in
                [ (x-(dx/2*magnitude), y-(dy/2*magnitude)), (x, y) ]
        )
        pointsWithNeighbours


stdAttributes : String -> Style -> List (Svg.Attribute a)
stdAttributes d style =
    [ Svg.Attributes.d d
    , Svg.Attributes.style (toStyle style)
    , Svg.Attributes.class "elm-plot__serie--line"
    ]
