module Plot
    exposing
        ( plot
        , xAxis
        , yAxis
        , axisClasses
        , axisStyle
        , axisLineStyle
        , tickValues
        , tickDelta
        , tickLength
        , tickWidth
        , tickClasses
        , tickStyle
        , tickConfigView
        , tickConfigViewFunc
        , tickCustomView
        , tickCustomViewIndexed
        , tickRemoveZero
        , labelValues
        , labelFilter
        , labelFormat
        , labelClasses
        , labelDisplace
        , labelStyle
        , labelConfigView
        , labelConfigViewFunc
        , labelCustomView
        , labelCustomViewIndexed
        , verticalGrid
        , horizontalGrid
        , tooltip
        , tooltipCustomView
        , tooltipRemoveLine
        , area
        , line
        , Element
        , TickViewAttr
        , LabelViewAttr
        , AxisAttr
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
@docs Element, plot, line, area, xAxis, yAxis, verticalGrid, horizontalGrid

# Configuration

## Axis configuration
@docs AxisAttr, axisClasses, axisStyle, axisLineStyle

### Tick values configuration
@docs tickValues, tickDelta, tickRemoveZero

### Tick view configuration
@docs TickViewAttr, tickConfigView, tickConfigViewFunc, tickLength, tickWidth, tickClasses, tickStyle, tickCustomView, tickCustomViewIndexed

### Label values configuration
@docs labelValues, labelFilter

### Label values configuration
@docs LabelViewAttr, labelConfigView, labelConfigViewFunc, labelFormat, labelDisplace, labelClasses, labelStyle, labelCustomView, labelCustomViewIndexed

## Tooltip configuration
@docs tooltip, tooltipRemoveLine, tooltipCustomView

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
import Plot.Grid as Grid
import Plot.Area as Area
import Plot.Line as Line




-- CONFIGS


{-| Represents child element of the plot.
-}
type Element msg
    = Axis (AxisConfig msg)
    | Tooltip (TooltipConfig msg) ( Float, Float )
    | Grid Grid.Config
    | Line Line.Config (List Point)
    | Area Area.Config (List Point)



-- TICK CONFIG


type alias TickViewConfig =
    { length : Int
    , width : Int
    , style : Style
    , classes : List String
    }


type alias TickView msg =
    Orientation -> Int -> Float -> Svg.Svg msg


type alias TickValues =
    AxisScale -> List Float


type alias TickAttrFunc =
    Int -> Float -> List TickViewAttr


{-| Type representing a tick view configuration attribute.
-}
type alias TickViewAttr =
    TickViewConfig -> TickViewConfig


defaultTickViewConfig : TickViewConfig
defaultTickViewConfig =
    { length = 7
    , width = 1
    , style = []
    , classes = []
    }


{-| Set the length of the tick.

    main =
        plot
            []
            [ xAxis
                [ tickConfigView [ tickLength 10 ] ]
            ]
-}
tickLength : Int -> TickViewConfig -> TickViewConfig
tickLength length config =
    { config | length = length }


{-| Set the width of the tick.

    main =
        plot
            []
            [ xAxis
                [ tickConfigView [ tickWidth 2 ] ]
            ]
-}
tickWidth : Int -> TickViewConfig -> TickViewConfig
tickWidth width config =
    { config | width = width }


{-| Add classes to the tick.

    main =
        plot
            []
            [ xAxis
                [ tickConfigView
                    [ tickClasses [ "my-class" ] ]
                ]
            ]
-}
tickClasses : List String -> TickViewConfig -> TickViewConfig
tickClasses classes config =
    { config | classes = classes }


{-| Sets the style of the tick

    main =
        plot
            []
            [ xAxis
                [ tickConfigView
                    [ tickStyle [ ( "stroke", "blue" ) ] ]
                ]
            ]
-}
tickStyle : Style -> TickViewConfig -> TickViewConfig
tickStyle style config =
    { config | style = style }


toTickView : List TickViewAttr -> TickView Msg
toTickView attrs =
    defaultTickView (List.foldl (<|) defaultTickViewConfig attrs)


toTickViewDynamic : TickAttrFunc -> TickView Msg
toTickViewDynamic toTickConfig =
    defaultTickViewDynamic toTickConfig



-- LABEL CONFIG


type alias LabelViewConfig =
    { displace : Maybe ( Int, Int )
    , format : Int -> Float -> String
    , style : Style
    , classes : List String
    }


type alias LabelView msg =
    Orientation -> Int -> Float -> Svg.Svg msg


type LabelValues
    = LabelCustomValues (List Float)
    | LabelCustomFilter (Int -> Float -> Bool)


type alias LabelAttrFunc =
    Int -> Float -> List LabelViewAttr


{-| Type representing a label view configuration attribute.
-}
type alias LabelViewAttr =
    LabelViewConfig -> LabelViewConfig


defaultLabelViewConfig : LabelViewConfig
defaultLabelViewConfig =
    { displace = Nothing
    , format = (\_ -> toString)
    , style = []
    , classes = []
    }


{-| Move the position of the label.

    main =
        plot
            []
            [ xAxis
                [ labelConfigView [ labelDisplace ( 0, 27 ) ] ]
            ]
-}
labelDisplace : ( Int, Int ) -> LabelViewConfig -> LabelViewConfig
labelDisplace displace config =
    { config | displace = Just displace }


{-| Format the label based on its value.

    main =
        plot
            []
            [ xAxis
                [ labelConfigView
                    [ labelFormat (\l -> toString l ++ " DKK") ]
                ]
            ]
-}
labelFormat : (Float -> String) -> LabelViewConfig -> LabelViewConfig
labelFormat format config =
    { config | format = always format }


{-| Add classes to the label.

    main =
        plot
            []
            [ xAxis
                [ labelConfigView
                    [ labelClasses [ "my-class" ] ]
                ]
            ]
-}
labelClasses : List String -> LabelViewConfig -> LabelViewConfig
labelClasses classes config =
    { config | classes = classes }


{-| Format the label based on its value and/or index.

    formatter : Int -> Float -> String
    formatter index value =
        if isOdd index then
            toString l ++ " DKK"
        else
            ""

    main =
        plot
            []
            [ xAxis
                [ labelConfigView [ labelFormat formatter ] ]
            ]
-}
labelFormatIndexed : (Int -> Float -> String) -> LabelViewConfig -> LabelViewConfig
labelFormatIndexed format config =
    { config | format = format }


{-| Move the position of the label.

    main =
        plot
            []
            [ xAxis
                [ labelConfigView
                    [ labelStyle [ ("stroke", "blue" ) ] ]
                ]
            ]
-}
labelStyle : Style -> LabelViewConfig -> LabelViewConfig
labelStyle style config =
    { config | style = style }


toLabelView : List LabelViewAttr -> LabelView Msg
toLabelView attrs =
    defaultLabelView (List.foldl (<|) defaultLabelViewConfig attrs)


toLabelViewDynamic : LabelAttrFunc -> LabelView Msg
toLabelViewDynamic toLabelConfig =
    defaultLabelViewDynamic toLabelConfig



-- AXIS CONFIG


type alias AxisConfig msg =
    { toTickValues : TickValues
    , tickView : TickView msg
    , labelValues : LabelValues
    , labelView : LabelView msg
    , axisLineStyle : Style
    , axisCrossing : Bool
    , style : Style
    , classes : List String
    , orientation : Orientation
    }


{-| The type representing an axis configuration.
-}
type alias AxisAttr msg =
    AxisConfig msg -> AxisConfig msg


defaultAxisConfig : AxisConfig Msg
defaultAxisConfig =
    { toTickValues = toTickValuesAuto
    , tickView = defaultTickView defaultTickViewConfig
    , labelValues = LabelCustomFilter (\a b -> True)
    , labelView = defaultLabelView defaultLabelViewConfig
    , style = []
    , classes = []
    , axisLineStyle = []
    , axisCrossing = False
    , orientation = X
    }


{-| Add style to the container holding your axis. Most properties are
 conveniently inherited by your ticks and labels.

    main =
        plot
            []
            [ xAxis [ axisStyle [ ( "stroke", "red" ) ] ] ]

 Default: `[]`
-}
axisStyle : Style -> AxisConfig Msg -> AxisConfig Msg
axisStyle style config =
    { config | style = style }


{-| Add classes to the container holding your axis.

    main =
        plot
            []
            [ xAxis [ axisClasses [ "my-class" ] ] ]

 Default: `[]`
-}
axisClasses : List String -> AxisConfig msg -> AxisConfig msg
axisClasses classes config =
    { config | classes = classes }


{-| Add styling to the axis line.

    main =
        plot
            []
            [ xAxis [ axisLineStyle [ ( "stroke", "blue" ) ] ] ]

 Default: `[]`
-}
axisLineStyle : Style -> AxisConfig Msg -> AxisConfig Msg
axisLineStyle style config =
    { config | axisLineStyle = style }


{-| Defines what ticks will be shown on the axis by specifying a list of values.

    main =
        plot
            []
            [ xAxis [ tickValues [ 0, 1, 2, 4, 8 ] ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickDelta` attribute, then this attribute will have no effect.
-}
tickValues : List Float -> AxisConfig Msg -> AxisConfig Msg
tickValues values config =
    { config | toTickValues = toTickValuesFromList values }


{-| Defines what ticks will be shown on the axis by specifying the delta between the ticks.
 The delta will be added from zero.

    main =
        plot
            []
            [ xAxis [ tickDelta 4 ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickValues` attribute, then this attribute will have no effect.
-}
tickDelta : Float -> AxisConfig Msg -> AxisConfig Msg
tickDelta delta config =
    { config | toTickValues = toTickValuesFromDelta delta }


{-| Defines how the tick will be displayed by specifying a list of tick view attributes.

    main =
        plot
            []
            [ xAxis
                [ tickConfigView
                    [ tickLength 10
                    , tickWidth 2
                    , tickStyle [ ( "stroke", "red" ) ]
                    ]
                ]
            ]

 If you do not define another view configuration,
 the default will be `[ tickLength 7, tickWidth 1, tickStyle [] ]`

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickCustomView`, `tickConfigViewFunc` or a `tickCustomViewIndexed` attribute,
 then this attribute will have no effect.
-}
tickConfigView : List TickViewAttr -> AxisConfig Msg -> AxisConfig Msg
tickConfigView tickAttrs config =
    { config | tickView = toTickView tickAttrs }


{-| Defines how the tick will be displayed by specifying a list of tick view attributes.

    toTickConfig : Int -> Float -> List TickViewAttr
    toTickConfig index tick =
        if isOdd index then
            [ tickLength 7
            , tickStyle [ ( "stroke", "#e4e3e3" ) ]
            ]
        else
            [ tickLength 10
            , tickStyle [ ( "stroke", "#b9b9b9" ) ]
            ]

    main =
        plot
            []
            [ xAxis
                [ tickConfigViewFunc toTickConfig ]
            ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickConfigView`, `tickCustomView` or a `tickCustomViewIndexed` attribute,
 then this attribute will have no effect.
-}
tickConfigViewFunc : TickAttrFunc -> AxisConfig Msg -> AxisConfig Msg
tickConfigViewFunc toTickAttrs config =
    { config | tickView = toTickViewDynamic toTickAttrs }


{-| Defines how the tick will be displayed by specifying a function which returns your tick html.

    viewTick : Float -> Svg.Svg a
    viewTick tick =
        text_
            [ transform ("translate(-5, 10)") ]
            [ tspan [] [ text "✨" ] ]

    main =
        plot [] [ xAxis [ tickCustomView viewTick ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickConfigView` or a `tickCustomViewIndexed` attribute, then this attribute will have no effect.
-}
tickCustomView : (Float -> Svg.Svg Msg) -> AxisConfig Msg -> AxisConfig Msg
tickCustomView view config =
    { config | tickView = (\_ _ -> view) }


{-| Same as `tickCustomConfig`, but the functions is also passed a value
 which is how many ticks away the current tick is from the zero tick.

    viewTick : Int -> Float -> Svg.Svg a
    viewTick index tick =
        text_
            [ transform ("translate(-5, 10)") ]
            [ tspan
                []
                [ text (if isOdd index then "🌟" else "⭐") ]
            ]

    main =
        plot [] [ xAxis [ tickCustomViewIndexed viewTick ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `tickConfigView` or a `tickCustomView` attribute, then this attribute will have no effect.
-}
tickCustomViewIndexed : (Int -> Float -> Svg.Svg Msg) -> AxisConfig Msg -> AxisConfig Msg
tickCustomViewIndexed view config =
    { config | tickView = (\_ -> view) }


{-| Remove tick at origin. Useful when two axis' are crossing and you do not
 want the origin the be cluttered with labels.

    main =
        plot
            []
            [ xAxis [ tickRemoveZero ] ]
-}
tickRemoveZero : AxisConfig Msg -> AxisConfig Msg
tickRemoveZero config =
    { config | axisCrossing = True }


{-| Add a list of values where labels will be added.

    main =
        plot
            []
            [ xAxis [ labelValues [ 20, 40, 60 ] ] ]
-}
labelValues : List Float -> AxisConfig Msg -> AxisConfig Msg
labelValues filter config =
    { config | labelValues = LabelCustomValues filter }


{-| Add a filter determining which of the ticks are added a label. The first argument passed
 to the filter is a number describing how many ticks a way the current tick is. The second argument
 is the value of the tick.

    onlyEvenTicks : Int -> Float -> Bool
    onlyEvenTicks index value =
        rem 2 index == 0

    main =
        plot
            []
            [ xAxis [ labelValues onlyEvenTicks ] ]

 Default: `(\a b -> True)`

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `labelValues` attribute, then this attribute will have no effect.
-}
labelFilter : (Int -> Float -> Bool) -> AxisConfig Msg -> AxisConfig Msg
labelFilter filter config =
    { config | labelValues = LabelCustomFilter filter }


{-| Configure the label view specifying a list of label view attributes.

    main =
        plot
            []
            [ xAxis
                [ labelConfigView
                    [ labelFormat (\t -> toString t ++ " s") ]
                ]
            ]
-}
labelConfigView : List LabelViewAttr -> AxisConfig Msg -> AxisConfig Msg
labelConfigView attrs config =
    { config | labelView = toLabelView attrs }


{-| Configure the label view specifying a function returning a list of label view attributes.
 The function will be passed:
 1) An integer representing the amount of ticks away from the origin, the current tick is.
 2) A float value represeting the value of the tick.

    toLabelConfig : Int -> Float -> List TickViewAttr
    toLabelConfig index tick =
        if isOdd index then
            [ labelFormat (\t -> toString t ++ " s") ]
        else
            [ labelFormat (always "") ]

    main =
        plot
            []
            [ xAxis
                [ labelConfigViewFunc toLabelConfig ]
            ]
-}
labelConfigViewFunc : LabelAttrFunc -> AxisConfig Msg -> AxisConfig Msg
labelConfigViewFunc toAttrs config =
    { config | labelView = toLabelViewDynamic toAttrs }


{-| Add a custom view for rendering your label.

    viewLabel : Float -> Svg.Svg a
    viewLabel tick =
        text_ mySpecialAttributes mySpecialLabelDisplay

    main =
        plot
            []
            [ xAxis [ labelCustomView viewLabel ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `labelFormat` attribute, then this attribute will have no effect.
-}
labelCustomView : (Float -> Svg.Svg Msg) -> AxisConfig Msg -> AxisConfig Msg
labelCustomView view config =
    { config | labelView = (\_ _ -> view) }


{-| Same as `labelCustomView`, except this view is also passed the value being
 the amount of ticks the current tick is away from zero.

    viewLabel : Int -> Float -> Svg.Svg a
    viewLabel fromZero tick =
        let
            attrs =
                if isOdd fromZero then oddAttrs
                else evenAttrs
        in
            text_ attrs labelHtml

    main =
        plot
            []
            [ xAxis [ labelCustomViewIndexed viewLabel ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `labelFormat` attribute, then this attribute will have no effect.
-}
labelCustomViewIndexed : (Int -> Float -> Svg.Svg Msg) -> AxisConfig Msg -> AxisConfig Msg
labelCustomViewIndexed view config =
    { config | labelView = (\_ -> view) }


{-| This returns an axis element resulting in an x-axis being rendered in your plot.

    main =
        plot [] [ xAxis [] ]
-}
xAxis : List (AxisAttr Msg) -> Element Msg
xAxis attrs =
    Axis (List.foldl (<|) defaultAxisConfig attrs)


{-| This returns an axis element resulting in an y-axis being rendered in your plot.

    main =
        plot [] [ yAxis [] ]
-}
yAxis : List (AxisAttr Msg) -> Element Msg
yAxis attrs =
    Axis (List.foldl (<|) { defaultAxisConfig | orientation = Y } attrs)




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



-- AREA CONFIG


{-| This returns an area element resulting in an area serie rendered in your plot.

    main =
        plot [] [ area []  [ ( 0, -2 ), ( 2, 0 ), ( 3, 1 ) ] ]
-}
area : List Area.Attribute -> List Point -> Element Msg
area attrs points =
    Area (Area.toConfig attrs) points


-- LINE CONFIG


{-| This returns a line element resulting in an line serie rendered in your plot.

    main =
        plot [] [ line [] [ ( 0, 1 ), ( 2, 2 ), ( 3, 4 ) ] ]
-}
line : List Line.Attribute -> List Point -> Element Msg
line attrs points =
    Line (List.foldr (<|) Line.defaultConfig attrs) points



-- TOOLTIP


type alias TooltipConfig msg =
    { view : TooltipInfo -> Bool -> Html msg
    , showLine : Bool
    , lineStyle : Style
    }


defaultTooltipConfig : TooltipConfig Msg
defaultTooltipConfig =
    { view = defaultTooltipView
    , showLine = True
    , lineStyle = []
    }


{-| The type representing a tooltip configuration.
-}
type alias TooltipAttr msg =
    TooltipConfig msg -> TooltipConfig msg


{-| -}
tooltipRemoveLine : TooltipConfig msg -> TooltipConfig msg
tooltipRemoveLine config =
    { config | showLine = False }


{-| -}
tooltipCustomView : (TooltipInfo -> Bool -> Svg.Svg msg) -> TooltipConfig msg -> TooltipConfig msg
tooltipCustomView view config =
    { config | view = view }


{-| -}
tooltip : List (TooltipAttr Msg) -> ( Float, Float ) -> Element Msg
tooltip attrs position =
    Tooltip (List.foldr (<|) defaultTooltipConfig attrs) position



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
                ( (viewAxis plotPropsFitted config) :: svgViews, htmlViews )

        Tooltip config position ->
            let
                tooltipView = viewTooltip plotProps config position
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



-- VIEW AXIS


filterTicks : Bool -> List Float -> List Float
filterTicks axisCrossing ticks =
    if axisCrossing then
        List.filter (\p -> p /= 0) ticks
    else
        ticks


zipWithDistance : Bool -> Int -> Int -> Float -> ( Int, Float )
zipWithDistance hasZero lowerThanZero index tick =
    let
        distance =
            if tick == 0 then
                0
            else if tick > 0 && hasZero then
                index - lowerThanZero
            else if tick > 0 then
                index - lowerThanZero + 1
            else
                lowerThanZero - index
    in
        ( distance, tick )


indexTicks : List Float -> List ( Int, Float )
indexTicks ticks =
    let
        lowerThanZero =
            List.length (List.filter (\i -> i < 0) ticks)

        hasZero =
            List.any (\t -> t == 0) ticks
    in
        List.indexedMap (zipWithDistance hasZero lowerThanZero) ticks


viewAxis : PlotProps -> AxisConfig Msg -> Svg.Svg Msg
viewAxis plotProps { toTickValues, tickView, labelView, labelValues, style, classes, axisLineStyle, axisCrossing, orientation } =
    let
        { scale, oppositeScale, toSvgCoords, oppositeToSvgCoords } =
            plotProps

        tickPositions =
            toTickValues scale
                |> filterTicks axisCrossing
                |> indexTicks

        labelPositions =
            case labelValues of
                LabelCustomValues values ->
                    indexTicks values

                LabelCustomFilter filter ->
                    List.filter (\( a, b ) -> filter a b) tickPositions
    in
        Svg.g
            [ Svg.Attributes.style (toStyle style)
            , Svg.Attributes.class (String.join " " classes)
            ]
            [ Grid.viewLine plotProps axisLineStyle 0
            , Svg.g [] (List.map (placeTick plotProps (tickView orientation)) tickPositions)
            , Svg.g [] (List.map (placeTick plotProps (labelView orientation)) labelPositions)
            ]


placeTick : PlotProps -> (Int -> Float -> Svg.Svg Msg) -> ( Int, Float ) -> Svg.Svg Msg
placeTick { toSvgCoords } view ( index, tick ) =
    Svg.g [ Svg.Attributes.transform (toTranslate (toSvgCoords ( tick, 0 ))) ] [ view index tick ]


defaultTickView : TickViewConfig -> Orientation -> Int -> Float -> Svg.Svg Msg
defaultTickView { length, width, style, classes } orientation _ _ =
    let
        displacement =
            (?) orientation "" (toRotate 90 0 0)

        styleFinal =
            style ++ [ ( "stroke-width", (toString width) ++ "px" ) ]
    in
        Svg.line
            [ Svg.Attributes.style (toStyle styleFinal)
            , Svg.Attributes.y2 (toString length)
            , Svg.Attributes.transform displacement
            , Svg.Attributes.class (String.join " " classes)
            ]
            []


defaultTickViewDynamic : TickAttrFunc -> Orientation -> Int -> Float -> Svg.Svg Msg
defaultTickViewDynamic toTickAttrs orientation index float =
    let
        tickView =
            toTickView (toTickAttrs index float)
    in
        tickView orientation index float


defaultLabelStyleX : ( Style, ( Int, Int ) )
defaultLabelStyleX =
    ( [ ( "text-anchor", "middle" ) ], ( 0, 24 ) )


defaultLabelStyleY : ( Style, ( Int, Int ) )
defaultLabelStyleY =
    ( [ ( "text-anchor", "end" ) ], ( -10, 5 ) )


defaultLabelView : LabelViewConfig -> Orientation -> Int -> Float -> Svg.Svg Msg
defaultLabelView { displace, format, style, classes } orientation index tick =
    let
        ( defaultStyle, defaultDisplacement ) =
            (?) orientation defaultLabelStyleX defaultLabelStyleY

        ( dx, dy ) =
            Maybe.withDefault defaultDisplacement displace
    in
        Svg.text_
            [ Svg.Attributes.transform (toTranslate ( toFloat dx, toFloat dy ))
            , Svg.Attributes.style (toStyle (defaultStyle ++ style))
            , Svg.Attributes.class (String.join " " classes)
            ]
            [ Svg.tspan [] [ Svg.text (format index tick) ] ]


defaultLabelViewDynamic : LabelAttrFunc -> Orientation -> Int -> Float -> Svg.Svg Msg
defaultLabelViewDynamic toLabelAttrs orientation index float =
    let
        labelView =
            toLabelView (toLabelAttrs index float)
    in
        labelView orientation index float



-- VIEW TOOLTIP


viewTooltip : PlotProps -> TooltipConfig Msg -> ( Float, Float ) -> Html.Html Msg
viewTooltip { toSvgCoords, scale, getTooltipInfo } { showLine, view } position =
    let
        info =
            getTooltipInfo (Tuple.first position)

        ( xSvg, ySvg ) =
            toSvgCoords (info.xValue, 0)

        flipped =
            xSvg < scale.length / 2

        lineView =
            if showLine then [ viewTooltipLine ( xSvg, ySvg ) ] else []
    in
        Html.div
            [ Html.Attributes.class "elm-plot__tooltip"
            , Html.Attributes.style [ ( "left", (toString xSvg) ++ "px" ) ]
            ]
            ((view info flipped) :: lineView)


viewTooltipLine : ( Float, Float ) -> Html.Html Msg
viewTooltipLine ( x, y ) =
    Html.div
        [ Html.Attributes.class "elm-plot__tooltip__line" 
        , Html.Attributes.style
            [ ( "left", (toString x) ++ "px" ) 
            , ( "height", toString y ++ "px")]
        ]
        []


defaultTooltipView : TooltipInfo -> Bool -> Html.Html Msg
defaultTooltipView { xValue, yValues } isLeftSide =
    let
        classes =
            [ ( "elm-plot__tooltip__default-view", True )
            , ( "elm-plot__tooltip__default-view--left", isLeftSide )
            , ( "elm-plot__tooltip__default-view--right", not isLeftSide )
            ]
    in
        Html.div
            [ Html.Attributes.classList classes ]
            [ Html.div [] [ Html.text ("X: " ++ toString xValue) ]
            , Html.div [] (List.indexedMap viewTooltipYValue yValues)
            ]


viewTooltipYValue : Int -> Maybe Float -> Html.Html Msg
viewTooltipYValue index yValue =
    let
        yValueDisplayed =
            case yValue of
                Just value ->
                    toString value

                Nothing ->
                    "No data"
    in
        Html.div []
            [ Html.span [] [ Html.text ("Serie " ++ toString index ++ ": ") ]
            , Html.span [] [ Html.text yValueDisplayed ]
            ]


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
        { scale
        , oppositeScale
        , toSvgCoords
        , oppositeToSvgCoords
        , ticks
        , oppositeTicks
        } = plotProps
    in
    { plotProps
    | scale = oppositeScale
    , oppositeScale = scale
    , toSvgCoords = oppositeToSvgCoords
    , oppositeToSvgCoords = toSvgCoords
    , ticks = oppositeTicks
    , oppositeTicks = ticks
    }



-- CALCULATE TICKS


getFirstTickValue : Float -> Float -> Float
getFirstTickValue delta lowest =
    ceilToNearest delta lowest


getTickCount : Float -> Float -> Float -> Float -> Int
getTickCount delta lowest range firstValue =
    floor ((range - (abs lowest - abs firstValue)) / delta)


getDeltaPrecision : Float -> Int
getDeltaPrecision delta =
    logBase 10 delta
        |> floor
        |> min 0
        |> abs


toTickValue : Float -> Float -> Int -> Float
toTickValue delta firstValue index =
    firstValue
        + (toFloat index)
        * delta
        |> Round.round (getDeltaPrecision delta)
        |> String.toFloat
        |> Result.withDefault 0


toTickValuesFromDelta : Float -> AxisScale -> List Float
toTickValuesFromDelta delta { lowest, range } =
    let
        firstValue =
            getFirstTickValue delta lowest

        tickCount =
            getTickCount delta lowest range firstValue
    in
        List.map (toTickValue delta firstValue) (List.range 0 tickCount)


toTickValuesFromCount : Int -> AxisScale -> List Float
toTickValuesFromCount appxCount scale =
    toTickValuesFromDelta (getTickDelta scale.range appxCount) scale


toTickValuesFromList : List Float -> AxisScale -> List Float
toTickValuesFromList values _ =
    values


toTickValuesAuto : AxisScale -> List Float
toTickValuesAuto =
    toTickValuesFromCount 10



-- GET LAST AXIS TICK CONFIG


getAxisConfig : Orientation -> Element Msg -> Maybe (AxisConfig Msg) -> Maybe (AxisConfig Msg)
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
        |> Maybe.withDefault defaultAxisConfig
        |> .toTickValues



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
    List.foldr (\(x, y) res -> if x == xValue then Just y else res) Nothing points



-- Helpers


(?) : Orientation -> a -> a -> a
(?) orientation x y =
    case orientation of
        X ->
            x

        Y ->
            y
