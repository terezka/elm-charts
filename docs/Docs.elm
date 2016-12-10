port module Docs exposing (..)

import Dict exposing (..)
import Html exposing (Html, div, text, h1, img, a, br, span, code, pre, p)
import Html.Attributes exposing (style, src, href, class, classList, id)
import Html.Events exposing (onClick)
import Common exposing (..)
import Plot as Plot exposing (Interaction(..))
import PlotComposed
import PlotScatter
import PlotLines
import PlotArea
import PlotGrid
import PlotTicks
import PlotBars
import PlotSticky
import PlotHint


-- Examples


examples : List (PlotExample msg)
examples =
    [ PlotScatter.plotExample
    , PlotLines.plotExample
    , PlotArea.plotExample
    , PlotBars.plotExample
    , PlotGrid.plotExample
    , PlotTicks.plotExample
    , PlotSticky.plotExample
    , PlotHint.plotExample
    ]



-- MODEL


type alias Model =
    { openSection : Maybe String
    , plotStates : Dict String Plot.State
    }


initialModel : Model
initialModel =
    { openSection = Nothing
    , plotStates = empty
    }



-- Model helpers


getPlotState : Id -> Dict Id Plot.State -> Plot.State
getPlotState id plotStates =
    get id plotStates
        |> Maybe.withDefault Plot.initialState


setPlotState : Id -> Plot.State -> Dict Id Plot.State -> Dict Id Plot.State
setPlotState id newState states =
    Dict.update id (always (Just newState)) states


isCodeOpen : Model -> String -> Bool
isCodeOpen { openSection } title =
    case openSection of
        Just id ->
            id == title

        Nothing ->
            False



-- UPDATE


type Msg
    = Toggle (Maybe String)
    | PlotInteraction Id (Plot.Interaction Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ plotStates } as model) =
    case msg of
        Toggle id ->
            ( { model | openSection = id }, Cmd.none )

        PlotInteraction id interaction ->
            case interaction of
                Internal internalMsg ->
                    let
                        plotState =
                            getPlotState id plotStates

                        ( newState, cmd ) =
                            Plot.update internalMsg plotState
                    in
                        ( { model | plotStates = setPlotState id newState plotStates }, Cmd.map (PlotInteraction id) cmd )

                Custom customMsg ->
                    update customMsg model



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "view" ]
        [ img
            [ src "logo.png"
            , class "view__logo"
            ]
            []
        , h1
            [ class "view__title" ]
            [ text "Elm Plot" ]
        , div
            [ class "view__github-link" ]
            [ text "Find it on "
            , a
                [ href "https://github.com/terezka/elm-plot" ]
                [ text "Github" ]
            ]
        , Html.map
            (PlotInteraction PlotComposed.fileName)
            (PlotComposed.view (getPlotState PlotComposed.fileName model.plotStates))
        , div [] (List.map (viewExample model) examples)
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


getOnClickMsg : Bool -> String -> Msg
getOnClickMsg isOpen title =
    if isOpen then
        Toggle Nothing
    else
        Toggle (Just title)


viewHeading : Model -> String -> String -> Html Msg
viewHeading model title name =
    let
        isOpen =
            isCodeOpen model title

        codeStyle =
            getCodeStyle isOpen
    in
        div [ style [ ( "margin", "100px auto 10px" ) ] ]
            [ div [] [ text title ]
              --, viewToggler isOpen title
            ]


viewToggler : Bool -> String -> Html.Html Msg
viewToggler isOpen title =
    p
        [ class "view-heading__code-open"
        , onClick <| getOnClickMsg isOpen title
        ]
        [ text "View source snippet" ]


viewLink : String -> Html.Html Msg
viewLink name =
    a
        [ class "view-heading__code__link"
        , href (toUrl name)
        ]
        [ text "See full source" ]


viewCode : Model -> String -> String -> Html Msg
viewCode model id codeString =
    let
        isOpen =
            isCodeOpen model id

        codeStyle =
            getCodeStyle isOpen
    in
        div [ style codeStyle ]
            [ Html.code
                [ class "elm view-code" ]
                [ pre [] [ text codeString ] ]
            ]


viewExample : Model -> PlotExample Msg -> Html.Html Msg
viewExample ({ plotStates } as model) { title, fileName, view, code } =
    Html.div
        [ class "view-plot" ]
        [ viewHeading model title fileName
        , viewExampleInner plotStates view
        , viewCode model title code
        ]


viewExampleInner : Dict Id Plot.State -> ViewPlot Msg -> Html.Html Msg
viewExampleInner plotStates view =
    case view of
        ViewInteractive id view ->
            Html.map (PlotInteraction id) <| view (getPlotState id plotStates)

        ViewStatic view ->
            view



-- View helpers


toUrl : String -> String
toUrl end =
    "https://github.com/terezka/elm-plot/blob/master/docs/" ++ end ++ ".elm"


getCodeStyle : Bool -> List ( String, String )
getCodeStyle isOpen =
    if isOpen then
        [ ( "display", "block" ) ]
    else
        [ ( "display", "none" ) ]



-- Ports


port highlight : () -> Cmd msg



-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, highlight () )
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }
