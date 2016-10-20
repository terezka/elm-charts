module Plot exposing (..)

import Html exposing (Html, button, div, text)
import Svg exposing (g)
import Svg.Attributes exposing (height, width, style, d)
import String
import Debug
import Helpers
    exposing
        ( startPath
        , toInstruction
        , getLowest
        , getHighest
        , coordToInstruction
        )


type alias Point = (Float, Float)



-- CONFIGS


type Element msg
    = Axis (AxisConfig msg)
    | Area AreaConfig
    | Line LineConfig



type alias PlotConfig =
    { dimensions : (Int, Int)
    , id : String
    }


type PlotAttr
    = Dimensions (Int, Int)
    | Id String


type Orientation
    = X
    | Y


type alias AxisConfig msg =
    { amountOfTicks : Int
    , viewTick : Point -> Point -> Svg.Svg msg
    , viewLabel : Point -> Float -> Svg.Svg msg
    , orientation : Orientation
    } 


type AxisAttr msg
    = AmountOfTicks Int
    | ViewTick (Point -> Point -> Svg.Svg msg)
    | ViewLabel (Point -> Float -> Svg.Svg msg)


type alias AreaConfig =
    { fill : String
    , stroke : String
    , points : List Point
    }


type alias LineConfig =
    { stroke : String
    , points : List Point
    }


type SerieAttr
    = Stroke String
    | Fill String



-- VIEW



defaultPlotConfig =
    { dimensions = (800, 500)
    , id = "elm-plot"
    }


dimensions dimensions =
    Dimensions dimensions


buildPlotConfig : PlotConfig -> List PlotAttr -> PlotConfig
buildPlotConfig config attrs =
    case attrs of
        [] -> config

        attr :: rest ->
            case attr of
                Dimensions dimensions -> 
                    buildPlotConfig { config | dimensions = dimensions } rest

                Id id ->  -- TODO: Should eventually not be optional
                    buildPlotConfig { config | id = id } rest


collectPoints : List Point -> List (Element msg) -> List Point
collectPoints points elements =
    case elements of
        [] -> points

        element :: rest ->
            case element of
                Area config -> 
                    collectPoints (points ++ config.points) rest

                Line config -> 
                    collectPoints (points ++ config.points) rest

                _ ->
                    collectPoints points rest


plot : List PlotAttr -> List (Element msg) -> Svg.Svg msg
plot attrs elementConfigs =
    let
        plotConfig =
            buildPlotConfig defaultPlotConfig attrs

        points =
            collectPoints [] elementConfigs

        xAxis =
            calculateAxis plotConfig.dimensions X points

        yAxis =
            calculateAxis plotConfig.dimensions Y points

        toSvgCoords (x, y) =
            ( xAxis.toSvg x, yAxis.toSvg -y )

        elements =
            viewElements xAxis yAxis toSvgCoords elementConfigs []
    in
        viewFrame plotConfig elements



-- Calculations


type alias AxisCalulation =
    { span : Float
    , lowest : Float
    , highest : Float
    , toSvg : Float -> Float
    , addSvg : Point -> Point -> Point
    }


calculateAxis : (Int, Int) -> Orientation -> List Point -> AxisCalulation
calculateAxis (width, height) orientation points =
    let
        values =
            case orientation of
                X -> List.map fst points 
                Y -> List.map snd points 

        lowest =
            getLowest values

        highest =
            getHighest values

        span =
            abs lowest + abs highest

        delta =
            case orientation of
                X -> (toFloat width) / span
                Y -> (toFloat height) / span

        value0 =
            case orientation of
                X -> abs lowest * delta
                Y -> abs highest * delta

        toSvg a = 
            value0 + delta * a

        addSvg ( x, y ) ( dx, dy ) =
            case orientation of
                X -> ( x + dx, y + dy )
                Y -> ( x - dy, y + dx )
    in
        AxisCalulation span lowest highest toSvg addSvg



-- Elements


viewElements : AxisCalulation -> AxisCalulation -> (Point -> Point) -> List (Element msg) -> List (Svg.Svg msg) -> List (Svg.Svg msg)
viewElements xAxis yAxis toSvgCoords elements views =
    let
        nextViewElements =
            viewElements xAxis yAxis toSvgCoords
    in
        case elements of
            [] -> views

            element :: rest ->
                case element of
                    Area config -> 
                        let
                            view = viewArea toSvgCoords config
                        in
                            nextViewElements rest (views ++ [view])

                    Line config -> 
                        let
                            view = viewLine toSvgCoords config
                        in
                            nextViewElements rest (views ++ [view])

                    Axis config ->
                        let
                            calculations =
                                case config.orientation of
                                    X -> xAxis
                                    Y -> yAxis

                            toSvgCoordsAxis =
                                case config.orientation of
                                    X -> toSvgCoords
                                    Y -> toSvgCoords << flipToY

                            view = viewAxis toSvgCoordsAxis calculations config
                        in
                            nextViewElements rest (views ++ [view])


-- View frame 


viewFrame : PlotConfig -> List (Svg.Svg msg) -> Svg.Svg msg
viewFrame config elements =
    let 
        ( width, height ) = config.dimensions
    in
        Svg.svg
            [ Svg.Attributes.height (toString height)
            , Svg.Attributes.width (toString width)
            , Svg.Attributes.id config.id
            , style "padding: 50px;"
            ]
            elements



-- View axis


viewTick view =
    ViewTick view


defaultAxisConfig =
    { amountOfTicks = 10
    , viewTick = viewTickDefault
    , viewLabel = viewLabelDefault
    , orientation = X
    }


