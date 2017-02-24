module Svg.Path exposing (..)



type alias Point =
  ( Float, Float )



-- STANDARD SVG COMMANDS


move : Float -> Float -> String
move x y =
  "M" ++ pointToString ( x, y )


line : Float -> Float -> String
line x y =
  "L" ++ pointToString ( x, y )


horizontalLine : Float -> String
horizontalLine x =
  "H" ++ toString x


verticalLine : Float -> String
verticalLine y =
  "V" ++ toString y


cubicBeziers : Float -> Float -> Float -> Float -> Float -> Float -> String
cubicBeziers cx1 cy1 cx2 cy2 x y =
  "C" ++ pointsToString [ ( cx1, cy1 ), ( cx2, cy2 ), ( x, y ) ]


cubicBeziersShort : Float -> Float -> Float -> Float -> String
cubicBeziersShort cx1 cy1 x y  =
  "S" ++ pointsToString [ ( cx1, cy1 ), ( x, y ) ]


quadraticBeziers : Float -> Float -> Float -> Float -> String
quadraticBeziers cx1 cy1 x y =
  "Q" ++ pointsToString [ ( cx1, cy1 ), ( x, y ) ]


quadraticBeziersShort : Float -> Float -> String
quadraticBeziersShort x y =
  "T" ++ pointToString ( x, y )


arc : Float -> Float -> Bool -> Bool -> Bool -> Float -> Float -> String
arc rx ry xAxisRotation largeArcFlag sweepFlag x y =
  "A" ++
    joinCommands
      [ pointToString ( rx, ry )
      , toString xAxisRotation
      , boolToString largeArcFlag
      , boolToString sweepFlag
      , pointToString ( x, y )
      ]


close : String
close =
  "Z"


relative : String -> String
relative =
  String.toLower



-- PATHS


toPath : List String -> String
toPath =
  joinCommands



-- Line


toLinePath : List Point -> String
toLinePath points =
  toPath (List.map (\( x, y ) -> line x y) points)



-- MonotoneX


toMonotoneXPath : List Point -> String
toMonotoneXPath points =
    case points of
      p0 :: p1 :: p2 :: rest ->
        monotoneXPathBegin p0 p1 p2 rest

      _ ->
        ""


monotoneXPathBegin : Point -> Point -> Point -> List Point -> String
monotoneXPathBegin p0 p1 p2 rest =
    let
      tangent1 = slope3 p0 p1 p2
      tangent0 = slope2 p0 p1 tangent1
    in
      monotoneXCurve p0 p1 tangent0 tangent1 ++ monotoneXPath (p1 :: p2 :: rest) tangent1 ""


monotoneXPath : List Point -> Float -> String -> String
monotoneXPath points tangent0 path =
  case points of
    p0 :: p1 :: p2 :: rest ->
      let
          tangent1 = slope3 p0 p1 p2
          newPath = path ++ " " ++ monotoneXCurve p0 p1 tangent0 tangent1
      in
        monotoneXPath (p1 :: p2 :: rest) tangent0 newPath

    [ p1, p2 ] ->
      let
          tangent1 = slope3 p1 p2 p2
      in
        path ++ " " ++ monotoneXCurve p1 p2 tangent0 tangent1

    _ ->
      path


monotoneXCurve : Point -> Point -> Float -> Float -> String
monotoneXCurve ( x0, y0 ) ( x1, y1 ) tangent0 tangent1 =
    let
        dx = (x1 - x0) / 3
    in
        cubicBeziers (x0 + dx) (y0 + dx * tangent0) (x1 - dx) (y1 - dx * tangent1) x1 y1


-- Helpers


joinCommands : List String -> String
joinCommands commands =
  String.join " " commands


pointToString : Point -> String
pointToString ( x, y ) =
  toString x ++ " " ++ toString y


pointsToString : List Point -> String
pointsToString points =
  String.join "," (List.map pointToString points)


boolToString : Bool -> String
boolToString bool =
  if bool then "0" else "1"


{-| Calculate the slopes of the tangents (Hermite-type interpolation) based on
 the following paper: Steffen, M. 1990. A Simple Method for Monotonic
 Interpolation in One Dimension
-}
slope3 : Point -> Point -> Point -> Float
slope3 ( x0, y0 ) ( x1, y1 ) ( x2, y2 ) =
  let
    h0 = x1 - x0
    h1 = x2 - x1
    s0 = (y1 - y0) / h0
    s1 = (y2 - y1) / h1
    p = (s0 * h1 + s1 * h0) / (h0 + h1)
    slope = (sign s0 + sign s1) * (min (min (abs s0) (abs s1)) (0.5 * abs p))
  in
    if isNaN slope then 0 else slope


{-| Calculate a one-sided slope. -}
slope2 : Point -> Point -> Float -> Float
slope2 ( x0, y0 ) ( x1, y1 ) tangent0 =
  let
    h = x1 - x0
  in
    if h /= 0 then
      (3 * (y1 - y0) / ((x1 - x0) - tangent0)) / 2
    else
      tangent0




sign : Float -> Float
sign x =
  if x < 0 then -1 else 1
