module Svg.Plot
    exposing
        ( Value
        , Point
        , Element
        , Orientation(..)
        , PlotConfig
        , toPlotConfig
        , toPlotConfigFancy
        , plot
        , LineConfig
        , toLineConfig
        , lineSerie
        , AreaConfig
        , toAreaConfig
        , areaSerie
        , Interpolation(..)
        , DotsConfig
        , toDotsConfig
        , dotsSerie
        , BarsConfig
        , toBarsConfig
        , barsSerie
        , GroupTransformer
        , toGroups
        , MaxBarWidth(..)
        , fromList
        , fromDelta
        , fromRange
        , fromDomain
        , fromRangeAndDomain
        , remove
        , filterDelta
        , lowest
        , highest
        , closestToZero
        , verticalGrid
        , horizontalGrid
        , AxisConfig
        , toAxisConfig
        , axis
        , axisLine
        , TickConfig
        , tick
        , tickCustom
        , ticks
        , length
        , LabelConfig
        , label
        , labelCustom
        , labels
        , viewLabel
        , displace
        , positionAt
        , positionBy
        )

{-| Plot in SVG!

# Definitions
@docs Value, Point, Orientation, Element, Meta

# Plot elements
@docs PlotConfig, toPlotConfig, toPlotConfigFancy, plot

## Series

### Line
@docs LineConfig, toLineConfig, lineSerie

### Area
@docs AreaConfig, toAreaConfig, areaSerie

### Dots
@docs DotsConfig, toDotsConfig, dotsSerie

### Bars
@docs BarsConfig, BarValueInfo, MaxBarWidth, toBarsConfig, barsSerie,

### Data transformation
@docs Group, GroupTransformer, toGroups

## Axis elements
@docs xAxis, xAxisAt, yAxis, yAxisAt

### Value and position helpers
@docs onXAxisAt, onYAxisAt, lowest, highest, closestToZero, fromList, fromDelta, fromRangeAndDomain, remove, filterDelta

### Axis line
@docs axisLine

### Grid lines
@docs horizontalGrid, verticalGrid

### Labels
@docs LabelConfig, labelVerySimple, labelSimple, labelCustom, labelVeryCustom, labels, viewLabel

### Ticks
@docs TickConfig, tickSimple, tickCustom, ticks, tick

## Primitives
@docs positionBy, positionAt

-}

import Html exposing (Html)
import Svg exposing (Svg, g, text_, tspan, path, text, line)
import Svg.Attributes exposing (d, fill, transform, class, y2, x2, width, height, clipPath, stroke)
import Svg.Utils exposing (..)


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
type Element msg
    = SerieElement (Axised Reach) (Serie msg)
    | Axis AxisConfig (Element msg)
    | Line (List (Svg.Attribute msg)) (Meta -> List Point)
    | Position (Meta -> Point) (List (Svg msg))
    | List (List (Svg.Attribute msg)) (Meta -> List (Element msg))
    | SVGView (Svg msg)


type Serie msg
    = LineSerie (LineConfig msg) (List Point)
    | DotsSerie (DotsConfig msg) (List Point)
    | AreaSerie (AreaConfig msg) (List Point)
    | BarsSerie (BarsConfig msg) (List Group)



-- PRIMITIVES


{-| Place a list of SVG elements provided the information about the bounds of the plot.
 Use functions `fromRange`, `fromDomain` or `fromRangeAndDomain` to access this information.
-}
positionBy : (Meta -> Point) -> List (Svg msg) -> Element msg
positionBy =
    Position


{-| Place a list of SVG elements at a specific coordinate. The coordinate is Cartesian and
 relative to the space created to fit your data.
-}
positionAt : Point -> List (Svg msg) -> Element msg
positionAt point =
    Position (always point)


list : List (Svg.Attribute msg) -> (b -> Element msg) -> (Meta -> List b) -> Element msg
list attributes toElement toValues =
    List attributes (toValues >> List.map toElement)



-- POSITION/VALUE HELPERS


{-| Provided at delta it will create a list of values to be used for labels or ticks.
-}
fromDelta : Value -> Scale -> List Value
fromDelta delta scale =
    toValuesFromDelta scale.reach.lower scale.reach.upper delta


{-| Use your own list of values for labels or ticks.
-}
fromList : List Value -> Scale -> List Value
fromList values _ =
    values


{-| Remove a value from a list. Useful your axes are crossing at a paricular values
 and don't want the intersection cluttered with labels.

  labels (label [] toString) (fromDelta 10 >> remove 0)
-}
remove : Value -> List Value -> List Value
remove bannedValue =
    List.filter (\value -> value /= bannedValue)


{-| Remove values by their index.
-}
filterDelta : Int -> Int -> List Value -> List Value
filterDelta offset interval values =
    List.indexedMap (,) values
        |> List.filter (\( i, v ) -> rem (offset + i) interval /= 0)
        |> List.map Tuple.second


{-| Produce a value from the range of the plot.
-}
fromRange : (Value -> Value -> b) -> Meta -> b
fromRange toPoints { scale } =
    toPoints scale.x.reach.lower scale.x.reach.upper


{-| Produce a value from the domain of the plot.
-}
fromDomain : (Value -> Value -> b) -> Meta -> b
fromDomain toSomething { scale } =
    toSomething scale.y.reach.lower scale.y.reach.upper


{-| Produce a value from the range and domain of the plot.
-}
fromRangeAndDomain : (Value -> Value -> Value -> Value -> b) -> Meta -> b
fromRangeAndDomain toSomething { scale } =
    toSomething scale.x.reach.lower scale.x.reach.upper scale.y.reach.lower scale.y.reach.upper


{-| -}
onXAxisAt : (Value -> Value -> Value) -> Value -> Meta -> Point
onXAxisAt toYValue value =
    fromDomain (\l h -> ( value, toYValue l h ))


{-| -}
onYAxisAt : (Value -> Value -> Value) -> Value -> Meta -> Point
onYAxisAt toXValue value =
    fromRange (\l h -> ( toXValue l h, value ))


{-| -}
highest : Value -> Value -> Value
highest lower upper =
    upper


{-| -}
lowest : Value -> Value -> Value
lowest lower upper =
    lower


{-| -}
closestToZero : Value -> Value -> Value
closestToZero lower upper =
    clamp lower upper 0



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
dotsSerie : DotsConfig msg -> List Point -> Element msg
dotsSerie config data =
    SerieElement (findReachFromPoints data) (DotsSerie config data)



-- LINE CONFIG


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
lineSerie : LineConfig msg -> List Point -> Element msg
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
areaSerie : AreaConfig msg -> List Point -> Element msg
areaSerie config data =
    SerieElement (findReachFromAreaPoints data) (AreaSerie config data)



-- BARS CONFIG


{-| -}
type BarsConfig msg
    = BarsConfig
        { stackBy : Orientation
        , styles : List (List (Svg.Attribute msg))
        , labelConfig : LabelConfig BarValueInfo msg
        , maxWidth : MaxBarWidth
        }


{-| -}
type alias BarValueInfo =
    { xValue : Value, index : Int, yValue : Value }


{-| -}
type MaxBarWidth
    = Percentage Int
    | Fixed Float


{-| -}
toBarsConfig :
    { stackBy : Orientation
    , styles : List (List (Svg.Attribute msg))
    , labelConfig : LabelConfig BarValueInfo msg
    , maxWidth : MaxBarWidth
    }
    -> BarsConfig msg
toBarsConfig config =
    BarsConfig config


{-| -}
barsSerie : BarsConfig msg -> List Group -> Element msg
barsSerie config data =
    SerieElement (findReachFromGroups config data) (BarsSerie config data)



-- DATA TRANSFORMS


{-| -}
type alias GroupTransformer data =
    { xValue : Maybe (data -> Value)
    , yValues : data -> List Value
    }


{-| -}
toGroups : GroupTransformer data -> List data -> List Group
toGroups { xValue, yValues } allData =
    List.indexedMap
        (\index data ->
            { xValue = getGroupXValue xValue index data
            , yValues = yValues data
            }
        )
        allData


getGroupXValue : Maybe (data -> Value) -> Int -> data -> Value
getGroupXValue toXValue index data =
    case toXValue of
        Just getXValue ->
            getXValue data

        Nothing ->
            toFloat index + 1



-- AXIS ELEMENTS


type AxisConfig
    = AxisConfig
        { position : Value -> Value -> Value
        , clearIntersection : Bool
        , orientation : Orientation
        }


{-| -}
type alias AxisElement msg =
    AxisConfig -> AxisViewDetails msg -> Element msg


toAxisConfig :
    { position : Value -> Value -> Value
    , orientation : Orientation
    , clearIntersection : Bool
    }
    -> AxisConfig
toAxisConfig config =
    AxisConfig config