buildAxisConfig : AxisConfig msg -> List (AxisAttr msg) -> AxisConfig msg
buildAxisConfig config attrs =
    case attrs of
        [] ->
            config

        attr :: rest ->
            case attr of
                AmountOfTicks amountOfTicks ->
                    buildAxisConfig { config | amountOfTicks = amountOfTicks } rest

                ViewTick viewTick ->
                    buildAxisConfig { config | viewTick = viewTick } rest

                ViewLabel viewLabel ->
                    buildAxisConfig { config | viewLabel = viewLabel } rest



xAxis : List (AxisAttr msg) -> Element msg
xAxis attrs =
    Axis (buildAxisConfig defaultAxisConfig attrs)


yAxis : List (AxisAttr msg) -> Element msg
yAxis attrs =
    Axis (buildAxisConfig { defaultAxisConfig | orientation = Y } attrs)


viewAxis : (Point -> Point) -> AxisCalulation -> AxisConfig msg -> Svg.Svg msg
viewAxis toSvgCoords calculations { amountOfTicks, viewTick, viewLabel } =
    let
        { span, lowest, highest } = calculations

        delta =
            span / (toFloat amountOfTicks)

        -- round up to nearest delta
        lowestTick =
            toFloat (ceiling (lowest / delta)) * delta

        indexes =
            [0..amountOfTicks]

        ticks =
            List.map (\i -> lowestTick + (toFloat i) * delta) indexes

        -- for x: (-l, 0), for y: (0, -l)
        ( x1, y1 ) =
            toSvgCoords ( lowest, 0 )

        -- for x: (h, 0), for y: (0, h)
        ( x2, y2 ) =
            toSvgCoords ( highest, 0 )

        toTick =
            viewTickWrap toSvgCoords calculations viewTick

        toLabel =
            viewLabelWrap toSvgCoords calculations viewLabel
    in
        Svg.g []
            [ Svg.g [] (List.map toTick ticks)
            , Svg.g
                [ Svg.Attributes.transform "translate(0, 5)" ]
                (List.map toLabel ticks)
            , Svg.g []
                [ Svg.line
                    (toPositionAttr x1 y1 x2 y2)
                    []
                ]
            ]



-- View tick


viewTickWrap : (Point -> Point) -> AxisCalulation -> (Point -> Point -> Svg.Svg a) -> Float -> Svg.Svg a
viewTickWrap toSvgCoords { addSvg } viewTick tick =
    let
        -- for x: (v, 0), for y: (0, v)
        positionA =
            toSvgCoords ( tick, 0 )

        -- for x: (v, -h), for y: (-h, v)
        positionB =
            addSvg positionA ( 0, 7 )
    in
        viewTick positionA positionB


viewTickDefault : Point -> Point -> Svg.Svg a
viewTickDefault (x1, y1) (x2, y2) =
    Svg.g []
        [ Svg.line
            (toPositionAttr x1 y1 x2 y2)
            []
        ]



-- View Label


viewLabelWrap : (Point -> Point) -> AxisCalulation -> (Point -> Float -> Svg.Svg a) -> Float -> Svg.Svg a
viewLabelWrap toSvgCoords { addSvg } viewLabel tick =
    let
        -- for x: (v, 0), for y: (0, v)
        ( x0, y0 ) =
            toSvgCoords ( tick, 0 )

        -- for x: (v, -h), for y: (-h, v)
        ( x, y ) =
            addSvg ( x0, y0 ) ( 0, 20 )
    in
        viewLabel (x, y) tick


viewLabelDefault : Point -> Float -> Svg.Svg a
viewLabelDefault (x, y) tick =
    Svg.text'
        [ Svg.Attributes.x (toString x)
        , Svg.Attributes.y (toString y)
        , Svg.Attributes.style "stroke: #757575; text-anchor: middle;"
        ]
        [ Svg.tspan [] [ Svg.text (toString (round tick)) ] ]
        


-- Make line coords


toPositionAttr : Float -> Float -> Float -> Float -> List (Svg.Attribute a)
toPositionAttr x1 y1 x2 y2 =
    [ Svg.Attributes.style "stroke: #757575;"
    , Svg.Attributes.x1 (toString x1)
    , Svg.Attributes.y1 (toString y1)
    , Svg.Attributes.x2 (toString x2)
    , Svg.Attributes.y2 (toString y2)
    ]



-- VIEW SERIES


stroke stroke =
    Stroke stroke


fill fill =
    Fill fill


defaultAreaConfig =
    { fill = "#444444"
    , stroke = "#000000"
    , points = []
    }


buildAreaConfig : AreaConfig -> List SerieAttr -> AreaConfig
buildAreaConfig config attrs =
    case attrs of
        [] ->
            config

        attr :: rest ->
            case attr of
                Stroke stroke ->
                    buildAreaConfig { config | stroke = stroke } rest

                Fill fill ->
                    buildAreaConfig { config | fill = fill } rest


area : List SerieAttr -> List Point -> Element msg
area attrs points =
    let 
        config = buildAreaConfig defaultAreaConfig attrs
    in
        Area { config | points = points }


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


defaultLineConfig =
    { stroke = "#444444"
    , points = []
    }


buildLineConfig : LineConfig -> List SerieAttr -> LineConfig
buildLineConfig config attrs =
    case attrs of
        [] ->
            config

        attr :: rest ->
            case attr of
                Stroke stroke ->
                    buildLineConfig { config | stroke = stroke } rest

                Fill _ ->
                    buildLineConfig config rest


line : List SerieAttr -> List Point -> Element msg
line attrs points =
    let 
        config = buildLineConfig defaultLineConfig attrs
    in
        Line { config | points = points }



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
flipToY (x, y) =
    (y, x)