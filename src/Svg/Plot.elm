module Svg.Plot
    exposing
        ( Value
        , Point
        , Element
        , Meta
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
        , BarValueInfo
        , toBarsConfig
        , barsSerie
        , Group
        , GroupTransformer
        , toGroups
        , MaxBarWidth(..)
        , ValueProducer
        , ValueAlter
        , fromList
        , fromDelta
        , fromRange
        , fromDomain
        , fromRangeAndDomain
        , remove
        , atLowest
        , atHighest
        , atZero
        , verticalGrid
        , horizontalGrid
        , xAxis
        , yAxis
        , line
        , ticks
        , tick
        , length
        , labels
        , labelsFromStrings
        , label
        , displace
        , placeAt
        )

{-| This library helps you plot a variety of serie types including lines, areas, scatters and bars.
 It also provides functions to draw axes and their ticks and labels.

# Definitions
@docs Value, Point, Orientation, Meta

# Plot elements

## Line
@docs LineConfig, toLineConfig, Interpolation, lineSerie

## Area
@docs AreaConfig, toAreaConfig, Interpolation,  areaSerie

## Dots
@docs DotsConfig, toDotsConfig, dotsSerie

## Bars
@docs BarsConfig, toBarsConfig, BarValueInfo, MaxBarWidth, barsSerie

## Data transformation
@docs Group, GroupTransformer, toGroups

## Axis
@docs atLowest, atHighest, atZero, xAxis, yAxis

### Axis line
@docs line

### Grid lines
@docs horizontalGrid, verticalGrid

### Labels
@docs labels, labelsFromStrings, label

### Ticks
@docs ticks, tick, length

## Value helpers
These are functions to help you create the values you would like to have ticks, labels or grid lines at.
@docs ValueProducer, ValueAlter, fromList, fromDelta, remove

## General
@docs fromRange, fromDomain, fromRangeAndDomain, placeAt, displace


# Plot
@docs PlotConfig, Element, toPlotConfig, toPlotConfigFancy, plot



-}

import Html exposing (Html)
import Svg exposing (Svg, g, text_, tspan, path, text, line)
import Svg.Attributes exposing (d, fill, transform, class, y2, x2, width, height, clipPath, stroke)
import Svg.Utils exposing (..)


{-| Represents a x or y-value in a `Point`.
-}
type alias Value =
    Float


{-| Represents a point in the plot.
-}
type alias Point =
    ( Value, Value )


{-| An element in the plot.

    elements : List (Element msg)
    elements =
        [ lineSerie lineConfig [ ( 0, 1 ), ( 1, 2 ) ] ]


    myPlot : Svg msg
    myPlot =
        plot plotConfig elements

-}
type Element msg
    = SerieElement (Axised Reach) (Serie msg)
    | Views (List (Svg.Attribute msg)) (Meta -> List (Element msg))
    | View (Meta -> Svg msg)
    | SVGView (Svg msg)


type Serie msg
    = LineSerie (LineConfig msg) (List Point)
    | DotsSerie (DotsConfig msg) (List Point)
    | AreaSerie (AreaConfig msg) (List Point)
    | BarsSerie (BarsConfig msg) (List Group)



-- PRIMITIVES



{-| Take a list of SVG elements and place it somewhere in the plot.
 Use `fromRange`, `fromDomain` or `fromRangeAndDomain` to help you find the right coordinates.
 Beware that the plot will not adapt automatically to make sure the coordinate you provide is inside it's bounds.

    import Svg.Plot as Plot

    main =
        Plot.plot plotConfig
            [ Plot.customBy
                (Plot.fromDomain (\lowestY highestY -> ( 0, highestY )))
                [ Plot.label [] "✨" ]
            ]

-}
placeAt : (Meta -> Point) -> List (Svg msg) -> Element msg
placeAt toPoint views =
    View (\meta -> viewAtPosition (toPoint meta) views meta)




-- VALUE HELPERS


{-| Functions of this type are there to help you create values using the plot bounds.
-}
type alias ValueProducer =
    Scale -> ( List Value, Scale )


