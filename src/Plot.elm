module Plot
    exposing
        ( plot
        , size
        , padding
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
        , stroke
        , fill
        , Point
        , PlotAttr
        , Element
        , AxisAttr
        , GridAttr
        , SerieAttr
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
@docs Element, PlotAttr, AxisAttr, GridAttr, SerieAttr

# Plot
@docs plot

## Attributes
@docs size, padding

# Series
@docs Point, area, line

## Attributes
@docs stroke, fill

# Axis
@docs xAxis, yAxis

## Attributes
@docs tickList, stepSize, amountOfTicks, customViewTick, customViewLabel, axisLineStyle

# Grid
@docs horizontalGrid, verticalGrid

## Attributes
@docs gridStyle, gridTickList

-}

import Html exposing (Html, button, div, text)
import Html.Events exposing (on, onMouseOut)
import Html.Attributes exposing (id)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, d, style)
import String
import Debug
import Helpers exposing (..)


{-| Convinience type to represent coordinates
-}
type alias Point =
    ( Float, Float )


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
    , dimensions : Maybe (Float, Float)
    , padding : (Int, Int)
    , id : String
    }


{-| Represents an attribute for the plot.
-}
type PlotAttr
    = Dimensions (Maybe ( Float, Float ))
    | Padding (Int, Int)
    | Size ( Int, Int )
    | Id String


defaultPlotConfig =
    { size = ( 800, 500 )
    , dimensions = Nothing
    , padding = (10, 10)
    , id = "elm-plot"
    }


{-| Specify the coordinate dimensions of your plot.
-}
dimensions : Maybe ( Float, Float ) -> PlotAttr
dimensions =
    Dimensions


{-| Specify additional top padding on the y axis (in pixels)
-}
padding : (Int, Int) -> PlotAttr
padding =
    Padding


{-| Specify the width and height in pixels.
-}
size : (Int, Int) -> PlotAttr
size =
    Size


{-| Specify an id to the div wrapper of your plot.
-}
id : String -> PlotAttr
id =
    Id


toPlotConfig : PlotAttr -> PlotConfig -> PlotConfig
toPlotConfig attr config =
    case attr of
        Size size ->
            { config | size = size }

        Dimensions dimensions ->
            { config | dimensions = dimensions }
        
        Padding padding ->
            { config | padding = padding }
        
        Id id ->
            -- TODO: Should not be optional
            { config | id = id }



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
            fromOrientation axis ( 0, 22 ) ( -10, 5 )
    in
        Svg.text'
            [ Svg.Attributes.transform (toTranslate displacement)
            , Svg.Attributes.style (toStyle (style :: commonStyle))
            ]
            [ Svg.tspan [] [ Svg.text (toString tick) ] ]


defaultAxisConfig =
    { tickConfig = (TickStep 10)
    , customViewTick = defaultTickHtml X
    , customViewLabel = defaultLabelHtml X
    , axisLineStyle = [ ( "stroke", "#757575" ) ]
    , orientation = X
    }


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


toGridConfig : GridAttr -> GridConfig -> GridConfig
toGridConfig attr config =
    case attr of
        GridStyle styles ->
            { config | styles = styles }

        GridTicks ticks ->
            { config | ticks = ticks }


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



-- Serie config


type alias AreaConfig =
    { fill : String
    , stroke : String
    , points : List Point
    }


{-| Represents an attribute for the serie.
-}
type SerieAttr
    = Stroke String
    | Fill String


{-| Specify the stroke color.

    line [ stroke "blue" ]
-}
stroke : String -> SerieAttr
stroke =
    Stroke


{-| Specify the area fill color.

    area [ fill "red" ]

-}
fill : String -> SerieAttr
fill =
    Fill


defaultAreaConfig =
    { fill = "#ddd"
    , stroke = "#737373"
    , points = []
    }


toAreaConfig : SerieAttr -> AreaConfig -> AreaConfig
toAreaConfig attr config =
    case attr of
        Stroke stroke ->
            { config | stroke = stroke }

        Fill fill ->
            { config | fill = fill }


{-| Draws a area serie.

    area [] [ (2, 4), (3, 6), (5, 3.4) ]
-}
area : List SerieAttr -> List Point -> Element msg
area attrs points =
    let
        config =
            List.foldr toAreaConfig defaultAreaConfig attrs
    in
        Area { config | points = points }


type alias LineConfig =
    { stroke : String
    , points : List Point
    }


defaultLineConfig =
    { stroke = "#737373"
    , points = []
    }


toLineConfig : SerieAttr -> LineConfig -> LineConfig
toLineConfig attr config =
    case attr of
        Stroke stroke ->
            { config | stroke = stroke }

        _ ->
            config


{-| Draws a line serie.

    area [] [ (2, 3), (3, 8), (5, 7) ]
-}
line : List SerieAttr -> List Point -> Element msg
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


addEdgeValues : Int -> (Int, Int) -> List Float -> AxisCalulation -> AxisCalulation
addEdgeValues length (paddingBottom, paddingTop) values calculations =
    let
        lowestReal =
            getLowest values
            
        highestReal =
            getHighest values

        spanReal =
            abs lowestReal + abs highestReal

        paddingTopRelative =
            (spanReal * ((toFloat paddingTop) / (toFloat length)))

        paddingBottomRelative =
            (spanReal * ((toFloat paddingBottom) / (toFloat length)))

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


calculateAxis : Orientation -> Int -> (Int, Int) -> List Float -> AxisCalulation
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
    let
        plotConfig =
            List.foldr toPlotConfig defaultPlotConfig attrs

        ( width, height ) =
            plotConfig.size

        ( xValues, yValues ) =
            List.unzip (List.foldr collectPoints [] elements)

        xAxis =
            calculateAxis X width (0, 0) xValues

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
viewFrame { size, id } elements =
    let
        ( width, height ) =
            size
    in
        Html.div
            [ Html.Attributes.id id
            , Html.Attributes.style [ ( "margin", "50px" ), ( "position", "absolute" ) ]
            ]
            [ Svg.svg
                [ Svg.Attributes.height (toString height)
                , Svg.Attributes.width (toString width)
                ]
                elements
            ]



-- View axis


calulateTicks : AxisCalulation -> Float -> List Float
calulateTicks { span, lowest, highest } stepSize =
    let
        steps =
            round (span / stepSize)

        lowestTick =
            toFloat (ceiling (lowest / stepSize)) * stepSize

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
viewArea toSvgCoords { points, stroke, fill } =
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

        style' =
            String.join "" [ "stroke: ", stroke, "; fill:", fill ]
    in
        Svg.path
            [ d (startInstruction ++ instructions ++ endInstructions ++ "Z"), style style' ]
            []


viewLine : (Point -> Point) -> LineConfig -> Svg.Svg a
viewLine toSvgCoords { points, stroke } =
    let
        svgPoints =
            List.map toSvgCoords points

        ( startInstruction, tail ) =
            startPath svgPoints

        instructions =
            coordToInstruction "L" svgPoints

        style' =
            String.join "" [ "stroke: ", stroke, "; fill: none;" ]
    in
        Svg.path [ d (startInstruction ++ instructions), style style' ] []



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
