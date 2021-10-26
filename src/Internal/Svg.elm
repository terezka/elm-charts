module Internal.Svg exposing (..)

import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Svg.Events as SE
import Internal.Coordinates as Coord
import Internal.Commands as C exposing (..)
import Internal.Interpolation as Interpolation
import Intervals as I
import Json.Decode as Json
import DOM
import Time
import DateFormat as F
import Dict exposing (Dict)
import Internal.Helpers as Helpers



-- CONTAINER


{-| -}
type alias Container msg =
  { attrs : List (S.Attribute msg)
  , htmlAttrs : List (H.Attribute msg)
  , responsive : Bool
  , events : List (Event msg)
  }


{-| -}
type alias Event msg =
  { name : String
  , handler : Plane -> Point -> msg
  }


defaultContainer : Container msg
defaultContainer =
  { attrs = [ SA.style "overflow: visible;" ]
  , htmlAttrs = []
  , responsive = True
  , events = []
  }


container : Plane -> Container msg -> List (Html msg) -> List (Svg msg) -> List (Html msg) -> Html msg
container plane config below chartEls above =
  -- TODO seperate plane from container size
  -- TODO preserveAspectRatio?
  let htmlAttrsDef =
        [ HA.class "elm-charts__container-inner"
        ]

      htmlAttrsSize =
        if config.responsive then
          [ HA.style "width" "100%"
          , HA.style "height" "100%"
          ]
        else
          [ HA.style "width" (String.fromFloat plane.x.length ++ "px")
          , HA.style "height" (String.fromFloat plane.y.length ++ "px")
          ]

      htmlAttrs =
        config.htmlAttrs ++ htmlAttrsDef ++ htmlAttrsSize

      chart =
        S.svg
          (svgAttrsSize ++ config.attrs)
          ([clipPathDefs] ++ chartEls ++ [catcher])

      svgAttrsSize =
        if config.responsive then
          [ SA.viewBox ("0 0 " ++ String.fromFloat plane.x.length ++ " " ++ String.fromFloat plane.y.length)
          , HA.style "display" "block"
          ]
        else
          [ SA.width (String.fromFloat plane.x.length)
          , SA.height (String.fromFloat plane.y.length)
          , HA.style "display" "block"
          ]

      catcher =
        S.rect (chartPosition ++ List.map toEvent config.events) []

      toEvent event =
        SE.on event.name (decoder plane event.handler)

      chartPosition =
        [ SA.x (String.fromFloat plane.x.marginMin)
        , SA.y (String.fromFloat plane.y.marginMin)
        , SA.width (String.fromFloat (Coord.innerWidth plane))
        , SA.height (String.fromFloat (Coord.innerHeight plane))
        , SA.fill "transparent"
        ]

      clipPathDefs =
        S.defs []
          [ S.clipPath
            [ SA.id (Coord.toId plane) ]
            [ S.rect chartPosition [] ]
          ]
  in
  H.div
    [ HA.class "elm-charts__container"
    , HA.style "position" "relative"
    ]
    [ H.div htmlAttrs (below ++ [ chart ] ++ above) ]



-- TICK


{-| -}
type TickType
  = Floats
  | Ints
  | Times Time.Zone


{-| -}
type alias Tick =
  { color : String
  , width : Float
  , length : Float
  , attrs : List (S.Attribute Never)
  }


{-| -}
defaultTick : Tick
defaultTick =
  { length = 5
  , color = "rgb(210, 210, 210)"
  , width = 1
  , attrs = []
  }


{-| -}
xTick : Plane -> Tick -> Point -> Svg msg
xTick plane config point =
  tick plane config True point


{-| -}
yTick : Plane -> Tick -> Point -> Svg msg
yTick plane config point =
  tick plane config False point


tick : Plane -> Tick -> Bool -> Point -> Svg msg
tick plane config isX point =
  withAttrs config.attrs S.line
    [ SA.class "elm-charts__tick"
    , SA.stroke config.color
    , SA.strokeWidth (String.fromFloat config.width)
    , SA.x1 <| String.fromFloat (Coord.toSVGX plane point.x)
    , SA.x2 <| String.fromFloat (Coord.toSVGX plane point.x + if isX then 0 else -config.length)
    , SA.y1 <| String.fromFloat (Coord.toSVGY plane point.y)
    , SA.y2 <| String.fromFloat (Coord.toSVGY plane point.y + if isX then config.length else 0)
    ]
    []



-- LINE


{-| -}
type alias Line =
  { x1 : Maybe Float
  , x2 : Maybe Float
  , y1 : Maybe Float
  , y2 : Maybe Float
  , x2Svg : Maybe Float
  , y2Svg : Maybe Float
  , xOff : Float
  , yOff : Float
  , tickLength : Float
  , tickDirection : Float
  , color : String
  , width : Float
  , dashed : List Float
  , opacity : Float
  , break : Bool
  , flip : Bool
  , hideOverflow : Bool
  , attrs : List (S.Attribute Never)
  }


defaultLine : Line
defaultLine =
  { x1 = Nothing
  , x2 = Nothing
  , y1 = Nothing
  , y2 = Nothing
  , x2Svg = Nothing
  , y2Svg = Nothing
  , tickLength = 0
  , tickDirection = -90
  , xOff = 0
  , yOff = 0
  , color = "rgb(210, 210, 210)"
  , width = 1
  , dashed = []
  , opacity = 1
  , break = False
  , flip = False
  , hideOverflow = False
  , attrs = []
  }


