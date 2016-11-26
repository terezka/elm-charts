module Plot
    exposing
        ( plot
        , size
        , padding
        , plotClasses
        , plotStyle
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
        , gridValues
        , gridClasses
        , gridStyle
        , gridMirrorTicks
        , area
        , areaStyle
        , scatter
        , scatterStyle
        , scatterRadius
        , line
        , lineStyle
        , Element
        , MetaAttr
        , TickViewAttr
        , LabelViewAttr
        , AxisAttr
        , AreaAttr
        , ScatterAttr
        , LineAttr
        , Point
        , Style
        )

{-|
 This library aims to allow you to visualize a variety of graphs in
 an intuitve manner without comprimising flexibility regarding configuration.
 It is insprired by the elm-html api, using the `element attrs children` pattern.

# Elements
@docs Element, plot, area, scatter, line, xAxis, yAxis, Point, Style

# Configuration

## Meta configuration
@docs MetaAttr, size, padding, plotClasses, plotStyle

## Line configuration
@docs LineAttr, lineStyle

## Area configuration
@docs AreaAttr, areaStyle

## Scatter configuration
@docs ScatterAttr, scatterRadius, scatterStyle

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

## Grid configuration
@docs verticalGrid, horizontalGrid, gridMirrorTicks, gridValues, gridClasses, gridStyle

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


type Orientation
    = X
    | Y



-- CONFIGS


{-| Represents child element of the plot.
-}
type Element msg
    = Axis (AxisConfig msg)
    | Grid GridConfig
    | Line LineConfig
    | Area AreaConfig
    | Scatter ScatterConfig



-- META CONFIG


type alias MetaConfig =
    { size : ( Int, Int )
    , padding : ( Int, Int )
    , classes : List String
    , style : Style
    }


{-| The type representing an a meta configuration.
-}
type alias MetaAttr =
    MetaConfig -> MetaConfig


defaultMetaConfig =
    { size = ( 800, 500 )
    , padding = ( 0, 0 )
    , classes = []
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
    { config | style = style ++ defaultMetaConfig.style }


{-| Add classes to the svg element.

 Default: `[]`
-}
plotClasses : List String -> MetaConfig -> MetaConfig
plotClasses classes config =
    { config | classes = classes }


toMetaConfig : List MetaAttr -> MetaConfig
toMetaConfig attrs =
    List.foldr (<|) defaultMetaConfig attrs



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


toTickView : List TickViewAttr -> TickView msg
toTickView attrs =
    defaultTickView (List.foldl (<|) defaultTickViewConfig attrs)


toTickViewDynamic : TickAttrFunc -> TickView msg
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


toLabelView : List LabelViewAttr -> LabelView msg
toLabelView attrs =
    defaultLabelView (List.foldl (<|) defaultLabelViewConfig attrs)


toLabelViewDynamic : LabelAttrFunc -> LabelView msg
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
axisStyle : Style -> AxisConfig msg -> AxisConfig msg
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
axisLineStyle : Style -> AxisConfig msg -> AxisConfig msg
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
tickValues : List Float -> AxisConfig msg -> AxisConfig msg
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
tickDelta : Float -> AxisConfig msg -> AxisConfig msg
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
tickConfigView : List TickViewAttr -> AxisConfig msg -> AxisConfig msg
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
tickConfigViewFunc : TickAttrFunc -> AxisConfig msg -> AxisConfig msg
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
tickCustomView : (Float -> Svg.Svg msg) -> AxisConfig msg -> AxisConfig msg
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
tickCustomViewIndexed : (Int -> Float -> Svg.Svg msg) -> AxisConfig msg -> AxisConfig msg
tickCustomViewIndexed view config =
    { config | tickView = (\_ -> view) }


{-| Remove tick at origin. Useful when two axis' are crossing and you do not
 want the origin the be cluttered with labels.

    main =
        plot
            []
            [ xAxis [ tickRemoveZero ] ]
-}
tickRemoveZero : AxisConfig msg -> AxisConfig msg
tickRemoveZero config =
    { config | axisCrossing = True }


{-| Add a list of values where labels will be added.

    main =
        plot
            []
            [ xAxis [ labelValues [ 20, 40, 60 ] ] ]
-}
labelValues : List Float -> AxisConfig msg -> AxisConfig msg
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
labelFilter : (Int -> Float -> Bool) -> AxisConfig msg -> AxisConfig msg
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
labelConfigView : List LabelViewAttr -> AxisConfig msg -> AxisConfig msg
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
labelConfigViewFunc : LabelAttrFunc -> AxisConfig msg -> AxisConfig msg
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
labelCustomView : (Float -> Svg.Svg msg) -> AxisConfig msg -> AxisConfig msg
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
labelCustomViewIndexed : (Int -> Float -> Svg.Svg msg) -> AxisConfig msg -> AxisConfig msg
labelCustomViewIndexed view config =
    { config | labelView = (\_ -> view) }


{-| This returns an axis element resulting in an x-axis being rendered in your plot.

    main =
        plot [] [ xAxis [] ]
-}
xAxis : List (AxisAttr msg) -> Element msg
xAxis attrs =
    Axis (List.foldl (<|) defaultAxisConfig attrs)


{-| This returns an axis element resulting in an y-axis being rendered in your plot.

    main =
        plot [] [ yAxis [] ]
-}
yAxis : List (AxisAttr msg) -> Element msg
yAxis attrs =
    Axis (List.foldl (<|) { defaultAxisConfig | orientation = Y } attrs)



-- GRID CONFIG


type GridValues
    = GridMirrorTicks
    | GridCustomValues (List Float)


type alias GridConfig =
    { values : GridValues
    , style : Style
    , classes : List String
    , orientation : Orientation
    }


{-| The type representing an grid configuration.
-}
type alias GridAttr =
    GridConfig -> GridConfig


defaultGridConfig =
    { values = GridMirrorTicks
    , style = []
    , classes = []
    , orientation = X
    }


{-| Adds grid lines where the ticks on the corresponding axis are.

    main =
        plot
            []
            [ verticalGrid [ gridMirrorTicks ]
            , xAxis []
            ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `gridValues` attribute, then this attribute will have no effect.
-}
gridMirrorTicks : GridConfig -> GridConfig
gridMirrorTicks config =
    { config | values = GridMirrorTicks }


{-| Specify a list of ticks where you want grid lines drawn.

    plot [] [ verticalGrid [ gridValues [ 1, 2, 4, 8 ] ] ]

 **Note:** If in the list of axis attributes, this attribute is followed by a
 `gridMirrorTicks` attribute, then this attribute will have no effect.
-}
gridValues : List Float -> GridConfig -> GridConfig
gridValues values config =
    { config | values = GridCustomValues values }


{-| Specify styles for the gridlines.

    plot
        []
        [ verticalGrid
            [ gridMirrorTicks
            , gridStyle myGridStyles
            ]
        ]

 Remember that if you do not specify either `gridMirrorTicks`
 or `gridValues`, then we will default to not showing any grid lines.
-}
gridStyle : Style -> GridConfig -> GridConfig
gridStyle style config =
    { config | style = style }


{-| Specify classes for the grid.

    plot
        []
        [ verticalGrid
            [ gridMirrorTicks
            , gridClasses [ "my-class" ]
            ]
        ]

 Remember that if you do not specify either `gridMirrorTicks`
 or `gridValues`, then we will default to not showing any grid lines.
-}
gridClasses : List String -> GridConfig -> GridConfig
gridClasses classes config =
    { config | classes = classes }


{-| This returns an grid element resulting in vertical grid lines being rendered in your plot.

    main =
        plot [] [ horizontalGrid [] ]
-}
horizontalGrid : List GridAttr -> Element msg
horizontalGrid attrs =
    Grid (List.foldr (<|) defaultGridConfig attrs)


{-| This returns an axis element resulting in horizontal grid lines being rendered in your plot.

    main =
        plot [] [ verticalGrid [] ]
-}
verticalGrid : List GridAttr -> Element msg
verticalGrid attrs =
    Grid (List.foldr (<|) { defaultGridConfig | orientation = Y } attrs)



-- SCATTER CONFIG


type alias ScatterConfig =
    { style : Style
    , points : List Point
    , radius : Float
    }


{-| The type representing an scatter configuration.
-}
type alias ScatterAttr =
    ScatterConfig -> ScatterConfig


defaultScatterConfig : { style : List a, points : List b, radius : Float }
defaultScatterConfig =
    { style = []
    , points = []
    , radius = 5
    }


{-| Add styles to your scatter series

    main =
        plot
            []
            [ scatter
                [ scatterStyle
                    [ ( "stroke", "deeppink" )
                    , ( "opacity", "0.5" ) ]
                    ]
                , scatterRadius 4
                ]
                scatterDataPoints
            ]
-}
scatterStyle : Style -> ScatterConfig -> ScatterConfig
scatterStyle style config =
    { config | style = style }


{-| Add a radius to your scatter circles

    main =
        plot
            []
            [ scatter
                [ scatterStyle
                    [ ( "stroke", "deeppink" )
                    , ( "opacity", "0.5" ) ]
                    ]
                , scatterRadius 4
                ]
                scatterDataPoints
            ]
-}
scatterRadius : Float -> ScatterConfig -> ScatterConfig
scatterRadius radius config =
    { config | radius = radius }


{-| This returns a scatter element resulting in a scatter series rendered in your plot.

    main =
        plot [] [ scatter []  [ ( 0, -2 ), ( 2, 0 ), ( 3, 1 ) ] ]
-}
scatter : List ScatterAttr -> List Point -> Element msg
scatter attrs points =
    let
        config =
            List.foldr (<|) defaultScatterConfig attrs
    in
        Scatter { config | points = points }



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



-- VIEW


parsePlot : List MetaAttr -> List (Element msg) -> Svg.Svg msg
parsePlot attr elements =
    let
        metaConfig =
            toMetaConfig attr

        plotProps =
            getPlotProps metaConfig elements
    in
        viewPlot metaConfig (viewElements plotProps elements)


viewPlot : MetaConfig -> List (Svg.Svg msg) -> Svg.Svg msg
viewPlot { size, style, classes } children =
    let
        ( width, height ) =
            size
    in
        Svg.svg
            [ Svg.Attributes.height (toString height)
            , Svg.Attributes.width (toString width)
            , Svg.Attributes.style (toStyle style)
            , Svg.Attributes.class (String.join " " classes)
            ]
            children



-- VIEW ELEMENTS


viewElements : PlotProps -> List (Element msg) -> List (Svg.Svg msg)
viewElements plotProps elements =
    List.foldr (viewElement plotProps) [] elements


viewElement : PlotProps -> Element msg -> List (Svg.Svg msg) -> List (Svg.Svg msg)
viewElement plotProps element views =
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
                (viewAxis plotPropsFitted config) :: views

        Grid config ->
            let
                plotPropsFitted =
                    case config.orientation of
                        X ->
                            plotProps

                        Y ->
                            flipToY plotProps
            in
                (viewGrid plotPropsFitted config) :: views

        Line config ->
            (viewLine plotProps config) :: views

        Area config ->
            (viewArea plotProps config) :: views

        Scatter config ->
            (viewScatter plotProps config) :: views



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


viewAxis : PlotProps -> AxisConfig msg -> Svg.Svg msg
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
            [ viewGridLine toSvgCoords scale axisLineStyle 0
            , Svg.g [] (List.map (placeTick plotProps (tickView orientation)) tickPositions)
            , Svg.g [] (List.map (placeTick plotProps (labelView orientation)) labelPositions)
            ]


placeTick : PlotProps -> (Int -> Float -> Svg.Svg msg) -> ( Int, Float ) -> Svg.Svg msg
placeTick { toSvgCoords } view ( index, tick ) =
    Svg.g [ Svg.Attributes.transform (toTranslate (toSvgCoords ( tick, 0 ))) ] [ view index tick ]


defaultTickView : TickViewConfig -> Orientation -> Int -> Float -> Svg.Svg msg
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


defaultTickViewDynamic : TickAttrFunc -> Orientation -> Int -> Float -> Svg.Svg msg
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


defaultLabelView : LabelViewConfig -> Orientation -> Int -> Float -> Svg.Svg msg
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


defaultLabelViewDynamic : LabelAttrFunc -> Orientation -> Int -> Float -> Svg.Svg msg
defaultLabelViewDynamic toLabelAttrs orientation index float =
    let
        labelView =
            toLabelView (toLabelAttrs index float)
    in
        labelView orientation index float



-- VIEW GRID


getGridPositions : List Float -> GridValues -> List Float
getGridPositions tickValues values =
    case values of
        GridMirrorTicks ->
            tickValues

        GridCustomValues customValues ->
            customValues


viewGrid : PlotProps -> GridConfig -> Svg.Svg msg
viewGrid { scale, toSvgCoords, oppositeTicks } { values, style, classes } =
    let
        positions =
            getGridPositions oppositeTicks values
    in
        Svg.g
            [ Svg.Attributes.class (String.join " " classes) ]
            (List.map (viewGridLine toSvgCoords scale style) positions)


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


viewArea : PlotProps -> AreaConfig -> Svg.Svg a
viewArea { toSvgCoords } { points, style } =
    let
        range =
            List.map Tuple.first points

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


viewScatter : PlotProps -> ScatterConfig -> Svg.Svg a
viewScatter { toSvgCoords } { points, style, radius } =
    let
        svgPoints =
            List.map toSvgCoords points
    in
        Svg.g
            [ Svg.Attributes.style (toStyle style) ]
            (List.map (toSvgCircle radius) svgPoints)


toSvgCircle : Float -> Point -> Svg.Svg a
toSvgCircle radius point =
    Svg.circle
        [ Svg.Attributes.cx (toString (Tuple.first point))
        , Svg.Attributes.cy (toString (Tuple.second point))
        , Svg.Attributes.r (toString radius)
        ]
        []



-- VIEW LINE


viewLine : PlotProps -> LineConfig -> Svg.Svg a
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



-- CALCULATE SCALES


type alias AxisScale =
    { range : Float
    , lowest : Float
    , highest : Float
    , length : Float
    }


type alias PlotProps =
    { scale : AxisScale
    , oppositeScale : AxisScale
    , toSvgCoords : Point -> Point
    , oppositeToSvgCoords : Point -> Point
    , ticks : List Float
    , oppositeTicks : List Float
    }


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


getPlotProps : MetaConfig -> List (Element msg) -> PlotProps
getPlotProps { size, padding } elements =
    let
        ( xValues, yValues ) =
            List.unzip (List.foldr collectPoints [] elements)

        ( width, height ) =
            size

        xScale =
            getScales width ( 0, 0 ) xValues

        yScale =
            getScales height padding yValues

        xTicks =
            getLastGetTickValues X elements <| xScale

        yTicks =
            getLastGetTickValues Y elements <| yScale
    in
        { scale = xScale
        , oppositeScale = yScale
        , toSvgCoords = toSvgCoordsX xScale yScale
        , oppositeToSvgCoords = toSvgCoordsY xScale yScale
        , ticks = xTicks
        , oppositeTicks = yTicks
        }


flipToY : PlotProps -> PlotProps
flipToY { scale, oppositeScale, toSvgCoords, oppositeToSvgCoords, ticks, oppositeTicks } =
    { scale = oppositeScale
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


getAxisConfig : Orientation -> Element msg -> Maybe (AxisConfig msg) -> Maybe (AxisConfig msg)
getAxisConfig orientation element lastConfig =
    case element of
        Axis config ->
            if config.orientation == orientation then
                Just config
            else
                lastConfig

        _ ->
            lastConfig


getLastGetTickValues : Orientation -> List (Element msg) -> AxisScale -> List Float
getLastGetTickValues orientation elements =
    List.foldl (getAxisConfig orientation) Nothing elements
        |> Maybe.withDefault defaultAxisConfig
        |> .toTickValues



-- Collect points


collectPoints : Element msg -> List Point -> List Point
collectPoints element allPoints =
    case element of
        Area { points } ->
            allPoints ++ points

        Scatter { points } ->
            allPoints ++ points

        Line { points } ->
            allPoints ++ points

        _ ->
            allPoints



-- Helpers


(?) : Orientation -> a -> a -> a
(?) orientation x y =
    case orientation of
        X ->
            x

        Y ->
            y
