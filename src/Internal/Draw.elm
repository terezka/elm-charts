module Internal.Draw exposing (..)

import Svg exposing (Svg, Attribute)
import Svg.Attributes
import Plot.Types exposing (Point)
import Internal.Types exposing (Meta, Orientation, Smoothing(..))
import Internal.Stuff exposing (..)


{- Common drawing functions. -}


fullLine : List (Attribute a) -> Meta -> Float -> Svg a
fullLine attributes { toSvgCoords, scale } value =
    let
        { lowest, highest } =
            scale.x

        begin =
            toSvgCoords ( lowest, value )

        end =
            toSvgCoords ( highest, value )
    in
        Svg.line (positionAttributes begin end ++ attributes) []


positionAttributes : ( Float, Float ) -> ( Float, Float ) -> List (Attribute a)
positionAttributes ( x1, y1 ) ( x2, y2 ) =
    [ Svg.Attributes.x1 (toString x1)
    , Svg.Attributes.y1 (toString y1)
    , Svg.Attributes.x2 (toString x2)
    , Svg.Attributes.y2 (toString y2)
    ]


classAttribute : String -> List String -> Attribute a
classAttribute base classes =
    (classBase base)
        :: classes
        |> String.join " "
        |> Svg.Attributes.class


classAttributeOriented : String -> Orientation -> List String -> Attribute a
classAttributeOriented base orientation classes =
    ((?) orientation (classBase base ++ "--x") (classBase base ++ "--y"))
        :: classes
        |> classAttribute base


classBase : String -> String
classBase base =
    "elm-plot__" ++ base


toInstruction : String -> List Float -> String
toInstruction instructionType coords =
    let
        coordsString =
            List.map toString coords
                |> String.join ","
    in
        instructionType ++ " " ++ coordsString


toLineInstructions : Smoothing -> List Point -> String
toLineInstructions smoothing =
    case smoothing of
        None ->
            coordsToInstruction "L"

        Bezier ->
            coordsToSmoothBezierCoords >> coordsListToInstruction "S"


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


coordsToInstruction : String -> List ( Float, Float ) -> String
coordsToInstruction instructionType coords =
    List.map (\( x, y ) -> toInstruction instructionType [ x, y ]) coords |> String.join ""


coordsListToInstruction : String -> List (List Point) -> String
coordsListToInstruction instructionType coords =
    List.map
        (\points ->
            toInstruction instructionType
                (List.foldr (\( x, y ) all -> [ x, y ] ++ all) [] points)
        )
        coords
        |> String.join ""


startPath : List ( Float, Float ) -> ( String, List ( Float, Float ) )
startPath data =
    let
        ( x, y ) =
            Maybe.withDefault ( 0, 0 ) (List.head data)

        tail =
            Maybe.withDefault [] (List.tail data)
    in
        ( toInstruction "M" [ x, y ], tail )


toTranslate : ( Float, Float ) -> String
toTranslate ( x, y ) =
    "translate(" ++ (toString x) ++ "," ++ (toString y) ++ ")"


toRotate : Float -> Float -> Float -> String
toRotate d x y =
    "rotate(" ++ (toString d) ++ " " ++ (toString x) ++ " " ++ (toString y) ++ ")"


toStyle : List ( String, String ) -> String
toStyle styles =
    List.foldr (\( p, v ) r -> r ++ p ++ ":" ++ v ++ "; ") "" styles


toPixels : Float -> String
toPixels pixels =
    toString pixels ++ "px"


toPixelsInt : Int -> String
toPixelsInt =
    toPixels << toFloat


addDisplacement : Point -> Point -> Point
addDisplacement ( x, y ) ( dx, dy ) =
    ( x + dx, y + dy )
