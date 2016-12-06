port module Docs exposing (..)

import Svg
import Svg.Events
import Svg.Attributes
import Html exposing (Html, div, text, h1, img, a, br, span, code, pre, p)
import Html.Attributes exposing (style, src, href, class)
import Html.Events exposing (onClick)
import Plot as Plot exposing (Interaction(..))
import Plot.Line as Line
import Plot.Area as Area
import Plot.Grid as Grid
import Plot.Axis as Axis
import Plot.Label as Label
import MultiAreaChart
import GridChart
import MultiLineChart
import CustomTickChart
import ComposedChart
import ScatterChart
import BarChart
import HintChart
import PlotAxis


-- MODEL


type alias PlotExample a =
    { title : String
    , fileName : String
    , view : Svg.Svg a
    , code : String
    }


type alias PlotExampleInteractive a =
    { title : String
    , fileName : String
    , view : Plot.State -> Svg.Svg (Interaction a)
    , code : String
    }


type alias Model =
    { openSection : Maybe String
    , hintExample : Plot.State
    , everythingExample : Plot.State
    }


initialModel =
    { openSection = Nothing
    , hintExample = Plot.initialState
    , everythingExample = Plot.initialState
    }



-- UPDATE

type PlotId
    = HintExample
    | EverythingExample


type Msg
    = Toggle (Maybe String)
    | PlotInteraction PlotId (Plot.Interaction Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Toggle id ->
            ( { model | openSection = id }, Cmd.none )

        PlotInteraction id interaction ->
            case interaction of
                Internal internalMsg ->
                    case id of
                        HintExample ->
                            let 
                                ( state, cmd ) = Plot.update internalMsg model.hintExample
                            in
                                ({ model | hintExample = state }, Cmd.map (PlotInteraction HintExample) cmd)

                        EverythingExample ->
                            let 
                                ( state, cmd ) = Plot.update internalMsg model.everythingExample
                            in
                                ({ model | everythingExample = state }, Cmd.map (PlotInteraction EverythingExample) cmd)

                Custom customMsg ->
                    update customMsg model


-- VIEW


isSectionOpen : Model -> String -> Bool
isSectionOpen { openSection } title =
    case openSection of
        Just id ->
            id == title

        Nothing ->
            False


view : Model -> Html Msg
view model =
    div
        [ class "view" ]
        [ img
            [ src "logo.png"
            , class "view__logo"
            ] []
        , h1 [ class "view__title" ] [ text "Elm Plot" ]
        , div
            [ class "view__github-link" ]
            [ text "Find it on "
            , a
                [ href "https://github.com/terezka/elm-plot" ]
                [ text "Github" ]
            ]
        , Html.map (PlotInteraction EverythingExample) <| ComposedChart.chart model.everythingExample

        , viewPlot model ScatterChart.plotExample
        , viewPlot model MultiLineChart.plotExample
        , viewPlot model MultiAreaChart.plotExample
        , viewPlot model GridChart.plotExample
        , viewPlot model BarChart.plotExample
        , viewPlot model CustomTickChart.plotExample
        , viewPlot model PlotAxis.plotExample
        , viewPlotInteractive model model.hintExample HintChart.plotExample
        , div
            [ class "view__footer" ]
            [ text "Made by "
            , a
                [ href "https://twitter.com/terexka"
                , style [ ( "color", "#84868a" ) ]
                ]
                [ text "@terexka" ]
            ]
        ]



getCodeStyle : Bool -> ( String, String )
getCodeStyle isOpen =
    if isOpen then
        ( "display", "block" )
    else
        ( "display", "none" )


getOnClickMsg : Bool -> String -> Msg
getOnClickMsg isOpen title =
    if isOpen then
        Toggle Nothing
    else
        Toggle (Just title)


viewHeading : Model -> String -> String -> String -> Html Msg
viewHeading model title name codeString =
    let
        isOpen =
            isSectionOpen model title

        codeStyle =
            getCodeStyle isOpen

        onClickMsg =
            getOnClickMsg isOpen title
    in
        div [ style [ ( "margin", "100px auto 10px" ) ] ]
            [ div [] [ text title ]
            , p
                [ class "view-heading__code-toggler"
                , onClick onClickMsg
                ]
                [ text "View code snippet" ]
            , div
                [ class "view-heading__code"
                , style [ codeStyle ]
                ]
                [ Html.code
                    [ class "elm view-heading__code__inner" ]
                    [ pre [] [ text codeString ] ]
                , a
                    [ class "view-heading__code__link"
                    , href (toUrl name)
                    ]
                    [ text "See full source" ]
                ]
            ]


viewPlot : Model -> PlotExample Msg -> Html.Html Msg
viewPlot model { title, fileName, view, code } =
    Html.div
        [ class "view-plot" ]
        [ viewHeading model title fileName code
        , view
        ]


viewPlotInteractive : Model -> Plot.State -> PlotExampleInteractive Msg -> Html.Html Msg
viewPlotInteractive model state { title, fileName, view, code } =
    Html.div
        [ class "view-plot view-plot--interactive" ]
        [ viewHeading model title fileName code
        , Html.map (PlotInteraction HintExample) <| view state
        ]


main =
    Html.program
        { init = ( initialModel, highlight () )
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }



-- Ports


port highlight : () -> Cmd msg



-- Helpers


toUrl : String -> String
toUrl end =
    "https://github.com/terezka/elm-plot/blob/master/docs/" ++ end ++ ".elm"
