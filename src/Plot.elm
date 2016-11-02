module Plot
    exposing
        ( plot
        , size
        , padding
        , plotStyle
        , xAxis
        , yAxis
        , tickValues
        , tickDelta
        , tickTotal
        , viewTick
        , viewLabel
        , axisStyle
        , horizontalGridLines
        , verticalGridLines
        , gridTickValues
        , gridStyle
        , area
        , areaStyle
        , line
        , lineStyle
        , Point
        , Element
        , PlotAttr
        , AxisAttr
        , GridAttr
        , AreaAttr
        , LineAttr
        )

{-|
 This is a library to build configurable plots in svg. It aims to
 have sane defaults without compromising flexibility in custom styling.

 The api is inspired by the standard elm-html library, resulting in the
 following structure.

    view =
        plot
            [ dimensions ( 300, 400 ) ]
            [ line [ stroke "red" ] points
            , xAxis [ viewTick myCustomTick ]
            , yAxis [ tickValues [ -20, 20, 40, 82 ] ]
            ]

 You always have the top element `plot` and its first argument is its attributes
 and its second argument is its children elements. Similarily, the child elements'
 first argument is always a list of attributes.


# Definitions
@docs Element, PlotAttr, AxisAttr, GridAttr, AreaAttr, LineAttr

# Plot
@docs plot

## Attributes
@docs size, padding, plotStyle

# Series
@docs Point, area, line

## Attributes
@docs lineStyle, areaStyle

# Axis
@docs xAxis, yAxis

## Attributes
@docs tickValues, tickDelta, tickTotal, viewTick, viewLabel, axisStyle

# Grid
@docs horizontalGridLines, verticalGridLines

## Attributes
@docs gridStyle, gridTickValues

-}

import Html exposing (Html)
import Html.Events exposing (on, onMouseOut)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, d, style)
import Svg.Lazy
import String
import Debug
import Helpers exposing (..)


{-| Convinience type to represent coordinates
-}
type alias Point =
    ( Float, Float )


{-| Convinience type to represent style
-}
type alias Style =
    List ( String, String )



-- CONFIGS


{-| Represents the type which are allowed in the plots list of children.
-}
type Element msg
    = Axis (AxisConfig msg)
    | Grid GridConfig
    | Area AreaConfig
    | Line LineConfig



-- Plot config


type alias PlotConfig =
    { size : ( Int, Int )
    , dimensions : Maybe ( Float, Float )
    , padding : ( Int, Int )
    , style : Style
    }


{-| Represents an attribute for the plot.
-}
type alias PlotAttr =
    PlotConfig -> PlotConfig


defaultPlotConfig =
    { size = ( 800, 500 )
    , dimensions = Nothing
    , padding = ( 10, 10 )
    , style = [ ( "padding", "30px" ), ( "overflow", "hidden" ) ]
    }


{-| Specify the coordinate dimensions of your plot.
-}
dimensions : Maybe ( Float, Float ) -> PlotConfig -> PlotConfig
dimensions dimensions config =
    { config | dimensions = dimensions }


{-| Specify extra space outside your datas lowest
 and highest y-coordinates. Units are in pixels.

    paddingTop : Int
    paddingTop =
        40

    paddingBottom : Int
    paddingBottom =
        30

    view : Html msg
    view =
        plot [ padding (paddingBottom, paddingTop) ] []

-}
padding : ( Int, Int ) -> PlotConfig -> PlotConfig
padding padding config =
    { config | padding = padding }


{-| Specify the width and height in pixels.
-}
size : ( Int, Int ) -> PlotConfig -> PlotConfig
size size config =
    { config | size = size }


{-| Specify a list of style to apply to the svg element.
-}
plotStyle : List ( String, String ) -> PlotConfig -> PlotConfig
plotStyle style config =
    { config | style = style }



-- Axis config


type Direction
    = X
    | Y


type TickConfig
    = TickDelta Float
    | TickTotal Int
    | TickValues (List Float)


type alias AxisConfig msg =
    { tickConfig : TickConfig
    , viewTick : Float -> Svg.Svg msg
    , viewLabel : Float -> Svg.Svg msg
    , axisStyle : Style
    , direction : Direction
    }


