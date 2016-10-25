module Plot
    exposing 
        ( plot
        , dimensions
        , area
        , line
        , xAxis
        , yAxis
        , amountOfTicks
        , tickList
        , customViewTick
        , customViewLabel
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
import Helpers
    exposing
        ( startPath
        , toInstruction
        , getLowest
        , getHighest
        , coordToInstruction
        , toPositionAttr
        )


type alias Point =
    ( Float, Float )


type alias Position =
    { x : Int, y : Int }



-- CONFIGS


type Element msg
    = Axis (AxisConfig msg)
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


dimensions dimensions =
    Dimensions dimensions


id id =
    Id id


toPlotConfig : PlotAttr -> PlotConfig -> PlotConfig
toPlotConfig attr config =
    case attr of
        Dimensions dimensions ->
            { config | dimensions = dimensions }

        Id id ->
            -- TODO: Should eventually not be optional
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
    , customViewTick : Point -> Float -> Svg.Svg msg
    , customViewLabel : Point -> Float -> Svg.Svg msg
    , orientation : Orientation
    }


type AxisAttr msg
    = TickConfigAttr TickConfig
    | ViewTick (Point -> Float -> Svg.Svg msg)
    | ViewLabel (Point -> Float -> Svg.Svg msg)


defaultTickHtml : Orientation -> Point -> Float -> Svg.Svg msg
defaultTickHtml axis ( x1, y1 ) tick =
    let
        ( x2, y2 ) =
            case axis of
                X -> (x1, y1 + 7)
                Y -> (x1 - 7, y1)
    in
        Svg.g []
            [ Svg.line
                (toPositionAttr x1 y1 x2 y2)
                []
            ]


defaultLabelHtml : Orientation -> Point -> Float -> Svg.Svg a
defaultLabelHtml axis ( x, y ) tick =
    let
        style =
            case axis of
                X -> "stroke: #757575; text-anchor: middle;"
                Y -> "stroke: #757575; text-anchor: end;"

        displacement =
            case axis of
                X -> "translate(0, 12)"
                Y -> "translate(0, 5)"
    in
        Svg.text'
            [ Svg.Attributes.transform displacement
            , Svg.Attributes.x (toString x)
            , Svg.Attributes.y (toString y)
            , Svg.Attributes.style style
            ]
            [ Svg.tspan [] [ Svg.text (toString (round tick)) ] ]


defaultAxisConfig =
    { tickConfig = (TickAmount 10)
    , customViewTick = defaultTickHtml X
    , customViewLabel = defaultLabelHtml X
    , orientation = X
    }


amountOfTicks amount =
    TickConfigAttr (TickAmount amount)


tickList ticks =
    TickConfigAttr (TickList ticks)


customViewTick view =
    ViewTick view


customViewLabel view =
    ViewLabel view


toAxisConfig : AxisAttr msg -> AxisConfig msg -> AxisConfig msg
toAxisConfig attr config =
    case attr of
        TickConfigAttr tickConfig ->
            { config | tickConfig = tickConfig }

        ViewTick viewTick ->
            { config | customViewTick = viewTick }

        ViewLabel viewLabel ->
            { config | customViewLabel = viewLabel }


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



-- VIEW


collectPoints : Element msg -> List Point -> List Point
collectPoints element points =
    case element of
        Area config ->
            points ++ config.points

        Line config ->
            points ++ config.points

        _ ->
            points


plot : List PlotAttr -> List (Element msg) -> Svg.Svg msg
plot attrs elements =
    let
        plotConfig =
            List.foldr toPlotConfig defaultPlotConfig attrs

        points =
            List.foldr collectPoints [] elements

        xAxis =
            calculateAxis plotConfig.dimensions X points

        yAxis =
            calculateAxis plotConfig.dimensions Y points

        toSvgCoords ( x, y ) =
            ( xAxis.toSvg x, yAxis.toSvg -y )

        elementViews =
            List.foldl (viewElements xAxis yAxis toSvgCoords) [] elements
    in
        viewFrame plotConfig elementViews



