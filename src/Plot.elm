module Plot
    exposing
        ( plot

        , size
        , padding
        , plotStyle

        , xAxis
        , yAxis

        , axisStyle
        , tickValues
        , tickSequence
        , tickAutoValues
        , tickViewConfig
        , tickCustomView
        , tickRemoveZero

        , labelFormat
        , labelCustomView

        , gridValues
        , gridStyle
        , gridMirrorTicks

        , area
        , areaStyle
        , line
        , lineStyle

        , Element
        , MetaAttr
        , AxisAttr
        , AreaAttr
        , LineAttr
        , Point
        , Style
        )

{-| Elm-Plot

# Elements
@docs Element, plot, line, area, xAxis, yAxis, Point, Style

# Configuration

## Meta configuration
@docs MetaAttr, size, padding, plotStyle

## Line configuration
@docs LineAttr, lineStyle

## Area configuration
@docs AreaAttr, areaStyle

## Axis configuration
@docs AxisAttr, axisStyle

### Tick configuration
@docs tickValues, tickSequence, tickAutoValues, tickRemoveZero, tickViewConfig, tickCustomView

### Label configuration
@docs labelFormat, labelCustomView

### Grid configuration
@docs gridValues, gridStyle, gridMirrorTicks

-}

import Html exposing (Html)
import Html.Events exposing (on, onMouseOut)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, d, style)
import Svg.Lazy
import String
import Debug
import Helpers exposing (..)


{-| Convinience type to represent coordinates.
-}
type alias Point =
    ( Float, Float )


{-| Convinience type to represent style.
-}
type alias Style =
    List ( String, String )



-- CONFIGS


{-| Represents child element of the plot.
-}
type Element msg
    = Axis (AxisConfig msg)
    | Line LineConfig
    | Area AreaConfig



-- META CONFIG


type alias MetaConfig =
    { size : ( Int, Int )
    , padding : ( Int, Int )
    , style : Style
    }


{-| The type representing an a meta configuration.
-}
type alias MetaAttr =
    MetaConfig -> MetaConfig


defaultMetaConfig =
    { size = ( 800, 500 )
    , padding = ( 40, 40 )
    , style = [ ( "padding", "30px" ), ( "overflow", "hidden" ), ( "stroke", "#000" ) ]
    }


{-| Add padding to your plot, meaning extra space below
 and above the lowest and highest point in your plot.
 The unit is pixels.
-}
padding : ( Int, Int ) -> MetaConfig -> MetaConfig
padding padding config =
    { config | padding = padding }


{-| Specify the size of your plot in pixels.
-}
size : ( Int, Int ) -> MetaConfig -> MetaConfig
size size config =
    { config | size = size }


{-| Add styles to the svg element.
-}
plotStyle : Style -> MetaConfig -> MetaConfig
plotStyle style config =
    { config | style = style }


toMetaConfig : List MetaAttr -> MetaConfig
toMetaConfig attrs =
    List.foldr (<|) defaultMetaConfig attrs



-- AXIS CONFIG


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
    | TickCustomValues ( List Float )
    | TickAppxTotal Int
    | TickAutoValues


type LabelView msg
    = LabelFormat (Float -> String)
    | LabelCustomView (Float -> Svg.Svg msg)


type GridValues
    = GridMirrorTicks
    | GridCustomValues (List Float)


type Orientation = X | Y


type alias AxisConfig msg =
    { tickValues : TickValues
    , tickView : TickView msg
    , labelView : LabelView msg
    , gridValues : GridValues
    , gridStyle : Style
    , style : Style
    , orientation : Orientation
    , axisCrossing : Bool
    }


{-| -}
type alias AxisAttr msg =
    AxisConfig msg -> AxisConfig msg


defaultTickStyleX =
    { length = 7
    , width = 1
    , style = []
    }


defaultAxisConfig =
    { tickValues = TickAutoValues
    , tickView = TickConfigView defaultTickStyleX
    , labelView = LabelFormat toString
    , gridValues = GridCustomValues []
    , gridStyle = []
    , style = []
    , axisCrossing = False
    , orientation = X
    }



{-| Add styling to the axis line.
-}
axisStyle : Style -> AxisConfig msg -> AxisConfig msg
axisStyle style config =
    { config | style = style }


{-| Lets the library calculate some nice round values.
-}
tickAutoValues : AxisConfig msg -> AxisConfig msg
tickAutoValues config =
    { config | tickValues = TickAutoValues }


{-| Specify a list of ticks.
-}
tickValues : List Float -> AxisConfig msg -> AxisConfig msg
tickValues values config =
    { config | tickValues = TickCustomValues values }


{-| Specify the ( firstTick, delta ) to define a sequence.
-}
tickSequence : ( Float, Float ) -> AxisConfig msg -> AxisConfig msg
tickSequence sequenceConfig config =
    { config | tickValues = TickSequence sequenceConfig }


{-| Specify lenght, width and style of your ticks. -}
tickViewConfig : ( Int, Int, Style ) -> AxisConfig msg -> AxisConfig msg
tickViewConfig ( length, width, style ) config =
    { config | tickView = TickConfigView { length = length, width = width, style = style } }