{-| Represents an attribute for the axis.
-}
type alias AxisAttr msg =
    AxisConfig msg -> AxisConfig msg


defaultTickHtml : Direction -> Float -> Svg.Svg msg
defaultTickHtml axis tick =
    let
        displacement =
            fromDirection axis "" (toRotate 90 0 0)
    in
        Svg.line
            [ Svg.Attributes.style "stroke: #757575;"
            , Svg.Attributes.y2 "7"
            , Svg.Attributes.transform displacement
            ]
            []


defaultLabelStyleX : Style
defaultLabelStyleX =
    [ ( "stroke", "#757575" ), ( "text-anchor", "middle" ) ]


defaultLabelStyleY : Style
defaultLabelStyleY =
    [ ( "stroke", "#757575" ), ( "text-anchor", "end" ) ]


defaultLabelHtml : Direction -> Float -> Svg.Svg a
defaultLabelHtml direction tick =
    let
        ( style, displacement ) =
            fromDirection direction ( defaultLabelStyleX, ( 0, 24 ) ) ( defaultLabelStyleY, ( -10, 5 ) )
    in
        Svg.text'
            [ Svg.Attributes.transform (toTranslate displacement)
            , Svg.Attributes.style (toStyle style)
            ]
            [ Svg.tspan [] [ Svg.text (toString tick) ] ]


defaultAxisConfigX =
    { tickConfig = (TickTotal 10)
    , viewTick = defaultTickHtml X
    , viewLabel = defaultLabelHtml X
    , axisStyle = [ ( "stroke", "#757575" ) ]
    , direction = X
    }


defaultAxisConfigY =
    { tickConfig = (TickTotal 10)
    , viewTick = defaultTickHtml Y
    , viewLabel = defaultLabelHtml Y
    , axisStyle = [ ( "stroke", "#757575" ) ]
    , direction = Y
    }


{-| Specify a _guiding_ amount of ticks which the library will use to calculate "nice" axis values.

    xAxis [ tickTotal 5 ]

-}
tickTotal : Int -> AxisConfig msg -> AxisConfig msg
tickTotal total config =
    { config | tickConfig = TickTotal total }


{-| Specify the step size between the ticks.

    xAxis [ tickDelta 5 ]

-}
tickDelta : Float -> AxisConfig msg -> AxisConfig msg
tickDelta tickDelta config =
    { config | tickConfig = TickDelta tickDelta }


{-| Specify the list of ticks to be show in on the axis.

    xAxis [ tickValues [ 10 25 32 47 ] ]

-}
tickValues : List Float -> AxisConfig msg -> AxisConfig msg
tickValues ticks config =
    { config | tickConfig = TickValues ticks }


{-| Specify the html to use for each tick. If you want to displace the tick, it
 can be recommended to use `Svg.Attributes.transform` in your tick view.

    myCustomTick : Float -> Svg.Svg a
    myCustomTick tick =
        Svg.text' [] [ Svg.tspan [] [ Svg.text "⚡️" ] ]


    view : Html msg
    view =
        plot [] [ xAxis [ viewTick myCustomTick ] ]

-}
viewTick : (Float -> Svg.Svg msg) -> AxisConfig msg -> AxisConfig msg
viewTick viewTick config =
    { config | viewTick = viewTick }


{-| Specify the html to use for each label.

    myCustomLabel : Float -> Svg.Svg a
    myCustomLabel tick =
        Svg.text' [] [ Svg.tspan [] [ Svg.text ((toString tick) ++ " ms") ] ]


    view : Html msg
    view =
        plot [] [ xAxis [ viewLabel myCustomTick ] ]

-}
viewLabel : (Float -> Svg.Svg msg) -> AxisConfig msg -> AxisConfig msg
viewLabel viewLabel config =
    { config | viewLabel = viewLabel }


{-| Specify style of the axis.

    yAxis [ axisStyle [ ( "stroke", "red" ) ] ]

-}
axisStyle : List ( String, String ) -> AxisConfig msg -> AxisConfig msg
axisStyle style config =
    { config | axisStyle = style }


