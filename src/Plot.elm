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

{-|
 This library aims to allow you to visualize a variety of graphs in
 an intuitve manner without comprimising flexibility regarding configuration.
 It is insprired by the elm-html api, using the `element attrs children` pattern.

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
@docs tickValues, tickSequence, tickRemoveZero, tickViewConfig, tickCustomView

### Label configuration
@docs labelFormat, labelCustomView

### Grid configuration
@docs gridMirrorTicks, gridValues, gridStyle

-}

import Html exposing (Html)
import Html.Events exposing (on, onMouseOut)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, d, style)
import Svg.Lazy
import String
import Round
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
    , padding = ( 0, 0 )
    , style = [ ( "padding", "30px" ), ( "stroke", "#000" ) ]
    }


{-| Add padding to your plot, meaning extra space below
 and above the lowest and highest point in your plot.
 The unit is pixels.

 Default: `( 0, 0 )`
-}
padding : ( Int, Int ) -> MetaConfig -> MetaConfig
padding padding config =
    { config | padding = padding }


{-| Specify the size of your plot in pixels.

 Default: `( 800, 500 )`
-}
size : ( Int, Int ) -> MetaConfig -> MetaConfig
size size config =
    { config | size = size }


{-| Add styles to the svg element.

 Default: `[ ( "padding", "30px" ), ( "stroke", "#000" ) ]`
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
    | TickCustomValues (List Float)
    | TickAppxTotal Int
    | TickAutoValues


type LabelView msg
    = LabelFormat (Float -> String)
    | LabelCustomView (Float -> Svg.Svg msg)


type GridValues
    = GridMirrorTicks
    | GridCustomValues (List Float)


type Orientation
    = X
    | Y


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


{-| The type representing an axis configuration.
-}
type alias AxisAttr msg =
    AxisConfig msg -> AxisConfig msg


defaultTickStyle =
    { length = 7
    , width = 1
    , style = []
    }


defaultAxisConfig =
    { tickValues = TickAutoValues
    , tickView = TickConfigView defaultTickStyle
    , labelView = LabelFormat toString
    , gridValues = GridCustomValues []
    , gridStyle = []
    , style = []
    , axisCrossing = False
    , orientation = X
    }


{-| Add styling to the axis line.

    main =
        plot
            [] 
            [ xAxis [ axisStyle [ ( "stroke", "red" ) ] ] ]

 Default: `[]`
-}
axisStyle : Style -> AxisConfig msg -> AxisConfig msg
axisStyle style config =
    { config | style = style }


{-| Defines what ticks will be shown on the axis by specifying a list of values.

    main =
        plot
            []
            [ xAxis [ tickValues [ 0, 1, 2, 4, 8 ] ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickSequence` attribute, then this attribute will have no effect.
-}
tickValues : List Float -> AxisConfig msg -> AxisConfig msg
tickValues values config =
    { config | tickValues = TickCustomValues values }


{-| Defines what ticks will be shown on the axis by specifying the ( firstTick, delta ) to define a sequence.

    main =
        plot
            []
            [ xAxis [ tickSequence ( 0, 4 ) ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickValues` attribute, then this attribute will have no effect.
-}
tickSequence : ( Float, Float ) -> AxisConfig msg -> AxisConfig msg
tickSequence sequenceConfig config =
    { config | tickValues = TickSequence sequenceConfig }


{-| Defines how the tick will be displayed by specifying lenght, width and style of your ticks.

    axisStyleAttr : AxisAttr msg
    axisStyleAttr =
        tickViewConfig
            { length = 5
            , width = 2
            , style = [ ( "stroke", "red" ) ]
            }

    main =
        plot [] [ xAxis [ axisStyleAttr ] ]

 Default: `{ length = 7, width = 1, style = [] }`

 If you do not define another view configuration, this will be the default.

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickCustomView` attribute, then this attribute will have no effect.
-}
tickViewConfig : TickStyleConfig -> AxisConfig msg -> AxisConfig msg
tickViewConfig styleConfig config =
    { config | tickView = TickConfigView styleConfig }


{-| Defines how the tick will be displayed by specifying a function which returns your tick html.

    viewTick : Float -> Svg.Svg a
    viewTick tick =
        text'
            [ transform ("translate(-5, 10)") ]
            [ tspan
                []
                [ text "✨" ]
            ]

    main =
        plot [] [ xAxis [ tickCustomView viewTick ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickViewConfig` attribute, then this attribute will have no effect.
-}
tickCustomView : (Float -> Svg.Svg msg) -> AxisConfig msg -> AxisConfig msg
tickCustomView view config =
    { config | tickView = TickCustomView view }


{-| Remove tick at origin. Useful when two axis' are crossing and you do not
 want the origin the be cluttered with labels.

    main =
        plot
            []
            [ xAxis [ tickRemoveZero ] ]

 Default: `False`
-}
tickRemoveZero : AxisConfig msg -> AxisConfig msg
tickRemoveZero config =
    { config | axisCrossing = True }


{-| Specify a format for label.

    labelFormatter : Float -> String
    labelFormatter tick =
        (toString tick) ++ "$"

    main =
        plot
            []
            [ xAxis [ labelFormat labelFormatter ] ]

 Default: `toString`

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `labelCustomView` attribute, then this attribute will have no effect.
-}
labelFormat : (Float -> String) -> AxisConfig msg -> AxisConfig msg
labelFormat formatter config =
    { config | labelView = LabelFormat formatter }


{-| Add a custom view for rendering your label.

    viewLabel : Float -> Svg.Svg a
    viewLabel tick =
        text' mySpecialAttributes mySpecialLabelDisplay


    main =
        plot
            [] 
            [ xAxis [ labelCustomView viewLabel ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `labelFormat` attribute, then this attribute will have no effect.
-}
labelCustomView : (Float -> Svg.Svg msg) -> AxisConfig msg -> AxisConfig msg
labelCustomView view config =
    { config | labelView = LabelCustomView view }


{-| Adds grid lines where the ticks on the corresponding axis are.

    main =
        plot
            []
            [ xAxis [ gridMirrorTicks ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `gridValues` attribute, then this attribute will have no effect.
-}
gridMirrorTicks : AxisConfig msg -> AxisConfig msg
gridMirrorTicks config =
    { config | gridValues = GridMirrorTicks }


{-| Specify a list of ticks where you want grid lines drawn.

    plot [] [ xAxis [ gridValues [ 1, 2, 4, 8 ] ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `gridMirrorTicks` attribute, then this attribute will have no effect.
-}
gridValues : List Float -> AxisConfig msg -> AxisConfig msg
gridValues values config =
    { config | gridValues = GridCustomValues values }


{-| Specify styles for the gridlines.

    plot
        []
        [ xAxis
            [ gridMirrorTicks
            , gridStyle myGridStyles
            ]
        ]

 Remember that if you do not specify either `gridMirrorTicks`
 or `gridValues`, then we will default to not showing any grid lines.
-}
gridStyle : Style -> AxisConfig msg -> AxisConfig msg
gridStyle style config =
    { config | gridStyle = style }


{-| This returns an axis element resulting in an x-axis being rendered in your plot.

    main =
        plot [] [ xAxis [] ]
-}
xAxis : List (AxisAttr msg) -> Element msg
xAxis attrs =
    Axis (List.foldr (<|) defaultAxisConfig attrs)


{-| This returns an axis element resulting in an y-axis being rendered in your plot.

    main =
        plot [] [ yAxis [] ]
-}
yAxis : List (AxisAttr msg) -> Element msg
yAxis attrs =
    Axis (List.foldr (<|) { defaultAxisConfig | orientation = Y } attrs)



-- AREA CONFIG


type alias AreaConfig =
    { style : Style
    , points : List Point
    }


{-| The type representing an area configuration.
-}
type alias AreaAttr =
    AreaConfig -> AreaConfig


defaultAreaConfig =
    { style = []
    , points = []
    }


{-| Add styles to your area serie.

    main =
        plot
            []
            [ area
                [ areaStyle
                    [ ( "fill", "deeppink" )
                    , ( "stroke", "deeppink" )
                    , ( "opacity", "0.5" ) ]
                    ]
                ]
                areaDataPoints
            ]
-}
areaStyle : Style -> AreaConfig -> AreaConfig
areaStyle style config =
    { config | style = style }


{-| This returns an area element resulting in an area serie rendered in your plot.

    main =
        plot [] [ area []  [ ( 0, -2 ), ( 2, 0 ), ( 3, 1 ) ] ]
-}
area : List AreaAttr -> List Point -> Element msg
area attrs points =
    let
        config =
            List.foldr (<|) defaultAreaConfig attrs
    in
        Area { config | points = points }



-- LINE CONFIG


type alias LineConfig =
    { style : Style
    , points : List Point
    }


defaultLineConfig =
    { style = []
    , points = []
    }


{-| The type representing a line configuration.
-}
type alias LineAttr =
    LineConfig -> LineConfig


{-| Add styles to your line serie.

    main =
        plot
            []
            [ line
                [ lineStyle [ ( "fill", "deeppink" ) ] ]
                lineDataPoints
            ]
-}
lineStyle : Style -> LineConfig -> LineConfig
lineStyle style config =
    { config | style = ( "fill", "transparent" ) :: style }


{-| This returns a line element resulting in an line serie rendered in your plot.

    main =
        plot [] [ line [] [ ( 0, 1 ), ( 2, 2 ), ( 3, 4 ) ] ]
-}
line : List LineAttr -> List Point -> Element msg
line attrs points =
    let
        config =
            List.foldr (<|) defaultLineConfig attrs
    in
        Line { config | points = points }



-- PARSE PLOT


{-| This is the function processing your entire plot configuration.
 Pass your meta attributes and plot elements to this function and
 a svg plot will be returned!
-}
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
        { scale, oppositeScale, toSvgCoords, oppositeToSvgCoords } =
            scales

        positions =
            getTickValues scale tickValues

        tickPositions =
            if axisCrossing then
                List.filter (\p -> p /= 0) positions
            else
                positions

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
            [ Svg.g [] (List.map (viewGridLine oppositeToSvgCoords oppositeScale gridStyle) gridPositions)
            , viewGridLine toSvgCoords scale style 0
            , Svg.g [] (List.map (placeTick scales innerTick) tickPositions)
            , Svg.g [] (List.map (placeTick scales innerLabel) tickPositions)
            ]


placeTick : PlotScales -> (Float -> Svg.Svg msg) -> Float -> Svg.Svg msg
placeTick { toSvgCoords } view tick =
    Svg.g [ Svg.Attributes.transform (toTranslate (toSvgCoords ( tick, 0 ))) ] [ view tick ]


defaultTickView : Orientation -> TickStyleConfig -> Float -> Svg.Svg msg
defaultTickView orientation { length, width, style } _ =
    let
        displacement =
            fromOrientation orientation "" (toRotate 90 0 0)

        styleFinal =
            style ++ [ ( "stroke-width", (toString width) ++ "px" ) ]
    in
        Svg.line
            [ Svg.Attributes.style (toStyle styleFinal)
            , Svg.Attributes.y2 (toString length)
            , Svg.Attributes.transform displacement
            ]
            []


defaultLabelStyleX : ( Style, ( Float, Float ) )
defaultLabelStyleX =
    ( [ ( "text-anchor", "middle" ) ], ( 0, 24 ) )


defaultLabelStyleY : ( Style, ( Float, Float ) )
defaultLabelStyleY =
    ( [ ( "text-anchor", "end" ) ], ( -10, 5 ) )


defaultLabelView : Orientation -> (Float -> String) -> Float -> Svg.Svg msg
defaultLabelView orientation format tick =
    let
        ( style, displacement ) =
            fromOrientation orientation defaultLabelStyleX defaultLabelStyleY
    in
        Svg.text'
            [ Svg.Attributes.transform (toTranslate displacement)
            , Svg.Attributes.style (toStyle style)
            ]
            [ Svg.tspan [] [ Svg.text (format tick) ] ]



-- View Grid


getGridPositions : List Float -> GridValues -> List Float
getGridPositions tickValues values =
    case values of
        GridMirrorTicks ->
            tickValues

        GridCustomValues customValues ->
            customValues


viewGridLine : (Point -> Point) -> AxisScale -> Style -> Float -> Svg.Svg msg
viewGridLine toSvgCoords scale style position =
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
    ceilToNearest delta lowest


getTickTotal : Float -> Float -> Float -> Float -> Int
getTickTotal range lowest tick0 delta =
    floor ((range - (abs lowest - abs tick0)) / delta)


getTickNum : Float -> Float -> Int -> Float
getTickNum tick0 delta index =
    let
        mag =
            floor (logBase 10 delta)

        precision =
            if mag < 0 then
                abs mag
            else
                0
    in
        tick0
            + (toFloat index)
            * delta
            |> Round.round precision
            |> String.toFloat
            |> Result.withDefault 0


getTicksFromSequence : Float -> Float -> Float -> Float -> List Float
getTicksFromSequence lowest range tick0 delta =
    let
        tickTotal =
            getTickTotal range lowest tick0 delta
    in
        List.map (getTickNum tick0 delta) [0..tickTotal]


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