{-| Specify how the tick should be rendered.
-}
tickCustomView : (Float -> Svg.Svg msg) -> AxisConfig msg -> AxisConfig msg
tickCustomView view config =
    { config | tickView = TickCustomView view }


{-| Remove tick at origin. Useful when two axis' are crossing and you do not
 want the origin the be cluttered with labels.
-}
tickRemoveZero : AxisConfig msg -> AxisConfig msg
tickRemoveZero config =
    { config | axisCrossing = True }


{-| Specify a format for label.
-}
labelFormat : (Float -> String) -> AxisConfig msg -> AxisConfig msg
labelFormat formatter config =
    { config | labelView = LabelFormat formatter }


{-| Add a custom view for rendering your label.
-}
labelCustomView : (Float -> Svg.Svg msg) -> AxisConfig msg -> AxisConfig msg
labelCustomView view config =
    { config | labelView = LabelCustomView view }


{-| Adds grid lines where the ticks on the corresponding axis are.
-}
gridMirrorTicks : AxisConfig msg -> AxisConfig msg
gridMirrorTicks config =
    { config | gridValues = GridMirrorTicks }


{-| Specify a list of ticks where you want grid lines drawn.
-}
gridValues : List Float -> AxisConfig msg -> AxisConfig msg
gridValues values config =
    { config | gridValues = GridCustomValues values }


{-| Specify styles for the gridlines.
-}
gridStyle : Style -> AxisConfig msg -> AxisConfig msg
gridStyle style config =
    { config | gridStyle = style }


{-| -}
xAxis : List (AxisAttr msg) -> Element msg
xAxis attrs =
    Axis (List.foldr (<|) defaultAxisConfig attrs)


{-| -}
yAxis : List (AxisAttr msg) -> Element msg
yAxis attrs =
    Axis (List.foldr (<|) { defaultAxisConfig | orientation = Y } attrs)



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
areaStyle : Style -> AreaConfig -> AreaConfig
areaStyle style config =
    { config | style = style }


{-| -}
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


{-| -}
type alias LineAttr =
    LineConfig -> LineConfig


{-| -}
lineStyle : Style -> LineConfig -> LineConfig
lineStyle style config =
    { config | style = ( "fill", "transparent" ) :: style }


{-| -}
line : List LineAttr -> List Point -> Element msg
line attrs points =
    let
        config =
            List.foldr (<|) defaultLineConfig attrs
    in
        Line { config | points = points }



-- PARSE PLOT


{-| -}
plot : List MetaAttr -> List (Element msg) -> Svg.Svg msg
plot attr elements =
    Svg.Lazy.lazy2 parsePlot attr elements


parsePlot : List MetaAttr -> List (Element msg) -> Svg.Svg msg
parsePlot attr elements =
    let
        metaConfig =
            toMetaConfig attr

        scales =
            getPlotScales metaConfig elements
    in
        viewPlot metaConfig (viewElements scales elements)



-- VIEW


viewPlot : MetaConfig -> List (Svg.Svg msg) -> Svg.Svg msg
viewPlot { size, style } children =
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



-- VIEW ELEMENTS


viewElements : PlotScales -> List (Element msg) -> List (Svg.Svg msg)
viewElements scales elements =
    List.foldr (viewElement scales) [] elements


viewElement : PlotScales -> Element msg -> List (Svg.Svg msg) -> List (Svg.Svg msg)
viewElement scales element views =
    case element of
        Axis config ->
            let
                axisScales =
                    case config.orientation of
                        X ->
                            scales

                        Y ->
                            flipToY scales
            in
                (viewAxis axisScales config) :: views

        Line config ->
            (viewLine scales config) :: views

        Area config ->
            (viewArea scales config) :: views



-- VIEW AXIS


viewAxis : PlotScales -> AxisConfig msg -> Svg.Svg msg
viewAxis scales { tickValues, tickView, labelView, gridStyle, gridValues, style, axisCrossing, orientation } =
    let
        positions =
            getTickValues scales.scale tickValues

        tickPositions =
            if axisCrossing then List.filter (\p -> p /= 0) positions else positions

        gridPositions =
            getGridPositions tickPositions gridValues

        innerTick =
            case tickView of
                TickConfigView viewConfig ->
                    defaultTickView orientation viewConfig

                TickCustomView view ->
                    view

        innerLabel =
            case labelView of
                LabelFormat format ->
                    defaultLabelView orientation format

                LabelCustomView view ->
                    view
    in
        Svg.g []
            [ Svg.g [] (List.map (viewGridLine scales gridStyle) gridPositions)
            , viewGridLine scales style 0
            , Svg.g [] (List.map (viewTickWrap scales innerTick) tickPositions)
            , Svg.g [] (List.map (viewLabelWrap scales innerLabel) tickPositions)
            ]



-- View tick


