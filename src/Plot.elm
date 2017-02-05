module Plot
    exposing
        ( Value
        , Point
        , Element
        , PlotMeta
        , AxisMeta
        , PlotConfig
        , toPlotConfig
        , toPlotConfigCustom
        , plot
        , BarsConfig
        , BarConfig
        , MaxBarWidth(..)
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
        , toBarLabelConfig
        , toAnyLabelConfig
        , labels
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
@docs Value, Point, Element, PlotMeta, AxisMeta

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
@docs BarsConfig, BarConfig, MaxBarWidth, toBarsConfig, toBarConfig, barsSerie, toGroups, BarValueInfo

## Axis elements
@docs xAxis, xAxisAt, yAxis, yAxisAt

### Value and position helpers
@docs onAxis, fromAxis, fromCount, fromList

### Axis line
@docs toAxisLineConfig, AxisLineConfig, axisLine

### Grid lines
@docs grid

### Labels
@docs LabelConfig, toAxisLabelConfig, toBarLabelConfig, toAnyLabelConfig, labels, viewLabel, ValueInfo

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
import Svg.Attributes exposing (d, fill, transform, class, y2, x2, width, height, clipPath)
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
            , axisIntercept = valueClosestToZero meta.scale.y
            , toSVGPoint = meta.toSVGPoint
            , scale = meta.scale
            , id = meta.id
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
            , id = meta.id
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
            , axisIntercept = valueClosestToZero meta.scale.x
            , toSVGPoint = \( x, y ) -> meta.toSVGPoint ( y, x )
            , scale = meta.scale
            , id = meta.id
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
            , id = meta.id
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
lineSerie : LineConfig msg -> List Point -> Element PlotMeta msg
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
areaSerie : AreaConfig msg -> List Point -> Element PlotMeta msg
areaSerie config data =
    SerieElement (findReachFromAreaPoints data) (AreaSerie config data)



-- BARS CONFIG


{-| -}
type alias BarValueInfo =
    { xValue : Value, index : Int, yValue : Value }


{-| -}
type MaxBarWidth
    = Percentage Int
    | Fixed Float


{-| -}
type BarsConfig msg
    = BarsConfig
        { stackBy : Orientation
        , maxWidth : MaxBarWidth
        , barConfigs : List (BarConfig msg)
        }


{-| -}
type BarConfig msg
    = BarConfig
        { attributes : List (Svg.Attribute msg)
        , labelConfig : LabelConfig BarValueInfo PlotMeta msg
        }


{-| -}
toBarsConfig :
    { stackBy : Orientation
    , maxWidth : MaxBarWidth
    , barConfigs : List (BarConfig msg)
    }
    -> BarsConfig msg
toBarsConfig config =
    BarsConfig config


{-| -}
toBarConfig :
    { attributes : List (Svg.Attribute msg)
    , labelConfig : LabelConfig BarValueInfo PlotMeta msg
    }
    -> BarConfig msg
toBarConfig config =
    BarConfig config


{-| -}
barsSerie : BarsConfig msg -> List Group -> Element PlotMeta msg
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
dotsSerie : DotsConfig msg -> List Point -> Element PlotMeta msg
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
type LabelConfig a meta msg
    = LabelConfig
        { view : a -> Svg msg
        , position : a -> Meta meta -> Point
        }


{-| -}
toAxisLabelConfig :
    { attributes : List (Svg.Attribute msg)
    , format : ValueInfo a -> String
    }
    -> LabelConfig (ValueInfo a) AxisMeta msg
toAxisLabelConfig { attributes, format } =
    LabelConfig
        { view = viewLabel attributes << format
        , position = onAxis << .value
        }


{-| -}
toBarLabelConfig :
    { attributes : List (Svg.Attribute msg)
    , format : BarValueInfo -> String
    }
    -> LabelConfig BarValueInfo a msg
toBarLabelConfig { attributes, format } =
    LabelConfig
        { view = viewLabel attributes << format
        , position = \_ _ -> ( 0, 0 )
        }


{-| -}
toAnyLabelConfig :
    { view : a -> Svg msg
    , position : a -> Meta meta -> Point
    }
    -> LabelConfig a meta msg
toAnyLabelConfig config =
    LabelConfig config


{-| -}
labels : LabelConfig a meta msg -> (Meta meta -> List a) -> Element meta msg
labels (LabelConfig config) toValueInfo =
    list [ class "elm-plot__labels" ] (\v -> positionBy (config.position v) [ config.view v ]) toValueInfo


{-| -}
viewLabel : List (Svg.Attribute msg) -> String -> Svg msg
viewLabel attributes string =
    text_ attributes [ tspan [] [ text string ] ]



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
                , width (toString (getInnerLength meta.scale.x))
                , height (toString (getInnerLength meta.scale.y))
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

        SerieElement reach serie ->
            viewSerie reach serie meta

        Line attributes toPoints ->
            viewPath attributes (makeLinePath NoInterpolation (toPoints meta) meta)

        Position toPosition children ->
            viewPositioned (toPosition meta) children meta

        List attributes toElements ->
            g attributes (List.map (viewElement meta) (toElements meta))

        SVGView view ->
            view


viewSerie : Axised Reach -> Serie msg -> Meta a -> Svg msg
viewSerie reach serie meta =
    case serie of
        LineSerie config data ->
            viewLine config data meta

        DotsSerie config data ->
            viewDots config data meta

        AreaSerie config data ->
            viewArea config data meta reach

        BarsSerie config data ->
            viewBars config data meta


viewPositioned : Point -> List (Svg msg) -> Meta a -> Svg msg
viewPositioned point children meta =
    g [ transform (toTranslate (meta.toSVGPoint point)) ] children



-- VIEW LINE


viewLine : LineConfig msg -> List Point -> Meta a -> Svg msg
viewLine (LineConfig config) data meta =
    g [ class "elm-plot__serie--line", clipPath ("url(#" ++ toClipPathId meta ++ ")") ]
        [ viewPath (fill "transparent" :: config.attributes) (makeLinePath config.interpolation data meta) ]



-- VIEW DOTS


viewDots : DotsConfig msg -> List Point -> Meta a -> Svg msg
viewDots (DotsConfig config) data meta =
    g [ class "elm-plot__serie--dots" ]
        (List.map (meta.toSVGPoint >> viewCircle config.radius) data)


viewCircle : Float -> Point -> Svg.Svg a
viewCircle radius ( x, y ) =
    Svg.circle
        [ Svg.Attributes.cx (toString x)
        , Svg.Attributes.cy (toString y)
        , Svg.Attributes.r (toString radius)
        ]
        []



-- VIEW AREA


viewArea : AreaConfig msg -> List Point -> Meta a -> Axised Reach -> Svg msg
viewArea (AreaConfig config) data meta reach =
    let
        mostZeroY =
            valueClosestToZero meta.scale.y

        firstPoint =
            Maybe.withDefault ( 0, 0 ) (List.head data)

        pathString =
            List.concat
                [ [ M ( reach.x.lower, mostZeroY ) ]
                , [ L firstPoint ]
                , (toLinePath config.interpolation data)
                , [ L ( reach.x.upper, mostZeroY ) ]
                , [ Z ]
                ]
                |> toPath meta
    in
        g [ class "elm-plot__serie--area", clipPath ("url(#" ++ toClipPathId meta ++ ")") ]
            [ viewPath config.attributes pathString ]



-- VIEW BARS


viewBars : BarsConfig msg -> List Group -> Meta a -> Svg msg
viewBars (BarsConfig { stackBy, maxWidth, barConfigs }) groups { toSVGPoint, scale } =
    let
        barsPerGroup =
            toFloat (List.length barConfigs)

        defaultBarWidth =
            if stackBy == X then
                1 / barsPerGroup
            else
                1

        barWidth =
            case maxWidth of
                Percentage perc ->
                    defaultBarWidth * (toFloat perc) / 100

                Fixed max ->
                    if defaultBarWidth > (unScaleValue scale.x max) then
                        unScaleValue scale.x max
                    else
                        defaultBarWidth

        barHeight { yValue, index } =
            if stackBy == X || index == 0 then
                yValue - valueClosestToZero scale.y
            else
                yValue

        toValueInfo group =
            List.indexedMap (BarValueInfo group.xValue) group.yValues

        toYStackedOffset group bar =
            List.take bar.index group.yValues
                |> List.filter (\y -> (y < 0) == (bar.yValue < 0))
                |> List.sum

        barPosition group ({ xValue, yValue, index } as bar) =
            case stackBy of
                X ->
                    ( xValue + barWidth * (toFloat index - barsPerGroup / 2)
                    , max (min 0 scale.y.reach.upper) yValue
                    )

                Y ->
                    ( xValue - barWidth / 2
                    , yValue + toYStackedOffset group bar - min 0 (barHeight bar)
                    )

        viewBar group (BarConfig barConfig) bar =
            Svg.rect (barConfig.attributes ++ viewBarAttributes group bar) []

        viewBarAttributes group bar =
            [ transform <| toTranslate <| toSVGPoint <| barPosition group bar
            , height <| toString <| scaleValue scale.y <| abs (barHeight bar)
            , width <| toString <| scaleValue scale.x barWidth
            ]

        wrapBarLabel group (BarConfig barConfig) bar =
            g [ transform (toTranslate (labelPosition group bar)) ]
                [ viewBarLabel barConfig.labelConfig bar ]

        labelPosition group bar =
            toSVGPoint (barPosition group bar |> addDisplacement ( barWidth / 2, 0 ))

        viewBarLabel (LabelConfig labelConfig) =
            labelConfig.view

        viewGroup group =
            Svg.g [ class "elm-plot__series--bars__group" ]
                [ Svg.g [ class "elm-plot__series--bars__group__bars" ]
                    (List.map2 (viewBar group) barConfigs (toValueInfo group))
                , Svg.g [ class "elm-plot__series--bars__group__labels" ]
                    (List.map2 (wrapBarLabel group) barConfigs (toValueInfo group))
                ]
    in
        g [ class "elm-plot__series--bars" ] (List.map viewGroup groups)



-- PATH STUFF


type PathType
    = L Point
    | M Point
    | S Point Point Point
    | Z


viewPath : List (Svg.Attribute msg) -> String -> Svg msg
viewPath attributes pathString =
    path (d pathString :: attributes) []


makeLinePath : Interpolation -> List Point -> Meta a -> String
makeLinePath interpolation points meta =
    case points of
        p1 :: rest ->
            M p1 :: (toLinePath interpolation (p1 :: rest)) |> toPath meta

        _ ->
            ""


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


toClipPathId : Meta a -> String
toClipPathId plot =
    plot.id ++ "__scale-clip-path"


toTranslate : ( Float, Float ) -> String
toTranslate ( x, y ) =
    "translate(" ++ (toString x) ++ "," ++ (toString y) ++ ")"


addDisplacement : Point -> Point -> Point
addDisplacement ( x, y ) ( dx, dy ) =
    ( x + dx, y + dy )


valueClosestToZero : Scale -> Value
valueClosestToZero scale =
    clamp scale.reach.lower scale.reach.upper 0



-- META AND SCALES


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
        , id : String
    }