{-| Draws a x-axis.
-}
xAxis : List (AxisAttr msg) -> Element msg
xAxis attrs =
    Axis (List.foldr (<|) defaultAxisConfigX attrs)


{-| Draws a y-axis.
-}
yAxis : List (AxisAttr msg) -> Element msg
yAxis attrs =
    Axis (List.foldr (<|) defaultAxisConfigY attrs)



-- Grid config


type alias GridConfig =
    { tickValues : List Float
    , direction : Direction
    , style : Style
    }


{-| Represents an attribute for the grid.
-}
type alias GridAttr =
    GridConfig -> GridConfig


defaultGridConfig =
    { tickValues = []
    , direction = X
    , style = [ ( "stroke", "#737373" ) ]
    }


{-| Specify the styling for the grid.

    verticalGridLines [ gridStyle [ ( "stroke", "#cee0e2" ) ] ]

-}
gridStyle : List ( String, String ) -> GridConfig -> GridConfig
gridStyle style config =
    { config | style = style }


{-| Specify the styling for the grid.

    verticalGridLines [ gridTickValues [ 200, 400, 600 ] ]

**Note:** This will _eventually_ be changed to a Maybe type and will default to
align with whatever ticks are on your axis.
-}
gridTickValues : List Float -> GridConfig -> GridConfig
gridTickValues tickValues config =
    { config | tickValues = tickValues }


{-| Draws a vertical grid.

    verticalGridLines [ gridTickValues [ 10 40 90 ] ]
-}
verticalGridLines : List GridAttr -> Element msg
verticalGridLines attrs =
    Grid (List.foldr (<|) defaultGridConfig attrs)


{-| Draws  a horizontal grid.

    horizontalGridLines [ gridTickValues [ 20 30 40 ] ]
-}
horizontalGridLines : List GridAttr -> Element msg
horizontalGridLines attrs =
    let
        defaultGridConfigY =
            { defaultGridConfig | direction = Y }
    in
        Grid (List.foldr (<|) defaultGridConfigY attrs)



-- Area config


type alias AreaConfig =
    { style : Style
    , points : List Point
    }


{-| Represents an attribute for the serie.
-}
type alias AreaAttr =
    AreaConfig -> AreaConfig


defaultAreaConfig =
    { style = [ ( "stroke", "#737373" ), ( "fill", "#ddd" ) ]
    , points = []
    }


{-| Specify the area serie style.

    area [ areaStyle [ ( "stroke", "blue", "fill", "green" ) ] ]
-}
areaStyle : List ( String, String ) -> AreaConfig -> AreaConfig
areaStyle style config =
    { config | style = style }


{-| Draws a area serie.

    area [] [ (2, 4), (3, 6), (5, 3.4) ]
-}
area : List AreaAttr -> List Point -> Element msg
area attrs points =
    let
        config =
            List.foldr (<|) defaultAreaConfig attrs
    in
        Area { config | points = points }



-- Line config


type alias LineConfig =
    { style : Style
    , points : List Point
    }


defaultLineConfig =
    { style = [ ( "stroke", "#737373" ) ]
    , points = []
    }


{-| Represents an attribute for the serie.
-}
type alias LineAttr =
    LineConfig -> LineConfig


{-| Specify the area serie style.

    line [ lineStyle [ ( "stroke", "blue" ) ] ]
-}
lineStyle : List ( String, String ) -> LineConfig -> LineConfig
lineStyle style config =
    { config | style = ( "fill", "transparent" ) :: style }


{-| Draws a line serie.

    area [] [ (2, 3), (3, 8), (5, 7) ]
-}
line : List LineAttr -> List Point -> Element msg
line attrs points =
    let
        config =
            List.foldr (<|) defaultLineConfig attrs
    in
        Line { config | points = points }



-- Calculations


type alias AxisScale =
    { range : Float
    , lowest : Float
    , highest : Float
    , length : Float
    }


