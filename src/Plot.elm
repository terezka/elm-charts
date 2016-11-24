module Plot
    exposing
        ( plot
        , plotStatic
        , xAxis
        , yAxis
        , verticalGrid
        , horizontalGrid
        , tooltip
        , area
        , line
        , Element
        , initialState
        , update
        , Msg
        , State
        )

{-|
 This library aims to allow you to visualize a variety of graphs in
 an intuitve manner without comprimising flexibility regarding configuration.
 It is insprired by the elm-html api, using the `element attrs children` pattern.

# Elements
@docs Element, plot, plotStatic, line, area, xAxis, yAxis, tooltip, verticalGrid, horizontalGrid

# Configuration

# State
@docs State, initialState, update, Msg


-}

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Svg exposing (g)
import Svg.Attributes exposing (height, width, d, style)
import Svg.Events exposing (onMouseOver)
import Svg.Lazy
import String
import Task
import Json.Decode as Json
import Dom
import Dom.Position
import Round
import Debug
import Helpers exposing (..)
import Plot.Types exposing (..)
import Plot.Meta as Meta
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Grid as Grid
import Plot.Area as Area
import Plot.Line as Line
import Plot.Tooltip as Tooltip


{-| Represents child element of the plot.
-}
type Element msg
    = Axis (Axis.Config msg)
    | Tooltip (Tooltip.Config msg) ( Float, Float )
    | Grid Grid.Config
    | Line Line.Config (List Point)
    | Area Area.Config (List Point)


{-| This returns an axis element resulting in an x-axis being rendered in your plot.

    main =
        plot [] [ xAxis [] ]
-}
xAxis : List (Axis.Attribute Msg) -> Element Msg
xAxis attrs =
    Axis (List.foldl (<|) Axis.defaultConfigX attrs)


{-| This returns an axis element resulting in an y-axis being rendered in your plot.

    main =
        plot [] [ yAxis [] ]
-}
yAxis : List (Axis.Attribute Msg) -> Element Msg
yAxis attrs =
    Axis (List.foldl (<|) Axis.defaultConfigY attrs)


{-| This returns an grid element resulting in vertical grid lines being rendered in your plot.

    main =
        plot [] [ horizontalGrid [] ]
-}
horizontalGrid : List Grid.Attribute -> Element Msg
horizontalGrid attrs =
    Grid (Grid.toConfigX attrs)


{-| This returns an axis element resulting in horizontal grid lines being rendered in your plot.

    main =
        plot [] [ verticalGrid [] ]
-}
verticalGrid : List Grid.Attribute -> Element Msg
verticalGrid attrs =
    Grid (Grid.toConfigY attrs)


{-| This returns an area element resulting in an area serie rendered in your plot.

    main =
        plot [] [ area []  [ ( 0, -2 ), ( 2, 0 ), ( 3, 1 ) ] ]
-}
area : List Area.Attribute -> List Point -> Element Msg
area attrs points =
    Area (Area.toConfig attrs) points


{-| This returns a line element resulting in an line serie rendered in your plot.

    main =
        plot [] [ line [] [ ( 0, 1 ), ( 2, 2 ), ( 3, 4 ) ] ]
-}
line : List Line.Attribute -> List Point -> Element Msg
line attrs points =
    Line (List.foldr (<|) Line.defaultConfig attrs) points


{-| -}
tooltip : List (Tooltip.Attribute Msg) -> ( Float, Float ) -> Element Msg
tooltip attrs position =
    Tooltip (List.foldr (<|) Tooltip.defaultConfig attrs) position



-- MODEL


{-| -}
type alias State =
    { position : Maybe ( Float, Float )
    , waiting : Bool
    }


{-| -}
initialState : State
initialState =
    { position = Nothing
    , waiting = True
    }



-- UPDATE


{-| -}
type Msg
    = Hovering PlotProps ( Float, Float )
    | ReceivePosition (Result Dom.Error ( Float, Float ))
    | ResetPosition


{-| -}
update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    case msg of
        Hovering plotProps eventPosition ->
            ( { state | waiting = True }, getPosition plotProps eventPosition )

        ReceivePosition result ->
            case result of
                Ok position ->
                    if state.waiting then
                        ( { state | position = Just position }, Cmd.none )
                    else
                        ( state, Cmd.none )

                Err err ->
                    ( state, Cmd.none )

        ResetPosition ->
            ( { position = Nothing, waiting = False }, Cmd.none )


getPosition : PlotProps -> ( Float, Float ) -> Cmd Msg
getPosition plotProps eventPosition =
    Task.map2
        (getRelativePosition plotProps eventPosition)
        (Dom.Position.left (getInnerId plotProps))
        (Dom.Position.top (getInnerId plotProps))
        |> Task.attempt ReceivePosition