{-| Functions of this type are there to help alter the values created e.g. by a `ValueProducer`.
-}
type alias ValueAlter =
    ( List Value, Scale ) -> ( List Value, Scale )


{-| Just returns the list of values you provided.

    import Svg.Plot as Plot

    lineData : List Point
    lineData =
        [ ( 0, 10 ), ( 200, 30 ), ( 1200, 180 ), ( 1900, 400 ), ( 2017, 1000 ) ]

    myXAxis : Element msg
    myXAxis =
        Plot.axis xAxisConfig
            [ Plot.labels
                (Plot.label [] toString)
                (Plot.fromList [ 500, 1000, 1500, 2000, 2017 ])
            ]

    main =
        Plot.plot plotConfig
            [ Plot.lineSerie lineConfig lineData
            , myXAxis
            ]

This produces labels at 500, 1000, 1500, 2000 and 2017.
-}
fromList : List Value -> ValueProducer
fromList values scale =
    ( values, scale )


{-| Takes a delta and produces a list of values with the delta as their interval.

    import Svg.Plot as Plot

    lineData : List Point
    lineData =
        [ ( 0, 10 ), ( 3, 20 ), ( 6, 15 ), ( 9, 30 ) ]

    myXAxis : Element msg
    myXAxis =
        Plot.axis xAxisConfig
            [ Plot.labels
                (Plot.label [] toString)
                (Plot.fromDelta 2)
            ]

    main =
        Plot.plot plotConfig
            [ Plot.lineSerie lineConfig lineData
            , myXAxis
            ]

This produces labels at 0, 2, 4, 6 and 8.
-}
fromDelta : Value -> Value -> ValueProducer
fromDelta offset delta scale =
    ( toValuesFromDelta offset scale.lowest scale.highest delta, scale )


{-| Remove a value from a list.

    import Svg.Plot as Plot

    lineData : List Point
    lineData =
        [ ( 0, 10 ), ( 3, 20 ), ( 6, 15 ), ( 9, 30 ) ]

    myXAxis : Element msg
    myXAxis =
        Plot.axis xAxisConfig
            [ Plot.labels
                (Plot.label [] toString)
                (Plot.fromDelta 2 >> Plot.remove 4)
            ]

    main =
        Plot.plot plotConfig
            [ Plot.lineSerie lineConfig lineData
            , myXAxis
            ]

This produces labels at 0, 2, 6 and 8.
-}
remove : Value -> ValueAlter
remove bannedValue ( values, scale ) =
    ( List.filter (\value -> value /= bannedValue) values, scale )



-- POSITION HELPERS


{-| Produce *something*, usually a point though, from the range of the plot.

    mySpecialElement : Plot.Element msg
    mySpecialElement =
        Plot.positionBy
          (fromRange (\lowestX highestX -> ( lowestX, 4 )))
          [ mySVGStuff ]
-}
fromRange : (Value -> Value -> b) -> Meta -> b
fromRange toPoints (Meta { xScale }) =
    toPoints xScale.lowest xScale.highest


{-| Produce *something*, usually a point though, from the domain of the plot.

    mySpecialElement : Plot.Element msg
    mySpecialElement =
        Plot.positionBy
          (Plot.fromDomain (\lowestY highestY -> ( 3, highestY )))
          [ mySVGStuff ]
-}
fromDomain : (Value -> Value -> b) -> Meta -> b
fromDomain toSomething (Meta { yScale }) =
    toSomething yScale.lowest yScale.highest


{-| Produce *something*, usually a point though, from the range and domain of the plot.

    mySpecialElement : Plot.Element msg
    mySpecialElement =
        Plot.positionBy
          (Plot.fromDomain (\lx hx ly hy -> ( lx, (hy - ly) / 2 )))
          [ mySVGStuff ]

 The code about will place `mySVGStuff` leftmost halfway from the top.
-}
fromRangeAndDomain : (Value -> Value -> Value -> Value -> b) -> Meta -> b
fromRangeAndDomain toSomething (Meta { xScale, yScale }) =
    toSomething xScale.lowest xScale.highest yScale.lowest yScale.highest


{-| A helper to place something e.g. your axis at the lowest possible position.

    myXAxis : Plot.AxisConfig msg
    myXAxis =
      Plot.toAxisConfig
        { orientation = X
        , position = atLowest
        , clearIntersection = False
        }

The code above will create a configuration for a x-axis placed at the bottom of your plot.
-}
atLowest : Value -> Value -> Value
atLowest lowest _ =
    lowest


{-| Like `atLowest` except it places something it the highest possible position.
-}
atHighest : Value -> Value -> Value
atHighest _ highest =
    highest


{-| Like `atLowest` except it places something it _closest possible_ to zero.
-}
atZero : Value -> Value -> Value
atZero lowest highest =
    clamp lowest highest 0



-- DOTS CONFIG


{-| -}
type DotsConfig msg
    = DotsConfig
        { attributes : List (Svg.Attribute msg)
        , radius : Float
        }


{-| Create a scatter configuration.
-}
toDotsConfig :
    { attributes : List (Svg.Attribute msg)
    , radius : Float
    }
    -> DotsConfig msg
toDotsConfig config =
    DotsConfig config


{-| Provided a scatter configuration and a list of points, it will produce a scatter plot! 🎉
-}
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


{-| Create a line configuration.
-}
toLineConfig :
    { attributes : List (Svg.Attribute msg)
    , interpolation : Interpolation
    }
    -> LineConfig msg
toLineConfig config =
    LineConfig config


{-| These are the interpolation options.
-}
type Interpolation
    = Bezier
    | NoInterpolation


{-| Provided a line configuration and a list of points, it will produce a line plot! 🙌
-}
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


{-| Create an area configuration.
-}
toAreaConfig :
    { attributes : List (Svg.Attribute msg)
    , interpolation : Interpolation
    }
    -> AreaConfig msg
toAreaConfig config =
    AreaConfig config


{-| Provided an area configuration and a list of points, it will produce an area plot! 🌟
-}
areaSerie : AreaConfig msg -> List Point -> Element msg
areaSerie config data =
    SerieElement (findReachFromAreaPoints data) (AreaSerie config data)



-- BARS CONFIG


{-| -}
type BarsConfig msg
    = BarsConfig
        { stackBy : Orientation
        , styles : List (List (Svg.Attribute msg))
        , labelView : BarValueInfo -> Svg msg
        , maxWidth : MaxBarWidth
        }


{-| Create a bar configuration.
-}
toBarsConfig :
    { stackBy : Orientation
    , styles : List (List (Svg.Attribute msg))
    , labelView : BarValueInfo -> Svg msg
    , maxWidth : MaxBarWidth
    }
    -> BarsConfig msg
toBarsConfig config =
    BarsConfig config


{-| This is the information that will be provided the label for each of your bars.
-}
type alias BarValueInfo =
    { xValue : Value, index : Int, yValue : Value }


{-| The bar with options. If you use `Percentage` the bars will be that percentage of one x-value length.
  If you use `Fixed` it will be that number in pixels.
-}
type MaxBarWidth
    = Percentage Int
    | Fixed Float


{-| Provided an area configuration and a list of points, it will produce an area plot! 💗
-}
barsSerie : BarsConfig msg -> List Group -> Element msg
barsSerie config data =
    SerieElement (findReachFromGroups config data) (BarsSerie config data)



-- DATA TRANSFORMS


{-| Represents a group of y-values belonging to a single x-value. Only used for bar series.
-}
type alias Group =
    { xValue : Value
    , yValues : List Value
    }


{-| The functions necessary to transform your data into the format the plot requires.
 If you provide the `xValue` with `Nothing`, the bars xValues will just be the index
 of the bar in the list.
-}
type alias GroupTransformer data =
    { xValue : Maybe (data -> Value)
    , yValues : data -> List Value
    }


