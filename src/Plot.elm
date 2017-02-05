module Plot
    exposing
        ( Value
        , Point
        , Element
        , PlotConfig
        , toPlotConfig
        , toPlotConfigCustom
        , plot
        , BarsConfig
        , BarConfig
        , toBarsConfig
        , toBarConfig
        , barsSerie
        , toGroups
        , BarValueInfo
        , AreaConfig
        , toAreaConfig
        , areaSerie
        , LineConfig
        , toLineConfig
        , lineSerie
        , DotsConfig
        , toDotsConfig
        , dotsSerie
        , TickConfig
        , toTickConfig
        , ticks
        , viewTick
        , LabelConfig
        , toAxisLabelConfig
        , toAnyLabelConfig
        , labels
        , label
        , viewLabel
        , ValueInfo
        , AxisLineConfig
        , toAxisLineConfig
        , axisLine
        , xAxis
        , xAxisAt
        , yAxis
        , yAxisAt
        , onAxis
        , Orientation(..)
        , Interpolation(..)
        , length
        , list
        , fromAxis
        , fromCount
        , fromList
        , displace
        , grid
        , fromRange
        , fromDomain
        , positionBy
        )

{-| Plot primities!

# Definitions
@docs Value, Point, Element

# Plot elements
@docs PlotConfig, toPlotConfig, toPlotConfigCustom, plot

## Series

### Line
@docs LineConfig, toLineConfig, lineSerie

### Area
@docs AreaConfig, toAreaConfig, areaSerie

### Dots
@docs DotsConfig, toDotsConfig, dotsSerie

### Bars
@docs BarsConfig, BarConfig, toBarsConfig, toBarConfig, barsSerie, toGroups, BarValueInfo

## Axis elements
@docs xAxis, xAxisAt, yAxis, yAxisAt

### Value and position helpers
@docs onAxis, fromAxis, fromCount, fromList

### Axis line
@docs toAxisLineConfig, AxisLineConfig, axisLine

### Grid lines
@docs grid

### Labels
@docs LabelConfig, toAxisLabelConfig, toAnyLabelConfig, labels, label, viewLabel, ValueInfo

### Ticks
@docs TickConfig, toTickConfig, ticks, viewTick

# General

## Value Helpers
@docs fromRange, fromDomain

## Helpers
@docs Interpolation, Orientation, positionBy, list

## Fake SVG Attributes
@docs length, displace

-}

import Html exposing (Html)
import Svg exposing (Svg, g, text_, tspan, path, text, line)
import Svg.Attributes exposing (d, fill, transform, class, y2, x2)
import Utils exposing (..)


-- PUBLIC TYPES


{-| -}
type alias Value =
    Float


{-| -}
type alias Point =
    ( Value, Value )


{-| -}
type alias Group =
    { xValue : Value
    , yValues : List Value
    }


{-| -}
type Element a msg
    = Axis (Meta a -> Meta AxisMeta) (List (Element AxisMeta msg))
    | SerieElement (Axised Reach) (Serie msg)
    | Line (List (Svg.Attribute msg)) (Meta a -> List Point)
    | Position (Meta a -> Point) (List (Svg msg))
    | List (List (Svg.Attribute msg)) (Meta a -> List (Element a msg))
    | SVGView (Svg msg)


type Serie msg
    = LineSerie (LineConfig msg) (List Point)
    | DotsSerie (DotsConfig msg) (List Point)
    | AreaSerie (AreaConfig msg) (List Point)
    | BarsSerie (BarsConfig msg) (List Group)



-- PRIMITIVES


{-| -}
positionBy : (Meta a -> Point) -> List (Svg msg) -> Element a msg
positionBy =
    Position


{-| -}
positionAt : Point -> List (Svg msg) -> Element a msg
positionAt point =
    Position (always point)


