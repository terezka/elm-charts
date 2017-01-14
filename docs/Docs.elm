port module Docs exposing (..)

import Dict exposing (..)
import Html exposing (Html, div, text, h1, img, a, br, span, code, pre, p)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style, src, href, class, classList, id, name)
import Common exposing (..)
import Plot as Plot exposing (Interaction(..))
import PlotComposed
import PlotScatter
import PlotGrid
import PlotTicks
import PlotBars
import PlotSticky
import PlotHint
import PlotSmooth


-- MODEL


type alias Model =
    { focused : Maybe Id
    , plotStates : Dict Id Plot.State
    }


initialModel : Model
initialModel =
    { focused = Nothing
    , plotStates = empty
    }


getPlotState : Id -> Dict Id Plot.State -> Plot.State
getPlotState id plotStates =
    get id plotStates
        |> Maybe.withDefault Plot.initialState



-- UPDATE


type Msg
    = FocusExample Id
    | PlotInteraction Id (Plot.Interaction Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ plotStates, focused } as model) =
    case msg of
        FocusExample id ->
            ( { model | focused = updateFocused id focused }, Cmd.none )

        PlotInteraction id interaction ->
            case interaction of
                Internal internalMsg ->
                    let
                        plotState =
                            getPlotState id plotStates

                        newState =
                            Plot.update internalMsg plotState
                    in
                        ( { model | plotStates = setPlotState id newState plotStates }, Cmd.none )

                Custom customMsg ->
                    update customMsg model


updateFocused : Id -> Maybe Id -> Maybe Id
updateFocused newId model =
    case model of
        Nothing ->
            Just newId

        Just oldId ->
            if oldId == newId then
                Nothing
            else
                Just newId


setPlotState : Id -> Plot.State -> Dict Id Plot.State -> Dict Id Plot.State
setPlotState id newState states =
    Dict.update id (always (Just newState)) states



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "view" ]
        [ viewTitle
        , viewExampleLarge model
        , div [] (List.map (viewExample model) examples)
        , viewFooter
        ]


viewTitle : Html msg
viewTitle =
    div
        []
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
        ]


viewExampleLarge : Model -> Html Msg
viewExampleLarge { plotStates } =
    Html.map
        (PlotInteraction PlotComposed.id)
        (PlotComposed.view (getPlotState PlotComposed.id plotStates))


viewExample : Model -> PlotExample Msg -> Html.Html Msg
viewExample ({ plotStates } as model) ({ title, id, view, code } as example) =
    Html.div
        [ class "view-plot" ]
        [ viewHeading model example
        , viewCode model example
        , viewExampleInner model view
        ]


viewHeading : Model -> PlotExample msg -> Html Msg
viewHeading model { title, id } =
    div [ class "view-heading" ]
        [ a [ name id, href ("#" ++ id) ] [ text title ]
        , viewToggler id
        ]


viewToggler : String -> Html.Html Msg
viewToggler id =
    p
        [ class "view-heading__code-open"
        , onClick (FocusExample id)
        ]
        [ text "View source snippet" ]


viewExampleInner : Model -> ViewPlot Msg -> Html.Html Msg
viewExampleInner { plotStates } view =
    case view of
        ViewInteractive id view ->
            getPlotState id plotStates
                |> view
                |> Html.map (PlotInteraction id)

        ViewStatic view ->
            view


viewCode : Model -> PlotExample msg -> Html Msg
viewCode model { id, code } =
    div
        [ style (getVisibility model id)
        , class "view-code"
        ]
        [ Html.code
            [ class "elm view-code__inner" ]
            [ pre [] [ text code ]
            ]
        , viewLink id
        ]


viewLink : String -> Html.Html Msg
viewLink id =
    a
        [ class "view-code__link"
        , href (toUrl id)
        ]
        [ text "See full source" ]


viewFooter : Html msg
viewFooter =
    div
        [ class "view__footer" ]
        [ text "Made by "
        , a
            [ href "https://twitter.com/terexka"
            , style [ ( "color", "#84868a" ) ]
            ]
            [ text "@terexka" ]
        ]



-- View helpers


toUrl : String -> String
toUrl end =
    "https://github.com/terezka/elm-plot/blob/master/docs/" ++ end ++ ".elm"


getVisibility : Model -> Id -> List ( String, String )
getVisibility { focused } id =
    if focused == Just id then
        [ ( "display", "block" ) ]
    else
        [ ( "display", "none" ) ]



-- Ports


port highlight : () -> Cmd msg



-- Main


examples : List (PlotExample msg)
examples =
    [ PlotSmooth.plotExample
    , PlotBars.plotExample
    , PlotHint.plotExample
    , PlotSticky.plotExample
    , PlotScatter.plotExample
    , PlotTicks.plotExample
    , PlotGrid.plotExample
    ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, highlight () )
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }
