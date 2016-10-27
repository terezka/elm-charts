module Plot
    exposing
        ( plot
        , dimensions
        , area
        , line
        , horizontalGrid
        , verticalGrid
        , xAxis
        , yAxis
        , tickList
        , amountOfTicks
        , customViewTick
        , customViewLabel
        , axisLineStyle
        , gridStyle
        , gridTicks
        , stroke
        , fill
        , Point
        )

import Html exposing (Html, button, div, text)
import Html.Events exposing (on, onMouseOut)
import Html.Attributes exposing (id)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, d, style)
import String
import Debug
import Helpers exposing (..)


type alias Point =
    ( Float, Float )


type alias Style =
    List ( String, String )


type alias Position =
    { x : Int, y : Int }



-- CONFIGS


type Element msg
    = Axis (AxisConfig msg)
    | Grid GridConfig
    | Area AreaConfig
    | Line LineConfig



-- Plot config


type alias PlotConfig =
    { dimensions : ( Int, Int )
    , id : String
    }


type PlotAttr
    = Dimensions ( Int, Int )
    | Id String


defaultPlotConfig =
    { dimensions = ( 800, 500 )
    , id = "elm-plot"
    }


dimensions : (Int, Int) -> PlotAttr
dimensions =
    Dimensions


id : String -> PlotAttr
id =
    Id


toPlotConfig : PlotAttr -> PlotConfig -> PlotConfig
toPlotConfig attr config =
    case attr of
        Dimensions dimensions ->
            { config | dimensions = dimensions }

        Id id ->
            -- TODO: Should not be optional
            { config | id = id }



-- Axis config


type Orientation
    = X
    | Y


type TickConfig
    = TickAmount Int
    | TickList (List Float)


type alias AxisConfig msg =
    { tickConfig : TickConfig
    , customViewTick : Float -> Svg.Svg msg
    , customViewLabel : Float -> Svg.Svg msg
    , axisLineStyle : Style
    , orientation : Orientation
    }


type AxisAttr msg
    = TickConfigAttr TickConfig
    | ViewTick (Float -> Svg.Svg msg)
    | ViewLabel (Float -> Svg.Svg msg)
    | AxisLineStyle Style


defaultTickHtml : Orientation -> Float -> Svg.Svg msg
defaultTickHtml axis tick =
    let
        displacement =
            if axis == Y then
                toRotate 90 0 0
            else
                ""
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
            case axis of
                X ->
                    ( "text-anchor", "middle" ) :: commonStyle

                Y ->
                    ( "text-anchor", "end" ) :: commonStyle

        displacement =
            case axis of
                X ->
                    toTranslate ( 0, 12 )

                Y ->
                    toTranslate ( 0, 5 )
    in
        Svg.text'
            [ Svg.Attributes.transform displacement
            , Svg.Attributes.style (toStyle style)
            ]
            [ Svg.tspan [] [ Svg.text (toString (round tick)) ] ]


defaultAxisConfig =
    { tickConfig = (TickAmount 10)
    , customViewTick = defaultTickHtml X
    , customViewLabel = defaultLabelHtml X
    , axisLineStyle = [ ( "stroke", "#757575" ) ]
    , orientation = X
    }


amountOfTicks : Int -> AxisAttr msg
amountOfTicks amount =
    TickConfigAttr (TickAmount amount)


tickList : List Float -> AxisAttr msg
tickList ticks =
    TickConfigAttr (TickList ticks)


customViewTick : (Float -> Svg.Svg msg) -> AxisAttr msg
customViewTick =
    ViewTick


customViewLabel : (Float -> Svg.Svg msg) -> AxisAttr msg
customViewLabel =
    ViewLabel


axisLineStyle : List (String, String) -> AxisAttr msg
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


xAxis : List (AxisAttr msg) -> Element msg
xAxis attrs =
    Axis (List.foldr toAxisConfig defaultAxisConfig attrs)


yAxis : List (AxisAttr msg) -> Element msg
yAxis attrs =
    let
        defaultAxisConfigY =
            { defaultAxisConfig | orientation = Y, customViewLabel = defaultLabelHtml Y, customViewTick = defaultTickHtml Y }
    in
        Axis (List.foldr toAxisConfig defaultAxisConfigY attrs)



-- Grid config


type alias GridConfig =
    { ticks : Maybe (List Float)
    , styles : Style
    , orientation : Orientation
    }


type GridAttr
    = GridStyle Style
    | GridTicks (Maybe (List Float))


defaultGridConfig =
    { ticks = Nothing
    , styles = [ ( "stroke", "#757575" ) ]
    , orientation = X
    }


gridStyle : List (String, String) -> GridAttr
gridStyle =
    GridStyle


gridTicks : Maybe (List Float) -> GridAttr
gridTicks =
    GridTicks


toGridConfig : GridAttr -> GridConfig -> GridConfig
toGridConfig attr config =
    case attr of
        GridStyle styles ->
            { config | styles = styles }

        GridTicks ticks ->
            { config | ticks = ticks }


verticalGrid : List GridAttr -> Element msg
verticalGrid attrs =
    Grid (List.foldr toGridConfig defaultGridConfig attrs)


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


type SerieAttr
    = Stroke String
    | Fill String


stroke : String -> SerieAttr
stroke =
    Stroke


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
    , displaceSvg : Point -> Point -> Point
    }


axisCalulationInit : AxisCalulation
axisCalulationInit =
    AxisCalulation 0 0 0 identity (\a b -> a)


addEdgeValues : List Float -> AxisCalulation -> AxisCalulation
addEdgeValues values calculations =
    let
        lowest =
            getLowest values

        highest =
            getHighest values

        span =
            abs lowest + abs highest
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