{-| -}
xAxis : List (Element AxisMeta msg) -> Element PlotMeta msg
xAxis =
    let
        toAxisMeta meta =
            { orientation = X
            , axisScale = meta.scale.x
            , oppositeAxisScale = meta.scale.y
            , axisIntercept = clampToZero meta.scale.y.reach.lower meta.scale.y.reach.upper
            , toSVGPoint = meta.toSVGPoint
            , scale = meta.scale
            }
    in
        Axis toAxisMeta


{-| -}
xAxisAt : (Value -> Value -> Value) -> List (Element AxisMeta msg) -> Element PlotMeta msg
xAxisAt toAxisIntercept =
    let
        toAxisMeta meta =
            { orientation = X
            , axisScale = meta.scale.x
            , oppositeAxisScale = meta.scale.y
            , axisIntercept = toAxisIntercept meta.scale.y.reach.lower meta.scale.y.reach.upper
            , toSVGPoint = meta.toSVGPoint
            , scale = meta.scale
            }
    in
        Axis toAxisMeta


{-| -}
yAxis : List (Element AxisMeta msg) -> Element PlotMeta msg
yAxis =
    let
        toAxisMeta meta =
            { orientation = Y
            , axisScale = meta.scale.y
            , oppositeAxisScale = meta.scale.x
            , axisIntercept = clampToZero meta.scale.x.reach.lower meta.scale.x.reach.upper
            , toSVGPoint = \( x, y ) -> meta.toSVGPoint ( y, x )
            , scale = meta.scale
            }
    in
        Axis toAxisMeta


{-| -}
yAxisAt : (Value -> Value -> Value) -> List (Element AxisMeta msg) -> Element PlotMeta msg
yAxisAt toAxisIntercept =
    let
        toAxisMeta meta =
            { orientation = Y
            , axisScale = meta.scale.y
            , oppositeAxisScale = meta.scale.x
            , axisIntercept = toAxisIntercept meta.scale.x.reach.lower meta.scale.x.reach.upper
            , toSVGPoint = \( x, y ) -> meta.toSVGPoint ( y, x )
            , scale = meta.scale
            }
    in
        Axis toAxisMeta


{-| -}
grid : List (Svg.Attribute msg) -> (Meta AxisMeta -> List Value) -> Element AxisMeta msg
grid attributes toValues =
    list [ class "elm-plot__grid" ] (fullLengthline attributes) toValues


{-| -}
list : List (Svg.Attribute msg) -> (b -> Element a msg) -> (Meta a -> List b) -> Element a msg
list attributes toElement toValues =
    List attributes (toValues >> List.map toElement)


{-| -}
fullLengthline : List (Svg.Attribute msg) -> Value -> Element AxisMeta msg
fullLengthline attributes value =
    Line attributes (fromAxis (\_ l h -> [ ( l, value ), ( h, value ) ]))



-- POSITION HELPERS


clampToZero : Value -> Value -> Value
clampToZero lower upper =
    clamp 0 lower upper


{-| -}
fromCount : Int -> Meta AxisMeta -> List (ValueInfo {})
fromCount count meta =
    toDelta meta.axisScale.reach.lower meta.axisScale.reach.upper count
        |> toValuesFromDelta meta.axisScale.reach.lower meta.axisScale.reach.upper
        |> List.map (\value -> { value = value })


{-| -}
fromList : List Value -> Meta AxisMeta -> List (ValueInfo {})
fromList values _ =
    List.map (\value -> { value = value }) values


{-| Produce a value from the range of the plot.
-}
fromRange : (Value -> Value -> b) -> Meta a -> b
fromRange toPoints { scale } =
    toPoints scale.x.reach.lower scale.x.reach.upper


{-| Produce a value from the domain of the plot.
-}
fromDomain : (Value -> Value -> b) -> Meta a -> b
fromDomain toSomething { scale } =
    toSomething scale.y.reach.lower scale.y.reach.upper


{-| Provides you with the axis' interception with the opposite axis, the lowerst and highest value.
-}
fromAxis : (Value -> Value -> Value -> b) -> Meta AxisMeta -> b
fromAxis toSomething meta =
    toSomething meta.axisIntercept meta.axisScale.reach.lower meta.axisScale.reach.upper