type alias AxisViewDetails msg =
    { class : String
    , defaultTickAttributes : List (Svg.Attribute msg)
    , defaultLabelAttributes : List (Svg.Attribute msg)
    , onAxisAt : Value -> Meta -> Point
    , toScale : Meta -> Scale
    }


toAxisDetails : AxisConfig -> AxisViewDetails msg
toAxisDetails (AxisConfig { position, orientation }) =
    case orientation of
        X ->
            { class = "elm-plot__axis elm-plot__axis--x"
            , defaultTickAttributes = [ stroke "grey", length 10 ]
            , defaultLabelAttributes = [ Svg.Attributes.style "text-anchor: middle;" ]
            , onAxisAt = onXAxisAt position
            , toScale = .scale >> .x
            }

        Y ->
            { class = "elm-plot__axis elm-plot__axis--y"
            , defaultTickAttributes = [ stroke "grey", length 10, transform "rotate(90)" ]
            , defaultLabelAttributes = [ Svg.Attributes.style "text-anchor: end;" ]
            , onAxisAt = onYAxisAt position
            , toScale = .scale >> .y
            }


ifXthenElse : AxisConfig -> a -> a -> a
ifXthenElse (AxisConfig { orientation }) x y =
    if orientation == X then
        x
    else
        y


clearIntersection : Scale -> Bool -> List Value -> List Value
clearIntersection scale shouldClearIntersection values =
    if shouldClearIntersection then
        List.filter (\value -> not (List.member value scale.intersections)) values
    else
        values


{-| -}
axis : AxisConfig -> List (AxisElement msg) -> Element msg
axis config elements =
    Axis config (toAxisView config (toAxisDetails config) elements)


toAxisView : AxisConfig -> AxisViewDetails msg -> List (AxisElement msg) -> Element msg
toAxisView config details elements =
    list [ class details.class ]
        (\element -> element config details)
        (\_ -> elements)



-- AXIS LINE


{-| -}
axisLine : List (Svg.Attribute msg) -> AxisElement msg
axisLine attributes _ { onAxisAt, toScale } =
    Line attributes
        (\meta ->
            [ onAxisAt (toScale meta |> .reach |> .lower) meta
            , onAxisAt (toScale meta |> .reach |> .upper) meta
            ]
        )



-- LABELS


type LabelConfig a msg
    = LabelSimple (List (Svg.Attribute msg)) (a -> String)
    | LabelCustom (a -> Svg msg)


label : List (Svg.Attribute msg) -> (a -> String) -> LabelConfig a msg
label =
    LabelSimple


labelCustom : (a -> Svg msg) -> LabelConfig a msg
labelCustom =
    LabelCustom


{-| -}
labels : LabelConfig Value msg -> (Scale -> List Value) -> AxisElement msg
labels labelConfig toValues (AxisConfig config) { onAxisAt, toScale, defaultLabelAttributes } =
    list [ class "elm-plot__labels" ]
        (\value -> positionBy (onAxisAt value) [ toLabelView defaultLabelAttributes labelConfig value ])
        (toScale >> (\scale -> clearIntersection scale config.clearIntersection (toValues scale)))


toLabelView : List (Svg.Attribute msg) -> LabelConfig a msg -> a -> Svg msg
toLabelView defaultAttributes config value =
    case config of
        LabelSimple attributes format ->
            viewLabel (defaultAttributes ++ attributes) (format value)

        LabelCustom view ->
            view value


{-| -}
viewLabel : List (Svg.Attribute msg) -> String -> Svg msg
viewLabel attributes string =
    text_ attributes [ tspan [] [ text string ] ]



-- TICKS


type TickConfig msg
    = TickSimple (List (Svg.Attribute msg))
    | TickCustom (Value -> Svg msg)


tick : List (Svg.Attribute msg) -> TickConfig msg
tick =
    TickSimple


tickCustom : (Value -> Svg msg) -> TickConfig msg
tickCustom =
    TickCustom


{-| -}
ticks : TickConfig msg -> (Scale -> List Value) -> AxisElement msg
ticks tickConfig toValues (AxisConfig config) { onAxisAt, defaultTickAttributes, toScale } =
    list [ class "elm-plot__ticks" ]
        (\value -> positionBy (onAxisAt value) [ toTickView defaultTickAttributes tickConfig value ])
        (toScale >> (\scale -> clearIntersection scale config.clearIntersection (toValues scale)))