addDisplaceSvg : Orientation -> AxisCalulation -> AxisCalulation
addDisplaceSvg orientation calculations =
    let
        displaceSvg ( x, y ) ( dx, dy ) =
            fromOrientation orientation ( x + dx, y + dy ) ( x - dy, y + dx )
    in
        { calculations | displaceSvg = displaceSvg }


calculateAxis : Orientation -> Int -> List Float -> AxisCalulation
calculateAxis orientation length values =
    axisCalulationInit
        |> addEdgeValues values
        |> addToSvg orientation length
        |> addDisplaceSvg orientation



-- VIEW


collectPoints : Element msg -> List Point -> List Point
collectPoints element allPoints =
    case element of
        Area { points } ->
            allPoints ++ points

        Line { points } ->
            allPoints ++ points

        _ ->
            allPoints


plot : List PlotAttr -> List (Element msg) -> Svg.Svg msg
plot attrs elements =
    let
        plotConfig =
            List.foldr toPlotConfig defaultPlotConfig attrs

        (width, height) =
            plotConfig.dimensions

        (xValues, yValues) =
            List.unzip (List.foldr collectPoints [] elements)

        xAxis =
            calculateAxis X width xValues

        yAxis =
            calculateAxis Y height yValues

        toSvgCoords ( x, y ) =
            ( xAxis.toSvg x, yAxis.toSvg -y )

        elementViews =
            List.foldr (viewElements xAxis yAxis toSvgCoords) [] elements
    in
        viewFrame plotConfig elementViews



-- Elements


viewElements : AxisCalulation -> AxisCalulation -> (Point -> Point) -> Element msg -> List (Svg.Svg msg) -> List (Svg.Svg msg)
viewElements xAxis yAxis toSvgCoords element views =
    case element of
        Area config ->
            (viewArea toSvgCoords config) :: views

        Line config ->
            (viewLine toSvgCoords config) :: views

        Grid config ->
            let
                ( calculations, toSvgCoordsAxis ) =
                    case config.orientation of
                        X ->
                            ( xAxis, toSvgCoords )

                        Y ->
                            ( yAxis, toSvgCoords << flipToY )
            in
                (viewGrid toSvgCoordsAxis calculations config) :: views

        Axis config ->
            let
                ( calculations, toSvgCoordsAxis ) =
                    case config.orientation of
                        X ->
                            ( xAxis, toSvgCoords )

                        Y ->
                            ( yAxis, toSvgCoords << flipToY )
            in
                (viewAxis toSvgCoordsAxis calculations config) :: views



-- View frame


viewFrame : PlotConfig -> List (Svg.Svg msg) -> Svg.Svg msg
viewFrame config elements =
    let
        ( width, height ) =
            config.dimensions
    in
        Html.div
            [ Html.Attributes.id config.id
            , Html.Attributes.style [ ( "margin", "50px" ), ( "position", "absolute" ) ]
            ]
            [ Svg.svg
                [ Svg.Attributes.height (toString height)
                , Svg.Attributes.width (toString width)
                ]
                elements
            ]



-- View axis


calulateTicks : AxisCalulation -> Int -> List Float
calulateTicks { span, lowest, highest } amountOfTicks =
    let
        delta =
            calculateStep highest amountOfTicks

        steps =
            round (span / delta)

        -- round up to nearest delta
        lowestTick =
            toFloat (ceiling (lowest / delta)) * delta

        toTick i =
            lowestTick + (toFloat i) * delta
    in
        List.map toTick [0..steps]


viewAxis : (Point -> Point) -> AxisCalulation -> AxisConfig msg -> Svg.Svg msg
viewAxis toSvgCoords calculations config =
    let
        { tickConfig, customViewTick, customViewLabel, axisLineStyle } =
            config

        ticks =
            case tickConfig of
                TickAmount amount ->
                    calulateTicks calculations amount

                TickList ticks ->
                    ticks

        tickViews =
            List.map (viewTick toSvgCoords calculations customViewTick) ticks

        labelViews =
            List.map (viewLabel toSvgCoords calculations customViewLabel) ticks
    in
        Svg.g []
            [ viewGridLine toSvgCoords calculations axisLineStyle 0
            , Svg.g [] tickViews
            , Svg.g [] labelViews
            ]



-- View tick


viewTick : (Point -> Point) -> AxisCalulation -> (Float -> Svg.Svg msg) -> Float -> Svg.Svg msg
viewTick toSvgCoords { displaceSvg } customViewTick tick =
    let
        position =
            toSvgCoords ( tick, 0 )
    in
        Svg.g
            [ Svg.Attributes.transform (toTranslate position) ]
            [ customViewTick tick ]



-- View Label


viewLabel : (Point -> Point) -> AxisCalulation -> (Float -> Svg.Svg msg) -> Float -> Svg.Svg msg
viewLabel toSvgCoords { displaceSvg } viewLabel tick =
    let
        ( x0, y0 ) =
            toSvgCoords ( tick, 0 )

        position =
            displaceSvg ( x0, y0 ) ( 0, 10 )
    in
        Svg.g
            [ Svg.Attributes.transform (toTranslate position) ]
            [ viewLabel tick ]



-- View grid


viewGrid : (Point -> Point) -> AxisCalulation -> GridConfig -> Svg.Svg msg
viewGrid toSvgCoords calculations { ticks, styles } =
    let
        positions =
            Maybe.withDefault [] ticks

        lines =
            List.map (viewGridLine toSvgCoords calculations styles) positions
    in
        Svg.g [] lines


viewGridLine : (Point -> Point) -> AxisCalulation -> List ( String, String ) -> Float -> Svg.Svg msg
viewGridLine toSvgCoords { displaceSvg, lowest, highest } styles tick =
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
