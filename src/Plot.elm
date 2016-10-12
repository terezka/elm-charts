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


-- TYPES


type SerieType
    = Line
    | Area


type alias SerieConfig data =
    { serieType : SerieType
    , color : String
    , areaColor : String
    , toCoords : data -> List ( Float, Float )
    }


type alias PlotConfig data =
    { dimensions : ( Int, Int )
    , tickHeight : Int
    , series : List (SerieConfig data)
    }


type alias Coord =
    ( Float, Float )


type Axis
    = XAxis
    | YAxis



-- TODO: Move to config


totalTicks =
    ( 7, 6 )



-- VIEW


type alias AxisProps =
    { axis : Axis
    , lowest : Float
    , highest : Float
    , amountOfTicks : Int
    , tickHeight : Float
    , span : Float
    , toSvg : Float -> Float
    , addSvg : Coord -> Coord -> Coord
    }


getAxisProps : Axis -> PlotConfig data -> List data -> AxisProps
getAxisProps axis { dimensions, series } data =
    let
        getValue =
            case axis of
                XAxis ->
                    fst

                YAxis ->
                    snd

        values =
            List.map2 .toCoords series data
                |> List.concat
                |> List.map getValue

        edgeValues =
            ( getLowest values, getHighest values )

        ( lowestValue, highestValue ) =
            edgeValues

        span =
            abs lowestValue + abs highestValue

        delta =
            (toFloat (getValue dimensions)) / span

        origin =
            abs (getValue edgeValues) * delta

        toSvg =
            case axis of
                XAxis ->
                    (\x -> origin + delta * x)

                YAxis ->
                    (\y -> origin - delta * y)

        addSvg =
            case axis of
                XAxis ->
                    (\( x, y ) ( dx, dy ) -> ( x + dx, y + dy ))

                YAxis ->
                    (\( y, x ) ( dx, dy ) -> ( y - dy, x + dx ))

        amountOfTicks =
            getValue totalTicks
    in
        AxisProps
            axis
            lowestValue
            highestValue
            amountOfTicks
            7
            span
            toSvg
            addSvg



-- View plot


viewPlot : PlotConfig data -> List data -> Html msg
viewPlot config data =
    let
        xAxis =
            getAxisProps XAxis config data

        yAxis =
            getAxisProps YAxis config data

        toSvgCoordsX =
            (\( x, y ) -> ( xAxis.toSvg x, yAxis.toSvg y ))

        toSvgCoordsY =
            (\( y, x ) -> ( xAxis.toSvg x, yAxis.toSvg y ))

        toSvgCoordsOk =
            toSvgCoordsX

        -- The yAxis is switched, so cannot be used
        ( width, height ) =
            config.dimensions
    in
        Svg.svg
            [ Svg.Attributes.height (toString height)
            , Svg.Attributes.width (toString width)
            , style "padding: 50px;"
            ]
            [ Svg.g [] (List.map2 (viewSeries toSvgCoordsOk) config.series data)
            , viewAxis [ (ViewTick viewTickHtmlSpecial) ] xAxis toSvgCoordsX
            , viewAxis [] yAxis toSvgCoordsY
            ]



-- View axis


type AxisAttrs a
    = ViewTick (Coord -> Coord -> Svg.Svg a)
    | ViewLabel (Float -> Coord -> Svg.Svg a)


buildAxisConfig config attrs =
    case attrs of
        [] ->
            config

        attr :: rest ->
            case attr of
                ViewTick viewTick ->
                    buildAxisConfig { config | viewTickHtml = viewTick } rest
                ViewLabel viewLabel ->
                    buildAxisConfig { config | viewLabelHtml = viewLabel } rest