{-| -}
line : Plane -> Line -> Svg msg
line plane config =
  let ( ( x1, x2 ), ( y1, y2 ) ) =
        case ( ( config.x1, config.x2 ), ( config.y1, config.y2 ), ( config.x2Svg, config.y2Svg ) ) of
          -- ONLY X
          ( ( Just a, Just b ), ( Nothing, Nothing ), _ ) ->
            ( ( a, b ), ( plane.y.min, plane.y.min ) )

          ( ( Just a, Nothing ), ( Nothing, Nothing ), _ ) ->
            ( ( a, a ), ( plane.y.min, plane.y.max ) )

          ( ( Nothing, Just b ), ( Nothing, Nothing ), _ ) ->
            ( ( b, b ), ( plane.y.min, plane.y.max ) )

          -- ONLY Y
          ( ( Nothing, Nothing ), ( Just a, Just b ), _ ) ->
            ( ( plane.x.min, plane.x.min ), ( a, b ) )

          ( ( Nothing, Nothing ), ( Just a, Nothing ), _ ) ->
            ( ( plane.x.min, plane.x.max ), ( a, a ) )

          ( ( Nothing, Nothing ), ( Nothing, Just b ), _ ) ->
            ( ( plane.x.min, plane.x.max ), ( b, b ) )

          -- MIXED
          ( ( Nothing, Just c ), ( Just a, Just b ), _ ) ->
            ( ( c, c ), ( a, b ) )

          ( ( Just c, Nothing ), ( Just a, Just b ), _ ) ->
            ( ( c, c ), ( a, b ) )

          ( ( Just a, Just b ), ( Nothing, Just c ), _ ) ->
            ( ( a, b ), ( c, c ) )

          ( ( Just a, Just b ), ( Just c, Nothing ), _ ) ->
            ( ( a, b ), ( c, c ) )

          -- ONE FULL POINT
          ( ( Just a, Nothing ), ( Nothing, Just b ), ( Nothing, Nothing ) ) ->
            ( ( a, plane.x.max ), ( b, b ) )

          ( ( Just a, Nothing ), ( Nothing, Just b ), ( Just xOff, Just yOff ) ) ->
            ( ( a, a + Coord.scaleCartesianX plane xOff ), ( b, b + Coord.scaleCartesianY plane yOff ) )

          ( ( Just a, Nothing ), ( Nothing, Just b ), ( Just xOff, Nothing ) ) ->
            ( ( a, a + Coord.scaleCartesianX plane xOff ), ( b, b ) )

          ( ( Just a, Nothing ), ( Nothing, Just b ), ( Nothing, Just yOff ) ) ->
            ( ( a, a ), ( b, b + Coord.scaleCartesianY plane yOff ) )

          ( ( Just a, Nothing ), ( Just b, Nothing ), ( Nothing, Nothing ) ) ->
            ( ( a, plane.x.max ), ( b, b ) )

          ( ( Just a, Nothing ), ( Just b, Nothing ), ( Just xOff, Just yOff ) ) ->
            ( ( a, a + Coord.scaleCartesianX plane xOff ), ( b, b + Coord.scaleCartesianY plane yOff ) )

          ( ( Just a, Nothing ), ( Just b, Nothing ), ( Just xOff, Nothing ) ) ->
            ( ( a, a + Coord.scaleCartesianX plane xOff ), ( b, b ) )

          ( ( Just a, Nothing ), ( Just b, Nothing ), ( Nothing, Just yOff ) ) ->
            ( ( a, a ), ( b, b + Coord.scaleCartesianY plane yOff ) )

          ( ( Nothing, Just a ), ( Nothing, Just b ), ( Nothing, Nothing ) ) ->
            ( ( a, plane.x.max ), ( b, b ) )

          ( ( Nothing, Just a ), ( Nothing, Just b ), ( Just xOff, Just yOff ) ) ->
            ( ( a, a + Coord.scaleCartesianX plane xOff ), ( b, b + Coord.scaleCartesianY plane yOff ) )

          ( ( Nothing, Just a ), ( Nothing, Just b ), ( Just xOff, Nothing ) ) ->
            ( ( a, a + Coord.scaleCartesianX plane xOff ), ( b, b ) )

          ( ( Nothing, Just a ), ( Nothing, Just b ), ( Nothing, Just yOff ) ) ->
            ( ( a, a ), ( b, b + Coord.scaleCartesianY plane yOff ) )

          ( ( Nothing, Just a ), ( Just b, Nothing ), ( Nothing, Nothing ) ) ->
            ( ( a, plane.x.max ), ( b, b ) )

          ( ( Nothing, Just a ), ( Just b, Nothing ), ( Just xOff, Just yOff ) ) ->
            ( ( a, a + Coord.scaleCartesianX plane xOff ), ( b, b + Coord.scaleCartesianY plane yOff ) )

          ( ( Nothing, Just a ), ( Just b, Nothing ), ( Just xOff, Nothing ) ) ->
            ( ( a, a + Coord.scaleCartesianX plane xOff ), ( b, b ) )

          ( ( Nothing, Just a ), ( Just b, Nothing ), ( Nothing, Just yOff ) ) ->
            ( ( a, a ), ( b, b + Coord.scaleCartesianY plane yOff ) )

          -- NEITHER
          ( ( Nothing, Nothing ), ( Nothing, Nothing ), _ ) ->
            ( ( plane.x.min, plane.x.max ), ( plane.y.min, plane.y.max ) )

          _ ->
            ( ( Maybe.withDefault plane.x.min config.x1
              , Maybe.withDefault plane.x.max config.x2
              )
            , ( Maybe.withDefault plane.y.min config.y1
              , Maybe.withDefault plane.y.max config.y2
              )
            )

      angle =
        degrees config.tickDirection

      ( tickOffsetX, tickOffsetY ) =
        if config.tickLength > 0 then
        ( lengthInCartesianX plane (cos angle * config.tickLength)
        , lengthInCartesianY plane (sin angle * config.tickLength)
        ) else ( 0, 0 )

      x1_ = x1 + lengthInCartesianX plane config.xOff
      x2_ = x2 + lengthInCartesianX plane config.xOff
      y1_ = y1 - lengthInCartesianY plane config.yOff
      y2_ = y2 - lengthInCartesianY plane config.yOff

      cmds =
        if config.flip then
          (if config.tickLength > 0
            then [ C.Move (x2_ + tickOffsetX) (y2_ + tickOffsetY), C.Line x2_ y2_ ]
            else [ C.Move x2_ y2_ ])
          ++
          (if config.break
          then [ C.Line x2_ y1_, C.Line x1_ y1_ ]
          else [ C.Line x1_ y1_ ])
          ++
          (if config.tickLength > 0
          then [ C.Line (x1_ + tickOffsetX) (y1_ + tickOffsetY) ]
          else [])

        else
          (if config.tickLength > 0
            then [ C.Move (x1_ + tickOffsetX) (y1_ + tickOffsetY), C.Line x1_ y1_ ]
            else [ C.Move x1_ y1_ ])
          ++
          (if config.break
          then [ C.Line x1_ y2_, C.Line x2_ y2_ ]
          else [ C.Line x2_ y2_ ])
          ++
          (if config.tickLength > 0
          then [ C.Line (x2_ + tickOffsetX) (y2_ + tickOffsetY) ]
          else [])
  in
  withAttrs config.attrs S.path
    [ SA.class "elm-charts__line"
    , SA.fill "transparent"
    , SA.stroke config.color
    , SA.strokeWidth (String.fromFloat config.width)
    , SA.strokeOpacity (String.fromFloat config.opacity)
    , SA.strokeDasharray (String.join " " <| List.map String.fromFloat config.dashed)
    , SA.d (C.description plane cmds)
    , if config.hideOverflow then withinChartArea plane else SA.class ""
    ]
    []



{-| -}
type alias Rect =
  { x1 : Maybe Float
  , x2 : Maybe Float
  , y1 : Maybe Float
  , y2 : Maybe Float
  , color : String
  , border : String
  , borderWidth : Float
  , opacity : Float
  , hideOverflow : Bool
  , attrs : List (S.Attribute Never)
  }


defaultRect : Rect
defaultRect =
  { x1 = Nothing
  , x2 = Nothing
  , y1 = Nothing
  , y2 = Nothing
  , color = "rgba(210, 210, 210, 0.5)"
  , border = "rgba(210, 210, 210, 1)"
  , borderWidth = 1
  , opacity = 1
  , hideOverflow = False
  , attrs = []
  }


{-| -}
rect : Plane -> Rect -> Svg msg
rect plane config =
  let ( ( x1_, x2_ ), ( y1_, y2_ ) ) =
        case ( ( config.x1, config.x2 ), ( config.y1, config.y2 ) ) of
          -- ONLY X
          ( ( Just a, Just b ), ( Nothing, Nothing ) ) ->
            ( ( a, b ), ( plane.y.min, plane.y.max ) )

          ( ( Just a, Nothing ), ( Nothing, Nothing ) ) ->
            ( ( a, a ), ( plane.y.min, plane.y.max ) )

          ( ( Nothing, Just b ), ( Nothing, Nothing ) ) ->
            ( ( b, b ), ( plane.y.min, plane.y.max ) )

          -- ONLY Y
          ( ( Nothing, Nothing ), ( Just a, Just b ) ) ->
            ( ( plane.x.min, plane.x.min ), ( a, b ) )

          ( ( Nothing, Nothing ), ( Just a, Nothing ) ) ->
            ( ( plane.x.min, plane.x.max ), ( a, a ) )

          ( ( Nothing, Nothing ), ( Nothing, Just b ) ) ->
            ( ( plane.x.min, plane.x.max ), ( b, b ) )

          -- MIXED
          ( ( Nothing, Just c ), ( Just a, Just b ) ) ->
            ( ( c, c ), ( a, b ) )

          ( ( Just c, Nothing ), ( Just a, Just b ) ) ->
            ( ( c, c ), ( a, b ) )

          ( ( Just a, Just b ), ( Nothing, Just c ) ) ->
            ( ( a, b ), ( c, c ) )

          ( ( Just a, Just b ), ( Just c, Nothing ) ) ->
            ( ( a, b ), ( c, c ) )

          -- NEITHER
          ( ( Nothing, Nothing ), ( Nothing, Nothing ) ) ->
            ( ( plane.x.min, plane.x.max ), ( plane.y.min, plane.y.max ) )

          _ ->
            ( ( Maybe.withDefault plane.x.min config.x1
              , Maybe.withDefault plane.x.max config.x2
              )
            , ( Maybe.withDefault plane.y.min config.y1
              , Maybe.withDefault plane.y.max config.y2
              )
            )

      cmds =
        [ C.Move x1_ y1_
        , C.Line x1_ y1_
        , C.Line x2_ y1_
        , C.Line x2_ y2_
        , C.Line x1_ y2_
        , C.Line x1_ y1_
        ]
  in
  withAttrs config.attrs S.path
    [ SA.class "elm-charts__rect"
    , SA.fill config.color
    , SA.fillOpacity (String.fromFloat config.opacity)
    , SA.stroke config.border
    , SA.strokeWidth (String.fromFloat config.borderWidth)
    , SA.d (C.description plane cmds)
    , if config.hideOverflow then withinChartArea plane else SA.class ""
    ]
    []



-- LEGEND


type alias Legends msg =
  { alignment : Alignment
  , anchor : Maybe Anchor
  , xOff : Float
  , yOff : Float
  , spacing : Float
  , background : String
  , border : String
  , borderWidth : Float
  , htmlAttrs : List (H.Attribute msg)
  }


type Alignment
  = Row
  | Column


{-| -}
type Anchor
  = End
  | Start
  | Middle