getRelativePosition : PlotProps -> ( Float, Float ) -> Float -> Float -> ( Float, Float )
getRelativePosition { fromSvgCoords, toNearestX } ( mouseX, mouseY ) left top =
    let
        ( x, y ) =
            fromSvgCoords ( mouseX - left, mouseY - top )
    in
        ( toNearestX x, y )


getInnerId : PlotProps -> String
getInnerId { id } =
    id ++ "__inner"



-- PARSE PLOT


{-| This is the function processing your entire plot configuration.
 Pass your meta attributes and plot elements to this function and
 a svg plot will be returned!
-}
plotStatic : List Meta.Attribute -> List (Element Msg) -> Svg.Svg Msg
plotStatic attrs elements =
    Svg.Lazy.lazy3 parsePlot "elm-plot" attrs elements


{-| This is the function processing your entire plot configuration.
 Pass your meta attributes and plot elements to this function and
 a svg plot will be returned!
-}
plot : String -> List Meta.Attribute -> List (Element Msg) -> Svg.Svg Msg
plot id attrs elements =
    Svg.Lazy.lazy3 parsePlot id attrs elements



-- VIEW


parsePlot : String -> List Meta.Attribute -> List (Element Msg) -> Svg.Svg Msg
parsePlot id attrs elements =
    let
        metaConfig =
            Meta.toConfig attrs

        plotProps =
            getPlotProps id metaConfig elements
    in
        viewPlot metaConfig plotProps (viewElements plotProps elements)


getEventPostion : PlotProps -> Json.Decoder Msg
getEventPostion plotProps =
    Json.map2
        (\x y -> Hovering plotProps ( x, y ))
        (Json.field "clientX" Json.float)
        (Json.field "clientY" Json.float)


viewPlot : Meta.Config -> PlotProps -> ( List (Svg.Svg Msg), List (Html.Html Msg) ) -> Svg.Svg Msg
viewPlot { size, style, classes, margin } plotProps ( svgViews, htmlViews ) =
    let
        ( width, height ) =
            size

        ( top, right, bottom, left ) =
            margin

        paddingStyle =
            String.join "px " <| List.map toString [ top, right, bottom, left ]
    in
        Html.div
            [ Html.Attributes.class "elm-plot"
            , Html.Attributes.id plotProps.id
            ]
            [ Svg.svg
                [ Svg.Attributes.height (toString height)
                , Svg.Attributes.width (toString width)
                , Svg.Attributes.class "elm-plot__inner"
                ]
                svgViews
            , Html.div
                [ Html.Attributes.class "elm-plot__html" ]
                [ Html.div
                    [ Html.Attributes.class "elm-plot__html__inner"
                    , Html.Attributes.id (getInnerId plotProps)
                    , Html.Attributes.style
                        [ ( "width", toString (width - left - right) ++ "px" )
                        , ( "height", toString (height - top - bottom) ++ "px" )
                        , ( "padding", paddingStyle ++ "px" )
                        ]
                    , Html.Events.on "mousemove" (getEventPostion plotProps)
                      --, Html.Events.onMouseOut ResetPosition
                    ]
                    htmlViews
                ]
            ]



-- VIEW ELEMENTS


viewElements : PlotProps -> List (Element Msg) -> ( List (Svg.Svg Msg), List (Html.Html Msg) )
viewElements plotProps elements =
    List.foldr (viewElement plotProps) ( [], [] ) elements


viewElement : PlotProps -> Element Msg -> ( List (Svg.Svg Msg), List (Html.Html Msg) ) -> ( List (Svg.Svg Msg), List (Html.Html Msg) )
viewElement plotProps element ( svgViews, htmlViews ) =
    case element of
        Axis config ->
            let
                plotPropsFitted =
                    case config.orientation of
                        X ->
                            plotProps

                        Y ->
                            flipToY plotProps
            in
                ( (Axis.view plotPropsFitted config) :: svgViews, htmlViews )

        Tooltip config position ->
            let
                tooltipView =
                    Tooltip.view plotProps config position
            in
                ( svgViews, tooltipView :: htmlViews )

        Grid config ->
            let
                plotPropsFitted =
                    case config.orientation of
                        X ->
                            plotProps

                        Y ->
                            flipToY plotProps
            in
                ( (Grid.view plotPropsFitted config) :: svgViews, htmlViews )

        Line config points ->
            ( (Line.view plotProps config points) :: svgViews, htmlViews )

        Area config points ->
            ( (Area.view plotProps config points) :: svgViews, htmlViews )



-- CALCULATE SCALES