toTickView : List (Svg.Attribute msg) -> TickConfig msg -> Value -> Svg msg
toTickView defaultAttributes config value =
    case config of
        TickSimple attributes ->
            line (defaultAttributes ++ attributes) []

        TickCustom view ->
            view value



-- GRID


{-| -}
horizontalGrid : List (Svg.Attribute msg) -> (Scale -> List Value) -> Element msg
horizontalGrid attributes toValues =
    list [ class "elm-plot__grid elm-plot__grid--horizontal" ]
        (\value -> Line attributes (\meta -> [ onYAxisAt lowest value meta, onYAxisAt highest value meta ]))
        (.scale >> .y >> toValues)


{-| -}
verticalGrid : List (Svg.Attribute msg) -> (Scale -> List Value) -> Element msg
verticalGrid attributes toValues =
    list [ class "elm-plot__grid elm-plot__grid--vertical" ]
        (\value -> Line attributes (\meta -> [ onXAxisAt lowest value meta, onXAxisAt highest value meta ]))
        (.scale >> .x >> toValues)



-- HELPER ATTRIBUTES


{-| -}
displace : ( Float, Float ) -> Svg.Attribute msg
displace displacement =
    transform (toTranslate displacement)


{-| -}
length : Float -> Svg.Attribute msg
length length =
    y2 (toString length)


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
        , toDomainLowest : Value -> Value
        , toDomainHighest : Value -> Value
        , toRangeLowest : Value -> Value
        , toRangeHighest : Value -> Value
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
        , toDomainLowest = identity
        , toDomainHighest = identity
        , toRangeLowest = identity
        , toRangeHighest = identity
        }


{-| -}
toPlotConfigFancy :
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
    , toDomainLowest : Value -> Value
    , toDomainHighest : Value -> Value
    , toRangeLowest : Value -> Value
    , toRangeHighest : Value -> Value
    }
    -> PlotConfig msg
toPlotConfigFancy config =
    PlotConfig config


{-| Render your plot!
-}
plot : PlotConfig msg -> List (Element msg) -> Svg msg
plot config elements =
    viewPlot config elements (toPlotMeta config elements)



-- VIEW PLOT


viewPlot : PlotConfig msg -> List (Element msg) -> Meta -> Html msg
viewPlot (PlotConfig config) elements meta =
    let
        viewBoxValue =
            "0 0 " ++ toString meta.scale.x.length ++ " " ++ toString meta.scale.y.length

        attributes =
            config.attributes
                ++ [ Svg.Attributes.viewBox viewBoxValue, Svg.Attributes.id meta.id ]
    in
        Svg.svg attributes (scaleDefs meta :: (viewElements meta elements))


scaleDefs : Meta -> Svg.Svg msg
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


viewElements : Meta -> List (Element msg) -> List (Svg msg)
viewElements meta elements =
    List.map (viewElement meta) elements


viewElement : Meta -> Element msg -> Svg msg
viewElement meta element =
    case element of
        SerieElement reach serie ->
            viewSerie reach serie meta

        Axis _ element ->
            viewElement meta element

        Line attributes toPoints ->
            viewPath attributes (makeLinePath NoInterpolation (toPoints meta) meta)

        Position toPosition children ->
            viewPositioned (toPosition meta) children meta

        List attributes toElements ->
            g attributes (List.map (viewElement meta) (toElements meta))

        SVGView view ->
            view


viewSerie : Axised Reach -> Serie msg -> Meta -> Svg msg
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


viewPositioned : Point -> List (Svg msg) -> Meta -> Svg msg
viewPositioned point children meta =
    g [ transform (toTranslate (meta.toSVGPoint point)) ] children



-- VIEW LINE


viewLine : LineConfig msg -> List Point -> Meta -> Svg msg
viewLine (LineConfig config) data meta =
    g
        [ class "elm-plot__serie--line"
        , clipPath ("url(#" ++ toClipPathId meta ++ ")")
        ]
        [ viewPath (config.attributes ++ [ fill "transparent" ]) (makeLinePath config.interpolation data meta) ]



-- VIEW DOTS


viewDots : DotsConfig msg -> List Point -> Meta -> Svg msg
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


viewArea : AreaConfig msg -> List Point -> Meta -> Axised Reach -> Svg msg
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
        g
            [ class "elm-plot__serie--area"
            , clipPath ("url(#" ++ toClipPathId meta ++ ")")
            ]
            [ viewPath config.attributes pathString ]



-- VIEW BARS


