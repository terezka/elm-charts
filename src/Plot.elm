module Plot exposing (..)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (id)
import Html.Events exposing (on, onMouseOut)
import Json.Decode as Json exposing ((:=))
import Svg exposing (g)
import Svg.Attributes exposing (height, width, d, style)
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


type alias Position =
    { x : Int, y : Int }


-- CONFIGS


type Element msg
    = Axis (AxisConfig msg)
    | Area AreaConfig
    | Line LineConfig


-- Plot config

type alias PlotConfig =
    { dimensions : (Int, Int)
    , id : String
    }


type PlotAttr
    = Dimensions (Int, Int)
    | Id String


defaultPlotConfig =
    { dimensions = (800, 500)
    , id = "elm-plot"
    }


dimensions dimensions =
    Dimensions dimensions


id id =
    Id id


toPlotConfig : PlotAttr -> PlotConfig -> PlotConfig
toPlotConfig attr config =
    case attr of
        Dimensions dimensions -> 
            { config | dimensions = dimensions }

        Id id ->  -- TODO: Should eventually not be optional
            { config | id = id }


-- Axis config

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


defaultAxisConfig =
    { amountOfTicks = 10
    , viewTick = viewTickDefault
    , viewLabel = viewLabelDefault
    , orientation = X
    }


amountOfTicks amount =
    AmountOfTicks amount


viewTick view =
    ViewTick view


viewLabel view =
    ViewLabel view


toAxisConfig : AxisAttr msg -> AxisConfig msg -> AxisConfig msg
toAxisConfig attr config =
    case attr of
        AmountOfTicks amountOfTicks ->
            { config | amountOfTicks = amountOfTicks }

        ViewTick viewTick ->
            { config | viewTick = viewTick }

        ViewLabel viewLabel ->
            { config | viewLabel = viewLabel }


xAxis : List (AxisAttr Msg) -> Element Msg
xAxis attrs =
    Axis (List.foldr toAxisConfig defaultAxisConfig attrs)


yAxis : List (AxisAttr Msg) -> Element Msg
yAxis attrs =
    Axis (List.foldr toAxisConfig { defaultAxisConfig | orientation = Y } attrs)


-- Serie config

type alias AreaConfig =
    { fill : String
    , stroke : String
    , points : List Point
    }


type SerieAttr
    = Stroke String
    | Fill String


stroke stroke =
    Stroke stroke


fill fill =
    Fill fill


defaultAreaConfig =
    { fill = "#444444"
    , stroke = "#000000"
    , points = []
    }


toAreaConfig : SerieAttr -> AreaConfig -> AreaConfig
toAreaConfig attr config =
    case attr of
        Stroke stroke ->
            { config | stroke = stroke }

        Fill fill ->
            { config | fill = fill }


area : List SerieAttr -> List Point -> Element Msg
area attrs points =
    let 
        config = List.foldr toAreaConfig defaultAreaConfig attrs
    in
        Area { config | points = points }


type alias LineConfig =
    { stroke : String
    , points : List Point
    }


defaultLineConfig =
    { stroke = "#444444"
    , points = []
    }


toLineConfig : SerieAttr -> LineConfig -> LineConfig
toLineConfig attr config =
    case attr of
        Stroke stroke ->
            { config | stroke = stroke }

        _ ->
            config


line : List SerieAttr -> List Point -> Element Msg
line attrs points =
    let 
        config = List.foldr toLineConfig defaultLineConfig attrs
    in
        Line { config | points = points }



-- STATE


type State =
    State (Maybe Position)


init =
    State Nothing


type Msg
    = Hover Position
    | Unhover


update : Msg -> State -> State
update msg (State state) =
    case msg of
        Hover coords ->
            State (Just coords)

        Unhover ->
            State Nothing


-- VIEW


collectPoints : Element Msg -> List Point -> List Point
collectPoints element points =
    case element of
        Area config -> 
            points ++ config.points

        Line config -> 
            points ++ config.points

        _ ->
            points
            


plot : State -> List PlotAttr -> List (Element Msg) -> Svg.Svg Msg
plot state attrs elements =
    let
        plotConfig =
            List.foldr toPlotConfig defaultPlotConfig attrs

        points =
            List.foldr collectPoints [] elements

        xAxis =
            calculateAxis plotConfig.dimensions X points

        yAxis =
            calculateAxis plotConfig.dimensions Y points

        toSvgCoords (x, y) =
            ( xAxis.toSvg x, yAxis.toSvg -y )

        elementViews =
            List.foldl (viewElements xAxis yAxis toSvgCoords) [] elements
    in
        viewFrame plotConfig state elementViews



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


viewElements : AxisCalulation -> AxisCalulation -> (Point -> Point) -> Element Msg -> List (Svg.Svg Msg) -> List (Svg.Svg Msg)
viewElements xAxis yAxis toSvgCoords element views =
    case element of
        Area config -> 
            let
                view = viewArea toSvgCoords config
            in
                views ++ [view]

        Line config -> 
            let
                view = viewLine toSvgCoords config
            in
                views ++ [view]

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
                views ++ [view]
                


-- View frame 

getPosition : Json.Decoder Position
getPosition =
    Json.object2
        (\x y -> Position x y) 
        ("offsetX" := Json.int)
        ("offsetY" := Json.int)


viewFrame : PlotConfig -> State -> List (Svg.Svg Msg) -> Svg.Svg Msg
viewFrame config (State state) elements =
    let 
        ( width, height ) = config.dimensions

        tooltip =
            case state of
                Nothing ->
                    Html.div [] []

                Just { x, y } ->
                    Html.div
                        [ Html.Attributes.style
                            [ ("left", (toString x) ++ "px"), ("top", (toString y) ++ "px"), ("position", "absolute") ]
                        ]
                        [ Html.text "here" ]
    in
        Html.div
            [ Html.Attributes.id config.id
            , Html.Attributes.style [ ("margin", "50px"), ("position", "absolute") ]
            , Html.Events.onMouseOut Unhover 
            , on "mousemove" (Json.map Hover getPosition)
            ]
            [ Svg.svg
                [ Svg.Attributes.height (toString height)
                , Svg.Attributes.width (toString width)
                ]
                elements
            , tooltip
            ]



-- View axis



viewAxis : (Point -> Point) -> AxisCalulation -> AxisConfig Msg -> Svg.Svg Msg
viewAxis toSvgCoords calculations { amountOfTicks, viewTick, viewLabel } =
    let
        { span, lowest, highest } = calculations

        delta =
            span / (toFloat amountOfTicks + 1)

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


viewTickWrap : (Point -> Point) -> AxisCalulation -> (Point -> Point -> Svg.Svg Msg) -> Float -> Svg.Svg Msg
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


viewTickDefault : Point -> Point -> Svg.Svg Msg
viewTickDefault (x1, y1) (x2, y2) =
    Svg.g []
        [ Svg.line
            (toPositionAttr x1 y1 x2 y2)
            []
        ]


-- View Label


viewLabelWrap : (Point -> Point) -> AxisCalulation -> (Point -> Float -> Svg.Svg Msg) -> Float -> Svg.Svg Msg
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


toPositionAttr : Float -> Float -> Float -> Float -> List (Svg.Attribute Msg)
toPositionAttr x1 y1 x2 y2 =
    [ Svg.Attributes.style "stroke: #757575;"
    , Svg.Attributes.x1 (toString x1)
    , Svg.Attributes.y1 (toString y1)
    , Svg.Attributes.x2 (toString x2)
    , Svg.Attributes.y2 (toString y2)
    ]



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
flipToY (x, y) =
    (y, x)
