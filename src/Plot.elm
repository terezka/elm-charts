module Plot
    exposing
        ( Value
        , Point
        , Interpolation(..)
        , Element
        , flipToY
        , label
        , defaultLabelView
        , defaultTickView
        , map
        , onAxis
        , plot
        , lineSerie
        , axisLine
        , fromReach
        , fromCount
        , margin
        , size
        , xAxis
        , xAxisAt
        , yAxis
        , yAxisAt
        , ticks
        , labels
        , grid
        , length
        , positionBy
        , fromOppositeReach
        )

{-| Plot primities!

# elements
@docs Value, Point, Interpolation, Element, flipToY, margin, size, xAxis, xAxisAt, yAxis, yAxisAt, ticks, labels, grid

# other
@docs plot, lineSerie, axisLine, fromReach, label,onAxis, map, fromCount, defaultLabelView, defaultTickView, length, positionBy, fromOppositeReach
-}

import Html exposing (Html)
import Html.Attributes
import Svg exposing (Svg, Attribute, g, text_, tspan, path, text, line)
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
type Interpolation
    = Bezier
    | NoInterpolation



-- INTERNAL TYPES


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


type alias Meta a msg =
    { id : String
    , orientation : Orientation
    , axisPosition : Float
    , scale : Axised Scale
    , elements : List (Element a msg)
    }


type Orientation
    = X
    | Y


{-| -}
type Element a msg
    = Axis (Meta a msg -> Value) (Meta a msg -> Meta a msg) (List (Element a msg))
    | SerieElement (Axised Reach) (Serie msg)
    | Line (List (Attribute msg)) (Meta a msg -> List Point)
    | Position (Meta a msg -> Point) (List (Svg msg))
    | Map (List (Attribute msg)) (a -> Element a msg) (Meta a msg -> List a)
    | SVGView (Svg msg)


type Serie msg
    = LineSerie (List (Attribute msg)) Interpolation (List Point)
    | DotsSerie (List (Attribute msg)) (List Point)



-- PRIMITIVES


{-| -}
plot : List (MetaAttribute a msg) -> List (Element a msg) -> Html msg
plot attributes elements =
    findPlotReach elements
        |> toInitialPlot elements
        |> applyAttributes attributes
        |> viewPlot


{-| -}
positionBy : (Meta a msg -> Point) -> List (Svg msg) -> Element a msg
positionBy =
    Position


{-| -}
positionAt : Point -> List (Svg msg) -> Element a msg
positionAt point =
    Position (always point)


{-| -}
xAxis : List (Element a msg) -> Element a msg
xAxis =
    Axis (fromOppositeReach (\l h -> clamp 0 l h)) identity


{-| -}
xAxisAt : (Meta a msg -> Value) -> List (Element a msg) -> Element a msg
xAxisAt toPosition =
    Axis toPosition identity


{-| -}
yAxis : List (Element a msg) -> Element a msg
yAxis =
    Axis (fromReach (\l h -> clamp 0 l h)) flipToY


{-| -}
yAxisAt : (Meta a msg -> Value) -> List (Element a msg) -> Element a msg
yAxisAt toPosition =
    Axis toPosition flipToY


{-| -}
axisLine : List (Attribute msg) -> Element a msg
axisLine attributes =
    Line attributes (fromAxis (\v l h -> [ ( l, v ), ( h, v ) ]))


{-| -}
fullLengthline : List (Attribute msg) -> Value -> Element a msg
fullLengthline attributes value =
    Line attributes (fromReach (\l h -> [ ( l, value ), ( h, value ) ]))


{-| -}
labels : List (Attribute msg) -> (Value -> String) -> (Meta Value msg -> List Value) -> Element Value msg
labels attributes valueToString toValues =
    map [ class "elm-plot__labels" ] (label attributes valueToString) toValues


{-| -}
ticks : List (Attribute msg) -> List TickAttribute -> (Meta Value msg -> List Value) -> Element Value msg
ticks attributes tickAttributes toValues =
    map [ class "elm-plot__ticks" ] (tick attributes tickAttributes) toValues