defaultLegends : Legends msg
defaultLegends =
  { alignment = Row
  , anchor = Nothing
  , spacing = 10
  , xOff = 0
  , yOff = 0
  , background = ""
  , border = ""
  , borderWidth = 0
  , htmlAttrs = []
  }


legendsAt : Plane -> Float -> Float -> Legends msg -> List (Html msg) -> Html msg
legendsAt plane x y config children =
  let ( alignmentAttrs, direction ) =
        case config.alignment of
          Row ->
            ( [ HA.style "display" "flex"
              , HA.style "align-items" "center"
              ]
            , "right"
            )

          Column ->
            ( [ HA.style "display" "flex"
              , HA.style "flex-direction" "column"
              , HA.style "align-items" "baseline"
              ]
            , "bottom"
            )

      otherAttrs =
        [ HA.class "elm-charts__legends"
        , HA.style "background" config.background
        , HA.style "border-color" config.border
        , HA.style "border-width" (String.fromFloat config.borderWidth ++ "px")
        , HA.style "border-style" "solid"
        ]

      paddingStyle =
        """ .elm-charts__legends .elm-charts__legend {
              margin-""" ++ direction ++ """:""" ++ String.fromFloat config.spacing ++ """px;
            }

            .elm-charts__legends .elm-charts__legend:last-child {
              margin-""" ++ direction ++ """: 0px;
            }
        """
      anchorAttrs =
        case config.anchor of
          Nothing -> [ HA.style "transform" "translate(-0%, 0%)" ]
          Just End -> [ HA.style "transform" "translate(-100%, 0%)" ]
          Just Start -> [ HA.style "transform" "translate(-0%, 0%)" ]
          Just Middle -> [ HA.style "transform" "translate(-50%, 0%)" ]
  in
  positionHtml plane x y config.xOff -config.yOff
    (anchorAttrs ++ alignmentAttrs ++ otherAttrs ++ config.htmlAttrs)
    (H.node "style" [] [ H.text paddingStyle ] :: children)



-- LEGEND



type alias Legend msg =
  { xOff : Float
  , yOff : Float
  , width : Float
  , height : Float
  , fontSize : Maybe Int
  , color : String
  , spacing : Float
  , title : String
  , htmlAttrs : List (H.Attribute msg)
  }


defaultBarLegend : Legend msg
defaultBarLegend =
  { xOff = 0
  , yOff = 0
  , width = 10
  , height = 10
  , fontSize = Nothing
  , color = "#808BAB"
  , spacing = 10
  , title = ""
  , htmlAttrs = []
  }


defaultLineLegend : Legend msg
defaultLineLegend =
  { xOff = 0
  , yOff = 0
  , width = 30
  , height = 16
  , fontSize = Nothing
  , color = "#808BAB"
  , spacing = 10
  , title = ""
  , htmlAttrs = []
  }


barLegend : Legend msg -> Bar ->  Html msg
barLegend config barConfig =
  let fakePlane =
        { x = Coord.Axis config.width 0 0 0 10 0 10
        , y = Coord.Axis config.height 0 0 0 10 0 10
        }

      fontStyle =
        case config.fontSize of
          Just size_ -> HA.style "font-size" (String.fromInt size_ ++ "px")
          Nothing -> HA.style "" ""
  in
  H.div
    ([ HA.class "elm-charts__legend"
    , HA.style "display" "flex"
    , HA.style "align-items" "center"
    ] ++ config.htmlAttrs)
    [ container fakePlane { defaultContainer | responsive = False } []
        [ bar fakePlane barConfig { x1 = 0, y1 = 0, x2 = 10, y2 = 10 } ]
        []
    , H.div
        [ fontStyle
        , HA.style "margin-left" (String.fromFloat config.spacing ++ "px")
        ]
        [ H.text config.title ]
    ]


lineLegend : Legend msg -> Interpolation -> Dot -> Html msg
lineLegend config interConfig dotConfig =
  let topMargin =
        case dotConfig.shape of
          Just shape -> toRadius dotConfig.size shape
          Nothing -> 0

      bottomMargin =
        if interConfig.opacity == 0 then topMargin else 0

      fakePlane =
        { x = Coord.Axis config.width 0 0 0 10 0 10
        , y = Coord.Axis config.height 0 0 0 10 0 10
        }

      fontStyle =
        case config.fontSize of
          Just size_ -> HA.style "font-size" (String.fromInt size_ ++ "px")
          Nothing -> HA.style "" ""
  in
  H.div
    ([ HA.class "elm-charts__legend"
    , HA.style "display" "flex"
    , HA.style "align-items" "center"
    ] ++ config.htmlAttrs)
    [ container fakePlane { defaultContainer | responsive = False } []
        [ interpolation fakePlane .x (.y >> Just) interConfig [ Point 0 5, Point 10 5 ]
        , area fakePlane .x Nothing (.y >> Just) interConfig [ Point 0 5, Point 10 5 ]
        , dot fakePlane .x .y dotConfig (Point 5 5)
        ]
        []
    , H.div
        [ fontStyle
        , HA.style "margin-left" (String.fromFloat config.spacing ++ "px")
        ]
        [ H.text config.title ]
    ]



-- LABEL


{-| -}
type alias Label =
  { xOff : Float
  , yOff : Float
  , border : String
  , borderWidth : Float
  , fontSize : Maybe Int
  , color : String
  , anchor : Maybe Anchor
  , rotate : Float
  , uppercase : Bool
  , hideOverflow : Bool
  , attrs : List (S.Attribute Never)
  , ellipsis : Maybe { width : Float, height : Float }
  }


defaultLabel : Label
defaultLabel =
  { xOff = 0
  , yOff = 0
  , border = "white"
  , borderWidth = 0
  , fontSize = Nothing
  , color = "#808BAB"
  , anchor = Nothing
  , rotate = 0
  , uppercase = False
  , hideOverflow = False
  , attrs = []
  , ellipsis = Nothing
  }


{-| -}
label : Plane -> Label -> List (Svg msg) -> Point -> Svg msg
label plane config inner point =
  case config.ellipsis of
    Nothing ->
      let fontStyle =
            case config.fontSize of
              Just size_ -> "font-size: " ++ String.fromInt size_ ++ "px;"
              Nothing -> ""

          anchorStyle =
            case config.anchor of
              Nothing -> "text-anchor: middle;"
              Just End -> "text-anchor: end;"
              Just Start -> "text-anchor: start;"
              Just Middle -> "text-anchor: middle;"

          uppercaseStyle =
            if config.uppercase then "text-transform: uppercase;" else ""

          withOverflowWrap el =
            if config.hideOverflow then
              S.g [ withinChartArea plane ] [ el ]
            else
              el
      in
      withOverflowWrap <|
        withAttrs config.attrs S.text_
          [ SA.class "elm-charts__label"
          , SA.stroke config.border
          , SA.strokeWidth (String.fromFloat config.borderWidth)
          , SA.fill config.color
          , position plane -config.rotate point.x point.y config.xOff config.yOff
          , SA.style <| String.join " " [ "pointer-events: none;", fontStyle, anchorStyle, uppercaseStyle ]
          ]
          [ S.tspan [] inner ]

    Just ellipsis ->
      let fontStyle =
            case config.fontSize of
              Just size_ -> HA.style "font-size"  (String.fromInt size_ ++ "px")
              Nothing -> HA.style "" ""

          xOffWithAnchor =
            case config.anchor of
              Nothing -> config.xOff - ellipsis.width / 2
              Just End -> config.xOff - ellipsis.width
              Just Start -> config.xOff
              Just Middle -> config.xOff - ellipsis.width / 2

          anchorStyle =
            case config.anchor of
              Nothing -> HA.style "text-align" "center"
              Just End -> HA.style "text-align" "right"
              Just Start -> HA.style "text-align" "left"
              Just Middle -> HA.style "text-align" "center"

          uppercaseStyle =
            if config.uppercase then HA.style "text-transform" "uppercase" else HA.style "" ""

          withOverflowWrap el =
            if config.hideOverflow then
              S.g [ withinChartArea plane ] [ el ]
            else
              el
      in
      withOverflowWrap <|
        withAttrs config.attrs S.foreignObject
          [ SA.class "elm-charts__label"
          , SA.class "elm-charts__html-label"
          , SA.width (String.fromFloat ellipsis.width)
          , SA.height (String.fromFloat ellipsis.height)
          , position plane -config.rotate point.x point.y xOffWithAnchor (config.yOff - 10)
          ]
          [ H.div
              [ HA.attribute "xmlns" "http://www.w3.org/1999/xhtml"
              , HA.style "white-space" "nowrap"
              , HA.style "overflow" "hidden"
              , HA.style "text-overflow" "ellipsis"
              , HA.style "height" "100%"
              , HA.style "pointer-events" "none"
              , HA.style "color" config.color
              , fontStyle
              , uppercaseStyle
              , anchorStyle
              ]
              inner
          ]



