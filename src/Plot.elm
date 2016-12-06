module Plot
    exposing
        ( Attribute
        , plot
        , plotInteractive
        , xAxis
        , yAxis
        , verticalGrid
        , horizontalGrid
        , hint
        , area
        , line
        , pile
        , scatter
        , custom
        , classes
        , id
        , margin
        , padding
        , size
        , style
        , range
        , domain
        , Element
        , initialState
        , update
        , Interaction(..)
        , State
        , getHoveredValue
        , Point
        , Style
        )

{-|
 This library aims to allow you to visualize a variety of graphs in
 an intuitve manner without comprimising flexibility regarding configuration.
 It is insprired by the elm-html api, using the `element attrs children` pattern.

# Definitions
@docs Attribute, Element, Point, Style

# Elements
@docs plot, plotInteractive, scatter, line, area, pile, xAxis, yAxis, hint, verticalGrid, horizontalGrid, custom

# Styling and sizes
@docs classes, id, margin, padding, size, style, range, domain

# State
@docs State, initialState, update, Interaction, getHoveredValue


-}

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Svg exposing (Svg)
import Svg.Attributes
import Svg.Events
import Svg.Lazy
import Task
import Json.Decode as Json
import Dom
import Dom.Position
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Grid as Grid
import Plot.Area as Area
import Plot.Pile as Pile
import Plot.Scatter as Scatter
import Plot.Line as Line
import Plot.Hint as Hint
import Internal.Grid as GridInternal
import Internal.Axis as AxisInternal
import Internal.Pile as PileInternal
import Internal.Bars as BarsInternal
import Internal.Area as AreaInternal
import Internal.Scatter as ScatterInternal
import Internal.Line as LineInternal
import Internal.Tick as TickInternal
import Internal.Hint as HintInternal
import Internal.Stuff exposing (..)
import Internal.Types exposing (..)
import Internal.Draw exposing (..)


{-| Convinience type to represent coordinates.
-}
type alias Point =
    ( Float, Float )


{-| Convinience type to represent style.
-}
type alias Style =
    List ( String, String )


{-| Represents child element of the plot.
-}
type Element msg
    = Line (LineInternal.Config msg) (List Point)
    | Area (AreaInternal.Config msg) (List Point)
    | Pile PileInternal.Config (List (PileInternal.Element msg)) PileMeta
    | Scatter (ScatterInternal.Config msg) (List Point)
    | Hint (HintInternal.Config msg) (Maybe Point)
    | Axis (AxisInternal.Config msg)
    | Grid (GridInternal.Config msg)
    | CustomElement ((Point -> Point) -> Svg.Svg msg)


type alias Config =
    { size : ( Float, Float )
    , padding : ( Float, Float )
    , margin : ( Float, Float, Float, Float )
    , classes : List String
    , style : Style
    , domain : ( Maybe Float, Maybe Float )
    , range : ( Maybe Float, Maybe Float )
    , id : String
    }


defaultConfig : Config
defaultConfig =
    { size = ( 800, 500 )
    , padding = ( 0, 0 )
    , margin = ( 0, 0, 0, 0 )
    , classes = []
    , style = [ ( "padding", "0" ), ( "stroke", "#000" ) ]
    , domain = ( Nothing, Nothing )
    , range = ( Nothing, Nothing )
    , id = "elm-plot"
    }


{-| -}
type alias Attribute =
    Config -> Config


{-| Adds padding to your plot, meaning extra space below
 and above the lowest and highest point in your plot.
 The unit is pixels and the format is `( bottom, top )`.

 Default: `( 0, 0 )`
-}
padding : ( Int, Int ) -> Attribute
padding ( bottom, top ) config =
    { config | padding = ( toFloat bottom, toFloat top ) }


{-| Specify the size of your plot in pixels and in the format
 of `( width, height )`.

 Default: `( 800, 500 )`
-}
size : ( Int, Int ) -> Attribute
size ( width, height ) config =
    { config | size = ( toFloat width, toFloat height ) }


{-| Specify margin around the plot. Useful when your ticks are outside the
 plot and you would like to add space to see them! Values are in pixels and
the format is `( top, right, bottom, left )`.

 Default: `( 0, 0, 0, 0 )`
-}
margin : ( Int, Int, Int, Int ) -> Attribute
margin ( t, r, b, l ) config =
    { config | margin = ( toFloat t, toFloat r, toFloat b, toFloat l ) }


{-| Adds styles to the svg element.
-}
style : Style -> Attribute
style style config =
    { config | style = defaultConfig.style ++ style ++ [ ( "padding", "0" ) ] }