{-| This function can be used to transform your own data format
 into something the bar serie can understand.

    myBarSeries : Element msg
    myBarSeries =
        barsSerie
            barConfig <|
            Plot.toGroups
                { yValues = .revenueByYear
                , xValue = Just .quarter
                }
                [ { quarter = 1, revenueByYear = [ 10000, 30000, 20000 ] }
                , { quarter = 2, revenueByYear = [ 20000, 10000, 40000 ] }
                , { quarter = 3, revenueByYear = [ 40000, 20000, 10000 ] }
                , { quarter = 4, revenueByYear = [ 40000, 50000, 20000 ] }
                ]
-}
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
            toFloat index



-- AXIS ELEMENTS



{-| -}
type alias AxisElement msg =
    Scale -> (Value -> Point) -> Element msg


{-| Provided an axis configuration and a list of axis elements, it will produce an axis in your plot! ✨
-}
xAxis : (Value -> Value -> Value) -> List (AxisElement msg) -> Element msg
xAxis toYValue elements =
    let
        toAxisPoint xScale x =
          ( x, toYValue xScale.lowest xScale.highest )

        viewAxisElement (Meta { xScale, yScale }) element =
          element xScale (toAxisPoint yScale)

        view meta =
          List.map (viewAxisElement meta) elements
    in
        Views [ class "elm-plot__axis elm-plot__axis--x" ] view


{-| -}
yAxis : (Value -> Value -> Value) -> List (AxisElement msg) -> Element msg
yAxis toXValue elements =
    let
        toAxisPoint xScale y =
          ( toXValue xScale.lowest xScale.highest, y )

        viewAxisElement (Meta { xScale, yScale }) element =
          element yScale (toAxisPoint xScale)

        view meta =
          List.map (viewAxisElement meta) elements
    in
        Views [ class "elm-plot__axis elm-plot__axis--y" ] view





-- LABELS


{-| Place and view labels provided a label configuration and a function to produce values.

    myXAxis : Element msg
    myXAxis =
        Plot.axis xAxisConfig
            [ Plot.labels (toString >> label) (Plot.fromDelta 2) ]
-}
labels : (Value -> Svg msg) -> ValueProducer -> AxisElement msg
labels svgView valueBuilder scale toPoint =
    let
      view value =
        View (viewAtPosition (toPoint value) [ svgView value ])

      views _ =
        List.map view (Tuple.first (valueBuilder scale))
    in
      Views [ class "elm-plot__labels" ] views



{-| Just like `labels` except you add another list of strings which will be passed to your label view. Useful for
 bar series if you have specific names for your groups.

    myLabels : AxisElement msg
    myLabels =
        labelsFromStrings label (fromDelta 0 1) [ "Spring", "Summer", "Autumn", "Winter"]

-}
labelsFromStrings : (String -> Svg msg) -> ValueProducer -> List String -> AxisElement msg
labelsFromStrings svgView valueBuilder strings scale toPoint  =
    let
      view value string =
        View (viewAtPosition (toPoint value) [ svgView string ])

      views _ =
        List.map2 view (Tuple.first (valueBuilder scale)) strings
    in
      Views [ class "elm-plot__labels" ] views


{-| Just a simple view for a label in case you need it. You can use it with `custom` to create titles for axes.
-}
label : List (Svg.Attribute msg) -> String -> Svg msg
label attributes string =
    text_ attributes [ tspan [] [ text string ] ]



-- TICKS


{-| Place and view ticks provided a tick configuration and a function to produce values.
-}
ticks : Svg msg -> ValueProducer -> AxisElement msg
ticks svgView valueBuilder scale toPoint =
    let
      view value =
        View (viewAtPosition (toPoint value) [ svgView ])

      views _ =
        List.map view (Tuple.first (valueBuilder scale))
    in
      Views [ class "elm-plot__ticks" ] views


{-| -}
tick : List (Svg.Attribute msg) -> Svg msg
tick attributes =
    Svg.line attributes []


-- AXIS LINE


{-| Draw a line along your axis.
-}
line : List (Svg.Attribute msg) -> AxisElement msg
line attributes scale toPoint =
    View (viewAxisLine attributes [ toPoint scale.lowest, toPoint scale.highest ])



-- GRID