{-| -}
grid : List (Attribute msg) -> (Meta Value msg -> List Value) -> Element Value msg
grid attributes toValues =
    map [ class "elm-plot__grid" ] (fullLengthline attributes) toValues


{-| -}
map : List (Attribute msg) -> (a -> Element a msg) -> (Meta a msg -> List a) -> Element a msg
map =
    Map


{-| -}
label : List (Attribute msg) -> (Value -> String) -> Value -> Element a msg
label attributes valueToString value =
    positionBy (onAxis value) [ defaultLabelView attributes (valueToString value) ]


{-| -}
tick : List (Attribute msg) -> List TickAttribute -> Value -> Element a msg
tick attributes tickAttibutes value =
    positionBy (onAxis value) [ defaultTickView attributes tickAttibutes ]



-- SERIES


{-| -}
lineSerie : Interpolation -> List (Attribute msg) -> List Point -> Element a msg
lineSerie interpolation attributes points =
    SerieElement (findReachFromPoints points) (LineSerie attributes interpolation points)


dotsSerie : List (Attribute msg) -> List Point -> Element a msg
dotsSerie attributes points =
    SerieElement (findReachFromPoints points) (DotsSerie attributes points)



-- POSITION HELPERS


{-| -}
flipToY : Meta a msg -> Meta a msg
flipToY =
    (\meta -> { meta | orientation = Y, scale = Axised meta.scale.y meta.scale.x })


{-| -}
fromCount : Int -> Meta a msg -> List Float
fromCount count meta =
    toDelta meta.scale.x.reach.lower meta.scale.x.reach.upper count
        |> toValuesFromDelta meta.scale.x.reach.lower meta.scale.x.reach.upper


{-| -}
fromReach : (Value -> Value -> b) -> Meta a msg -> b
fromReach toPoints meta =
    toPoints meta.scale.x.reach.lower meta.scale.x.reach.upper


{-| -}
fromOppositeReach : (Value -> Value -> b) -> Meta a msg -> b
fromOppositeReach toPoints meta =
    toPoints meta.scale.y.reach.lower meta.scale.y.reach.upper


{-| -}
fromPlotReach : (Value -> Value -> Value -> Value -> b) -> Meta a msg -> b
fromPlotReach toPoints meta =
    toPoints meta.scale.x.reach.lower meta.scale.x.reach.upper meta.scale.y.reach.lower meta.scale.y.reach.upper


{-| -}
onAxis : Value -> Meta a msg -> Point
onAxis value meta =
    ( value, meta.axisPosition )


{-| -}
fromAxis : (Value -> Value -> Value -> b) -> Meta a msg -> b
fromAxis toSomething meta =
    toSomething meta.axisPosition meta.scale.x.reach.lower meta.scale.x.reach.upper



-- PUBLIC VIEWS


{-| -}
defaultLabelView : List (Attribute msg) -> String -> Svg msg
defaultLabelView attributes formattetValue =
    text_ attributes [ tspan [] [ text formattetValue ] ]


{-| -}
defaultTickView : List (Attribute msg) -> List TickAttribute -> Svg msg
defaultTickView attributes tickAttibutes =
    let
        config =
            applyAttributes tickAttibutes defaultTickConfig
    in
        line (y2 (toString config.length) :: attributes) []



-- ATTRIBUTES


type alias TickConfig =
    { length : Float }


defaultTickConfig : TickConfig
defaultTickConfig =
    { length = 5 }


type alias TickAttribute =
    TickConfig -> TickConfig


{-| -}
length : Float -> TickAttribute
length length config =
    { config | length = length }


type alias MetaAttribute a msg =
    Meta a msg -> Meta a msg


{-| Specify the size of the plot in pixels.

 Format: `( width, height )`
 Default: `( 800, 500 )`
-}
size : ( Int, Int ) -> MetaAttribute a msg
size ( width, height ) plot =
    plot
        |> updateXScale (updateScaleLength width plot.scale.x)
        |> updateYScale (updateScaleLength height plot.scale.y)


{-| Specify margin around the plot in pixels. Particularly useful if your ticks
 or labels are not showing.

 Format: `( top, right, bottom, left )`
 Default: `( 10, 10, 10, 10 )`
-}
margin : ( Int, Int, Int, Int ) -> MetaAttribute a msg
margin ( top, right, bottom, left ) plot =
    plot
        |> updateXScale (updateScaleOffset left right plot.scale.x)
        |> updateYScale (updateScaleOffset bottom top plot.scale.y)