viewBars : BarsConfig msg -> List Group -> Meta -> Svg msg
viewBars (BarsConfig { stackBy, maxWidth, styles, labelConfig }) groups { toSVGPoint, scale } =
    let
        barsPerGroup =
            toFloat (List.length styles)

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

        viewBar group attributes bar =
            Svg.rect (attributes ++ viewBarAttributes group bar) []

        viewBarAttributes group bar =
            [ transform <| toTranslate <| toSVGPoint <| barPosition group bar
            , height <| toString <| scaleValue scale.y <| abs (barHeight bar)
            , width <| toString <| scaleValue scale.x barWidth
            ]

        wrapBarLabel group bar =
            g
                [ transform (toTranslate (labelPosition group bar)) ]
                [ toLabelView [] labelConfig bar ]

        labelPosition group bar =
            toSVGPoint (barPosition group bar |> addDisplacement ( barWidth / 2, 0 ))

        viewGroup group =
            Svg.g [ class "elm-plot__series--bars__group" ]
                [ Svg.g [ class "elm-plot__series--bars__group__bars" ]
                    (List.map2 (viewBar group) styles (toValueInfo group))
                , Svg.g [ class "elm-plot__series--bars__group__labels" ]
                    (List.map (wrapBarLabel group) (toValueInfo group))
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


makeLinePath : Interpolation -> List Point -> Meta -> String
makeLinePath interpolation points meta =
    case points of
        p1 :: rest ->
            M p1 :: (toLinePath interpolation (p1 :: rest)) |> toPath meta

        _ ->
            ""


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


toClipPathId : Meta -> String
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
    , intersections : List Value
    }


type alias Meta =
    { toSVGPoint : Point -> Point
    , scale : Axised Scale
    , id : String
    }


{-| -}
type Orientation
    = X
    | Y


toPlotMeta : PlotConfig msg -> List (Element msg) -> Meta
toPlotMeta (PlotConfig { id, margin, proportions, toRangeLowest, toRangeHighest, toDomainLowest, toDomainHighest }) elements =
    let
        reach =
            findPlotReach elements

        range =
            { lower = toRangeLowest reach.x.lower
            , upper = toRangeHighest reach.x.upper
            }

        domain =
            { lower = toDomainLowest reach.y.lower
            , upper = toDomainHighest reach.y.upper
            }

        ( yIntersections, xIntersections ) =
            findIntersections (Axised range domain) elements ( [], [] )

        scale =
            { x = toScale proportions.x range margin.left margin.right yIntersections
            , y = toScale proportions.y domain margin.top margin.bottom xIntersections
            }
    in
        { scale = scale
        , toSVGPoint = toSVGPoint scale.x scale.y
        , id = id
        }


toScale : Int -> Reach -> Int -> Int -> List Value -> Scale
toScale length reach offsetLower offsetUpper intersections =
    { length = toFloat length
    , offset = Reach (toFloat offsetLower) (toFloat offsetUpper)
    , reach = reach
    , intersections = intersections
    }


findIntersections : Axised Reach -> List (Element msg) -> ( List Value, List Value ) -> ( List Value, List Value )
findIntersections scale elements ( yIntersections, xIntersections ) =
    case elements of
        [] ->
            ( yIntersections, xIntersections )

        element :: rest ->
            case element of
                Axis config _ ->
                    findIntersections scale
                        rest
                        (ifXthenElse config
                            ( (toAxisPosition config scale.y) :: yIntersections, xIntersections )
                            ( yIntersections, (toAxisPosition config scale.x) :: xIntersections )
                        )

                _ ->
                    findIntersections scale rest ( yIntersections, xIntersections )


toAxisPosition : AxisConfig -> Reach -> Value
toAxisPosition (AxisConfig config) reach =
    config.position reach.lower reach.upper


findPlotReach : List (Element msg) -> Axised Reach
findPlotReach elements =
    List.filterMap getReach elements
        |> List.foldl strechReach Nothing
        |> Maybe.withDefault (Axised (Reach 0 1) (Reach 0 1))


getReach : Element msg -> Maybe (Axised Reach)
getReach element =
    case element of
        SerieElement reach _ ->
            Just reach

        _ ->
            Nothing


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


findReachFromGroups : BarsConfig msg -> List Group -> Axised Reach
findReachFromGroups (BarsConfig config) groups =
    toGroupPoints config.stackBy groups
        |> findReachFromPoints
        |> addBarPadding


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