-- ARROW


{-| -}
type alias Arrow =
  { xOff : Float
  , yOff : Float
  , color : String
  , width : Float
  , length : Float
  , rotate : Float
  , attrs : List (S.Attribute Never)
  }


defaultArrow : Arrow
defaultArrow =
  { xOff = 0
  , yOff = 0
  , color = "rgb(210, 210, 210)"
  , width = 4
  , length = 7
  , rotate = 0
  , attrs = []
  }


{-| -}
arrow : Plane -> Arrow -> Point -> Svg msg
arrow plane config point =
  let points_ =
        "0,0 " ++ String.fromFloat config.length ++ "," ++ String.fromFloat config.width ++ " 0, " ++ String.fromFloat (config.width * 2)

      commands =
        "rotate(" ++ String.fromFloat config.rotate ++ ") translate(0 " ++ String.fromFloat -config.width ++ ") "
  in
  S.g
    [ SA.class "elm-charts__arrow"
    , position plane 0 point.x point.y config.xOff config.yOff
    ]
    [ withAttrs config.attrs S.polygon
        [ SA.fill config.color
        , SA.points points_
        , SA.transform commands
        ]
        []
    ]



-- BAR


{-| -}
type alias Bar =
  { roundTop : Float
  , roundBottom : Float
  , color : String
  , border : String
  , borderWidth : Float
  , opacity : Float
  , design : Maybe Design
  , attrs : List (S.Attribute Never)
  , highlight : Float
  , highlightWidth : Float
  , highlightColor : String
  }


{-| -}
type Design
  = Striped (List (Helpers.Attribute Pattern))
  | Dotted (List (Helpers.Attribute Pattern))
  | Gradient (List String)


{-| -}
type alias Pattern =
  { color : String
  , width : Float
  , spacing : Float
  , rotate : Float
  }


defaultBar : Bar
defaultBar =
  { roundTop = 0
  , roundBottom = 0
  , border = "white"
  , borderWidth = 0
  , color = Helpers.pink
  , opacity = 1
  , design = Nothing
  , attrs = []
  , highlight = 0
  , highlightWidth = 10
  , highlightColor = ""
  }


{-| -}
bar : Plane -> Bar -> Position -> Svg msg
bar plane config point =
  let highlightColor = if config.highlightColor == "" then config.color else config.highlightColor

      borderWidthCarX = Coord.scaleCartesianX plane (config.borderWidth / 2)
      borderWidthCarY = Coord.scaleCartesianY plane (config.borderWidth / 2)

      pos =
        { x1 = min point.x1 point.x2 + borderWidthCarX
        , x2 = max point.x1 point.x2 - borderWidthCarX
        , y1 = min point.y1 point.y2 + borderWidthCarY
        , y2 = max point.y1 point.y2 - borderWidthCarY
        }

      highlightWidthCarX = borderWidthCarX + Coord.scaleCartesianX plane (config.highlightWidth / 2)
      highlightWidthCarY = borderWidthCarY + Coord.scaleCartesianY plane (config.highlightWidth / 2)

      highlightPos =
        { x1 = pos.x1 - highlightWidthCarX
        , x2 = pos.x2 + highlightWidthCarX
        , y1 = pos.y1 - highlightWidthCarY
        , y2 = pos.y2 + highlightWidthCarY
        }

      width = abs (pos.x2 - pos.x1)
      roundingTop = Coord.scaleSVGX plane width * 0.5 * (clamp 0 1 config.roundTop)
      roundingBottom = Coord.scaleSVGX plane width * 0.5 * (clamp 0 1 config.roundBottom)
      radiusTopX = Coord.scaleCartesianX plane roundingTop
      radiusTopY = Coord.scaleCartesianY plane roundingTop
      radiusBottomX = Coord.scaleCartesianX plane roundingBottom
      radiusBottomY = Coord.scaleCartesianY plane roundingBottom

      height = abs (pos.y2 - pos.y1)
      ( roundTop, roundBottom ) =
        if height - radiusTopY * 0.8 - radiusBottomY * 0.8 <= 0 || width - radiusTopX * 0.8 - radiusBottomX * 0.8 <= 0
        then ( 0, 0 ) else ( config.roundTop, config.roundBottom )

      ( commands, highlightCommands ) =
        if pos.y1 == pos.y2 then
          ( [], [] )
        else
          case ( roundTop > 0, roundBottom > 0 ) of
            ( False, False ) ->
              ( [ C.Move pos.x1 pos.y1
                , C.Line pos.x1 pos.y2
                , C.Line pos.x2 pos.y2
                , C.Line pos.x2 pos.y1
                , C.Line pos.x1 pos.y1
                ]
              , [ C.Move highlightPos.x1 pos.y1
                , C.Line highlightPos.x1 highlightPos.y2
                , C.Line highlightPos.x2 highlightPos.y2
                , C.Line highlightPos.x2 pos.y1
                -- ^ outer
                , C.Line pos.x2 pos.y1
                , C.Line pos.x2 pos.y2
                , C.Line pos.x1 pos.y2
                , C.Line pos.x1 pos.y1
                ]
              )

            ( True, False ) ->
              ( [ C.Move pos.x1 pos.y1
                , C.Line pos.x1 (pos.y2 - radiusTopY)
                , C.Arc roundingTop roundingTop -45 False True (pos.x1 + radiusTopX) pos.y2
                , C.Line (pos.x2 - radiusTopX) pos.y2
                , C.Arc roundingTop roundingTop -45 False True pos.x2 (pos.y2 - radiusTopY)
                , C.Line pos.x2 pos.y1
                , C.Line pos.x1 pos.y1
                ]
              , [ C.Move highlightPos.x1 pos.y1
                , C.Line highlightPos.x1 (highlightPos.y2 - radiusTopY)
                , C.Arc roundingTop roundingTop -45 False True (highlightPos.x1 + radiusTopX) highlightPos.y2
                , C.Line (highlightPos.x2 - radiusTopX) highlightPos.y2
                , C.Arc roundingTop roundingTop -45 False True highlightPos.x2 (highlightPos.y2 - radiusTopY)
                , C.Line highlightPos.x2 pos.y1
                -- ^ outer
                , C.Line pos.x2 pos.y1
                , C.Line pos.x2 (pos.y2 - radiusTopY)
                , C.Arc roundingTop roundingTop -45 False False (pos.x2 - radiusTopX) pos.y2
                , C.Line (pos.x1 + radiusTopX) pos.y2
                , C.Arc roundingTop roundingTop -45 False False pos.x1 (pos.y2 - radiusTopY)
                , C.Line pos.x1 pos.y1
                ]
              )

            ( False, True ) ->
              ( [ C.Move (pos.x1 + radiusBottomX) pos.y1
                , C.Arc roundingBottom roundingBottom -45 False True pos.x1 (pos.y1 + radiusBottomY)
                , C.Line pos.x1 pos.y2
                , C.Line pos.x2 pos.y2
                , C.Line pos.x2 (pos.y1 + radiusBottomY)
                , C.Arc roundingBottom roundingBottom -45 False True (pos.x2 - radiusBottomX) pos.y1
                , C.Line (pos.x1 + radiusBottomX) pos.y1
                ]
              , [ C.Move (highlightPos.x1 + radiusBottomX) highlightPos.y1
                , C.Arc roundingBottom roundingBottom -45 False True highlightPos.x1 (highlightPos.y1 + radiusBottomY)
                , C.Line highlightPos.x1 highlightPos.y2
                , C.Line highlightPos.x2 highlightPos.y2
                , C.Line highlightPos.x2 (highlightPos.y1 + radiusBottomY)
                , C.Arc roundingBottom roundingBottom -45 False True (highlightPos.x2 - radiusBottomX) highlightPos.y1
                , C.Line (highlightPos.x1 + radiusBottomX) highlightPos.y1
                -- ^ outer
                , C.Line (pos.x2 - radiusBottomX) pos.y1
                , C.Arc roundingBottom roundingBottom -45 False False pos.x2 (pos.y1 + radiusBottomY)
                , C.Line pos.x2 pos.y2
                , C.Line pos.x1 pos.y2
                , C.Line pos.x1 (pos.y1 + radiusBottomY)
                , C.Line pos.x2 pos.y1
                ]
              )

            ( True, True ) ->
              ( [ C.Move (pos.x1 + radiusBottomX) pos.y1
                , C.Arc roundingBottom roundingBottom -45 False True pos.x1 (pos.y1 + radiusBottomY)
                , C.Line pos.x1 (pos.y2 - radiusTopY)
                , C.Arc roundingTop roundingTop -45 False True (pos.x1 + radiusTopX) pos.y2
                , C.Line (pos.x2 - radiusTopX) pos.y2
                , C.Arc roundingTop roundingTop -45 False True pos.x2 (pos.y2 - radiusTopY)
                , C.Line pos.x2 (pos.y1 + radiusBottomY)
                , C.Arc roundingBottom roundingBottom -45 False True (pos.x2 - radiusBottomX) pos.y1
                , C.Line (pos.x1 + radiusBottomX) pos.y1
                ]
              , [ C.Move (highlightPos.x1 + radiusBottomX) highlightPos.y1
                , C.Arc roundingBottom roundingBottom -45 False True highlightPos.x1 (highlightPos.y1 + radiusBottomY)
                , C.Line highlightPos.x1 (highlightPos.y2 - radiusTopY)
                , C.Arc roundingTop roundingTop -45 False True (highlightPos.x1 + radiusTopX) highlightPos.y2
                , C.Line (highlightPos.x2 - radiusTopX) highlightPos.y2
                , C.Arc roundingTop roundingTop -45 False True highlightPos.x2 (highlightPos.y2 - radiusTopY)
                , C.Line highlightPos.x2 (highlightPos.y1 + radiusBottomY)
                , C.Arc roundingBottom roundingBottom -45 False True (highlightPos.x2 - radiusBottomX) highlightPos.y1
                , C.Line (highlightPos.x1 + radiusBottomX) highlightPos.y1
                -- ^ outer
                , C.Line (pos.x2 - radiusBottomX) pos.y1
                , C.Arc roundingBottom roundingBottom -45 False False pos.x2 (pos.y1 + radiusBottomY)
                , C.Line pos.x2 (pos.y2 - radiusTopY)
                , C.Arc roundingTop roundingTop -45 False False (pos.x2 - radiusTopX) pos.y2
                , C.Line (pos.x1 + radiusTopX) pos.y2
                , C.Arc roundingTop roundingTop -45 False False pos.x1 (pos.y2 - radiusTopY)
                , C.Line pos.x1 (pos.y1 + radiusBottomY)
                , C.Line pos.x2 pos.y1
                ]
              )

      viewAuraBar fill =
        if config.highlight == 0 then
          viewBar fill config.opacity config.border config.borderWidth 1 commands
        else
          S.g
            [ SA.class "elm-charts__bar-with-highlight" ]
            [ viewBar highlightColor config.highlight "transparent" 0 0 highlightCommands
            , viewBar fill config.opacity config.border config.borderWidth 1 commands
            ]

      viewBar fill fillOpacity border borderWidth strokeOpacity cmds =
          withAttrs config.attrs S.path
            [ SA.class "elm-charts__bar"
            , SA.fill fill
            , SA.fillOpacity (String.fromFloat fillOpacity)
            , SA.stroke border
            , SA.strokeWidth (String.fromFloat borderWidth)
            , SA.strokeOpacity (String.fromFloat strokeOpacity)
            , SA.d (C.description plane cmds)
            , withinChartArea plane
            ]
            []
  in
  case config.design of
    Nothing ->
      viewAuraBar config.color

    Just design ->
      let ( patternDefs, fill ) =
            toPattern config.color design
      in
      S.g
        [ SA.class "elm-charts__bar-with-pattern" ]
        [ patternDefs
        , viewAuraBar fill
        ]