{-| Place at `value` on current axis.
-}
onAxis : Value -> Meta AxisMeta -> Point
onAxis value meta =
    ( value, meta.axisIntercept )



-- CONFIGS


{-| -}
type LineConfig msg
    = LineConfig
        { attributes : List (Svg.Attribute msg)
        , interpolation : Interpolation
        }


{-| -}
toLineConfig :
    { attributes : List (Svg.Attribute msg)
    , interpolation : Interpolation
    }
    -> LineConfig msg
toLineConfig config =
    LineConfig config


{-| -}
lineSerie : LineConfig msg -> List Point -> Element a msg
lineSerie config data =
    SerieElement (findReachFromPoints data) (LineSerie config data)



-- AREA CONFIG


{-| -}
type AreaConfig msg
    = AreaConfig
        { attributes : List (Svg.Attribute msg)
        , interpolation : Interpolation
        }


{-| -}
toAreaConfig :
    { attributes : List (Svg.Attribute msg)
    , interpolation : Interpolation
    }
    -> AreaConfig msg
toAreaConfig config =
    AreaConfig config


{-| -}
areaSerie : AreaConfig msg -> List Point -> Element a msg
areaSerie config data =
    SerieElement (findReachFromPoints data) (AreaSerie config data)



-- BARS CONFIG


{-| -}
type alias BarValueInfo =
    { xValue : Value, index : Int, yValue : Value }


{-| -}
type BarsConfig msg
    = BarsConfig
        { stackBy : Orientation
        , barConfigs : List (BarConfig msg)
        }


{-| -}
type BarConfig msg
    = BarConfig
        { attributes : List (Svg.Attribute msg)
        , maxWidth : Float
        , labelConfig : LabelConfig BarValueInfo msg
        }


{-| -}
toBarsConfig :
    { stackBy : Orientation
    , barConfigs : List (BarConfig msg)
    }
    -> BarsConfig msg
toBarsConfig config =
    BarsConfig config


{-| -}
toBarConfig :
    { attributes : List (Svg.Attribute msg)
    , maxWidth : Float
    , labelConfig : LabelConfig BarValueInfo msg
    }
    -> BarConfig msg
toBarConfig config =
    BarConfig config


{-| -}
barsSerie : BarsConfig msg -> List Group -> Element a msg
barsSerie config data =
    SerieElement (findReachFromGroups config data) (BarsSerie config data)


{-| The functions necessary to transform your data into the format the plot requires.
 If you provide the `xValue` with `Nothing`, the bars xValues will just be the index
 of the bar in the list.
-}
type alias GroupTransformers data =
    { yValues : data -> List Value
    , xValue : Maybe (data -> Value)
    }


{-| This function can be used to transform your own data format
 into something the plot can understand.

    toGroups
        { yValues = .revenueByYear
        , xValue = Just .quarter
        }
        [ { quarter = 1, revenueByYear = [ 10000, 30000, 20000 ] }
        , { quarter = 2, revenueByYear = [ 20000, 10000, 40000 ] }
        , { quarter = 3, revenueByYear = [ 40000, 20000, 10000 ] }
        , { quarter = 4, revenueByYear = [ 40000, 50000, 20000 ] }
        ]
-}
toGroups : GroupTransformers data -> List data -> List Group
toGroups transform allData =
    List.indexedMap
        (\index data ->
            { xValue = getGroupXValue transform index data
            , yValues = transform.yValues data
            }
        )
        allData


getGroupXValue : GroupTransformers data -> Int -> data -> Value
getGroupXValue { xValue } index data =
    case xValue of
        Just getXValue ->
            getXValue data

        Nothing ->
            toFloat index + 1



-- DOTS CONFIG


{-| -}
type DotsConfig msg
    = DotsConfig
        { attributes : List (Svg.Attribute msg)
        , radius : Float
        }