{-| Specify the lowest value on your y-axis based on the your elements lowest y-value.

    plot [ domainLowest (\lowestY -> ceiling (lowestY / 10) * 10) ] elements

 Default: `identity`.
-}
domainLowest : (Float -> Float) -> MetaAttribute a msg
domainLowest toLowest plot =
    updateYScale (updateScaleLowerReach toLowest plot.scale.y) plot


{-| Specify the highest value on your y-axis based on the your elements highest y-value.

    plot [ domainHighest (\highestY -> floor (highestY / 10) * 10) ] elements

 Default: `identity`.
-}
domainHighest : (Float -> Float) -> MetaAttribute a msg
domainHighest toHighest plot =
    updateYScale (updateScaleUpperReach toHighest plot.scale.y) plot


{-| Specify the lowest value on your x-axis based on the your elements lowest x-value.

    plot [ rangeLowest (\lowestX -> ceiling (lowestX / 10) * 10) ] elements

 Default: `identity`.
-}
rangeLowest : (Float -> Float) -> MetaAttribute a msg
rangeLowest toLowest plot =
    updateXScale (updateScaleLowerReach toLowest plot.scale.x) plot


{-| Specify the highest value on your x-axis based on the your elements highest x-value.

    plot [ rangeHighest (\highestX -> floor (highestX / 10) * 10) ] elements

 Default: `identity`.
-}
rangeHighest : (Float -> Float) -> MetaAttribute a msg
rangeHighest toHighest plot =
    updateXScale (updateScaleUpperReach toHighest plot.scale.x) plot



-- VIEW


viewPlot : Meta a msg -> Html msg
viewPlot meta =
    Html.div
        [ Html.Attributes.class "elm-plot"
        , Html.Attributes.id meta.id
        ]
        [ Svg.svg
            [ Svg.Attributes.class "elm-plot__inner"
            , Svg.Attributes.viewBox ("0 0 " ++ toString meta.scale.x.length ++ " " ++ toString meta.scale.y.length)
            ]
            (scaleDefs meta :: (viewElements meta meta.elements))
        ]


scaleDefs : Meta a msg -> Svg.Svg msg
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


viewElements : Meta a msg -> List (Element a msg) -> List (Svg msg)
viewElements meta elements =
    List.map (viewElement meta) meta.elements


viewElement : Meta a msg -> Element a msg -> Svg msg
viewElement meta element =
    case element of
        Axis toPosition toMeta elements ->
            g [] (List.map (viewElement (toMeta meta |> updateAxisPosition (toPosition meta))) elements)

        SerieElement _ serie ->
            viewSerie meta serie

        Line attributes toPoints ->
            viewPath attributes (makeLinePath NoInterpolation (toPoints meta) meta)

        Position toPosition children ->
            viewPositioned (toPosition meta) children meta

        Map attributes toElement toValues ->
            g attributes (List.map (toElement >> viewElement meta) (toValues meta))

        SVGView view ->
            view


viewSerie : Meta a msg -> Serie msg -> Svg msg
viewSerie meta serie =
    case serie of
        LineSerie attributes interpolation points ->
            viewPath attributes (makeLinePath interpolation points meta)

        DotsSerie attributes points ->
            g [] []


viewPositioned : Point -> List (Svg msg) -> Meta a msg -> Svg msg
viewPositioned point children meta =
    g [ transform (toTranslate (toSVGPoint meta point)) ] children



-- VIEW LINE


viewPath : List (Attribute msg) -> String -> Svg msg
viewPath attributes pathString =
    path (d pathString :: fill "transparent" :: attributes |> List.reverse) []


makeLinePath : Interpolation -> List Point -> Meta a msg -> String
makeLinePath interpolation points meta =
    case points of
        p1 :: rest ->
            M p1 :: (toLinePath interpolation (p1 :: rest)) |> toPath meta

        _ ->
            ""



-- PATH STUFF


