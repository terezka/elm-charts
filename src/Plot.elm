module Plot
    exposing
        ( plot
        , size
        , padding
        , plotStyle

        , tickValues
        , tickSequence
        , tickAutoValues
        , tickViewConfig
        , tickCustomView
        , tickLabelFormat
        , tickLabelCustomView

        , gridLinesStyle
        , gridZeroLineStyle
        , gridValues
        , gridAutoValues
        , gridNoZeroLine

        , area
        , areaStyle

        , line
        , lineStyle

        , Point
        , MetaAttr
        , TicksAttr
        , GridAttr
        , AreaAttr
        , LineAttr
        )

{-| Elm-Plot

# Definition
@docs plot

# Rest
@docs size, padding, plotStyle, tickValues, tickSequence, tickAutoValues, tickViewConfig, tickCustomView, tickLabelFormat, tickLabelCustomView, gridLinesStyle, gridZeroLineStyle, gridValues, gridAutoValues, gridNoZeroLine, area, areaStyle, line, lineStyle, Point, MetaAttr, TicksAttr, GridAttr, AreaAttr, LineAttr

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


type alias Plot msg =
    { meta : List MetaAttr
    , xGrid : List GridAttr
    , yGrid : List GridAttr
    , xTicks : List (TicksAttr msg)
    , yTicks : List (TicksAttr msg)
    , series : List Serie
    }


type alias PlotConfig msg =
    { meta : MetaConfig
    , xGrid : GridConfig
    , yGrid : GridConfig
    , xTicks : TicksConfig msg
    , yTicks : TicksConfig msg
    , series : List Serie
    }


type Serie
    = Line LineConfig
    | Area AreaConfig



-- META CONFIG


type alias MetaConfig =
    { size : ( Int, Int )
    , padding : ( Int, Int )
    , style : Style
    }



{-| -}
type alias MetaAttr =
    MetaConfig -> MetaConfig


defaultMetaConfig =
    { size = ( 800, 500 )
    , padding = ( 20, 20 )
    , style = [ ( "padding", "30px" ), ( "overflow", "hidden" ), ( "stroke", "#aaa" ), ( "fill", "#aaa" ) ]
    }


{-| -}
padding : ( Int, Int ) -> MetaConfig -> MetaConfig
padding padding config =
    { config | padding = padding }


{-| -}
size : ( Int, Int ) -> MetaConfig -> MetaConfig
size size config =
    { config | size = size }


{-| -}
plotStyle : List ( String, String ) -> MetaConfig -> MetaConfig
plotStyle style config =
    { config | style = style }


toMetaConfig : List MetaAttr -> MetaConfig
toMetaConfig attrs =
    List.foldr (<|) defaultMetaConfig attrs



-- TICKS CONFIG


type alias TickStyleConfig =
    { length : Int
    , width : Int
    , style : Style
    }


type TickView msg
    = TickCustomView (Float -> Svg.Svg msg)
    | TickConfigView TickStyleConfig


type TickValues
    = TickSequence ( Float, Float )
    | TickCustomValues (List Float)
    | TickAppxTotal Int
    | TickAutoValues


type TickLabelView msg
    = TickLabelFormat (Float -> String)
    | TickLabelCustomView (Float -> Svg.Svg msg)


type alias TicksConfig msg =
    { values : TickValues
    , labelView : TickLabelView msg
    , tickView : TickView msg
    }


{-| -}
type alias TicksAttr msg =
    TicksConfig msg -> TicksConfig msg


defaultTickStyle =
    { length = 7
    , width = 1
    , style = []
    }


defaultTickConfig =
    { values = TickAutoValues
    , labelView = TickLabelFormat toString
    , tickView = TickConfigView defaultTickStyle
    }


{-| -}
tickAutoValues : TicksConfig msg -> TicksConfig msg
tickAutoValues config =
    { config | values = TickAutoValues }


{-| -}
tickValues : List Float -> TicksConfig msg -> TicksConfig msg
tickValues values config =
    { config | values = TickCustomValues values }


{-| -}
tickSequence : ( Float, Float ) -> TicksConfig msg -> TicksConfig msg
tickSequence sequenceConfig config =
    { config | values = TickSequence sequenceConfig }


{-| -}
tickViewConfig : ( Int, Int, Style ) -> TicksConfig msg -> TicksConfig msg
tickViewConfig ( length, width, style ) config =
    { config | tickView = TickConfigView { length = length, width = width, style = style } }


{-| -}
tickCustomView : (Float -> Svg.Svg msg) -> TicksConfig msg -> TicksConfig msg
tickCustomView view config =
    { config | tickView = TickCustomView view }


{-| -}
tickLabelFormat : (Float -> String) -> TicksConfig msg -> TicksConfig msg
tickLabelFormat formatter config =
    { config | labelView = TickLabelFormat formatter }


{-| -}
tickLabelCustomView : (Float -> Svg.Svg msg) -> TicksConfig msg -> TicksConfig msg
tickLabelCustomView view config =
    { config | labelView = TickLabelCustomView view }


toTicksConfig : List (TicksAttr msg) -> TicksConfig msg
toTicksConfig attrs =
    List.foldr (<|) defaultTickConfig attrs



-- GRID CONFIG


type GridValues
    = GridMirrorTicks
    | GridCustomValues (List Float)


type GridZeroLine
    = GridNoZeroLine
    | GridZeroLineStyle Style


type alias GridConfig =
    { values : GridValues
    , lineStyle : Style
    , zeroLine : GridZeroLine
    }    


{-| -}
type alias GridAttr =
    GridConfig -> GridConfig


defaultGridConfig =
    { values = GridCustomValues []
    , lineStyle = []
    , zeroLine = GridZeroLineStyle []
    }


{-| -}
gridAutoValues : GridConfig -> GridConfig
gridAutoValues config =
    { config | values = GridMirrorTicks }


{-| -}
gridValues : List Float -> GridConfig -> GridConfig
gridValues values config =
    { config | values = GridCustomValues values }


{-| -}
gridLinesStyle : Style -> GridConfig -> GridConfig
gridLinesStyle style config =
    { config | lineStyle = style }


{-| -}
gridNoZeroLine : GridConfig -> GridConfig
gridNoZeroLine config =
    { config | zeroLine = GridNoZeroLine }


{-| -}
gridZeroLineStyle : Style -> GridConfig -> GridConfig
gridZeroLineStyle style config =
    { config | zeroLine = GridZeroLineStyle style }


toGridConfig : List GridAttr -> GridConfig
toGridConfig attrs =
    List.foldr (<|) defaultGridConfig attrs



-- SERIES CONFIG


-- Area config


type alias AreaConfig =
    { style : Style
    , points : List Point
    }


{-| -}
type alias AreaAttr =
    AreaConfig -> AreaConfig


defaultAreaConfig =
    { style = [ ( "stroke", "#737373" ), ( "fill", "#ddd" ) ]
    , points = []
    }


{-| -}
areaStyle : List ( String, String ) -> AreaConfig -> AreaConfig
areaStyle style config =
    { config | style = style }


{-| -}
area : List AreaAttr -> List Point -> Serie
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


{-| -}
type alias LineAttr =
    LineConfig -> LineConfig


{-| -}
lineStyle : List ( String, String ) -> LineConfig -> LineConfig
lineStyle style config =
    { config | style = ( "fill", "transparent" ) :: style }


{-| -}
line : List LineAttr -> List Point -> Serie
line attrs points =
    let
        config =
            List.foldr (<|) defaultLineConfig attrs
    in
        Line { config | points = points }




-- PARSE PLOT


{-| -}
plot : Plot msg -> Svg.Svg msg
plot plot =
    Svg.Lazy.lazy parsePlot plot


parsePlot : Plot msg -> Svg.Svg msg
parsePlot { meta, xTicks, yTicks, xGrid, yGrid, series } =
    let
        plotConfig =
            { meta = toMetaConfig meta 
            , xTicks = toTicksConfig xTicks
            , yTicks = toTicksConfig yTicks
            , xGrid = toGridConfig xGrid
            , yGrid = toGridConfig yGrid
            , series = series
            }

        plotScales =
            getPlotScales plotConfig
    in
        viewPlot plotScales plotConfig



-- VIEW


viewPlot : PlotScales -> PlotConfig msg -> Svg.Svg msg
viewPlot plotProps { meta, xGrid, yGrid, xTicks, yTicks, series } =
    viewFrame meta 
        [ viewGrid plotProps xGrid 
        , viewGrid (flipToY plotProps) yGrid
        , Svg.g [] (List.map (viewSerie plotProps) series)
        , viewTicks plotProps xTicks
        , viewTicks (flipToY plotProps) yTicks
        ]



-- VIEW FRAME


viewFrame : MetaConfig -> List (Svg.Svg msg) -> Svg.Svg msg
viewFrame { size, style } children =
    let
        ( width, height ) =
            size
    in
        Svg.svg
            [ Svg.Attributes.height (toString height)
            , Svg.Attributes.width (toString width)
            , Svg.Attributes.style (toStyle style)
            ]
            children



-- VIEW TICKS


viewTicks : PlotScales -> TicksConfig msg -> Svg.Svg msg
viewTicks plotProps config =
    let
        { tickView, labelView } =
            config

        tickViews =
            List.map (viewTick plotProps tickView) plotProps.tickValues

        labelViews =
            List.map (viewLabel plotProps labelView) plotProps.tickValues
    in
        Svg.g []
            [ Svg.g [] tickViews
            , Svg.g [] labelViews
            ]


-- Tick


defaultTickView : TickStyleConfig -> Float -> Svg.Svg msg
defaultTickView { length, width, style } _ =
    Svg.line
        [ Svg.Attributes.style (toStyle style)
        , Svg.Attributes.x1 (toString width)
        , Svg.Attributes.x2 (toString width)
        , Svg.Attributes.y2 (toString length)
        ]
        []


viewTick : PlotScales -> TickView msg -> Float -> Svg.Svg msg
viewTick { toSvgCoords } viewTick tick =
    let
        position =
            toSvgCoords ( tick, 0 )

        innerTick =
            case viewTick of
                TickConfigView config ->
                    defaultTickView config

                TickCustomView view ->
                    view
    in
        Svg.g
            [ Svg.Attributes.transform (toTranslate position) ]
            [ innerTick tick ]



-- Label


defaultLabelView : (Float -> String) -> Float -> Svg.Svg msg
defaultLabelView format tick =
    Svg.text' [] [ Svg.tspan [] [ Svg.text (format tick) ] ]


viewLabel : PlotScales -> TickLabelView msg -> Float -> Svg.Svg msg
viewLabel { toSvgCoords } viewLabel tick =
    let
        position =
            toSvgCoords ( tick, 0 )

        innerLabel =
            case viewLabel of
                TickLabelFormat format ->
                    defaultLabelView format

                TickLabelCustomView view ->
                    view
    in
        Svg.g
            [ Svg.Attributes.transform (toTranslate position) ]
            [ innerLabel tick ]



-- VIEW GRID


getGridPositions : PlotScales -> GridConfig -> List Float
getGridPositions { oppositeTickValues } { values } =
    case values of
        GridMirrorTicks ->
            oppositeTickValues

        GridCustomValues positions ->
            positions


getGridZeroLineStyle : GridConfig -> Style
getGridZeroLineStyle { lineStyle, zeroLine } =
    case zeroLine of
        GridZeroLineStyle style ->
            style

        GridNoZeroLine ->
            [ ( "stroke", "transparent" ), ( "fill", "transparent" ) ]


viewGrid : PlotScales -> GridConfig -> Svg.Svg msg
viewGrid plotProps config =
    let
        positions =
            getGridPositions plotProps config

        zeroLineStyle =
            getGridZeroLineStyle config
    in
        Svg.g
            [] 
            [ Svg.g [] (List.map (viewGridLine plotProps config.lineStyle) positions)
            , viewGridLine plotProps zeroLineStyle 0
            ]


viewGridLine : PlotScales -> Style -> Float -> Svg.Svg msg
viewGridLine { toSvgCoords, scale } style position =
    let
        { lowest, highest } =
            scale

        ( x1, y1 ) =
            toSvgCoords ( lowest, position )

        ( x2, y2 ) =
            toSvgCoords ( highest, position )

        attrs =
            Svg.Attributes.style (toStyle style) :: (toPositionAttr x1 y1 x2 y2)
    in
        Svg.line attrs []



-- VIEW SERIES


viewSerie : PlotScales -> Serie -> Svg.Svg a
viewSerie plotScales serie =
    case serie of
        Line config ->
            viewLine plotScales config

        Area config ->
            viewArea plotScales config


viewArea : PlotScales -> AreaConfig -> Svg.Svg a
viewArea { toSvgCoords } { points, style } =
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


viewLine : PlotScales -> LineConfig -> Svg.Svg a
viewLine { toSvgCoords } { points, style } =
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



-- CALCULATIONS


type alias AxisScale =
    { range : Float
    , lowest : Float
    , highest : Float
    , length : Float
    }


type alias PlotScales =
    { scale : AxisScale
    , oppositeScale : AxisScale
    , tickValues : List Float
    , oppositeTickValues : List Float
    , toSvgCoords : Point -> Point
    }


-- SCALES


getScales : Int -> ( Int, Int ) -> List Float -> AxisScale
getScales length ( paddingBottomPx, paddingTopPx ) values =
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


scaleValue : AxisScale -> Float -> Float
scaleValue { length, range } v =
    v * length / range


toSvgCoordsX : AxisScale -> AxisScale -> Point -> Point
toSvgCoordsX xScale yScale ( x, y ) =
    ( scaleValue xScale (abs xScale.lowest + x), scaleValue yScale (yScale.highest - y) )


toSvgCoordsY : AxisScale -> AxisScale -> Point -> Point
toSvgCoordsY xScale yScale ( x, y ) =
    toSvgCoordsX xScale yScale ( y, x )


getPlotScales : PlotConfig msg -> PlotScales
getPlotScales { meta, xTicks, yTicks, series } =
    let
        ( xValues, yValues ) =
            List.unzip (List.foldr collectPoints [] series)

        ( width, height ) =
            meta.size

        xScale =
            getScales width ( 0, 0 ) xValues

        yScale =
            getScales height meta.padding yValues

        xTickValues = 
            getTickValues xScale xTicks

        yTickValues = 
            getTickValues yScale yTicks
    in
        { scale = xScale
        , oppositeScale = yScale
        , tickValues = xTickValues
        , oppositeTickValues = yTickValues
        , toSvgCoords = toSvgCoordsX xScale yScale
        }


flipToY : PlotScales -> PlotScales
flipToY { scale, oppositeScale, tickValues, oppositeTickValues } =
    { scale = oppositeScale
    , oppositeScale = scale
    , tickValues = oppositeTickValues
    , oppositeTickValues = tickValues
    , toSvgCoords = toSvgCoordsY scale oppositeScale
    }



-- TICKS


getTick0 : AxisScale -> Float -> Float
getTick0 { lowest } delta =
    roundBy delta lowest


getTotalSteps : AxisScale -> Float -> Float -> Int
getTotalSteps { range, lowest } tick0 delta =
    floor ( (range - (abs lowest - abs tick0)) / delta )


getAppxStep : AxisScale -> Int -> Float
getAppxStep { range } total =
    range / (toFloat total)


getTickFromSteps : Int -> Float -> Float -> List Float
getTickFromSteps steps tick0 delta =
    List.map (\v -> tick0 + (toFloat v) * delta) [0..steps]


getTickValues : AxisScale -> TicksConfig msg -> List Float
getTickValues scale config =
    case config.values of
        TickSequence ( tick0, delta ) ->
            let
                steps = 
                    getTotalSteps scale tick0 delta
            in
                getTickFromSteps steps tick0 delta

        TickCustomValues ticks ->
            ticks

        TickAppxTotal total ->
            let
                delta =
                    getTickDelta (getAppxStep scale total) 

                tick0 =
                    getTick0 scale delta

                steps = 
                    getTotalSteps scale tick0 delta
            in
                getTickFromSteps steps tick0 delta

        TickAutoValues ->
            let
                delta =
                    getTickDelta (getAppxStep scale 10) 

                tick0 =
                    getTick0 scale delta

                steps = 
                    getTotalSteps scale tick0 delta
            in
                getTickFromSteps steps tick0 delta



-- Collect points


collectPoints : Serie -> List Point -> List Point
collectPoints serie allPoints =
    case serie of
        Area { points } ->
            allPoints ++ points

        Line { points } ->
            allPoints ++ points