viewAxis : List (AxisAttrs a) -> AxisProps -> (Coord -> Coord) -> Svg.Svg a
viewAxis attrs axis toSvgCoords =
    let
        default = { viewTickHtml = viewTickHtmlDefault, viewLabelHtml = viewLabelHtmlDefault }
        
        { viewTickHtml, viewLabelHtml } = buildAxisConfig default attrs

        { span, amountOfTicks, lowest, highest } =
            axis

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
    in
        Svg.g []
            [ Svg.g [] (List.map (viewTick axis toSvgCoords viewTickHtml) ticks)
            , Svg.g
                [ Svg.Attributes.transform "translate(0, 5)" ]
                (List.map (viewLabel axis toSvgCoords viewLabelHtml) ticks)
            , Svg.g []
                [ Svg.line
                    (toPositionAttr x1 y1 x2 y2)
                    []
                ]
            ]



-- View tick


viewTick : AxisProps -> (Coord -> Coord) -> (Coord -> Coord -> Svg.Svg a) -> Float -> Svg.Svg a
viewTick { addSvg, tickHeight } toSvgCoords viewTickHtml tick =
    let
        -- for x: (v, 0), for y: (0, v)
        positionA =
            toSvgCoords ( tick, 0 )

        -- for x: (v, -h), for y: (-h, v)
        positionB =
            addSvg positionA ( 0, tickHeight )
    in
        viewTickHtml positionA positionB


viewTickHtmlDefault : Coord -> Coord -> Svg.Svg a
viewTickHtmlDefault (x1, y1) (x2, y2) =
    Svg.g []
        [ Svg.line
            (toPositionAttr x1 y1 x2 y2)
            []
        ]



viewTickHtmlSpecial : Coord -> Coord -> Svg.Svg a
viewTickHtmlSpecial (x1, y1) (x2, y2) =
    Svg.g []
        [ Svg.line
            ((toPositionAttr x1 y1 x2 y2) ++ [(Svg.Attributes.style "stroke: red;")] )
            []
        ]
        



-- View Label


viewLabel : AxisProps -> (Coord -> Coord) -> (Float -> Coord -> Svg.Svg a) -> Float -> Svg.Svg a
viewLabel { addSvg, tickHeight } toSvgCoords viewLabelHtml tick =
    let
        -- for x: (v, 0), for y: (0, v)
        ( x0, y0 ) =
            toSvgCoords ( tick, 0 )

        -- for x: (v, -h), for y: (-h, v)
        ( x, y ) =
            addSvg ( x0, y0 ) ( 0, 20 )
    in
        viewLabelHtml tick (x, y)


viewLabelHtmlDefault : Float -> Coord -> Svg.Svg a
viewLabelHtmlDefault tick (x, y) =
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


viewSeries : (Coord -> Coord) -> SerieConfig data -> data -> Svg.Svg a
viewSeries toSvgCoords config data =
    case config.serieType of
        Line ->
            viewSeriesLine toSvgCoords config data

        Area ->
            viewSeriesArea toSvgCoords config data



{- Draw area series -}


viewSeriesArea : (Coord -> Coord) -> SerieConfig data -> data -> Svg.Svg a
viewSeriesArea toSvgCoords config data =
    let
        allCoords =
            config.toCoords data

        range =
            List.map fst allCoords

        ( lowestX, highestX ) =
            ( getLowest range, getHighest range )

        svgCoords =
            List.map toSvgCoords allCoords

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
            String.join "" [ "stroke: ", config.color, "; fill:", config.areaColor ]
    in
        Svg.path
            [ d (startInstruction ++ instructions ++ endInstructions ++ "Z"), style style' ]
            []



{- Draw line series -}


viewSeriesLine : (Coord -> Coord) -> SerieConfig data -> data -> Svg.Svg a
viewSeriesLine toSvgCoords config data =
    let
        svgCoords =
            List.map toSvgCoords (config.toCoords data)

        ( startInstruction, tail ) =
            startPath svgCoords

        instructions =
            coordToInstruction "L" svgCoords

        style' =
            String.join "" [ "stroke: ", config.color, "; fill: none;" ]
    in
        Svg.path [ d (startInstruction ++ instructions), style style' ] []
