module Plot
    exposing
        ( plot
        , size
        , padding
        , plotStyle
        , area
        , line
        , horizontalGrid
        , verticalGrid
        , xAxis
        , yAxis
        , tickList
        , stepSize
        , amountOfTicks
        , customViewTick
        , customViewLabel
        , axisLineStyle
        , gridStyle
        , gridTickList
        , lineStyle
        , areaStyle
        , Point
        , PlotAttr
        , Element
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
            , xAxis [ customViewTick myCustomTick ]
            , yAxis [ tickList [ -20, 20, 40, 82 ] ]
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
@docs tickList, stepSize, amountOfTicks, customViewTick, customViewLabel, axisLineStyle

# Grid
@docs horizontalGrid, verticalGrid

## Attributes
@docs gridStyle, gridTickList

-}

import Html exposing (Html)
import Html.Events exposing (on, onMouseOut)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, d, style)
import Svg.Lazy
import String
import Debug
import Helpers exposing (..)


{-| Convenience type to represent coordinates
-}
type alias Point =
    ( Float, Float )


{-| Convenience type to represent style
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
type PlotAttr
    = Dimensions (Maybe ( Float, Float ))
    | Padding ( Int, Int )
    | Size ( Int, Int )
    | PlotStyle Style


defaultPlotConfig =
    { size = ( 800, 500 )
    , dimensions = Nothing
    , padding = ( 10, 10 )
    , style = [ ( "padding", "30px" ), ( "overflow", "hidden" ) ]
    }


{-| Specify the coordinate dimensions of your plot.
-}
dimensions : Maybe ( Float, Float ) -> PlotAttr
dimensions =
    Dimensions


{-| Specify padding on the y axis (in pixels)

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
padding : ( Int, Int ) -> PlotAttr
padding =
    Padding


{-| Specify the width and height in pixels.
-}
size : ( Int, Int ) -> PlotAttr
size =
    Size


{-| Specify a list of styles to apply to the svg element.
-}
plotStyle : List ( String, String ) -> PlotAttr
plotStyle =
    PlotStyle


toPlotConfig : PlotAttr -> PlotConfig -> PlotConfig
toPlotConfig attr config =
    case attr of
        Size size ->
            { config | size = size }

        Dimensions dimensions ->
            { config | dimensions = dimensions }

        Padding padding ->
            { config | padding = padding }

        PlotStyle style ->
            { config | style = style }



-- Axis config


type Orientation
    = X
    | Y


type TickConfig
    = TickStep Float
    | TickAmount Int
    | TickList (List Float)


type alias AxisConfig msg =
    { tickConfig : TickConfig
    , customViewTick : Float -> Svg.Svg msg
    , customViewLabel : Float -> Svg.Svg msg
    , axisLineStyle : Style
    , orientation : Orientation
    }


{-| Represents an attribute for the axis.
-}
type AxisAttr msg
    = TickConfigAttr TickConfig
    | ViewTick (Float -> Svg.Svg msg)
    | ViewLabel (Float -> Svg.Svg msg)
    | AxisLineStyle Style


defaultTickHtml : Orientation -> Float -> Svg.Svg msg
defaultTickHtml axis tick =
    let
        displacement =
            fromOrientation axis "" (toRotate 90 0 0)
    in
        Svg.line
            [ Svg.Attributes.style "stroke: #757575;"
            , Svg.Attributes.y2 "7"
            , Svg.Attributes.transform displacement
            ]
            []


defaultLabelHtml : Orientation -> Float -> Svg.Svg a
defaultLabelHtml axis tick =
    let
        commonStyle =
            [ ( "stroke", "#757575" ) ]

        style =
            fromOrientation axis ( "text-anchor", "middle" ) ( "text-anchor", "end" )

        displacement =
            fromOrientation axis ( 0, 24 ) ( -10, 5 )
    in
        Svg.text'
            [ Svg.Attributes.transform (toTranslate displacement)
            , Svg.Attributes.style (toStyle (style :: commonStyle))
            ]
            [ Svg.tspan [] [ Svg.text (toString tick) ] ]


defaultAxisConfig =
    { tickConfig = (TickAmount 10)
    , customViewTick = defaultTickHtml X
    , customViewLabel = defaultLabelHtml X
    , axisLineStyle = [ ( "stroke", "#757575" ) ]
    , orientation = X
    }


toAxisConfig : AxisAttr msg -> AxisConfig msg -> AxisConfig msg
toAxisConfig attr config =
    case attr of
        TickConfigAttr tickConfig ->
            { config | tickConfig = tickConfig }

        ViewTick viewTick ->
            { config | customViewTick = viewTick }

        ViewLabel viewLabel ->
            { config | customViewLabel = viewLabel }

        AxisLineStyle styles ->
            { config | axisLineStyle = styles }


{-| Specify a _guiding_ amount of ticks which the library will use to calculate "nice" axis values.

    xAxis [ amountOfTicks 5 ]

-}
amountOfTicks : Int -> AxisAttr msg
amountOfTicks amount =
    TickConfigAttr (TickAmount amount)


{-| Specify the step size between the ticks.

    xAxis [ stepSize 5 ]

-}
stepSize : Float -> AxisAttr msg
stepSize stepSize =
    TickConfigAttr (TickStep stepSize)


{-| Specify the list of ticks to be show in on the axis.

    xAxis [ tickList [ 10 25 32 47 ] ]

-}
tickList : List Float -> AxisAttr msg
tickList ticks =
    TickConfigAttr (TickList ticks)


{-| Specify the html to use for each tick. If you want to displace the tick, it
 can be recommended to use `Svg.Attributes.transform` in your tick view.

    myCustomTick : Float -> Svg.Svg a
    myCustomTick tick =
        Svg.text' [] [ Svg.tspan [] [ Svg.text "⚡️" ] ]


    view : Html msg
    view =
        plot [] [ xAxis [ customViewTick myCustomTick ] ]

-}
customViewTick : (Float -> Svg.Svg msg) -> AxisAttr msg
customViewTick =
    ViewTick


{-| Specify the html to use for each label.

    myCustomLabel : Float -> Svg.Svg a
    myCustomLabel tick =
        Svg.text' [] [ Svg.tspan [] [ Svg.text ((toString tick) ++ " ms") ] ]


    view : Html msg
    view =
        plot [] [ xAxis [ customViewLabel myCustomTick ] ]

-}
customViewLabel : (Float -> Svg.Svg msg) -> AxisAttr msg
customViewLabel =
    ViewLabel


{-| Specify style of the axis.

    yAxis [ axisLineStyle [ ( "stroke", "red" ) ] ]

-}
axisLineStyle : List ( String, String ) -> AxisAttr msg
axisLineStyle =
    AxisLineStyle


{-| Draws a x-axis.
-}
xAxis : List (AxisAttr msg) -> Element msg
xAxis attrs =
    Axis (List.foldr toAxisConfig defaultAxisConfig attrs)


{-| Draws a y-axis.
-}
yAxis : List (AxisAttr msg) -> Element msg
yAxis attrs =
    let
        defaultAxisConfigY =
            { defaultAxisConfig | orientation = Y, customViewLabel = defaultLabelHtml Y, customViewTick = defaultTickHtml Y }
    in
        Axis (List.foldr toAxisConfig defaultAxisConfigY attrs)



-- Grid config


type alias GridConfig =
    { ticks : List Float
    , styles : Style
    , orientation : Orientation
    }


{-| Represents an attribute for the grid.
-}
type GridAttr
    = GridStyle Style
    | GridTicks (List Float)


defaultGridConfig =
    { ticks = []
    , styles = [ ( "stroke", "#757575" ) ]
    , orientation = X
    }


toGridConfig : GridAttr -> GridConfig -> GridConfig
toGridConfig attr config =
    case attr of
        GridStyle styles ->
            { config | styles = styles }

        GridTicks ticks ->
            { config | ticks = ticks }


{-| Specify the styling for the grid.

    verticalGrid [ gridStyle [ ( "stroke", "#cee0e2" ) ] ]

-}
gridStyle : List ( String, String ) -> GridAttr
gridStyle =
    GridStyle


{-| Specify the styling for the grid.

    verticalGrid [ gridTickList [ 200, 400, 600 ] ]

**Note:** This will _eventually_ be changed to a Maybe type and will default to
align with whatever ticks are on your axis.
-}
gridTickList : List Float -> GridAttr
gridTickList =
    GridTicks


{-| Draws a vertical grid.

    verticalGrid [ gridTickList [ 10 40 90 ] ]
-}
verticalGrid : List GridAttr -> Element msg
verticalGrid attrs =
    Grid (List.foldr toGridConfig defaultGridConfig attrs)


{-| Draws  a horizontal grid.

    horizontalGrid [ gridTickList [ 20 30 40 ] ]
-}
horizontalGrid : List GridAttr -> Element msg
horizontalGrid attrs =
    let
        defaultGridConfigY =
            { defaultGridConfig | orientation = Y }
    in
        Grid (List.foldr toGridConfig defaultGridConfigY attrs)



-- Area config


type alias AreaConfig =
    { style : Style
    , points : List Point
    }


{-| Represents an attribute for the serie.
-}
type AreaAttr
    = AreaStyle Style


defaultAreaConfig =
    { style = [ ( "stroke", "#737373" ), ( "fill", "#ddd" ) ]
    , points = []
    }


toAreaConfig : AreaAttr -> AreaConfig -> AreaConfig
toAreaConfig attr config =
    case attr of
        AreaStyle style ->
            { config | style = style }


{-| Specify the area serie style.

    area [ areaStyle [ ( "stroke", "blue", "fill", "green" ) ] ]
-}
areaStyle : List ( String, String ) -> AreaAttr
areaStyle =
    AreaStyle


{-| Draws a area serie.

    area [] [ (2, 4), (3, 6), (5, 3.4) ]
-}
area : List AreaAttr -> List Point -> Element msg
area attrs points =
    let
        config =
            List.foldr toAreaConfig defaultAreaConfig attrs
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
type LineAttr
    = LineStyle Style


toLineConfig : LineAttr -> LineConfig -> LineConfig
toLineConfig attr config =
    case attr of
        LineStyle style ->
            { config | style = style }


{-| Specify the area serie style.

    line [ lineStyle [ ( "stroke", "blue" ) ] ]
-}
lineStyle : List ( String, String ) -> LineAttr
lineStyle style =
    LineStyle (( "fill", "transparent" ) :: style)


{-| Draws a line serie.

    area [] [ (2, 3), (3, 8), (5, 7) ]
-}
line : List LineAttr -> List Point -> Element msg
line attrs points =
    let
        config =
            List.foldr toLineConfig defaultLineConfig attrs
    in
        Line { config | points = points }



-- Calculations


type alias AxisCalulation =
    { span : Float
    , lowest : Float
    , highest : Float
    , toSvg : Float -> Float
    }


axisCalulationInit : AxisCalulation
axisCalulationInit =
    AxisCalulation 0 0 0 identity


addEdgeValues : Int -> ( Int, Int ) -> List Float -> AxisCalulation -> AxisCalulation
addEdgeValues length ( paddingBottom, paddingTop ) values calculations =
    let
        lowestReal =
            getLowest values

        highestReal =
            getHighest values

        spanReal =
            abs lowestReal + abs highestReal

        paddingTopRelative =
            spanReal * (toFloat paddingTop) / (toFloat length)

        paddingBottomRelative =
            spanReal * (toFloat paddingBottom) / (toFloat length)

        lowest =
            lowestReal - paddingBottomRelative

        highest =
            highestReal + paddingTopRelative

        span =
            spanReal + paddingBottomRelative + paddingTopRelative
    in
        { calculations | lowest = lowest, highest = highest, span = span }


addToSvg : Orientation -> Int -> AxisCalulation -> AxisCalulation
addToSvg orientation length calculations =
    let
        { span, lowest, highest } =
            calculations

        smallestValue =
            fromOrientation orientation lowest highest

        delta =
            toFloat length / span

        toSvg v =
            (abs smallestValue * delta) + delta * v
    in
        { calculations | toSvg = toSvg }


calculateAxis : Orientation -> Int -> ( Int, Int ) -> List Float -> AxisCalulation
calculateAxis orientation length padding values =
    axisCalulationInit
        |> addEdgeValues length padding values
        |> addToSvg orientation length


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
        , xAxis [ customViewTick myCustomTick ]
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
            List.foldr toPlotConfig defaultPlotConfig attrs

        ( width, height ) =
            plotConfig.size

        ( xValues, yValues ) =
            List.unzip (List.foldr collectPoints [] elements)

        xAxis =
            calculateAxis X width ( 0, 0 ) xValues

        yAxis =
            calculateAxis Y height plotConfig.padding yValues

        toSvgCoordsX ( x, y ) =
            ( xAxis.toSvg x, yAxis.toSvg -y )

        toSvgCoordsY =
            toSvgCoordsX << flipToY

        elementViews =
            List.foldr (viewElements xAxis yAxis toSvgCoordsX toSvgCoordsY) [] elements
    in
        viewFrame plotConfig elementViews



-- VIEW


viewElements : AxisCalulation -> AxisCalulation -> (Point -> Point) -> (Point -> Point) -> Element msg -> List (Svg.Svg msg) -> List (Svg.Svg msg)
viewElements xAxis yAxis toSvgCoordsX toSvgCoordsY element views =
    case element of
        Area config ->
            (viewArea toSvgCoordsX config) :: views

        Line config ->
            (viewLine toSvgCoordsX config) :: views

        Grid config ->
            let
                ( calculations, toSvgCoords ) =
                    fromOrientation config.orientation ( xAxis, toSvgCoordsX ) ( yAxis, toSvgCoordsY )
            in
                (viewGrid toSvgCoords calculations config) :: views

        Axis config ->
            let
                ( calculations, toSvgCoords ) =
                    fromOrientation config.orientation ( xAxis, toSvgCoordsX ) ( yAxis, toSvgCoordsY )
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


calulateTicks : AxisCalulation -> Float -> List Float
calulateTicks { span, lowest, highest } stepSize =
    let
        lowestTick =
            toFloat (ceiling (lowest / stepSize)) * stepSize

        -- Prevent overflow
        steps =
            ceiling ((span - (abs lowest - abs lowestTick) - stepSize + 1) / stepSize)

        toTick i =
            lowestTick + (toFloat i) * stepSize
    in
        List.map toTick [0..steps]


getTicks : AxisCalulation -> TickConfig -> List Float
getTicks calculations tickConfig =
    case tickConfig of
        TickAmount amount ->
            let
                stepSize =
                    calculateStep (calculations.span / (toFloat amount))
            in
                calulateTicks calculations stepSize

        TickStep stepSize ->
            calulateTicks calculations stepSize

        TickList ticks ->
            ticks


viewAxis : (Point -> Point) -> AxisCalulation -> AxisConfig msg -> Svg.Svg msg
viewAxis toSvgCoords calculations config =
    let
        { tickConfig, customViewTick, customViewLabel, axisLineStyle } =
            config

        ticks =
            getTicks calculations tickConfig

        tickViews =
            List.map (viewTick toSvgCoords customViewTick) ticks

        labelViews =
            List.map (viewLabel toSvgCoords customViewLabel) ticks
    in
        Svg.g []
            [ viewGridLine toSvgCoords calculations axisLineStyle 0
            , Svg.g [] tickViews
            , Svg.g [] labelViews
            ]



-- View tick


viewTick : (Point -> Point) -> (Float -> Svg.Svg msg) -> Float -> Svg.Svg msg
viewTick toSvgCoords customViewTick tick =
    let
        position =
            toSvgCoords ( tick, 0 )
    in
        Svg.g
            [ Svg.Attributes.transform (toTranslate position) ]
            [ customViewTick tick ]



-- View Label


viewLabel : (Point -> Point) -> (Float -> Svg.Svg msg) -> Float -> Svg.Svg msg
viewLabel toSvgCoords viewLabel tick =
    let
        position =
            toSvgCoords ( tick, 0 )
    in
        Svg.g
            [ Svg.Attributes.transform (toTranslate position) ]
            [ viewLabel tick ]



-- View grid


viewGrid : (Point -> Point) -> AxisCalulation -> GridConfig -> Svg.Svg msg
viewGrid toSvgCoords calculations { ticks, styles } =
    let
        lines =
            List.map (viewGridLine toSvgCoords calculations styles) ticks
    in
        Svg.g [] lines


viewGridLine : (Point -> Point) -> AxisCalulation -> List ( String, String ) -> Float -> Svg.Svg msg
viewGridLine toSvgCoords { lowest, highest } styles tick =
    let
        ( x1, y1 ) =
            toSvgCoords ( lowest, tick )

        ( x2, y2 ) =
            toSvgCoords ( highest, tick )

        attrs =
            Svg.Attributes.style (toStyle styles) :: (toPositionAttr x1 y1 x2 y2)
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


fromOrientation : Orientation -> a -> a -> a
fromOrientation orientation x y =
    case orientation of
        X ->
            x

        Y ->
            y