{-| -}
toDotsConfig :
    { attributes : List (Svg.Attribute msg)
    , radius : Float
    }
    -> DotsConfig msg
toDotsConfig config =
    DotsConfig config


{-| -}
dotsSerie : DotsConfig msg -> List Point -> Element a msg
dotsSerie config data =
    SerieElement (findReachFromPoints data) (DotsSerie config data)



-- TICK CONFIG


{-| -}
type TickConfig msg
    = TickConfig { attributes : List (Svg.Attribute msg) }


{-| -}
toTickConfig :
    { attributes : List (Svg.Attribute msg) }
    -> TickConfig msg
toTickConfig config =
    TickConfig config


{-| -}
ticks : TickConfig msg -> (Meta AxisMeta -> List (ValueInfo a)) -> Element AxisMeta msg
ticks (TickConfig config) toValues =
    list [ class "elm-plot__ticks" ] (tick config.attributes) toValues


{-| -}
tick : List (Svg.Attribute msg) -> ValueInfo a -> Element AxisMeta msg
tick attributes valueInfo =
    positionBy (onAxis valueInfo.value) [ viewTick attributes ]


{-| -}
viewTick : List (Svg.Attribute msg) -> Svg msg
viewTick attributes =
    line attributes []



-- LABEL CONFIG


{-| -}
type alias ValueInfo a =
    { a | value : Value }


{-| -}
type LabelConfig a msg
    = LabelConfig
        { attributes : List (Svg.Attribute msg)
        , toValue : a -> Value
        , format : a -> String
        }


{-| -}
toAxisLabelConfig :
    { attributes : List (Svg.Attribute msg)
    , format : ValueInfo a -> String
    }
    -> LabelConfig (ValueInfo a) msg
toAxisLabelConfig { attributes, format } =
    LabelConfig
        { attributes = attributes
        , toValue = .value
        , format = format
        }


{-| -}
toAnyLabelConfig :
    { attributes : List (Svg.Attribute msg)
    , toValue : a -> Value
    , format : a -> String
    }
    -> LabelConfig a msg
toAnyLabelConfig config =
    LabelConfig config


{-| -}
labels : LabelConfig a msg -> (Meta AxisMeta -> List a) -> Element AxisMeta msg
labels (LabelConfig config) toValueInfo =
    list [ class "elm-plot__labels" ] (label config.attributes config.toValue config.format) toValueInfo


{-| -}
label : List (Svg.Attribute msg) -> (a -> Value) -> (a -> String) -> a -> Element AxisMeta msg
label attributes toValue format valueInfo =
    positionBy (onAxis (toValue valueInfo)) [ viewLabel attributes (format valueInfo) ]


{-| -}
viewLabel : List (Svg.Attribute msg) -> String -> Svg msg
viewLabel attributes formattetValue =
    text_ attributes [ tspan [] [ text formattetValue ] ]



-- AXIS LINE CONFIG


{-| -}
type AxisLineConfig msg
    = AxisLineConfig { attributes : List (Svg.Attribute msg) }


{-| -}
toAxisLineConfig :
    { attributes : List (Svg.Attribute msg) }
    -> AxisLineConfig msg
toAxisLineConfig config =
    AxisLineConfig config


{-| -}
axisLine : AxisLineConfig msg -> Element AxisMeta msg
axisLine (AxisLineConfig { attributes }) =
    Line attributes (fromAxis (\p l h -> [ ( l, p ), ( h, p ) ]))



-- ATTRIBUTES


{-| -}
displace : ( Float, Float ) -> Svg.Attribute msg
displace displacement =
    transform (toTranslate displacement)


{-| -}
length : Float -> Svg.Attribute msg
length length =
    y2 (toString length)


type alias Attribute c =
    c -> c


{-| -}
type Interpolation
    = Bezier
    | NoInterpolation



-- PLOT CUSTOMIZATIONS