{-| Adds classes to the svg element.
-}
classes : List String -> Attribute
classes classes config =
    { config | classes = classes }


{-| Adds an id to the svg element.

 **Note:** If you have more than one plot in your DOM,
 then you most provide a unique id using this attribute for
 the hint to work!
-}
id : String -> Attribute
id id config =
    { config | id = id }


{-| Specifically set the domain. The format is ( lowest, highest )
 and if left with a `Nothing` value, then it default to the edges of your series y-coordinates.

 **Note:** If you are using `padding` as well, the extra padding will still be
 added outside the domain.
-}
domain : ( Maybe Float, Maybe Float ) -> Attribute
domain domain config =
    { config | domain = domain }


{-| Specifically set the range. The format is ( lowest, highest )
 and if left with a `Nothing` value, then it default to the edges of your series x-coordinates.
-}
range : ( Maybe Float, Maybe Float ) -> Attribute
range range config =
    { config | range = range }


{-| -}
xAxis : List (Axis.Attribute msg) -> Element msg
xAxis attrs =
    Axis (List.foldl (<|) AxisInternal.defaultConfigX attrs)


{-| -}
yAxis : List (Axis.Attribute msg) -> Element msg
yAxis attrs =
    Axis (List.foldl (<|) AxisInternal.defaultConfigY attrs)


{-| -}
horizontalGrid : List (Grid.Attribute msg) -> Element msg
horizontalGrid attrs =
    Grid (List.foldr (<|) GridInternal.defaultConfigX attrs)


{-| -}
verticalGrid : List (Grid.Attribute msg) -> Element msg
verticalGrid attrs =
    Grid (List.foldr (<|) GridInternal.defaultConfigY attrs)


{-| Draws an area.

    myPlot : Svg.Svg msg
    myPlot =
        plot
            []
            [ area [] [ ( 0, -2 ), ( 2, 0 ), ( 3, 1 ) ] ]
-}
area : List (Area.Attribute msg) -> List Point -> Element msg
area attrs points =
    Area (List.foldr (<|) AreaInternal.defaultConfig attrs) points


{-| Draws an line.

    myPlot : Svg.Svg msg
    myPlot =
        plot [] [ line [] [ ( 0, 1 ), ( 2, 2 ), ( 3, 4 ) ] ]
-}
line : List (Line.Attribute msg) -> List Point -> Element msg
line attrs points =
    Line (List.foldr (<|) LineInternal.defaultConfig attrs) points


{-| Draws a scatter.

    myPlot : Svg.Svg msg
    myPlot =
        plot
            []
            [ scatter [] [ ( 0, -2 ), ( 2, 0 ), ( 3, 1 ) ] ]
-}
scatter : List (Scatter.Attribute msg) -> List Point -> Element msg
scatter attrs points =
    Scatter (List.foldr (<|) ScatterInternal.defaultConfig attrs) points


{-| Draws a bar chart.

    myPlot : Svg.Svg msg
    myPlot =
        plot
            []
            [ bars [] [ ( 0, -2 ), ( 2, 0 ), ( 3, 1 ) ] ]
-}
pile : List Pile.Attribute -> List (Pile.Element msg) -> Element msg
pile attrs barsConfigs =
    let
        config =
            List.foldr (<|) PileInternal.defaultConfig attrs
    in
        Pile config barsConfigs (PileInternal.toPileMeta config barsConfigs)


{-| -}
hint : List (Hint.Attribute msg) -> Maybe Point -> Element msg
hint attrs position =
    Hint (List.foldr (<|) HintInternal.defaultConfig attrs) position


{-| -}
custom : ((Point -> Point) -> Svg.Svg msg) -> Element msg
custom view =
    CustomElement view


{-| This is the function processing your entire plot configuration.
 Pass your meta attributes and plot elements to this function and
 a svg plot will be returned!
-}
plot : List Attribute -> List (Element msg) -> Svg msg
plot attrs =
    Svg.Lazy.lazy2 parsePlot (toPlotConfig attrs)


{-| So this is like `plot`, except the message to is `Interaction yourMsg`. It's a message wrapping
 your message, so you can use down the build in inteactions in the plot as well as adding your own.
 See example here (if I forget to insert link, please let me know).
-}
plotInteractive : List Attribute -> List (Element (Interaction yourMsg)) -> Svg (Interaction yourMsg)
plotInteractive attrs =
    Svg.Lazy.lazy2 parsePlotInteractive (toPlotConfig attrs)


