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
        , domainLowest
        , domainHighest
        , rangeLowest
        , rangeHighest
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

 This is still in beta! The api might and probably will change!

# Definitions
@docs Attribute, Element, Point, Style

# Elements
@docs plot, plotInteractive, xAxis, yAxis, hint, verticalGrid, horizontalGrid, custom

## Series
@docs scatter, line, area, pile

# Styling and sizes
@docs classes, id, margin, padding, size, style, domainLowest, domainHighest, rangeLowest, rangeHighest

# State
For an example of the update flow see [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm).

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
import Internal.Scale exposing (..)


{-| Convinience type to represent coordinates.
-}
type alias Point =
    ( Float, Float )


{-| Convinience type to represent style.
-}
type alias Style =
    List ( String, String )


{-| Represents a child element of the plot.
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
    { size : Oriented Float
    , padding : ( Float, Float )
    , margin : ( Float, Float, Float, Float )
    , classes : List String
    , style : Style
    , domain : EdgesAny (Float -> Float)
    , range : EdgesAny (Float -> Float)
    , id : String
    }


defaultConfig : Config
defaultConfig =
    { size = Oriented 800 500
    , padding = ( 0, 0 )
    , margin = ( 0, 0, 0, 0 )
    , classes = []
    , style = []
    , domain = EdgesAny (min 0) (identity)
    , range = EdgesAny (min 0) (identity)
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
    { config | size = Oriented (toFloat width) (toFloat height) }


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
-}
id : String -> Attribute
id id config =
    { config | id = id }


{-| Alter the domain's lower boundery. The function provided will
 be passed the lowest y-value present in any of your series and the result will
 be the lower boundery of your series. So if you would like
 the lowest boundery to simply be the edge of your series, then set
 this attribute to the function `identity`.
 If you want it to always be -5, then set this attribute to the function `always -5`.

 The default is `min 0`.

 **Note:** If you are using `padding` as well, the extra padding will still be
 added outside the domain.
-}
domainLowest : (Float -> Float) -> Attribute
domainLowest toLowest ({ domain } as config) =
    { config | domain = { domain | lower = toLowest } }


{-| Alter the domain's upper boundery. The function provided will
 be passed the lowest y-value present in any of your series and the result will
 be the upper boundery of your series. So if you would like
 the lowest boundery to  always be 10, then set this attribute to the function `always 10`.

 The default is `identity`.

 **Note:** If you are using `padding` as well, the extra padding will still be
 added outside the domain.
-}
domainHighest : (Float -> Float) -> Attribute
domainHighest toHighest ({ domain } as config) =
    { config | domain = { domain | upper = toHighest } }


{-| Provide a function to determine the lower boundery of range.
 See `domainLowest` and imagine we're talking about the x-axis.
-}
rangeLowest : (Float -> Float) -> Attribute
rangeLowest toLowest ({ range } as config) =
    { config | range = { range | lower = toLowest } }


{-| Provide a function to determine the upper boundery of range.
 See `domainHighest` and imagine we're talking about the x-axis.
-}
rangeHighest : (Float -> Float) -> Attribute
rangeHighest toHighest ({ range } as config) =
    { config | range = { range | upper = toHighest } }


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


{-| -}
area : List (Area.Attribute msg) -> List Point -> Element msg
area attrs points =
    Area (List.foldr (<|) AreaInternal.defaultConfig attrs) points


{-| -}
line : List (Line.Attribute msg) -> List Point -> Element msg
line attrs points =
    Line (List.foldr (<|) LineInternal.defaultConfig attrs) points


{-| -}
scatter : List (Scatter.Attribute msg) -> List Point -> Element msg
scatter attrs points =
    Scatter (List.foldr (<|) ScatterInternal.defaultConfig attrs) points


{-| This wraps all your bar series.
-}
pile : List Pile.Attribute -> List (Pile.Element msg) -> Element msg
pile attrs barsConfigs =
    let
        config =
            List.foldr (<|) PileInternal.defaultConfig attrs
    in
        Pile config barsConfigs (PileInternal.toPileMeta config barsConfigs)


{-| Adds a hint to your plot. See [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm)

 **Note:** If you have more than one plot in your DOM,
 then you most provide a unique id using the `id` attribute for
 the hint to work!

 Also remember to use `plotInteractive`.
-}
hint : List (Hint.Attribute msg) -> Maybe Point -> Element msg
hint attrs position =
    Hint (List.foldr (<|) HintInternal.defaultConfig attrs) position


{-| This element is passed a function which can translate your values into
 svg coordinates. This way you can build your own serie types. Although
 if you feel like you're missing something let me know!
-}
custom : ((Point -> Point) -> Svg.Svg msg) -> Element msg
custom view =
    CustomElement view


{-| This is the function processing your entire plot configuration.
 Pass your attributes and elements to this function and
 a svg plot will be returned!
-}
plot : List Attribute -> List (Element msg) -> Svg msg
plot attrs =
    Svg.Lazy.lazy2 parsePlot (toPlotConfig attrs)


{-| So this is like `plot`, except the message to is `Interaction msg`. It's a message wrapping
 your message, so you can use the build in inteactions (like the hint!) in the plot as well as adding your own.
 See [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm).
-}
plotInteractive : List Attribute -> List (Element (Interaction msg)) -> Svg (Interaction msg)
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
type Interaction msg
    = Internal Msg
    | Custom msg


type Msg
    = Hovering Meta ( Float, Float )
    | ReceivePosition (Result Dom.Error Point)
    | ResetPosition


{-| -}
update : Msg -> State -> ( State, Cmd (Interaction msg) )
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


cmdPosition : Meta -> ( Float, Float ) -> Cmd (Interaction msg)
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


parsePlotInteractive : Config -> List (Element (Interaction msg)) -> Svg (Interaction msg)
parsePlotInteractive config elements =
    let
        meta =
            calculateMeta config elements
    in
        viewPlotInteractive config meta (viewElements meta elements)


viewPlotInteractive : Config -> Meta -> ( List (Svg (Interaction msg)), List (Html (Interaction msg)) ) -> Html (Interaction msg)
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
plotAttributes { size, id, style } =
    [ Html.Attributes.class "elm-plot"
    , Html.Attributes.style <| sizeStyle size ++ style
    , Html.Attributes.id id
    ]


plotAttributesInteraction : Meta -> List (Html.Attribute (Interaction msg))
plotAttributesInteraction meta =
    [ Html.Events.on "mousemove" (getMousePosition meta)
    , Html.Events.onMouseLeave (Internal ResetPosition)
    ]


viewSvg : Oriented Float -> List (Svg msg) -> Svg msg
viewSvg { x, y } views =
    Svg.svg
        [ Svg.Attributes.height (toString y)
        , Svg.Attributes.width (toString x)
        , Svg.Attributes.class "elm-plot__inner"
        ]
        views


getMousePosition : Meta -> Json.Decoder (Interaction msg)
getMousePosition meta =
    Json.map2
        (\x y -> Internal <| Hovering meta ( x, y ))
        (Json.field "clientX" Json.float)
        (Json.field "clientY" Json.float)


sizeStyle : Oriented Float -> Style
sizeStyle { x, y } =
    [ ( "height", toPixels y ), ( "width", toPixels x ) ]


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
        values =
            toValuesOriented elements

        axisConfigs =
            toAxisConfigsOriented elements

        pileMetas =
            toPileMetas elements

        pileEdges =
            PileInternal.toPileEdges pileMetas

        ( top, right, bottom, left ) =
            margin

        xScale =
            getScale size.x range ( left, right ) ( 0, 0 ) values.x pileEdges.x

        yScale =
            getScale size.y domain ( top, bottom ) padding values.y pileEdges.y

        xTicks =
            getLastGetTickValues axisConfigs.x xScale

        yTicks =
            getLastGetTickValues axisConfigs.y yScale
    in
        { scale = Oriented xScale yScale
        , toSvgCoords = toSvgCoordsX xScale yScale
        , oppositeToSvgCoords = toSvgCoordsY xScale yScale
        , fromSvgCoords = fromSvgCoords xScale yScale
        , ticks = xTicks
        , oppositeTicks = yTicks
        , axisCrossings = getAxisCrossings axisConfigs.x yScale
        , oppositeAxisCrossings = getAxisCrossings axisConfigs.y xScale
        , toNearestX = toNearest values.x
        , getHintInfo = getHintInfo elements
        , pileMetas = pileMetas
        , id = id
        }


toValuesOriented : List (Element msg) -> Oriented (List Value)
toValuesOriented elements =
    List.foldr foldPoints [] elements
        |> List.unzip
        |> (\( x, y ) -> Oriented x y)


foldPoints : Element msg -> List Point -> List Point
foldPoints element allPoints =
    case element of
        Area config points ->
            allPoints ++ points

        Line config points ->
            allPoints ++ points

        Scatter config points ->
            allPoints ++ points

        Pile config pileElements _ ->
            allPoints ++ (PileInternal.toPilePoints pileElements)

        _ ->
            allPoints


flipMeta : Meta -> Meta
flipMeta ({ scale, toSvgCoords, oppositeToSvgCoords, ticks, oppositeTicks, axisCrossings, oppositeAxisCrossings } as meta) =
    { meta
        | scale = flipOriented scale
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
            flipMeta meta


getHintInfo : List (Element msg) -> Float -> HintInfo
getHintInfo elements xValue =
    HintInfo xValue <| List.foldr (collectYValues xValue) [] elements


toAxisConfigsOriented : List (Element msg) -> Oriented (List (AxisInternal.Config msg))
toAxisConfigsOriented =
    List.foldr foldAxisConfigs { x = [], y = [] }


foldAxisConfigs : Element msg -> Oriented (List (AxisInternal.Config msg)) -> Oriented (List (AxisInternal.Config msg))
foldAxisConfigs element axisConfigs =
    case element of
        Axis ({ orientation } as config) ->
            foldOriented (\configs -> config :: configs) orientation axisConfigs

        _ ->
            axisConfigs


getLastGetTickValues : List (AxisInternal.Config msg) -> Scale -> List Value
getLastGetTickValues axisConfigs =
    List.head axisConfigs
        |> Maybe.withDefault AxisInternal.defaultConfigX
        |> .tickConfig
        |> TickInternal.getValues


toPileMetas : List (Element msg) -> List PileMeta
toPileMetas =
    List.foldr foldPileMeta []


foldPileMeta : Element msg -> List PileMeta -> List PileMeta
foldPileMeta element allPileMetas =
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
            (List.map (PileInternal.toPoints >> collectYValue xValue) barsConfigs) ++ yValues

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