getScales : Int -> ( Int, Int ) -> List Float -> AxisScale
getScales length (paddingBottomPx, paddingTopPx) values =
    let
        lowest =
            getLowest values

        highest =
            getHighest values

        range =
            getRange lowest highest

        paddingTop =
            pixelsToValue length range paddingTopPx

        paddingBottom =
            pixelsToValue length range paddingBottomPx
    in
        { lowest = lowest - paddingBottom
        , highest = highest + paddingTop
        , range = range + paddingBottom + paddingTop
        , length = toFloat length
        }


toScale : AxisScale -> Float -> Float
toScale { length, range } v =
    v * length / range


toSvgCoords : AxisScale -> AxisScale -> Point -> Point
toSvgCoords xScale yScale ( x, y ) =
    let
        xValue =
            abs xScale.lowest + x

        yValue =
            yScale.highest - y
    in
        ( toScale xScale xValue, toScale yScale yValue )


collectPoints : Element msg -> List Point -> List Point
collectPoints element allPoints =
    case element of
        Area { points } ->
            allPoints ++ points

        Line { points } ->
            allPoints ++ points

        _ ->
            allPoints


{-| The parent to all your plot elements. Specify a list attributes as the first argument and a list
of plot elements as the second.


    attributes : List PlotAttr
    attributes =
        [ dimensions ( 300, 400 ) ]

    children : List (Element msg)
    children =
        [ line [ stroke "red" ] points
        , xAxis [ viewTick myCustomTick ]
        , yAxis []
        ]

    view =
        plot attributes children

-}
plot : List PlotAttr -> List (Element msg) -> Svg.Svg msg
plot attrs elements =
    Svg.Lazy.lazy2 viewPlot attrs elements


viewPlot : List PlotAttr -> List (Element msg) -> Svg.Svg msg
viewPlot attrs elements =
    let
        plotConfig =
            List.foldr (<|) defaultPlotConfig attrs

        ( width, height ) =
            plotConfig.size

        ( xValues, yValues ) =
            List.unzip (List.foldr collectPoints [] elements)

        xScale =
            getScales width ( 0, 0 ) xValues

        yScale =
            getScales height plotConfig.padding yValues

        toSvgCoordsX =
            toSvgCoords xScale yScale

        toSvgCoordsY =
            toSvgCoordsX << flipToY

        elementViews =
            List.foldr (viewElements xScale yScale toSvgCoordsX toSvgCoordsY) [] elements
    in
        viewFrame plotConfig elementViews



-- VIEW


viewElements : AxisScale -> AxisScale -> (Point -> Point) -> (Point -> Point) -> Element msg -> List (Svg.Svg msg) -> List (Svg.Svg msg)
viewElements xScale yScale toSvgCoordsX toSvgCoordsY element views =
    case element of
        Area config ->
            (viewArea toSvgCoordsX config) :: views

        Line config ->
            (viewLine toSvgCoordsX config) :: views

        Grid config ->
            let
                ( calculations, toSvgCoords ) =
                    fromDirection config.direction ( xScale, toSvgCoordsX ) ( yScale, toSvgCoordsY )
            in
                (viewGrid toSvgCoords calculations config) :: views

        Axis config ->
            let
                ( calculations, toSvgCoords ) =
                    fromDirection config.direction ( xScale, toSvgCoordsX ) ( yScale, toSvgCoordsY )
            in
                (viewAxis toSvgCoords calculations config) :: views



-- View frame


viewFrame : PlotConfig -> List (Svg.Svg msg) -> Svg.Svg msg
viewFrame { size, style } elements =
    let
        ( width, height ) =
            size
    in
        Svg.svg
            [ Svg.Attributes.height (toString height)
            , Svg.Attributes.width (toString width)
            , Svg.Attributes.style (toStyle style)
            ]
            elements



-- View axis


calulateTicks : AxisScale -> Float -> List Float
calulateTicks { highest, lowest } tickDelta =
    let
        lowestTick =
            toFloat (ceiling (lowest / tickDelta)) * tickDelta

        -- Prevent overflow
        steps =
            ceiling ((highest + abs lowestTick - tickDelta + 1) / tickDelta)

        toTick i =
            lowestTick + (toFloat i) * tickDelta
    in
        List.map toTick [0..steps]