toPlotConfig : List Attribute -> Config
toPlotConfig =
    List.foldl (<|) defaultConfig



-- MODEL


{-| -}
type State
    = State
        { position : Maybe ( Float, Float )
        , waiting : Bool
        }


{-| -}
initialState : State
initialState =
    State
        { position = Nothing
        , waiting = True
        }



-- UPDATE


{-| -}
type Interaction c
    = Internal Msg
    | Custom c


type Msg
    = Hovering Meta ( Float, Float )
    | ReceivePosition (Result Dom.Error Point)
    | ResetPosition


{-| -}
update : Msg -> State -> ( State, Cmd (Interaction c) )
update msg (State state) =
    case msg of
        Hovering meta eventPosition ->
            ( State { state | waiting = True }, cmdPosition meta eventPosition )

        ReceivePosition result ->
            case result of
                Ok position ->
                    if state.waiting && positionChanged state.position position then
                        ( State { state | position = Just position }, Cmd.none )
                    else
                        ( State state, Cmd.none )

                Err err ->
                    ( State state, Cmd.none )

        ResetPosition ->
            ( State { position = Nothing, waiting = False }, Cmd.none )


{-| Get the hovered position from state.
-}
getHoveredValue : State -> Maybe Point
getHoveredValue (State { position }) =
    position


positionChanged : Maybe ( Float, Float ) -> ( Float, Float ) -> Bool
positionChanged position ( left, top ) =
    case position of
        Nothing ->
            True

        Just ( leftOld, topOld ) ->
            topOld /= top || leftOld /= left


cmdPosition : Meta -> ( Float, Float ) -> Cmd (Interaction c)
cmdPosition meta eventPosition =
    Task.map2
        (getRelativePosition meta eventPosition)
        (Dom.Position.left meta.id)
        (Dom.Position.top meta.id)
        |> Task.attempt ReceivePosition
        |> Cmd.map Internal


getRelativePosition : Meta -> ( Float, Float ) -> Float -> Float -> Point
getRelativePosition { fromSvgCoords, toNearestX } ( mouseX, mouseY ) left top =
    let
        ( x, y ) =
            fromSvgCoords ( mouseX - left, mouseY - top )
    in
        ( toNearestX x, y )



-- VIEW


parsePlot : Config -> List (Element msg) -> Svg msg
parsePlot config elements =
    let
        meta =
            calculateMeta config elements
    in
        viewPlot config meta (viewElements meta elements)


parsePlotInteractive : Config -> List (Element (Interaction c)) -> Svg (Interaction c)
parsePlotInteractive config elements =
    let
        meta =
            calculateMeta config elements
    in
        viewPlotInteractive config meta (viewElements meta elements)


viewPlotInteractive : Config -> Meta -> ( List (Svg (Interaction c)), List (Html (Interaction c)) ) -> Html (Interaction c)
viewPlotInteractive ({ size } as config) meta ( svgViews, htmlViews ) =
    Html.div
        (plotAttributes config ++ plotAttributesInteraction meta)
        (viewSvg size svgViews :: htmlViews)


viewPlot : Config -> Meta -> ( List (Svg msg), List (Html msg) ) -> Svg msg
viewPlot ({ size } as config) meta ( svgViews, htmlViews ) =
    Html.div
        (plotAttributes config)
        (viewSvg size svgViews :: htmlViews)


plotAttributes : Config -> List (Html.Attribute msg)
plotAttributes { size, id } =
    [ Html.Attributes.class "elm-plot"
    , Html.Attributes.style <| sizeStyle size
    , Html.Attributes.id id
    ]


plotAttributesInteraction : Meta -> List (Html.Attribute (Interaction c))
plotAttributesInteraction meta =
    [ Html.Events.on "mousemove" (getMousePosition meta)
    , Html.Events.onMouseLeave (Internal ResetPosition)
    ]


viewSvg : ( Float, Float ) -> List (Svg msg) -> Svg msg
viewSvg ( width, height ) views =
    Svg.svg
        [ Svg.Attributes.height (toString height)
        , Svg.Attributes.width (toString width)
        , Svg.Attributes.class "elm-plot__inner"
        ]
        views


getMousePosition : Meta -> Json.Decoder (Interaction c)
getMousePosition meta =
    Json.map2
        (\x y -> Internal <| Hovering meta ( x, y ))
        (Json.field "clientX" Json.float)
        (Json.field "clientY" Json.float)


sizeStyle : ( Float, Float ) -> Style
sizeStyle ( width, height ) =
    [ ( "height", toPixels height ), ( "width", toPixels width ) ]