{-| -}
type PlotConfig msg
    = PlotConfig
        { attributes : List (Svg.Attribute msg)
        , id : String
        , margin :
            { top : Int
            , right : Int
            , bottom : Int
            , left : Int
            }
        , proportions :
            { x : Int
            , y : Int
            }
        , toDomain : Value -> Value -> { lower : Value, upper : Value }
        , toRange : Value -> Value -> { lower : Value, upper : Value }
        }


{-| -}
toPlotConfig :
    { attributes : List (Svg.Attribute msg)
    , id : String
    , margin :
        { top : Int
        , right : Int
        , bottom : Int
        , left : Int
        }
    , proportions :
        { x : Int
        , y : Int
        }
    }
    -> PlotConfig msg
toPlotConfig { attributes, id, margin, proportions } =
    PlotConfig
        { attributes = []
        , id = id
        , margin = margin
        , proportions = proportions
        , toDomain = \min max -> { lower = min, upper = max }
        , toRange = \min max -> { lower = min, upper = max }
        }


{-| -}
toPlotConfigCustom :
    { attributes : List (Svg.Attribute msg)
    , id : String
    , margin :
        { top : Int
        , right : Int
        , bottom : Int
        , left : Int
        }
    , proportions :
        { x : Int
        , y : Int
        }
    , toDomain : Value -> Value -> { lower : Value, upper : Value }
    , toRange : Value -> Value -> { lower : Value, upper : Value }
    }
    -> PlotConfig msg
toPlotConfigCustom config =
    PlotConfig config


{-| Render your plot!
-}
plot : PlotConfig msg -> List (Element PlotMeta msg) -> Svg msg
plot config elements =
    viewPlot config elements (toPlotMeta config elements)



-- PLOT META


type alias Axised a =
    { x : a
    , y : a
    }


type alias Reach =
    { lower : Float
    , upper : Float
    }


type alias Scale =
    { reach : Reach
    , offset : Reach
    , length : Float
    }


type alias Meta a =
    { a
        | toSVGPoint : Point -> Point
        , scale : Axised Scale
    }


type alias PlotMeta =
    { id : String }


type alias AxisMeta =
    { orientation : Orientation
    , axisScale : Scale
    , oppositeAxisScale : Scale
    , axisIntercept : Value
    }


{-| -}
type Orientation
    = X
    | Y


toPlotMeta : PlotConfig msg -> List (Element PlotMeta msg) -> Meta PlotMeta
toPlotMeta (PlotConfig { id, margin, proportions, toRange, toDomain }) elements =
    let
        reach =
            findPlotReach elements

        range =
            toRange reach.x.lower reach.x.upper

        domain =
            toDomain reach.y.lower reach.y.upper

        scale =
            { x = toScale proportions.x range margin.left margin.right
            , y = toScale proportions.y domain margin.top margin.bottom
            }
    in
        { scale = scale
        , toSVGPoint = toSVGPoint scale.x scale.y
        , id = id
        }


toScale : Int -> Reach -> Int -> Int -> Scale
toScale length reach offsetLower offsetUpper =
    { length = toFloat length
    , offset = Reach (toFloat offsetLower) (toFloat offsetUpper)
    , reach = reach
    }



-- VIEW PLOT


viewPlot : PlotConfig msg -> List (Element PlotMeta msg) -> Meta PlotMeta -> Html msg
viewPlot (PlotConfig config) elements meta =
    let
        viewBoxValue =
            "0 0 " ++ toString meta.scale.x.length ++ " " ++ toString meta.scale.y.length

        attributes =
            config.attributes
                ++ [ Svg.Attributes.viewBox viewBoxValue, Svg.Attributes.id meta.id ]
    in
        Svg.svg attributes (scaleDefs meta :: (viewElements meta elements))


