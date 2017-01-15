module Internal.Draw
    exposing
        ( fullLine
        , positionAttributes
        , PathType(..)
        , toPath
        , classAttribute
        , classBase
        , classAttributeOriented
        , toLinePath
        , toTranslate
        , toRotate
        , toStyle
        , toPixels
        , toPixelsInt
        , addDisplacement
        )

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



-- Path Stuff


type PathType
    = L Point
    | M Point
    | S Point Point Point
    | Z


toPath : Meta -> List PathType -> String
toPath meta pathParts =
    List.foldl (\part result -> result ++ toPathTypeString meta part) "" pathParts


toPathTypeString : Meta -> PathType -> String
toPathTypeString meta pathType =
    case pathType of
        M point ->
            toPathTypeStringSinglePoint meta "M" point

        L point ->
            toPathTypeStringSinglePoint meta "L" point

        S p1 p2 p3 ->
            toPathTypeStringS meta p1 p2 p3

        Z ->
            "Z"


toPathTypeStringSinglePoint : Meta -> String -> Point -> String
toPathTypeStringSinglePoint meta typeString point =
    typeString ++ " " ++ pointToString meta point


toPathTypeStringS : Meta -> Point -> Point -> Point -> String
toPathTypeStringS meta p1 p2 p3 =
    let
        ( point1, point2 ) =
            toBezierPoints p1 p2 p3
    in
        "S" ++ " " ++ pointToString meta point1 ++ "," ++ pointToString meta point2


magnitude : Float
magnitude =
    0.5


toBezierPoints : Point -> Point -> Point -> ( Point, Point )
toBezierPoints ( x0, y0 ) ( x, y ) ( x1, y1 ) =
    ( ( x - ((x1 - x0) / 2 * magnitude), y - ((y1 - y0) / 2 * magnitude) )
    , ( x, y )
    )


pointToString : Meta -> Point -> String
pointToString meta point =
    let
        ( x, y ) =
            meta.toSvgCoords point
    in
        (toString x) ++ "," ++ (toString y)


toLinePath : Smoothing -> List Point -> List PathType
toLinePath smoothing =
    case smoothing of
        None ->
            List.map L

        Bezier ->
            toSPathTypes [] >> List.reverse


toSPathTypes : List PathType -> List Point -> List PathType
toSPathTypes result points =
    case points of
        [ p1, p2 ] ->
            S p1 p2 p2 :: result

        [ p1, p2, p3 ] ->
            toSPathTypes (S p1 p2 p3 :: result) [ p2, p3 ]

        p1 :: p2 :: p3 :: rest ->
            toSPathTypes (S p1 p2 p3 :: result) (p2 :: p3 :: rest)

        _ ->
            result



-- Utils


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