viewElements : Meta -> List (Element msg) -> ( List (Svg msg), List (Html msg) )
viewElements meta elements =
    List.foldr (viewElement meta) ( [], [] ) elements


viewElement : Meta -> Element msg -> ( List (Svg msg), List (Html msg) ) -> ( List (Svg msg), List (Html msg) )
viewElement meta element ( svgViews, htmlViews ) =
    case element of
        Line config points ->
            ( (LineInternal.view meta config points) :: svgViews, htmlViews )

        Area config points ->
            ( (AreaInternal.view meta config points) :: svgViews, htmlViews )

        Scatter config points ->
            ( (ScatterInternal.view meta config points) :: svgViews, htmlViews )

        Pile config barsConfigs pileMeta ->
            ( (PileInternal.view meta pileMeta config barsConfigs) :: svgViews, htmlViews )

        Axis ({ orientation } as config) ->
            ( (AxisInternal.view (getFlippedMeta orientation meta) config) :: svgViews, htmlViews )

        Grid ({ orientation } as config) ->
            ( (GridInternal.view (getFlippedMeta orientation meta) config) :: svgViews, htmlViews )

        CustomElement view ->
            ( (view meta.toSvgCoords :: svgViews), htmlViews )

        Hint config position ->
            case position of
                Just point ->
                    ( svgViews, (HintInternal.view meta config point) :: htmlViews )

                Nothing ->
                    ( svgViews, htmlViews )



-- CALCULATIONS OF META


calculateMeta : Config -> List (Element msg) -> Meta
calculateMeta ({ size, padding, margin, id, range, domain } as config) elements =
    let
        ( xValues, yValues ) =
            List.unzip (List.foldr collectPoints [] elements)

        axisConfigs =
            List.foldr collectAxisConfigs { x = [], y = [] } elements

        pileMetas =
            List.foldr collectPileMetas [] elements

        pileEdges =
            PileInternal.toPileEdges pileMetas

        ( width, height ) =
            size

        ( top, right, bottom, left ) =
            margin

        xScale =
            getScale width range ( left, right ) ( 0, 0 ) xValues pileEdges.x

        yScale =
            getScale height domain ( top, bottom ) padding yValues pileEdges.y

        xTicks =
            getLastGetTickValues axisConfigs.x xScale

        yTicks =
            getLastGetTickValues axisConfigs.y yScale
    in
        { scale = xScale
        , oppositeScale = yScale
        , oppositeToSvgCoords = toSvgCoordsY xScale yScale
        , toSvgCoords = toSvgCoordsX xScale yScale
        , fromSvgCoords = fromSvgCoords xScale yScale
        , ticks = xTicks
        , oppositeTicks = yTicks
        , axisCrossings = getAxisCrossings axisConfigs.x yScale
        , oppositeAxisCrossings = getAxisCrossings axisConfigs.y xScale
        , toNearestX = toNearest xValues
        , getHintInfo = getHintInfo elements
        , pileMetas = pileMetas
        , id = id
        }


flipToY : Meta -> Meta
flipToY ({ scale, oppositeScale, toSvgCoords, oppositeToSvgCoords, ticks, oppositeTicks, axisCrossings, oppositeAxisCrossings } as meta) =
    { meta
        | scale = oppositeScale
        , oppositeScale = scale
        , toSvgCoords = oppositeToSvgCoords
        , oppositeToSvgCoords = toSvgCoords
        , axisCrossings = oppositeAxisCrossings
        , oppositeAxisCrossings = axisCrossings
        , ticks = oppositeTicks
        , oppositeTicks = ticks
    }


getFlippedMeta : Orientation -> Meta -> Meta
getFlippedMeta orientation meta =
    case orientation of
        X ->
            meta

        Y ->
            flipToY meta


{-| All naming assumes dealing with the x-axis, but can also be used with
 the t-axis, just flip it in your mind.
-}
getScale : Float -> ( Maybe Value, Maybe Value ) -> ( Value, Value ) -> ( Value, Value ) -> List Value -> Maybe Edges -> Scale
getScale lengthTotal ( forcedLowest, forcedHighest ) ( offsetLeft, offsetRight ) ( paddingBottomPx, paddingTopPx ) values pileEdges =
    let
        length =
            lengthTotal - offsetLeft - offsetRight

        lowest =
            getScaleLowest forcedLowest values pileEdges

        highest =
            getScaleHighest forcedHighest values pileEdges

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