-- Calculations


type alias AxisCalulation =
    { span : Float
    , lowest : Float
    , highest : Float
    , toSvg : Float -> Float
    , addSvg : Point -> Point -> Point
    }


calculateAxis : ( Int, Int ) -> Orientation -> List Point -> AxisCalulation
calculateAxis ( width, height ) orientation points =
    let
        values =
            case orientation of
                X ->
                    List.map fst points

                Y ->
                    List.map snd points

        lowest =
            getLowest values

        highest =
            getHighest values

        span =
            abs lowest + abs highest

        delta =
            case orientation of
                X ->
                    (toFloat width) / span

                Y ->
                    (toFloat height) / span

        value0 =
            case orientation of
                X ->
                    abs lowest * delta

                Y ->
                    abs highest * delta

        toSvg a =
            value0 + delta * a

        addSvg ( x, y ) ( dx, dy ) =
            case orientation of
                X ->
                    ( x + dx, y + dy )

                Y ->
                    ( x - dy, y + dx )
    in
        AxisCalulation span lowest highest toSvg addSvg



-- Elements


viewElements : AxisCalulation -> AxisCalulation -> (Point -> Point) -> Element msg -> List (Svg.Svg msg) -> List (Svg.Svg msg)
viewElements xAxis yAxis toSvgCoords element views =
    case element of
        Area config ->
            let
                view =
                    viewArea toSvgCoords config
            in
                views ++ [ view ]

        Line config ->
            let
                view =
                    viewLine toSvgCoords config
            in
                views ++ [ view ]

        Axis config ->
            let
                calculations =
                    case config.orientation of
                        X ->
                            xAxis

                        Y ->
                            yAxis

                toSvgCoordsAxis =
                    case config.orientation of
                        X ->
                            toSvgCoords

                        Y ->
                            toSvgCoords << flipToY

                view =
                    viewAxis toSvgCoordsAxis calculations config
            in
                views ++ [ view ]



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
            span / (toFloat amountOfTicks + 1)

        -- round up to nearest delta
        lowestTick =
            toFloat (ceiling (lowest / delta)) * delta

        toTick i =
            lowestTick + (toFloat i) * delta
    in
        List.map toTick [0..amountOfTicks]


viewAxis : (Point -> Point) -> AxisCalulation -> AxisConfig msg -> Svg.Svg msg
viewAxis toSvgCoords calculations { tickConfig, customViewTick, customViewLabel } =
    let
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
            [ viewAxisLine toSvgCoords calculations
            , Svg.g [] tickViews
            , Svg.g [] labelViews
            ]


viewAxisLine : (Point -> Point) -> AxisCalulation -> Svg.Svg msg
viewAxisLine toSvgCoords { lowest, highest } =
    let
        ( x1, y1 ) =
            toSvgCoords ( lowest, 0 )

        ( x2, y2 ) =
            toSvgCoords ( highest, 0 )
    in
        Svg.line
            (toPositionAttr x1 y1 x2 y2)
            []


-- View tick


viewTick : (Point -> Point) -> AxisCalulation -> (Point -> Float -> Svg.Svg msg) -> Float -> Svg.Svg msg
viewTick toSvgCoords { addSvg } customViewTick tick =
    let
        -- for x: (v, 0), for y: (0, v)
        positionA =
            toSvgCoords ( tick, 0 )
    in
        customViewTick positionA tick



-- View Label


viewLabel : (Point -> Point) -> AxisCalulation -> (Point -> Float -> Svg.Svg msg) -> Float -> Svg.Svg msg
viewLabel toSvgCoords { addSvg } viewLabel tick =
    let
        -- for x: (v, 0), for y: (0, v)
        ( x0, y0 ) =
            toSvgCoords ( tick, 0 )

        -- for x: (v, -h), for y: (-h, v)
        ( x, y ) =
            addSvg ( x0, y0 ) ( 0, 10 )
    in
        viewLabel ( x, y ) tick



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