getScales : Float -> ( Float, Float ) -> ( Float, Float ) -> List Float -> AxisScale
getScales lengthTotal ( offsetLeft, offsetRight ) ( paddingBottomPx, paddingTopPx ) values =
    let
        length =
            lengthTotal - offsetLeft - offsetRight

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
        , length = length
        , offset = offsetLeft
        }


scaleValue : AxisScale -> Float -> Float
scaleValue { length, range } v =
    v * length / range


unScaleValue : AxisScale -> Float -> Float
unScaleValue { length, range } v =
    v * range / length


fromSvgCoords : AxisScale -> AxisScale -> Point -> Point
fromSvgCoords xScale yScale ( x, y ) =
    ( unScaleValue xScale x
    , unScaleValue yScale (yScale.length - y)
    )


toSvgCoordsX : AxisScale -> AxisScale -> Point -> Point
toSvgCoordsX xScale yScale ( x, y ) =
    ( xScale.offset + scaleValue xScale (abs xScale.lowest + x)
    , yScale.offset + scaleValue yScale (yScale.highest - y)
    )


toSvgCoordsY : AxisScale -> AxisScale -> Point -> Point
toSvgCoordsY xScale yScale ( x, y ) =
    toSvgCoordsX xScale yScale ( y, x )


getDiff : Float -> Float -> Float
getDiff a b =
    abs ((abs a) - (abs b))


getClosest : Float -> Float -> Float -> Float
getClosest value candidate closest =
    if getDiff value candidate < getDiff value closest then
        candidate
    else
        closest


toNearestX : List Float -> Float -> Float
toNearestX xValues value =
    List.foldr (getClosest value) 0 xValues


getTooltipInfo : List (Element Msg) -> Float -> TooltipInfo
getTooltipInfo elements xValue =
    let
        yValues =
            List.foldr (collectYValues xValue) [] elements
    in
        TooltipInfo xValue yValues


getPlotProps : String -> Meta.Config -> List (Element Msg) -> PlotProps
getPlotProps id { size, padding, margin } elements =
    let
        ( xValues, yValues ) =
            List.unzip (List.foldr collectPoints [] elements)

        ( width, height ) =
            size

        ( top, right, bottom, left ) =
            margin

        xScale =
            getScales width ( left, right ) ( 0, 0 ) xValues

        yScale =
            getScales height ( top, bottom ) padding yValues

        xTicks =
            getLastGetTickValues X elements <| xScale

        yTicks =
            getLastGetTickValues Y elements <| yScale
    in
        { scale = xScale
        , oppositeScale = yScale
        , toSvgCoords = toSvgCoordsX xScale yScale
        , oppositeToSvgCoords = toSvgCoordsY xScale yScale
        , fromSvgCoords = fromSvgCoords xScale yScale
        , ticks = xTicks
        , oppositeTicks = yTicks
        , toNearestX = toNearestX xValues
        , getTooltipInfo = getTooltipInfo elements
        , id = id
        }


flipToY : PlotProps -> PlotProps
flipToY plotProps =
    let
        { scale, oppositeScale, toSvgCoords, oppositeToSvgCoords, ticks, oppositeTicks } =
            plotProps
    in
        { plotProps
            | scale = oppositeScale
            , oppositeScale = scale
            , toSvgCoords = oppositeToSvgCoords
            , oppositeToSvgCoords = toSvgCoords
            , ticks = oppositeTicks
            , oppositeTicks = ticks
        }



-- GET LAST AXIS TICK CONFIG


getAxisConfig : Orientation -> Element Msg -> Maybe (Axis.Config Msg) -> Maybe (Axis.Config Msg)
getAxisConfig orientation element lastConfig =
    case element of
        Axis config ->
            if config.orientation == orientation then
                Just config
            else
                lastConfig

        _ ->
            lastConfig


getLastGetTickValues : Orientation -> List (Element Msg) -> AxisScale -> List Float
getLastGetTickValues orientation elements =
    List.foldl (getAxisConfig orientation) Nothing elements
        |> Maybe.withDefault Axis.defaultConfigX
        |> .tickConfig
        |> Tick.getValues



-- Collect points


collectPoints : Element Msg -> List Point -> List Point
collectPoints element allPoints =
    case element of
        Area config points ->
            allPoints ++ points

        Line config points ->
            allPoints ++ points

        _ ->
            allPoints


collectYValues : Float -> Element Msg -> List (Maybe Float) -> List (Maybe Float)
collectYValues xValue element yValues =
    case element of
        Area config points ->
            getYValue xValue points :: yValues

        Line config points ->
            getYValue xValue points :: yValues

        _ ->
            yValues


getYValue : Float -> List Point -> Maybe Float
getYValue xValue points =
    List.foldr
        (\( x, y ) res ->
            if x == xValue then
                Just y
            else
                res
        )
        Nothing
        points
