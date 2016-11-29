port module Docs exposing (..)

import Svg
import Svg.Events
import Svg.Attributes
import Html exposing (Html, div, text, h1, img, a, br, span, code, pre, p)
import Html.Attributes exposing (style, src, href, class)
import Html.Events exposing (onClick)
import Plot as Plot exposing (Interaction(..))
import Plot.Line as Line
import Plot.Axis as Axis
import AreaChart
import MultiAreaChart
import GridChart
import MultiLineChart
import CustomTickChart
import ComposedChart


-- MODEL


type alias Model =
    { openSection : Maybe String
    , plotState : Plot.State
    }


initialModel =
    { openSection = Nothing
    , plotState = Plot.initialState
    }



-- UPDATE


type Msg
    = Toggle (Maybe String)
    | ClickTick
    | PlotInteraction (Plot.Interaction Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Toggle id ->
            ( { model | openSection = id }, Cmd.none )

        PlotInteraction interaction ->
            case interaction of
                Internal internalMsg ->
                    let
                        ( state, cmd ) =
                            Plot.update internalMsg model.plotState
                    in
                        ( { model | plotState = state }, Cmd.map PlotInteraction cmd )

                Custom customMsg ->
                    update customMsg model

        ClickTick ->
            ( model |> Debug.log "click tick!!!", Cmd.none )



-- VIEW


viewTitle : Model -> String -> String -> String -> Html Msg
viewTitle { openSection } title name codeString =
    let
        isOpen =
            case openSection of
                Just id ->
                    id == title

                Nothing ->
                    False

        codeStyle =
            if isOpen then
                ( "display", "block" )
            else
                ( "display", "none" )

        onClickMsg =
            if isOpen then
                Toggle Nothing
            else
                Toggle (Just title)
    in
        div [ style [ ( "margin", "100px auto 10px" ) ] ]
            [ div [] [ text title ]
            , p
                [ style
                    [ ( "color", "#9ea0a2" )
                    , ( "font-size", "12px" )
                    , ( "cursor", "pointer" )
                    ]
                , onClick onClickMsg
                ]
                [ text "View code snippet" ]
            , div
                [ style
                    (codeStyle
                        :: [ ( "text-align", "right" )
                           , ( "margin", "30px auto" )
                           , ( "width", "600px" )
                           , ( "position", "relative" )
                           ]
                    )
                ]
                [ Html.code
                    [ class "elm"
                    , style [ ( "text-align", "left" ) ]
                    ]
                    [ pre [] [ text codeString ] ]
                , a
                    [ style
                        [ ( "font-size", "12px" )
                        , ( "color", "#9ea0a2" )
                        , ( "position", "absolute" )
                        , ( "top", "0" )
                        , ( "right", "0" )
                        , ( "margin", "15px 20px" )
                        ]
                    , href (toUrl name)
                    ]
                    [ text "See full code" ]
                ]
            ]


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "width", "800px" )
            , ( "margin", "80px auto" )
            , ( "font-family", "sans-serif" )
            , ( "color", "#7F7F7F" )
            , ( "font-weight", "200" )
            , ( "text-align", "center" )
            ]
        ]
        [ img [ src "logo.png", style [ ( "width", "100px" ), ( "height", "100px" ) ] ] []
        , h1 [ style [ ( "font-weight", "200" ) ] ] [ text "Elm Plot" ]
        , div
            [ style [ ( "margin", "40px auto 100px" ) ] ]
            [ text "Find it on "
            , a
                [ href "https://github.com/terezka/elm-plot"
                , style [ ( "color", "#84868a" ) ]
                ]
                [ text "Github" ]
            ]
        , viewTitle model "Simple Area Chart" "AreaChart" AreaChart.code
        , Html.map PlotInteraction (AreaChart.chart)
        , viewTitle model "Multi Area Chart" "MultiAreaChart" MultiAreaChart.code
        , Html.map PlotInteraction MultiAreaChart.chart
        , viewTitle model "Line Chart" "MultiLineChart" MultiLineChart.code
        , Html.map PlotInteraction MultiLineChart.chart
        , viewTitle model "Grid" "GridChart" GridChart.code
        , Html.map PlotInteraction GridChart.chart
        , viewTitle model "Custom ticks and labels" "CustomTickChart" CustomTickChart.code
        , Html.map PlotInteraction CustomTickChart.chart
        , viewTitle model "Composable" "ComposedChart" ComposedChart.code
        , Html.map PlotInteraction <| ComposedChart.chart model.plotState
        , Html.map PlotInteraction <| testChart model.plotState
        , div
            [ style [ ( "margin", "100px auto 30px" ), ( "font-size", "14px" ) ] ]
            [ text "Made by "
            , a
                [ href "https://twitter.com/terexka"
                , style [ ( "color", "#84868a" ) ]
                ]
                [ text "@terexka" ]
            ]
        ]


testChart : Plot.State -> Svg.Svg (Interaction Msg)
testChart state =
    Plot.plot
        [ Plot.size ( 600, 300 )
        , Plot.margin ( 10, 20, 40, 20 )
        ]
        [ Plot.line
            [ Line.stroke "red"
            , Line.strokeWidth 2
            , Line.customAttrs [ Svg.Events.onClick <| Custom ClickTick ]
            ]
            [ (0, 1), (1, 2), (2, 0.5) ]
        , Plot.xAxis []
        ]


main =
    Html.program
        { init = ( initialModel, highlight "none" )
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }



-- Ports


port highlight : String -> Cmd msg



-- Helpers


toUrl : String -> String
toUrl end =
    "https://github.com/terezka/elm-plot/blob/master/docs/" ++ end ++ ".elm"