{-| Draw horizontal grid lines provided a list of attributes and a function to produce values. 💫

    myGrid : Element msg
    myGrid =
        horizontalGrid [ stroke "grey" ] (fromDelta 10)
-}
horizontalGrid : List (Svg.Attribute msg) -> ValueProducer -> Element msg
horizontalGrid attributes valueBuilder =
    let
      view scale y =
        line attributes scale (\x -> ( x, y ))

      views (Meta { xScale, yScale }) =
        List.map (view xScale) (Tuple.first (valueBuilder yScale))
    in
      Views [ class "elm-plot__grid elm-plot__grid--horizontal" ] views



{-| Draw vertical grid lines provided a list of attributes and a function to produce values. 🎼

    myGrid : Element msg
    myGrid =
        verticalGrid [ stroke "grey" ] (fromDelta 1)
-}
verticalGrid : List (Svg.Attribute msg) -> ValueProducer -> Element msg
verticalGrid attributes valueBuilder =
    let
      view scale x =
        line attributes scale (\y -> ( x, y ))

      views (Meta { yScale, xScale }) =
        List.map (view yScale) (Tuple.first (valueBuilder xScale))
    in
      Views [ class "elm-plot__grid elm-plot__grid--vertical" ] views





-- HELPER ATTRIBUTES


{-| A shortcut to displace the element. This is literally just a `SVG.Attributes.transform "translate(x, y)"`,
 so if you add your own `transform` afterwards it will be overwritten and have no effect.
-}
displace : ( Float, Float ) -> Svg.Attribute msg
displace displacement =
    transform (toTranslate displacement)


{-| A shortcut to set the length of a tick. This is just a `SVG.Attributes.y2 "length"` under the hood,
 so if you add your own `y2` afterwards it will be overwritten and have no effect.
-}
length : Float -> Svg.Attribute msg
length length =
    y2 (toString length)



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


{-| Alter the proportions of your plot. The proportions are set by using the SVG `viewBox`. This means
 that the plot have the proportions you specify, but it will fill out the div you place your plot in.
 The great thing about it is that it will be responsive! Regarding the margin, then it's for adding some space around
 your actual plot. This is especially useful if your ticks are hidding outside the plot's borders. The provided `id` will overrule
 any `Svg.Attributes.id` attribute you may add to the `attributes` property.
-}
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


{-| Provide the regular plot config _and_ functions to alter the reach of the plot. This is useful
 if you'd like to not show all your data points or you want extra space somewhere. Using the standard
 math functions like `min` and `max` can be helpful. If you just want the range to be what the plot
 calculates provided it with `identity`.

    plotConfig : PlotConfig msg
    plotConfig =
        toPlotConfigFancy
            { attributes = [ Svg.Events.onMouseOver HoveringPlot ]
            , id = "terezkas-plot"
            , margin =
                { top = 20
                , left = 30
                , right = 30
                , bottom = 90
                }
            , proportions =
                { x = 600, y = 400 }
            , toDomainLowest = min 0
            , toDomainHighest = \h -> h + 5
            , toRangeLowest = \l -> l - 0.5
            , toRangeHighest = \h -> h + 0.5
            }
-}
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


{-| Provided a plot configuration and a list of elements, it will produce an SVG plot! 💥
-}
plot : PlotConfig msg -> List (Element msg) -> Svg msg
plot config elements =
    viewPlot config elements (toPlotMeta config elements)



-- VIEW PLOT


viewPlot : PlotConfig msg -> List (Element msg) -> Meta -> Html msg
viewPlot (PlotConfig config) elements (Meta meta) =
    let
        viewBoxValue =
            "0 0 " ++ toString meta.xScale.length ++ " " ++ toString meta.yScale.length

        attributes =
            config.attributes
                ++ [ Svg.Attributes.viewBox viewBoxValue, Svg.Attributes.id meta.id ]
    in
        Svg.svg attributes (scaleDefs (Meta meta) :: Svg.style [] [ text defaultStyles ] :: (viewElements (Meta meta) elements))