{-| -}
type alias PlotMeta =
    {}


{-| -}
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
        |> addBarPadding


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


addBarPadding : Axised Reach -> Axised Reach
addBarPadding { x, y } =
    { x = { lower = x.lower - 0.5, upper = x.upper + 0.5 }
    , y = { lower = min 0 y.lower, upper = y.upper }
    }


findReachFromPoints : List Point -> Axised Reach
findReachFromPoints points =
    List.unzip points |> (\( xValues, yValues ) -> Axised (findReachFromValues xValues) (findReachFromValues yValues))


findReachFromAreaPoints : List Point -> Axised Reach
findReachFromAreaPoints points =
    findReachFromPoints points
        |> addAreaPadding


addAreaPadding : Axised Reach -> Axised Reach
addAreaPadding { x, y } =
    { x = x
    , y = { lower = min 0 y.lower, upper = y.upper }
    }


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


unScaleValue : Scale -> Value -> Value
unScaleValue scale value =
    value * (getRange scale) / (getInnerLength scale)


scaleValue : Scale -> Value -> Value
scaleValue scale value =
    value * (getInnerLength scale) / (getRange scale)


toSVGPoint : Scale -> Scale -> Point -> Point
toSVGPoint xScale yScale ( x, y ) =
    ( scaleValue xScale (x - xScale.reach.lower) + xScale.offset.lower
    , scaleValue yScale (yScale.reach.upper - y) + yScale.offset.lower
    )