-- SERIES


{-| -}
type alias Interpolation =
  { method : Maybe Method
  , color : String
  , width : Float
  , opacity : Float
  , design : Maybe Design
  , dashed : List Float
  , attrs : List (S.Attribute Never)
  }


{-| -}
type Method
  = Linear
  | Monotone
  | Stepped


defaultInterpolation : Interpolation
defaultInterpolation =
  { method = Nothing
  , color = Helpers.pink
  , width = 1
  , opacity = 0
  , design = Nothing
  , dashed = []
  , attrs = []
  }


{-| -}
interpolation : Plane -> (data -> Float) -> (data -> Maybe Float) -> Interpolation -> List data -> Svg msg
interpolation plane toX toY config data =
  let view ( first, cmds, _ ) =
        withAttrs config.attrs S.path
          [ SA.class "elm-charts__interpolation-section"
          , SA.fill "transparent"
          , SA.stroke config.color
          , SA.strokeDasharray (String.join " " <| List.map String.fromFloat config.dashed)
          , SA.strokeWidth (String.fromFloat config.width)
          , SA.d (C.description plane (Move first.x first.y :: cmds))
          , withinChartArea plane
          ]
          []
  in
  case config.method of
    Nothing -> S.text ""
    Just method ->
      S.g [ SA.class "elm-charts__interpolation-sections" ] <|
        List.map view (toCommands method toX toY data)


defaultArea : Interpolation
defaultArea =
  { method = Nothing
  , color = Helpers.pink
  , width = 1
  , opacity = 0.2
  , design = Nothing
  , dashed = []
  , attrs = []
  }


{-| -}
area : Plane -> (data -> Float) -> Maybe (data -> Maybe Float) -> (data -> Maybe Float) -> Interpolation -> List data -> Svg msg
area plane toX toY2M toY config data =
  let ( patternDefs, fill ) =
        case config.design of
          Nothing -> ( S.text "", config.color )
          Just design -> toPattern config.color design

      view cmds =
        withAttrs config.attrs S.path
          [ SA.class "elm-charts__area-section"
          , SA.fill fill
          , SA.fillOpacity (String.fromFloat config.opacity)
          , SA.strokeWidth "0"
          , SA.fillRule "evenodd"
          , SA.d (C.description plane cmds)
          , withinChartArea plane
          ]
          []

      withoutUnder ( first, cmds, end ) =
        view <|
          [ C.Move first.x 0, C.Line first.x first.y ] ++ cmds ++ [ C.Line end.x 0 ]

      withUnder ( firstBottom, cmdsBottom, endBottom ) ( firstTop, cmdsTop, endTop ) =
        view <|
          [ C.Move firstBottom.x firstBottom.y, C.Line firstTop.x firstTop.y ] ++ cmdsTop ++
          [ C.Move firstBottom.x firstBottom.y ] ++ cmdsBottom ++ [ C.Line endTop.x endTop.y ]
  in
  if config.opacity <= 0 then S.text "" else
  case config.method of
    Nothing -> S.text ""
    Just method ->
      S.g [ SA.class "elm-charts__area-sections" ] <|
        case toY2M of
          Nothing -> patternDefs :: List.map withoutUnder (toCommands method toX toY data)
          Just toY2 -> patternDefs :: List.map2 withUnder (toCommands method toX toY2 data) (toCommands method toX toY data)


toCommands : Method -> (data -> Float) -> (data -> Maybe Float) -> List data -> List ( Point, List C.Command, Point )
toCommands method toX toY data =
  let fold datum_ acc =
        case toY datum_ of
          Just y_ ->
            case acc of
              latest :: rest -> (latest ++ [ { x = toX datum_, y = y_ } ]) :: rest
              [] -> [ { x = toX datum_, y = y_ } ] :: acc

          Nothing ->
            [] :: acc

      points =
        List.reverse (List.foldl fold [] data)

      commands =
        case method of
          Linear -> Interpolation.linear points
          Monotone -> Interpolation.monotone points
          Stepped -> Interpolation.stepped points

      toSets ps cmds =
        withBorder ps <| \first last_ -> ( first, cmds, last_ )
  in
  List.map2 toSets points commands
    |> List.filterMap identity


-- DOTS


{-| -}
type alias Dot =
  { color : String
  , opacity : Float
  , size : Float
  , border : String
  , borderWidth : Float
  , highlight : Float
  , highlightWidth : Float
  , highlightColor : String
  , shape : Maybe Shape
  , hideOverflow : Bool
  }


type Shape
  = Circle
  | Triangle
  | Square
  | Diamond
  | Cross
  | Plus


defaultDot : Dot
defaultDot =
  { color = Helpers.pink
  , opacity = 1
  , size = 6
  , border = ""
  , borderWidth = 0
  , highlight = 0
  , highlightWidth = 5
  , highlightColor = ""
  , shape = Nothing
  , hideOverflow = False
  }