getScaleLowest : Maybe Value -> List Value -> Maybe Edges -> Value
getScaleLowest forcedLowest values pileEdges =
    case forcedLowest of
        Just value ->
            value

        Nothing ->
            getAutoLowest pileEdges (getLowest values)


getAutoLowest : Maybe Edges -> Value -> Value
getAutoLowest pileEdges lowestFromValues =
    case pileEdges of
        Just { lower } ->
            min lower lowestFromValues

        Nothing ->
            lowestFromValues


getScaleHighest : Maybe Value -> List Value -> Maybe Edges -> Value
getScaleHighest forcedHighest values pileEdges =
    case forcedHighest of
        Just value ->
            value

        Nothing ->
            getAutoHighest pileEdges (getHighest values)


getAutoHighest : Maybe Edges -> Value -> Value
getAutoHighest pileEdges highestFromValues =
    case pileEdges of
        Just { upper } ->
            max upper highestFromValues

        Nothing ->
            highestFromValues


scaleValue : Scale -> Value -> Value
scaleValue { length, range, offset } v =
    (v * length / range) + offset


unScaleValue : Scale -> Value -> Value
unScaleValue { length, range, offset, lowest } v =
    ((v - offset) * range / length) + lowest


fromSvgCoords : Scale -> Scale -> Point -> Point
fromSvgCoords xScale yScale ( x, y ) =
    ( unScaleValue xScale x
    , unScaleValue yScale (yScale.length - y)
    )


toSvgCoordsX : Scale -> Scale -> Point -> Point
toSvgCoordsX xScale yScale ( x, y ) =
    ( scaleValue xScale (abs xScale.lowest + x)
    , scaleValue yScale (yScale.highest - y)
    )


toSvgCoordsY : Scale -> Scale -> Point -> Point
toSvgCoordsY xScale yScale ( x, y ) =
    toSvgCoordsX xScale yScale ( y, x )


getHintInfo : List (Element msg) -> Float -> HintInfo
getHintInfo elements xValue =
    HintInfo xValue <| List.foldr (collectYValues xValue) [] elements


collectAxisConfigs : Element msg -> Axis (List (AxisInternal.Config msg)) -> Axis (List (AxisInternal.Config msg))
collectAxisConfigs element axisConfigs =
    case element of
        Axis config ->
            case config.orientation of
                X ->
                    { axisConfigs | x = config :: axisConfigs.x }

                Y ->
                    { axisConfigs | y = config :: axisConfigs.y }

        _ ->
            axisConfigs


getLastGetTickValues : List (AxisInternal.Config msg) -> Scale -> List Value
getLastGetTickValues axisConfigs =
    List.head axisConfigs
        |> Maybe.withDefault AxisInternal.defaultConfigX
        |> .tickConfig
        |> TickInternal.getValues


collectPoints : Element msg -> List Point -> List Point
collectPoints element allPoints =
    case element of
        Area config points ->
            allPoints ++ points

        Line config points ->
            allPoints ++ points

        Scatter config points ->
            allPoints ++ points

        Pile config pileElements _ ->
            let
                points =
                    List.foldr (\(PileInternal.Bars config points) allBarPoints -> allBarPoints ++ points) [] pileElements
            in
                allPoints ++ points

        _ ->
            allPoints


collectPileMetas : Element msg -> List PileMeta -> List PileMeta
collectPileMetas element allPileMetas =
    case element of
        Pile _ _ meta ->
            meta :: allPileMetas

        _ ->
            allPileMetas


collectYValues : Float -> Element msg -> List (Maybe Value) -> List (Maybe Value)
collectYValues xValue element yValues =
    case element of
        Area config points ->
            collectYValue xValue points :: yValues

        Line config points ->
            collectYValue xValue points :: yValues

        Scatter config points ->
            collectYValue xValue points :: yValues

        Pile config barsConfigs _ ->
            List.map (\(PileInternal.Bars config points) -> collectYValue xValue points) barsConfigs
                |> (++) yValues

        _ ->
            yValues


collectYValue : Float -> List Point -> Maybe Value
collectYValue xValue points =
    List.foldr (getYValue xValue) Nothing points


getYValue : Float -> Point -> Maybe Value -> Maybe Value
getYValue xValue ( x, y ) result =
    if x == xValue then
        Just y
    else
        result


getAxisCrossings : List (AxisInternal.Config msg) -> Scale -> List Value
getAxisCrossings axisConfigs oppositeScale =
    List.map (AxisInternal.getAxisPosition oppositeScale << .position) axisConfigs