scaleDefs : Meta PlotMeta -> Svg.Svg msg
scaleDefs meta =
    Svg.defs []
        [ Svg.clipPath [ Svg.Attributes.id (toClipPathId meta) ]
            [ Svg.rect
                [ Svg.Attributes.x (toString meta.scale.x.offset.lower)
                , Svg.Attributes.y (toString meta.scale.y.offset.lower)
                , Svg.Attributes.width (toString (getInnerLength meta.scale.x))
                , Svg.Attributes.height (toString (getInnerLength meta.scale.y))
                ]
                []
            ]
        ]



-- VIEW ELEMENTS


viewElements : Meta a -> List (Element a msg) -> List (Svg msg)
viewElements meta elements =
    List.map (viewElement meta) elements


viewElement : Meta a -> Element a msg -> Svg msg
viewElement meta element =
    case element of
        Axis toMeta elements ->
            g [ class "elm-plot__axis" ] (viewElements (toMeta meta) elements)

        SerieElement _ serie ->
            viewSerie meta serie

        Line attributes toPoints ->
            viewPath attributes (makeLinePath NoInterpolation (toPoints meta) meta)

        Position toPosition children ->
            viewPositioned (toPosition meta) children meta

        List attributes toElements ->
            g attributes (List.map (viewElement meta) (toElements meta))

        SVGView view ->
            view


viewSerie : Meta a -> Serie msg -> Svg msg
viewSerie meta serie =
    case serie of
        LineSerie (LineConfig config) data ->
            g [ class "elm-plot__serie--line" ] [ viewPath config.attributes (makeLinePath config.interpolation data meta) ]

        DotsSerie (DotsConfig config) data ->
            g [ class "elm-plot__serie--dots" ] (List.map (meta.toSVGPoint >> viewCircle config.radius) data)

        AreaSerie config data ->
            g [ class "elm-plot__serie--area" ] [ viewArea config data meta ]

        BarsSerie config data ->
            g [ class "elm-plot__serie--bars" ] [ viewBars config data meta ]


viewPositioned : Point -> List (Svg msg) -> Meta a -> Svg msg
viewPositioned point children meta =
    g [ transform (toTranslate (meta.toSVGPoint point)) ] children



-- VIEW LINE


viewPath : List (Svg.Attribute msg) -> String -> Svg msg
viewPath attributes pathString =
    path (d pathString :: fill "transparent" :: attributes |> List.reverse) []


makeLinePath : Interpolation -> List Point -> Meta a -> String
makeLinePath interpolation points meta =
    case points of
        p1 :: rest ->
            M p1 :: (toLinePath interpolation (p1 :: rest)) |> toPath meta

        _ ->
            ""



-- VIEW AREA


viewArea : AreaConfig msg -> List Point -> Meta a -> Svg msg
viewArea (AreaConfig config) data meta =
    let
        ( lowestX, highestX ) =
            getEdgesX data

        mostZeroY =
            clamp meta.scale.y.reach.lower meta.scale.y.reach.upper 0

        firstPoint =
            Maybe.withDefault ( 0, 0 ) (List.head data)

        pathString =
            List.concat
                [ [ M ( lowestX, mostZeroY ) ]
                , [ L firstPoint ]
                , (toLinePath config.interpolation data)
                , [ L ( highestX, mostZeroY ) ]
                , [ Z ]
                ]
                |> toPath meta
    in
        path (d pathString :: config.attributes |> List.reverse) []


viewCircle : Float -> Point -> Svg.Svg a
viewCircle radius ( x, y ) =
    Svg.circle
        [ Svg.Attributes.cx (toString x)
        , Svg.Attributes.cy (toString y)
        , Svg.Attributes.r (toString radius)
        ]
        []


getEdgesX : List Point -> ( Float, Float )
getEdgesX points =
    getEdges <| List.map Tuple.first points


getEdgesY : List Point -> ( Float, Float )
getEdgesY points =
    getEdges <| List.map Tuple.second points


getEdges : List Float -> ( Float, Float )
getEdges range =
    ( getLowest range, getHighest range )



-- VIEW BARS


