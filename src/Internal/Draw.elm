module Internal.Draw
  exposing
    ( Point
    , PlotSummary
    , AxisSummary
    , Command
    , draw
    , place
    , range
    , length
    , scaleValue
    , unScaleValue
    , toUnSVGX
    , toUnSVGY
    , toSVGX
    , toSVGY
    , linear
    , linearArea
    , monotoneX
    , monotoneXArea
    )

import Svg exposing (Svg, Attribute, path, g)
import Svg.Attributes exposing (d, transform)


type alias Point =
  { x : Float
  , y : Float
  }



-- TRANSLATION


type alias AxisSummary =
  { min : Float
  , max : Float
  , dataMin : Float
  , dataMax : Float
  , marginLower : Float
  , marginUpper : Float
  , length : Float
  , all : List Float
  }


type alias PlotSummary =
  { x : AxisSummary
  , y : AxisSummary
  }


range : AxisSummary -> Float
range axis =
  if axis.max - axis.min /= 0 then axis.max - axis.min else 1


length : AxisSummary -> Float
length axis =
  axis.length - axis.marginLower - axis.marginUpper


scaleValue : AxisSummary -> Float -> Float
scaleValue axis value =
  value * (length axis) / (range axis)


unScaleValue : AxisSummary -> Float -> Float
unScaleValue axis v =
  v * (range axis) / (length axis)


toUnSVGX : PlotSummary -> Float -> Float
toUnSVGX { x } value =
  unScaleValue x (value - x.marginLower) + x.min


toUnSVGY : PlotSummary -> Float -> Float
toUnSVGY { y } value =
  range y - unScaleValue y (value - y.marginLower) + y.min


toSVGX : PlotSummary -> Float -> Float
toSVGX { x } value =
  scaleValue x (value - x.min) + x.marginLower


toSVGY : PlotSummary -> Float -> Float
toSVGY { y } value =
  scaleValue y (y.max - value) + y.marginLower



-- DRAW API


draw : List (Attribute msg) -> List Command -> Svg msg
draw attributes commands =
  path (d (joinCommands (List.map stringifyCommand commands)) :: attributes) []


place : PlotSummary -> Point -> Float -> Float -> Attribute msg
place plot { x, y } offsetX offsetY =
  transform <| "translate(" ++ toString (toSVGX plot x + offsetX) ++ "," ++ toString (toSVGY plot y + offsetY) ++ ")"



-- LINEAR


linear : PlotSummary -> List Point -> List Command
linear plot points =
  List.map (translateCommand plot) <| lineBegin plot points ++ List.map lineCommand points


linearArea : PlotSummary -> List Point -> List Command
linearArea plot points =
  List.map (translateCommand plot) <| areaBegin plot points ++ List.map lineCommand points ++ areaEnd plot points


lineCommand : Point -> Command
lineCommand { x, y } =
  Line x y



-- MONOTONE X / "NORMAL"


monotoneX : PlotSummary -> List Point -> List Command
monotoneX plot points =
  List.map (translateCommand plot) <| lineBegin plot points ++ monotoneXBegin points


monotoneXArea : PlotSummary -> List Point -> List Command
monotoneXArea plot points =
  List.map (translateCommand plot) <| areaBegin plot points ++ monotoneXBegin points ++ areaEnd plot points


monotoneXBegin : List Point -> List Command
monotoneXBegin points =
    case points of
      p0 :: p1 :: p2 :: rest ->
        let
          tangent1 = slope3 p0 p1 p2
          tangent0 = slope2 p0 p1 tangent1
        in
          monotoneXCurve p0 p1 tangent0 tangent1 ++ monotoneXNext (p1 :: p2 :: rest) tangent1 []

      _ ->
        []


monotoneXNext : List Point -> Float -> List Command -> List Command
monotoneXNext points tangent0 commands =
  case points of
    p0 :: p1 :: p2 :: rest ->
      let
        tangent1 = slope3 p0 p1 p2
        nextCommands = commands ++ monotoneXCurve p0 p1 tangent0 tangent1
      in
        monotoneXNext (p1 :: p2 :: rest) tangent1 nextCommands

    [ p1, p2 ] ->
      let
        tangent1 = slope3 p1 p2 p2
      in
        commands ++ monotoneXCurve p1 p2 tangent0 tangent1

    _ ->
        commands


monotoneXCurve : Point -> Point -> Float -> Float -> List Command
monotoneXCurve point0 point1 tangent0 tangent1 =
  let
    dx = (point1.x - point0.x) / 3
  in
    [ CubicBeziers (point0.x + dx) (point0.y + dx * tangent0) (point1.x - dx) (point1.y - dx * tangent1) point1.x point1.y ]



-- PATH HELPERS


lineBegin : PlotSummary -> List Point -> List Command
lineBegin plot points =
  case points of
    { x, y } :: rest ->
      [ Move x y ]

    _ ->
      []


areaBegin : PlotSummary -> List Point -> List Command
areaBegin plot points =
  case points of
    { x, y } :: rest ->
      [ Move x (yClosestToZero plot), Line x y ]

    _ ->
      []