defaultStyles : String
defaultStyles =
  """
    .elm-plot__axis--y .elm-plot__labels {
      text-anchor: end;
    }

    .elm-plot__axis--x .elm-plot__labels {
      text-anchor: middle;
    }

    .elm-plot__axis--y .elm-plot__ticks line {
      transform: rotate(90deg);
    }
  """



scaleDefs : Meta -> Svg.Svg msg
scaleDefs (Meta meta) =
    Svg.defs []
        [ Svg.clipPath [ Svg.Attributes.id (toClipPathId (Meta meta)) ]
            [ Svg.rect
                [ Svg.Attributes.x (toString meta.xScale.offset.lower)
                , Svg.Attributes.y (toString meta.yScale.offset.lower)
                , width (toString (getInnerLength meta.xScale))
                , height (toString (getInnerLength meta.yScale))
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

        Views attributes toElements ->
            g attributes (viewElements meta (toElements meta))

        View view ->
            view meta

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


viewAtPosition : Point -> List (Svg msg) -> Meta -> Svg msg
viewAtPosition point children meta =
    g [ transform (toTranslate (toSVGPoint meta point)) ] children



-- VIEW LINE


viewLine : LineConfig msg -> List Point -> Meta -> Svg msg
viewLine (LineConfig config) data meta =
    g
        [ class "elm-plot__serie--line"
        , clipPath ("url(#" ++ toClipPathId meta ++ ")")
        ]
        [ viewPath (config.attributes ++ [ fill "transparent" ]) (makeLinePath config.interpolation data meta) ]



viewAxisLine : List (Svg.Attribute msg) -> List Point -> Meta -> Svg msg
viewAxisLine attributes =
    viewLine (toLineConfig { attributes = attributes, interpolation = NoInterpolation })


-- VIEW DOTS


viewDots : DotsConfig msg -> List Point -> Meta -> Svg msg
viewDots (DotsConfig config) data meta =
    g [ class "elm-plot__serie--dots" ]
        (List.map (toSVGPoint meta >> viewCircle config.radius) data)


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
viewArea (AreaConfig config) data (Meta meta) reach =
    let
        mostZeroY =
            valueClosestToZero meta.yScale

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
                |> toPath (Meta meta)
    in
        g
            [ class "elm-plot__serie--area"
            , clipPath ("url(#" ++ toClipPathId (Meta meta) ++ ")")
            ]
            [ viewPath config.attributes pathString ]



-- VIEW BARS


viewBars : BarsConfig msg -> List Group -> Meta -> Svg msg
viewBars (BarsConfig { stackBy, maxWidth, styles, labelView }) groups meta =
    let
        (Meta { xScale, yScale }) =
          meta

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
                    if defaultBarWidth > (unScaleValue xScale max) then
                        unScaleValue xScale max
                    else
                        defaultBarWidth

        barHeight { yValue, index } =
            if stackBy == X || index == 0 then
                yValue - valueClosestToZero yScale
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
                    , max (min 0 yScale.highest) yValue
                    )

                Y ->
                    ( xValue - barWidth / 2
                    , yValue + toYStackedOffset group bar - min 0 (barHeight bar)
                    )

        viewBar group attributes bar =
            Svg.rect (attributes ++ viewBarAttributes group bar) []

        viewBarAttributes group bar =
            [ transform <| toTranslate <| toSVGPoint meta <| barPosition group bar
            , height <| toString <| scaleValue yScale <| abs (barHeight bar)
            , width <| toString <| scaleValue xScale barWidth
            ]

        wrapBarLabel group bar =
            g
                [ transform (toTranslate (labelPosition group bar)) ]
                [ labelView bar ]

        labelPosition group bar =
            toSVGPoint meta (barPosition group bar |> addDisplacement ( barWidth / 2, 0 ))

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
toPathTypeStringS meta ( x0, y0 ) ( x, y ) ( x1, y1 ) =
    let
        t0 = slope3 ( x0, y0 ) ( x, y ) ( x1, y1 )
        dx = (x1 - x0) / 3

        point(this, slope2(this, t1 = slope3(this, x, y)), t1)
    in
        "C " ++ pointToString meta ( x0 + dx, y0 + dx * t0 ) ++ "," ++ pointToString meta ( x1 - dx, y1 - dx * 1) ++ "," ++ pointToString meta (x1, y1)


toMonotoneXPath : List Point -> Float -> String -> String
toMonotoneXPath points t1 path =
  case points of
    ( x0, y0 ) :: ( x, y ) :: ( x1, y1 ) :: rest ->
      let
          t0 = slope3 ( x0, y0 ) ( x, y ) ( x1, y1 )
          newPath = path ++ beziesMonotoneXPath ( x0, y0 ) ( x, y ) ( x1, y1 ) t0 t1
      in
        toMonotoneXPath rest t0 newPath

    _ ->
      path


beziesMonotoneXPath : Point -> Point -> Point -> String
beziesMonotoneXPath ( x0, y0 ) ( x, y ) ( x1, y1 ) =
    let
        t0 = slope3 ( x0, y0 ) ( x, y ) ( x1, y1 )
        dx = (x1 - x0) / 3
    in
        bezierCurveTo ( x0 + dx, y0 + dx * t0 ) ( x1 - dx, y1 - dx * 1 ) ( x1, y1 )


bezierCurveTo : Meta -> Point -> Point -> Point -> String -> String
bezierCurveTo meta p1 p2 p3 =
    "C " ++ pointToString p1 ++ "," ++ pointToString p2 ++ "," ++ pointToString p3



{-| Calculate the slopes of the tangents (Hermite-type interpolation) based on
  the following paper: Steffen, M. 1990. A Simple Method for Monotonic
  Interpolation in One Dimension
-}
slope3 : Point -> Point -> Point -> Float
slope3 (x0, y0) (x1, y1) (x2, y2) =
  let
    h0 = x1 - x0
    h1 = x2 - x1

    s0 = (y1 - y0) / h0
    s1 = (y2 - y1) / h1

    p = (s0 * h1 + s1 * h0) / (h0 + h1)
  in
    (sign s0  + sign s1 ) * min (min (abs s0) (abs s1)) (0.5 * abs p)



{-| Calculate a one-sided slope. -}
slope2 : Point -> Point -> Float -> Float
slope2 (x0, y0) (x1, y1) t =
  let
    h = x1 - x0
  in
    (3 * (y1 - y0) / h - t) / 2


sign : Float -> Float
sign x =
  if x < 0 then -1 else 1



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
            toSVGPoint meta point
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
toClipPathId (Meta meta) =
    meta.id ++ "__scale-clip-path"


toTranslate : ( Float, Float ) -> String
toTranslate ( x, y ) =
    "translate(" ++ (toString x) ++ "," ++ (toString y) ++ ")"


addDisplacement : Point -> Point -> Point
addDisplacement ( x, y ) ( dx, dy ) =
    ( x + dx, y + dy )


valueClosestToZero : Scale -> Value
valueClosestToZero scale =
    clamp scale.lowest scale.highest 0



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
    { lowest : Value
    , highest : Value
    , offset : Reach
    , length : Float
    }


{-| Represents internal information about the plot needed all over.
-}
type Meta
    = Meta
        { xScale : Scale
        , yScale : Scale
        , id : String
        }


{-| Represents an orientation.
-}
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

        xScale =
            toScale proportions.x range margin.left margin.right

        yScale =
            toScale proportions.y domain margin.top margin.bottom
    in
        Meta
            { xScale = xScale
            , yScale = yScale
            , id = id
            }


toScale : Int -> Reach -> Int -> Int -> Scale
toScale length reach offsetLower offsetUpper =
    { length = toFloat length
    , offset = Reach (toFloat offsetLower) (toFloat offsetUpper)
    , lowest = reach.lower
    , highest = reach.upper
    }


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
    addAreaPadding (findReachFromPoints points)


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
            scale.highest - scale.lowest
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


toSVGPoint : Meta -> Point -> Point
toSVGPoint (Meta { xScale, yScale }) ( x, y ) =
    ( scaleValue xScale (x - xScale.lowest) + xScale.offset.lower
    , scaleValue yScale (yScale.highest - y) + yScale.offset.lower
    )