{-| -}
dot : Plane -> (data -> Float) -> (data -> Float) -> Dot -> data -> Svg msg
dot plane toX toY config datum_ =
  let xOrg = toX datum_
      yOrg = toY datum_
      x_ = Coord.toSVGX plane xOrg
      y_ = Coord.toSVGY plane yOrg
      area_ = 2 * pi * config.size
      highlightColor = if config.highlightColor == "" then config.color else config.highlightColor
      showDot = isWithinPlane plane xOrg yOrg || config.hideOverflow

      styleAttrs =
        [ SA.stroke (if config.border == "" then config.color else config.border)
        , SA.strokeWidth (String.fromFloat config.borderWidth)
        , SA.fillOpacity (String.fromFloat config.opacity)
        , SA.fill config.color
        , SA.class "elm-charts__dot"
        , if config.hideOverflow then withinChartArea plane else SA.class ""
        ]

      highlightAttrs =
        [ SA.stroke highlightColor
        , SA.strokeWidth (String.fromFloat config.highlightWidth)
        , SA.strokeOpacity (String.fromFloat config.highlight)
        , SA.fill "transparent"
        , SA.class "elm-charts__dot-highlight"
        ]

      view toEl highlightOff toAttrs =
        if config.highlight > 0 then
          S.g
            [ SA.class "elm-charts__dot-container" ]
            [ toEl (toAttrs highlightOff ++ highlightAttrs) []
            , toEl (toAttrs 0 ++ styleAttrs) []
            ]
        else
          toEl (toAttrs 0 ++ styleAttrs) []
  in
  if not showDot then S.text "" else
  case config.shape of
    Nothing ->
      S.text ""

    Just Circle ->
      view S.circle (config.highlightWidth / 2) <| \off ->
        let radius = sqrt (area_ / pi) in
        [ SA.cx (String.fromFloat x_)
        , SA.cy (String.fromFloat y_)
        , SA.r (String.fromFloat (radius + off))
        ]

    Just Triangle ->
      view S.path config.highlightWidth <| \off ->
        [ SA.d (trianglePath area_ off x_ y_) ]

    Just Square ->
      view S.rect config.highlightWidth <| \off ->
        let side = sqrt area_
            sideOff = side + off
        in
        [ SA.x <| String.fromFloat (x_ - sideOff / 2)
        , SA.y <| String.fromFloat (y_ - sideOff / 2)
        , SA.width (String.fromFloat sideOff)
        , SA.height (String.fromFloat sideOff)
        ]

    Just Diamond ->
      view S.rect config.highlightWidth <| \off ->
        let side = sqrt area_
            sideOff = side + off
        in
        [ SA.x <| String.fromFloat (x_ - sideOff / 2)
        , SA.y <| String.fromFloat (y_ - sideOff / 2)
        , SA.width (String.fromFloat sideOff)
        , SA.height (String.fromFloat sideOff)
        , SA.transform ("rotate(45 " ++ String.fromFloat x_ ++ " " ++ String.fromFloat y_ ++ ")")
        ]

    Just Cross ->
      view S.path config.highlightWidth <| \off ->
        [ SA.d (plusPath area_ off x_ y_)
        , SA.transform ("rotate(45 " ++ String.fromFloat x_ ++ " " ++ String.fromFloat y_ ++ ")")
        ]

    Just Plus ->
      view S.path config.highlightWidth <| \off ->
        [ SA.d (plusPath area_ off x_ y_) ]


toRadius : Float -> Shape -> Float
toRadius size_ shape =
  let area_ = 2 * pi * size_ in
  case shape of
    Circle   -> sqrt (area_ / pi)
    Triangle -> let side = sqrt <| area_ * 4 / (sqrt 3) in (sqrt 3) * side
    Square   -> sqrt area_ / 2
    Diamond  -> sqrt area_ / 2
    Cross    -> sqrt (area_ / 4)
    Plus     -> sqrt (area_ / 4)


trianglePath : Float -> Float -> Float -> Float -> String
trianglePath area_ off x_ y_ =
  let side = sqrt (area_ * 4 / sqrt 3) + off * sqrt 3
      height = (sqrt 3) * side / 2
      fromMiddle = height - tan (degrees 30) * side / 2
  in
  String.join " "
    [ "M" ++ String.fromFloat x_ ++ " " ++ String.fromFloat (y_ - fromMiddle)
    , "l" ++ String.fromFloat (-side / 2) ++ " " ++ String.fromFloat height
    , "h" ++ String.fromFloat side
    , "z"
    ]


plusPath : Float -> Float -> Float -> Float ->  String
plusPath area_ off x_ y_ =
  let side = sqrt (area_ / 4) + off
      r3 = side
      r6 = side / 2
  in
  String.join " "
    [ "M" ++ String.fromFloat (x_ - r6) ++ " " ++ String.fromFloat (y_ - r3 - r6 + off)
    , "v" ++ String.fromFloat (r3 - off)
    , "h" ++ String.fromFloat (-r3 + off)
    , "v" ++ String.fromFloat r3
    , "h" ++ String.fromFloat (r3 - off)
    , "v" ++ String.fromFloat (r3 - off)
    , "h" ++ String.fromFloat r3
    , "v" ++ String.fromFloat (-r3 + off)
    , "h" ++ String.fromFloat (r3 - off)
    , "v" ++ String.fromFloat -r3
    , "h" ++ String.fromFloat (-r3 + off)
    , "v" ++ String.fromFloat (-r3 + off)
    , "h" ++ String.fromFloat -r3
    , "v" ++ String.fromFloat (r3 - off)
    ]



-- TOOLTIP


{-| -}
type alias Tooltip =
  { direction : Maybe Direction
  , focal : Maybe (Position -> Position)
  , height : Float
  , width : Float
  , offset : Float
  , arrow : Bool
  , border : String
  , background : String
  }


type Direction
  = Top
  | Left
  | Right
  | Bottom
  | LeftOrRight
  | TopOrBottom


defaultTooltip : Tooltip
defaultTooltip =
  { direction = Nothing
  , focal = Nothing
  , height = 0
  , width = 0
  , offset = 8
  , arrow = True
  , border = "#D8D8D8"
  , background = "white"
  }


{-| -}
tooltip : Plane -> Position -> Tooltip -> List (H.Attribute Never) -> List (H.Html Never) -> H.Html msg
tooltip plane pos config htmlAttrs content =
  let distanceTop = Coord.toSVGY plane pos.y2
      distanceBottom = plane.y.length - Coord.toSVGY plane pos.y1
      distanceLeft = Coord.toSVGX plane pos.x2
      distanceRight = plane.x.length - Coord.toSVGX plane pos.x1

      direction =
        case config.direction of
          Just LeftOrRight ->
            if config.width > 0
            then if distanceLeft > (config.width + config.offset) then Left else Right
            else if distanceLeft > distanceRight then Left else Right

          Just TopOrBottom ->
            if config.height > 0
            then if distanceTop > (config.height + config.offset) then Top else Bottom
            else if distanceTop > distanceBottom then Top else Bottom

          Just dir ->
            dir

          Nothing ->
            let isLargest a = List.all (\b -> a >= b) in
            if isLargest distanceTop [ distanceBottom, distanceLeft, distanceRight ] then Top
            else if isLargest distanceBottom [ distanceTop, distanceLeft, distanceRight ] then Bottom
            else if isLargest distanceLeft [ distanceTop, distanceBottom, distanceRight ] then Left
            else Right

      arrowWidth =
        if config.arrow then 4 else 0

      { xOff, yOff, transformation, className } =
        case direction of
          Top         -> { xOff = 0, yOff = config.offset + arrowWidth, transformation = "translate(-50%, -100%)", className = "elm-charts__tooltip-top" }
          Bottom      -> { xOff = 0, yOff = -config.offset - arrowWidth, transformation = "translate(-50%, 0%)", className = "elm-charts__tooltip-bottom" }
          Left        -> { xOff = -config.offset - arrowWidth, yOff = 0, transformation = "translate(-100%, -50%)", className = "elm-charts__tooltip-left" }
          Right       -> { xOff = config.offset + arrowWidth, yOff = 0, transformation = "translate(0, -50%)", className = "elm-charts__tooltip-right" }
          LeftOrRight -> { xOff = -config.offset - arrowWidth, yOff = 0, transformation = "translate(0, -50%)", className = "elm-charts__tooltip-leftOrRight" }
          TopOrBottom -> { xOff = 0, yOff = config.offset + arrowWidth, transformation =  "translate(-50%, -100%)", className = "elm-charts__tooltip-topOrBottom" }

      children =
        if config.arrow then
          H.node "style" [] [ H.text (tooltipPointerStyle direction className config.background config.border) ] :: content
        else
          content

      attributes =
        [ HA.class className
        , HA.style "transform" transformation
        , HA.style "padding" "5px 8px"
        , HA.style "background" config.background
        , HA.style "border" ("1px solid " ++ config.border)
        , HA.style "border-radius" "3px"
        , HA.style "pointer-events" "none"
        ] ++ htmlAttrs

      focalPoint =
        case config.focal of
          Just focal ->
            case direction of
              Top         -> Coord.top (focal pos)
              Bottom      -> Coord.bottom (focal pos)
              Left        -> Coord.left (focal pos)
              Right       -> Coord.right (focal pos)
              LeftOrRight -> Coord.left (focal pos)
              TopOrBottom -> Coord.right (focal pos)

          Nothing ->
            case direction of
              Top         -> Coord.top pos
              Bottom      -> Coord.bottom pos
              Left        -> Coord.left pos
              Right       -> Coord.right pos
              LeftOrRight -> Coord.left pos
              TopOrBottom -> Coord.right pos
  in
  positionHtml plane focalPoint.x focalPoint.y xOff yOff attributes children
    |> H.map never