areaEnd : PlotSummary -> List Point -> List Command
areaEnd plot points =
  case List.head <| List.reverse <| points of
    Just { x, y } ->
      [ Line x (yClosestToZero plot) ]

    Nothing ->
      []


yClosestToZero : PlotSummary -> Float
yClosestToZero { y } =
  clamp y.min y.max 0


-- PATH COMMANDS


type Command
  = Move Float Float
  | Line Float Float
  | HorizontalLine Float
  | VerticalLine Float
  | CubicBeziers Float Float Float Float Float Float
  | CubicBeziersShort Float Float Float Float
  | QuadraticBeziers Float Float Float Float
  | QuadraticBeziersShort Float Float
  | Arc Float Float Bool Bool Bool Float Float
  | Close


stringifyCommand : Command -> String
stringifyCommand command =
  case command of
    Move x y ->
      "M" ++ pointToString (Point x y)

    Line x y ->
      "L" ++ pointToString (Point x y)

    HorizontalLine x ->
      "H" ++ toString x

    VerticalLine y ->
      "V" ++ toString y

    CubicBeziers cx1 cy1 cx2 cy2 x y ->
      "C" ++ pointsToString [ (Point cx1 cy1), (Point cx2 cy2), (Point x y) ]

    CubicBeziersShort cx1 cy1 x y ->
      "Q" ++ pointsToString [ (Point cx1 cy1), (Point x y) ]

    QuadraticBeziers cx1 cy1 x y ->
      "Q" ++ pointsToString [ (Point cx1 cy1), (Point x y) ]

    QuadraticBeziersShort x y ->
      "T" ++ pointToString (Point x y)

    Arc rx ry xAxisRotation largeArcFlag sweepFlag x y ->
      "A" ++ joinCommands
              [ pointToString (Point rx ry)
              , toString xAxisRotation
              , boolToString largeArcFlag
              , boolToString sweepFlag
              , pointToString (Point x y)
              ]

    Close ->
      "Z"


translateCommand : PlotSummary -> Command -> Command
translateCommand plot command =
    case command of
      Move x y ->
        Move (toSVGX plot x) (toSVGY plot y)

      Line x y ->
        Line (toSVGX plot x) (toSVGY plot y)

      HorizontalLine x ->
        HorizontalLine (toSVGX plot x)

      VerticalLine y ->
        VerticalLine (toSVGY plot y)

      CubicBeziers cx1 cy1 cx2 cy2 x y ->
          CubicBeziers (toSVGX plot cx1) (toSVGY plot cy1) (toSVGX plot cx2) (toSVGY plot cy2) (toSVGX plot x) (toSVGY plot y)

      CubicBeziersShort cx1 cy1 x y ->
          CubicBeziersShort (toSVGX plot cx1) (toSVGY plot cy1) (toSVGX plot x) (toSVGY plot y)

      QuadraticBeziers cx1 cy1 x y ->
          QuadraticBeziers (toSVGX plot cx1) (toSVGY plot cy1) (toSVGX plot x) (toSVGY plot y)

      QuadraticBeziersShort x y ->
          QuadraticBeziersShort (toSVGX plot x) (toSVGY plot y)

      Arc rx ry xAxisRotation largeArcFlag sweepFlag x y ->
        Arc (toSVGX plot rx) (toSVGY plot ry) xAxisRotation largeArcFlag sweepFlag (toSVGX plot x) (toSVGY plot y)

      Close ->
          Close



-- HELPERS


joinCommands : List String -> String
joinCommands commands =
    String.join " " commands


pointToString : Point -> String
pointToString { x, y } =
    toString x ++ " " ++ toString y


pointsToString : List Point -> String
pointsToString points =
    String.join "," (List.map pointToString points)


boolToString : Bool -> String
boolToString bool =
    if bool then
        "0"
    else
        "1"



-- MATH


{-| Calculate the slopes of the tangents (Hermite-type interpolation) based on
 the following paper: Steffen, M. 1990. A Simple Method for Monotonic
 Interpolation in One Dimension
-}
slope3 : Point -> Point -> Point -> Float
slope3 point0 point1 point2 =
    let
        h0 =
            point1.x - point0.x

        h1 =
            point2.x - point1.x

        s0h =
            toH h0 h1

        s1h =
            toH h1 h0

        s0 =
            (point1.y - point0.y) / s0h

        s1 =
            (point2.y - point1.y) / s1h

        p =
            (s0 * h1 + s1 * h0) / (h0 + h1)

        slope =
            (sign s0 + sign s1) * (min (min (abs s0) (abs s1)) (0.5 * abs p))
    in
        if isNaN slope then
            0
        else
            slope


toH : Float -> Float -> Float
toH h0 h1 =
    if h0 == 0 then
        if h1 < 0 then
            0 * -1
        else
            h1
    else
        h0


{-| Calculate a one-sided slope.
-}
slope2 : Point -> Point -> Float -> Float
slope2 point0 point1 t =
    let
        h =
            point1.x - point0.x
    in
        if h /= 0 then
            (3 * (point1.y - point0.y) / h - t) / 2
        else
            t


sign : Float -> Float
sign x =
    if x < 0 then
        -1
    else
        1