getTicks : AxisScale -> TickConfig -> List Float
getTicks scale tickConfig =
    case tickConfig of
        TickTotal total ->
            let
                tickDelta =
                    calculateStep (scale.range / (toFloat total))
            in
                calulateTicks scale tickDelta

        TickDelta tickDelta ->
            calulateTicks scale tickDelta

        TickValues tickValues ->
            tickValues


viewAxis : (Point -> Point) -> AxisScale -> AxisConfig msg -> Svg.Svg msg
viewAxis toSvgCoords scale config =
    let
        { tickConfig, viewTick, viewLabel, axisStyle } =
            config

        ticks =
            getTicks scale tickConfig

        tickViews =
            List.map (viewTickInternal toSvgCoords viewTick) ticks

        labelViews =
            List.map (viewLabelInternal toSvgCoords viewLabel) ticks
    in
        Svg.g []
            [ viewGridLine toSvgCoords scale axisStyle 0
            , Svg.g [] tickViews
            , Svg.g [] labelViews
            ]



-- View tick


viewTickInternal : (Point -> Point) -> (Float -> Svg.Svg msg) -> Float -> Svg.Svg msg
viewTickInternal toSvgCoords viewTick tick =
    let
        position =
            toSvgCoords ( tick, 0 )
    in
        Svg.g
            [ Svg.Attributes.transform (toTranslate position) ]
            [ viewTick tick ]



-- View Label


viewLabelInternal : (Point -> Point) -> (Float -> Svg.Svg msg) -> Float -> Svg.Svg msg
viewLabelInternal toSvgCoords viewLabel tick =
    let
        position =
            toSvgCoords ( tick, 0 )
    in
        Svg.g
            [ Svg.Attributes.transform (toTranslate position) ]
            [ viewLabel tick ]



-- View grid


viewGrid : (Point -> Point) -> AxisScale -> GridConfig -> Svg.Svg msg
viewGrid toSvgCoords calculations { tickValues, style } =
    let
        lines =
            List.map (viewGridLine toSvgCoords calculations style) tickValues
    in
        Svg.g [] lines


viewGridLine : (Point -> Point) -> AxisScale -> List ( String, String ) -> Float -> Svg.Svg msg
viewGridLine toSvgCoords { lowest, highest } style tick =
    let
        ( x1, y1 ) =
            toSvgCoords ( lowest, tick )

        ( x2, y2 ) =
            toSvgCoords ( highest, tick )

        attrs =
            Svg.Attributes.style (toStyle style) :: (toPositionAttr x1 y1 x2 y2)
    in
        Svg.line attrs []



-- VIEW SERIES


viewArea : (Point -> Point) -> AreaConfig -> Svg.Svg a
viewArea toSvgCoords { points, style } =
    let
        range =
            List.map fst points

        ( lowestX, highestX ) =
            ( getLowest range, getHighest range )

        svgCoords =
            List.map toSvgCoords points

        ( highestSvgX, originY ) =
            toSvgCoords ( highestX, 0 )

        ( lowestSvgX, _ ) =
            toSvgCoords ( lowestX, 0 )

        startInstruction =
            toInstruction "M" [ lowestSvgX, originY ]

        endInstructions =
            toInstruction "L" [ highestSvgX, originY ]

        instructions =
            coordToInstruction "L" svgCoords
    in
        Svg.path
            [ Svg.Attributes.d (startInstruction ++ instructions ++ endInstructions ++ "Z")
            , Svg.Attributes.style (toStyle style)
            ]
            []


viewLine : (Point -> Point) -> LineConfig -> Svg.Svg a
viewLine toSvgCoords { points, style } =
    let
        svgPoints =
            List.map toSvgCoords points

        ( startInstruction, tail ) =
            startPath svgPoints

        instructions =
            coordToInstruction "L" svgPoints
    in
        Svg.path
            [ Svg.Attributes.d (startInstruction ++ instructions)
            , Svg.Attributes.style (toStyle style)
            ]
            []



-- Helpers


flipToY : Point -> Point
flipToY ( x, y ) =
    ( y, x )


fromDirection : Direction -> a -> a -> a
fromDirection direction x y =
    case direction of
        X ->
            x

        Y ->
            y