defaultTickView : Orientation -> TickStyleConfig -> Float -> Svg.Svg msg
defaultTickView orientation { length, width, style } _ =
    let
        displacement =
            fromOrientation orientation "" (toRotate 90 0 0)
    in
        Svg.line
            [ Svg.Attributes.style (toStyle style)
            , Svg.Attributes.x1 (toString width)
            , Svg.Attributes.x2 (toString width)
            , Svg.Attributes.y2 (toString length)
            , Svg.Attributes.transform displacement
            ]
            []


viewTickWrap : PlotScales -> (Float -> Svg.Svg msg) -> Float -> Svg.Svg msg
viewTickWrap { toSvgCoords } innerTick tick =
    let
        position =
            toSvgCoords ( tick, 0 )
    in
        Svg.g
            [ Svg.Attributes.transform (toTranslate position) ]
            [ innerTick tick ]



-- View label


defaultLabelView : Orientation -> (Float -> String) -> Float -> Svg.Svg msg
defaultLabelView orientation format tick =
    let
        commonStyle =
            [ ( "stroke", "#757575" ) ]

        style =
            fromOrientation orientation ( "text-anchor", "middle" ) ( "text-anchor", "end" )

        displacement =
            fromOrientation orientation ( 0, 24 ) ( -10, 5 )
    in
        Svg.text'
            [ Svg.Attributes.transform (toTranslate displacement)
            , Svg.Attributes.style (toStyle (style :: commonStyle))
            ]
            [ Svg.tspan [] [ Svg.text (format tick) ] ]


viewLabelWrap : PlotScales -> (Float -> Svg.Svg msg) -> Float -> Svg.Svg msg
viewLabelWrap { toSvgCoords } innerLabel tick =
    let
        position =
            toSvgCoords ( tick, 0 )
    in
        Svg.g
            [ Svg.Attributes.transform (toTranslate position) ]
            [ innerLabel tick ]



-- View Grid


getGridPositions : List Float -> GridValues -> List Float
getGridPositions tickValues values =
    case values of
        GridMirrorTicks ->
            tickValues

        GridCustomValues customValues ->
            customValues


viewGridLine : PlotScales -> Style -> Float -> Svg.Svg msg
viewGridLine { oppositeToSvgCoords, oppositeScale } style position =
    let
        { lowest, highest } =
            oppositeScale

        ( x1, y1 ) =
            oppositeToSvgCoords ( lowest, position )

        ( x2, y2 ) =
            oppositeToSvgCoords ( highest, position )

        attrs =
            Svg.Attributes.style (toStyle style) :: (toPositionAttr x1 y1 x2 y2)
    in
        Svg.line attrs []



-- VIEW AREA


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



-- VIEW LINE


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
    , toSvgCoords : Point -> Point
    , oppositeToSvgCoords : Point -> Point
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


getPlotScales : MetaConfig -> List (Element msg) -> PlotScales
getPlotScales { size, padding } elements =
    let
        ( xValues, yValues ) =
            List.unzip (List.foldr collectPoints [] elements)

        ( width, height ) =
            size

        xScale =
            getScales width ( 0, 0 ) xValues

        yScale =
            getScales height padding yValues
    in
        { scale = xScale
        , oppositeScale = yScale
        , toSvgCoords = toSvgCoordsX xScale yScale
        , oppositeToSvgCoords = toSvgCoordsY xScale yScale
        }


flipToY : PlotScales -> PlotScales
flipToY { scale, oppositeScale, toSvgCoords, oppositeToSvgCoords } =
    { scale = oppositeScale
    , oppositeScale = scale
    , toSvgCoords = oppositeToSvgCoords
    , oppositeToSvgCoords = toSvgCoords
    }



-- TICKS


getTick0 : Float -> Float -> Float
getTick0 lowest delta =
    roundBy delta lowest


getTickTotal : Float -> Float -> Float -> Float -> Int
getTickTotal range lowest tick0 delta =
    floor ((range - (abs lowest - abs tick0)) / delta)


getTicksFromSequence : Float -> Float -> Float -> Float -> List Float
getTicksFromSequence lowest range tick0 delta =
    let
        tickTotal =
            getTickTotal range lowest tick0 delta
    in
         List.map (\v -> tick0 + (toFloat v) * delta) [0..tickTotal]


getTickValues : AxisScale -> TickValues -> List Float
getTickValues { lowest, range } tickValues =
    case tickValues of
        TickCustomValues ticks ->
            ticks

        TickSequence ( tick0, delta ) ->
            getTicksFromSequence lowest range tick0 delta

        TickAppxTotal total ->
            let
                delta =
                    getTickDelta range total

                tick0 =
                    getTick0 lowest delta
            in
                getTicksFromSequence lowest range tick0 delta

        TickAutoValues ->
            let
                delta =
                    getTickDelta range 10

                tick0 =
                    getTick0 lowest delta
            in
                getTicksFromSequence lowest range tick0 delta
    



-- Collect points


collectPoints : Element msg -> List Point -> List Point
collectPoints serie allPoints =
    case serie of
        Area { points } ->
            allPoints ++ points

        Line { points } ->
            allPoints ++ points

        _ ->
            allPoints



-- Helpers


fromOrientation : Orientation -> a -> a -> a
fromOrientation orientation x y =
    case orientation of
        X ->
            x

        Y ->
            y