viewBars : BarsConfig msg -> List Group -> Meta a -> Svg msg
viewBars (BarsConfig config) groups meta =
    let
        width =
            toDefaultBarWidth meta config.stackBy config.barConfigs

        toValueInfo group =
            List.indexedMap (BarValueInfo group.xValue) group.yValues

        position group ({ xValue, yValue, index } as bar) =
            case config.stackBy of
                X ->
                    ( xValue, max (min 0 meta.scale.y.reach.upper) bar.yValue )
                        |> meta.toSVGPoint
                        |> addDisplacement ( toBarXOffset config.barConfigs width index, 0 )

                Y ->
                    ( xValue, yValue )
                        |> addDisplacement ( 0, toBarYOffset group bar )
                        |> meta.toSVGPoint
                        |> addDisplacement ( -width / 2, min 0 (toBarLength meta config.stackBy bar) )

        viewBar (BarConfig barConfig) bar ( x, y ) =
            Svg.rect
                ([ Svg.Attributes.x (toString x)
                 , Svg.Attributes.y (toString y)
                 , Svg.Attributes.width (toString width)
                 , Svg.Attributes.height (toString (abs (toBarLength meta config.stackBy bar)))
                 ]
                    ++ barConfig.attributes
                )
                []

        wrapBarLabel group (BarConfig barConfig) valueInfo =
            viewPositioned
                (position group valueInfo)
                [ viewBarLabel barConfig.labelConfig valueInfo ]
                meta

        viewBarLabel (LabelConfig labelConfig) valueInfo =
            viewLabel labelConfig.attributes (labelConfig.format valueInfo)

        viewGroup group =
            Svg.g [ class "elm-plot__series--bars__bar" ]
                [ Svg.g
                    []
                    (List.map2
                        (\barConfig bar -> viewBar barConfig bar (position group bar))
                        config.barConfigs
                        (toValueInfo group)
                    )
                , Svg.g [] (List.map2 (wrapBarLabel group) config.barConfigs (toValueInfo group))
                ]
    in
        g [ class "elm-plot__series--bars" ] (List.map viewGroup groups)


toDefaultBarWidth : Meta a -> Orientation -> List (BarConfig msg) -> Float
toDefaultBarWidth meta stackBy groups =
    case stackBy of
        X ->
            (getInnerLength meta.scale.x) / (toFloat (List.length groups) * (getRange meta.scale.x))

        Y ->
            (getInnerLength meta.scale.x) / (getRange meta.scale.x)


toBarXOffset : List (BarConfig msg) -> Float -> Int -> Value
toBarXOffset groups width index =
    toFloat index * width - toFloat (List.length groups) * width / 2


toBarYOffset : Group -> BarValueInfo -> Value
toBarYOffset { yValues } { index, yValue } =
    List.take index yValues
        |> List.filter (\y -> (y < 0) == (yValue < 0))
        |> List.sum


toBarLength : Meta a -> Orientation -> BarValueInfo -> Value
toBarLength meta stackBy bar =
    case stackBy of
        X ->
            toLengthTouchingXAxis meta bar

        Y ->
            if bar.index == 0 then
                toLengthTouchingXAxis meta bar
            else
                bar.yValue * (getInnerLength meta.scale.y) / (getRange meta.scale.y)


toLengthTouchingXAxis : Meta a -> BarValueInfo -> Value
toLengthTouchingXAxis { scale } { yValue, index } =
    (yValue - (clamp scale.y.reach.lower scale.y.reach.upper 0)) * (getInnerLength scale.y) / (getRange scale.y)


addDisplacement : Point -> Point -> Point
addDisplacement ( x, y ) ( dx, dy ) =
    ( x + dx, y + dy )



-- PATH STUFF


type PathType
    = L Point
    | M Point
    | S Point Point Point
    | Z


toPath : Meta a -> List PathType -> String
toPath meta pathParts =
    List.foldl (\part result -> result ++ toPathTypeString meta part) "" pathParts


toPathTypeString : Meta a -> PathType -> String
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