-- POSITIONING


{-| -}
position : Plane -> Float -> Float -> Float -> Float -> Float -> S.Attribute msg
position plane rotation x_ y_ xOff_ yOff_ =
  SA.transform <| "translate(" ++ String.fromFloat (Coord.toSVGX plane x_ + xOff_) ++ "," ++ String.fromFloat (Coord.toSVGY plane y_ + yOff_) ++ ") rotate(" ++ String.fromFloat rotation ++ ")"



{-| -}
positionHtml : Plane -> Float -> Float -> Float -> Float -> List (H.Attribute msg) -> List (H.Html msg) -> H.Html msg
positionHtml plane x y xOff yOff attrs content =
    let
        xPercentage = (Coord.toSVGX plane x + xOff) * 100 / plane.x.length
        yPercentage = (Coord.toSVGY plane y - yOff) * 100 / plane.y.length

        posititonStyles =
          [ HA.style "left" (String.fromFloat xPercentage ++ "%")
          , HA.style "top" (String.fromFloat yPercentage ++ "%")
          , HA.style "margin-right" "-400px"
          , HA.style "position" "absolute"
          ]
    in
    H.div (posititonStyles ++ attrs) content



-- EVENTS


{-| -}
getNearest : (a -> Position) -> List a -> Plane -> Point -> List a
getNearest toPosition items plane searched =
  getNearestHelp toPosition items plane searched


{-| -}
getWithin : Float -> (a -> Position) -> List a -> Plane -> Point -> List a
getWithin radius toPosition items plane searched =
    let toPoint i =
          closestPoint (toPosition i) searched

        keepIfEligible closest =
          withinRadius plane radius searched (toPoint closest)
    in
    getNearestHelp toPosition items plane searched
      |> List.filter keepIfEligible


{-| -}
getNearestX : (a -> Position) -> List a -> Plane -> Point -> List a
getNearestX toPosition items plane searched =
    getNearestXHelp toPosition items plane searched


{-| -}
getWithinX : Float -> (a -> Position) -> List a -> Plane -> Point -> List a
getWithinX radius toPosition items plane searched =
    let toPoint i =
          closestPoint (toPosition i) searched

        keepIfEligible =
            withinRadiusX plane radius searched << toPoint
    in
    getNearestXHelp toPosition items plane searched
      |> List.filter keepIfEligible


getNearestHelp : (a -> Position) -> List a -> Plane -> Point -> List a
getNearestHelp toPosition items plane searched =
  let toPoint i =
        closestPoint (toPosition i) searched

      distanceSquared_ =
          distanceSquared plane searched

      getClosest item allClosest =
        case List.head allClosest of
          Just closest ->
            if toPoint closest == toPoint item then item :: allClosest
            else if distanceSquared_ (toPoint closest)
                    > distanceSquared_ (toPoint item) then [ item ]
            else allClosest

          Nothing ->
            [ item ]
  in
  List.foldl getClosest [] items
    |> keepOne toPosition


getNearestXHelp : (a -> Position) -> List a -> Plane -> Point -> List a
getNearestXHelp toPosition items plane searched =
  let toPoint i =
        closestPoint (toPosition i) searched

      distanceX_ =
          distanceX plane searched

      getClosest item allClosest =
        case List.head allClosest of
          Just closest ->
              if (toPoint closest).x == (toPoint item).x then item :: allClosest
              else if distanceX_ (toPoint closest) > distanceX_ (toPoint item) then [ item ]
              else allClosest

          Nothing ->
            [ item ]
  in
  List.foldl getClosest [] items
    |> keepOne toPosition


distanceX : Plane -> Point -> Point -> Float
distanceX plane searched point =
    abs <| Coord.toSVGX plane point.x - Coord.toSVGX plane searched.x


distanceY : Plane -> Point -> Point -> Float
distanceY plane searched point =
    abs <| Coord.toSVGY plane point.y - Coord.toSVGY plane searched.y


distanceSquared : Plane -> Point -> Point -> Float
distanceSquared plane searched point =
    -- True distance calculation requries the relatively expensive
    -- squareroot operation, but when we only need a metric to
    -- compare distances with eachother the squared distance will suffice.
    -- Possible future gotcha: Don't use this function when adding the
    -- resulting distances together since a^2 + b^2 != (a + b)^2.
    distanceX plane searched point ^ 2 + distanceY plane searched point ^ 2


closestPoint : Position -> Point -> Point
closestPoint pos searched =
  { x = clamp pos.x1 pos.x2 searched.x
  , y = clamp pos.y1 pos.y2 searched.y
  }


withinRadius : Plane -> Float -> Point -> Point -> Bool
withinRadius plane radius searched point =
    distanceSquared plane searched point <= radius ^ 2


withinRadiusX : Plane -> Float -> Point -> Point -> Bool
withinRadiusX plane radius searched point =
    distanceX plane searched point <= radius


keepOne : (a -> Position) -> List a -> List a
keepOne toPosition =
  let func one acc =
        case List.head acc of
          Nothing -> [ one ]
          Just other ->
            if toPosition other == toPosition one then
              other :: acc
            else if toArea other > toArea one then
              [ one ]
            else
              acc

      toArea a =
        toPosition a |> \pos ->
          (pos.x1 - pos.x2) * (pos.y1 - pos.y2)
  in
  List.foldr func []


{-| -}
decoder : Plane -> (Plane -> Point -> msg) -> Json.Decoder msg
decoder plane toMsg =
  let
    handle mouseX mouseY box =
      let
        widthPercent = box.width / plane.x.length
        heightPercent = box.height / plane.y.length

        xPrev = plane.x
        yPrev = plane.y

        newPlane =
          { plane
          | x =
              { xPrev | length = box.width
              , marginMin = plane.x.marginMin * widthPercent
              , marginMax = plane.x.marginMax * widthPercent
              }
          , y =
              { yPrev
              | length = box.height
              , marginMin = plane.y.marginMin * heightPercent
              , marginMax = plane.y.marginMax * heightPercent
              }
          }

        searched =
          fromSvg newPlane
            { x = mouseX - box.left
            , y = mouseY - box.top
            }
      in
      toMsg newPlane searched
  in
  Json.map3 handle
    (Json.field "pageX" Json.float)
    (Json.field "pageY" Json.float)
    (DOM.target decodePosition)


decodePosition : Json.Decoder DOM.Rectangle
decodePosition =
  Json.oneOf
    [ DOM.boundingClientRect
    , Json.lazy (\_ -> DOM.parentElement decodePosition)
    ]



-- PATTERN