type PathType
    = L Point
    | M Point
    | S Point Point Point
    | Z


toPath : Meta a msg -> List PathType -> String
toPath plot pathParts =
    List.foldl (\part result -> result ++ toPathTypeString plot part) "" pathParts


toPathTypeString : Meta a msg -> PathType -> String
toPathTypeString plot pathType =
    case pathType of
        M point ->
            toPathTypeStringSinglePoint plot "M" point

        L point ->
            toPathTypeStringSinglePoint plot "L" point

        S p1 p2 p3 ->
            toPathTypeStringS plot p1 p2 p3

        Z ->
            "Z"


toPathTypeStringSinglePoint : Meta a msg -> String -> Point -> String
toPathTypeStringSinglePoint plot typeString point =
    typeString ++ " " ++ pointToString plot point


toPathTypeStringS : Meta a msg -> Point -> Point -> Point -> String
toPathTypeStringS plot p1 p2 p3 =
    let
        ( point1, point2 ) =
            toBezierPoints p1 p2 p3
    in
        "S" ++ " " ++ pointToString plot point1 ++ "," ++ pointToString plot point2


magnitude : Float
magnitude =
    0.5


toBezierPoints : Point -> Point -> Point -> ( Point, Point )
toBezierPoints ( x0, y0 ) ( x, y ) ( x1, y1 ) =
    ( ( x - ((x1 - x0) / 2 * magnitude), y - ((y1 - y0) / 2 * magnitude) )
    , ( x, y )
    )


pointToString : Meta a msg -> Point -> String
pointToString plot point =
    let
        ( x, y ) =
            toSVGPoint plot point
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


toClipPathId : Meta a msg -> String
toClipPathId plot =
    plot.id ++ "__scale-clip-path"


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



-- SCALING HELPERS


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


toSVGPoint : Meta a msg -> Point -> Point
toSVGPoint plot ( x, y ) =
    case plot.orientation of
        X ->
            ( scaleValue plot.scale.x (x - plot.scale.x.reach.lower)
            , scaleValue plot.scale.y (plot.scale.y.reach.upper - y)
            )

        Y ->
            ( scaleValue plot.scale.y (y - plot.scale.y.reach.lower)
            , scaleValue plot.scale.x (plot.scale.x.reach.upper - x)
            )



-- META


applyAttributes : List (a -> a) -> a -> a
applyAttributes attributes config =
    List.foldl (<|) config attributes


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


toInitialPlot : List (Element a msg) -> Axised Reach -> Meta a msg
toInitialPlot elements reach =
    { id = "elm-plot"
    , orientation = X
    , axisPosition = 0
    , scale =
        Axised
            (Scale reach.x (Reach 0 0) 100)
            (Scale reach.y (Reach 0 0) 100)
    , elements = elements
    }



-- UPDATE HELPERS


updateAxisPosition : Value -> Meta a msg -> Meta a msg
updateAxisPosition value meta =
    { meta | axisPosition = value }


updateXScale : scale -> { p | scale : Axised scale } -> { p | scale : Axised scale }
updateXScale xScale ({ scale } as config) =
    { config | scale = { scale | x = xScale } }


updateYScale : scale -> { p | scale : Axised scale } -> { p | scale : Axised scale }
updateYScale yScale ({ scale } as config) =
    { config | scale = { scale | y = yScale } }


updateScaleLength : Int -> Scale -> Scale
updateScaleLength length scale =
    { scale | length = toFloat length }


updateScaleOffset : Int -> Int -> Scale -> Scale
updateScaleOffset lower upper ({ offset } as scale) =
    { scale | offset = { offset | lower = toFloat lower, upper = toFloat upper } }


updateScaleReach : Reach -> Scale -> Scale
updateScaleReach reach scale =
    { scale | reach = reach }


updateScaleLowerReach : (Float -> Float) -> Scale -> Scale
updateScaleLowerReach toLowest ({ reach } as scale) =
    { scale | reach = { reach | lower = toLowest reach.lower } }


updateScaleUpperReach : (Float -> Float) -> Scale -> Scale
updateScaleUpperReach toHighest ({ reach } as scale) =
    { scale | reach = { reach | upper = toHighest reach.upper } }