toPathTypeStringSinglePoint : Meta a -> String -> Point -> String
toPathTypeStringSinglePoint meta typeString point =
    typeString ++ " " ++ pointToString meta point


toPathTypeStringS : Meta a -> Point -> Point -> Point -> String
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


pointToString : Meta a -> Point -> String
pointToString meta point =
    let
        ( x, y ) =
            meta.toSVGPoint point
    in
        (toString x) ++ "," ++ (toString y)


toLinePath : Interpolation -> List Point -> List PathType
toLinePath smoothing =
    case smoothing of
        NoInterpolation ->
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



-- VIEW HELPERS


toClipPathId : Meta PlotMeta -> String
toClipPathId plot =
    plot.id ++ "__scale-clip-path"


toTranslate : ( Float, Float ) -> String
toTranslate ( x, y ) =
    "translate(" ++ (toString x) ++ "," ++ (toString y) ++ ")"



-- META


findPlotReach : List (Element a msg) -> Axised Reach
findPlotReach elements =
    List.filterMap getReach elements
        |> List.foldl strechReach Nothing
        |> Maybe.withDefault (Axised (Reach 0 1) (Reach 0 1))


getReach : Element a msg -> Maybe (Axised Reach)
getReach element =
    case element of
        SerieElement reach _ ->
            Just reach

        _ ->
            Nothing


findReachFromGroups : BarsConfig msg -> List Group -> Axised Reach
findReachFromGroups (BarsConfig config) groups =
    toGroupPoints config.stackBy groups
        |> findReachFromPoints


toGroupPoints : Orientation -> List Group -> List Point
toGroupPoints orientation groups =
    List.foldl (foldGroupPoints orientation) [] groups


foldGroupPoints : Orientation -> Group -> List Point -> List Point
foldGroupPoints stackBy { xValue, yValues } points =
    if stackBy == X then
        points ++ [ ( xValue, getLowest yValues ), ( xValue, getHighest yValues ) ]
    else
        let
            ( positive, negative ) =
                List.partition (\y -> y >= 0) yValues
        in
            points ++ [ ( xValue, List.sum positive ), ( xValue, List.sum negative ) ]


findReachFromPoints : List Point -> Axised Reach
findReachFromPoints points =
    List.unzip points |> (\( xValues, yValues ) -> Axised (findReachFromValues xValues) (findReachFromValues yValues))


findReachFromValues : List Value -> Reach
findReachFromValues values =
    { lower = getLowest values
    , upper = getHighest values
    }


getLowest : List Float -> Float
getLowest values =
    Maybe.withDefault 0 (List.minimum values)


getHighest : List Float -> Float
getHighest values =
    Maybe.withDefault 1 (List.maximum values)


strechReach : Axised Reach -> Maybe (Axised Reach) -> Maybe (Axised Reach)
strechReach elementReach plotReach =
    case plotReach of
        Just reach ->
            Just <|
                Axised
                    (strechSingleReach elementReach.x reach.x)
                    (strechSingleReach elementReach.y reach.y)

        Nothing ->
            Just elementReach


strechSingleReach : Reach -> Reach -> Reach
strechSingleReach elementReach plotReach =
    { lower = min plotReach.lower elementReach.lower
    , upper = max plotReach.upper elementReach.upper
    }


getRange : Scale -> Value
getRange scale =
    let
        range =
            scale.reach.upper - scale.reach.lower
    in
        if range > 0 then
            range
        else
            1


getInnerLength : Scale -> Value
getInnerLength scale =
    scale.length - scale.offset.lower - scale.offset.upper


scaleValue : Scale -> Value -> Value
scaleValue scale v =
    (v * (getInnerLength scale) / (getRange scale)) + scale.offset.lower


toSVGPoint : Scale -> Scale -> Point -> Point
toSVGPoint xScale yScale ( x, y ) =
    ( scaleValue xScale (x - xScale.reach.lower)
    , scaleValue yScale (yScale.reach.upper - y)
    )