toPattern : String -> Design -> ( S.Svg msg, String )
toPattern defaultColor design =
  let toPatternId props =
        String.replace "(" "-" <|
        String.replace ")" "-" <|
        String.replace "." "-" <|
        String.replace "," "-" <|
        String.replace " " "-" <|
        String.join "-" <|
          [ "elm-charts__pattern"
          , case design of
              Striped _ -> "striped"
              Dotted _ -> "dotted"
              Gradient _ -> "gradient"
          ] ++ props

      toPatternDefs id spacing rotate inside =
        S.defs []
          [ S.pattern
              [ SA.id id
              , SA.patternUnits "userSpaceOnUse"
              , SA.width (String.fromFloat spacing)
              , SA.height (String.fromFloat spacing)
              , SA.patternTransform ("rotate(" ++ String.fromFloat rotate ++ ")")
              ]
              [ inside ]
          ]

      ( patternDefs, patternId ) =
        case design of
          Striped edits ->
            let config =
                  apply edits
                    { color = defaultColor
                    , width = 3
                    , spacing = 4
                    , rotate = 45
                    }

                theId =
                  toPatternId
                    [ config.color
                    , String.fromFloat config.width
                    , String.fromFloat config.spacing
                    , String.fromFloat config.rotate
                    ]
            in
            ( toPatternDefs theId config.spacing config.rotate <|
                S.line
                  [ SA.x1 "0"
                  , SA.y "0"
                  , SA.x2 "0"
                  , SA.y2 (String.fromFloat config.spacing)
                  , SA.stroke config.color
                  , SA.strokeWidth (String.fromFloat config.width)
                  ]
                  []
            , theId
            )


          Dotted edits ->
            let config =
                  apply edits
                    { color = defaultColor
                    , width = 3
                    , spacing = 4
                    , rotate = 45
                    }

                theId =
                  toPatternId
                    [ config.color
                    , String.fromFloat config.width
                    , String.fromFloat config.spacing
                    , String.fromFloat config.rotate
                    ]
            in
            ( toPatternDefs theId config.spacing config.rotate <|
                S.circle
                  [ SA.fill config.color
                  , SA.cx (String.fromFloat <| config.width / 3)
                  , SA.cy (String.fromFloat <| config.width / 3)
                  , SA.r (String.fromFloat <| config.width / 3)
                  ]
                  []
            , theId
            )

          Gradient edits ->
            let colors =
                  if edits == [] then [ defaultColor, "white" ] else edits

                theId = toPatternId colors
                totalColors = List.length colors
                toPercentage i = toFloat i * 100 / toFloat (totalColors - 1)
                toStop i c =
                  S.stop
                    [ SA.offset (String.fromFloat (toPercentage i) ++ "%")
                    , SA.stopColor c
                    ]
                    []
            in
            ( S.defs []
                [ S.linearGradient
                    [ SA.id theId, SA.x1 "0", SA.x2 "0", SA.y1 "0", SA.y2 "1" ]
                    (List.indexedMap toStop colors)
                ]
            , theId
            )
  in
  ( patternDefs, "url(#" ++ patternId ++ ")" )



-- HELPERS


withBorder : List a -> (a -> a -> b) -> Maybe b
withBorder stuff func =
  case stuff of
    first :: rest ->
      Just (func first (Maybe.withDefault first (last rest)))

    _ ->
      Nothing


last : List a -> Maybe a
last list =
  List.head (List.drop (List.length list - 1) list)


closestToZero : Plane -> Float
closestToZero plane =
  clamp plane.y.min plane.y.max 0


apply : List (a -> a) -> a -> a
apply funcs default =
  let apply_ f a = f a in
  List.foldl apply_ default funcs


isWithinPlane : Plane -> Float -> Float -> Bool
isWithinPlane plane x y =
  clamp plane.x.min plane.x.max x == x && clamp plane.y.min plane.y.max y == y



-- STYLES


tooltipPointerStyle : Direction -> String -> String -> String -> String
tooltipPointerStyle direction className background borderColor =
  let config =
        case direction of
          Top          -> { a = "right", b = "top", c = "left" }
          Bottom       -> { a = "right", b = "bottom", c = "left" }
          Left         -> { a = "bottom", b = "left", c = "top" }
          Right        -> { a = "bottom", b = "right", c = "top" }
          LeftOrRight  -> { a = "bottom", b = "left", c = "top" }
          TopOrBottom  -> { a = "right", b = "top", c = "left" }
  in
  """
  .""" ++ className ++ """:before, .""" ++ className ++ """:after {
    content: "";
    position: absolute;
    border-""" ++ config.c ++ """: 5px solid transparent;
    border-""" ++ config.a ++ """: 5px solid transparent;
    """ ++ config.b ++ """: 100%;
    """ ++ config.c ++ """: 50%;
    margin-""" ++ config.c ++ """: -5px;
  }

  .""" ++ className ++ """:after {
    border-""" ++ config.b ++ """: 5px solid """ ++ background ++ """;
    margin-""" ++ config.b ++ """: -1px;
    z-index: 1;
    height: 0px;
  }

  .""" ++ className ++ """:before {
    border-""" ++ config.b ++ """: 5px solid """ ++ borderColor ++ """;
    height: 0px;
  }
  """



-- INTERVALS


type Generator a
  = Generator (Int -> Coord.Axis -> List a)


floats : Generator Float
floats =
  Generator (\i b -> I.floats (I.around i) { min = b.min, max = b.max })


ints : Generator Int
ints =
  Generator (\i b -> I.ints (I.around i) { min = b.min, max = b.max })


times : Time.Zone -> Generator I.Time
times zone =
  Generator (\i b -> I.times zone i { min = b.min, max = b.max })


generate : Int -> Generator a -> Coord.Axis -> List a
generate amount (Generator func) limits =
  func amount limits



-- FORMATTING


formatTime : Time.Zone -> I.Time -> String
formatTime zone time =
    case Maybe.withDefault time.unit time.change of
        I.Millisecond ->
            formatClockMillis zone time.timestamp

        I.Second ->
            formatClockSecond zone time.timestamp

        I.Minute ->
            formatClock zone time.timestamp

        I.Hour ->
            formatClock zone time.timestamp

        I.Day ->
            if time.multiple == 7
            then formatWeekday zone time.timestamp
            else formatDate zone time.timestamp

        I.Month ->
            formatMonth zone time.timestamp

        I.Year ->
            formatYear zone time.timestamp


formatFullTime : Time.Zone -> Time.Posix -> String
formatFullTime =
    F.format
        [ F.monthNumber
        , F.text "/"
        , F.dayOfMonthNumber
        , F.text "/"
        , F.yearNumberLastTwo
        , F.text " "
        , F.hourMilitaryFixed
        , F.text ":"
        , F.minuteFixed
        ]


formatFullDate : Time.Zone -> Time.Posix -> String
formatFullDate =
    F.format
        [ F.monthNumber
        , F.text "/"
        , F.dayOfMonthNumber
        , F.text "/"
        , F.yearNumberLastTwo
        ]


formatDate : Time.Zone -> Time.Posix -> String
formatDate =
    F.format
        [ F.monthNumber
        , F.text "/"
        , F.dayOfMonthNumber
        ]


formatClock : Time.Zone -> Time.Posix -> String
formatClock =
    F.format
        [ F.hourMilitaryFixed
        , F.text ":"
        , F.minuteFixed
        ]


formatClockSecond : Time.Zone -> Time.Posix -> String
formatClockSecond =
    F.format
        [ F.hourMilitaryFixed
        , F.text ":"
        , F.minuteFixed
        , F.text ":"
        , F.secondFixed
        ]


formatClockMillis : Time.Zone -> Time.Posix -> String
formatClockMillis =
    F.format
        [ F.hourMilitaryFixed
        , F.text ":"
        , F.minuteFixed
        , F.text ":"
        , F.secondFixed
        , F.text ":"
        , F.millisecondFixed
        ]


formatMonth : Time.Zone -> Time.Posix -> String
formatMonth =
    F.format
        [ F.monthNameAbbreviated
        ]


formatYear : Time.Zone -> Time.Posix -> String
formatYear =
    F.format
        [ F.yearNumber
        ]


formatWeekday : Time.Zone -> Time.Posix -> String
formatWeekday =
    F.format
        [ F.dayOfWeekNameFull ]



-- SYSTEM


type alias Plane =
  Coord.Plane


type alias Point =
  { x : Float
  , y : Float
  }


type alias Position =
  { x1 : Float
  , x2 : Float
  , y1 : Float
  , y2 : Float
  }


fromSvg : Plane -> Point -> Point
fromSvg plane point =
  { x = Coord.toCartesianX plane point.x
  , y = Coord.toCartesianY plane point.y
  }


fromCartesian : Plane -> Point -> Point
fromCartesian plane point =
  { x = Coord.toSVGX plane point.x
  , y = Coord.toSVGY plane point.y
  }


lengthInSvgX : Plane -> Float -> Float
lengthInSvgX =
  Coord.scaleSVGX


lengthInSvgY : Plane -> Float -> Float
lengthInSvgY =
  Coord.scaleSVGY


lengthInCartesianX : Plane -> Float -> Float
lengthInCartesianX =
  Coord.scaleCartesianX


lengthInCartesianY : Plane -> Float -> Float
lengthInCartesianY =
  Coord.scaleCartesianY


-- HELPERS


withAttrs : List (S.Attribute Never) -> (List (S.Attribute msg) -> List (S.Svg msg) -> S.Svg msg) -> List (S.Attribute msg) -> List (S.Svg msg) -> S.Svg msg
withAttrs attrs toEl defaultAttrs =
  toEl (defaultAttrs ++ List.map (HA.map never) attrs)


withinChartArea : Plane -> S.Attribute msg
withinChartArea plane =
  SA.clipPath <| "url(#" ++ Coord.toId plane ++ ")"
