module Interactive exposing (..)

import Svg
import Svg.Events
import Svg.Attributes
import Html exposing (h1, p, text, div, node)
import Html.Attributes
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Label as Label


-- MODEL


type alias Model =
    { yourState : Int
    , plotState : Plot.State
    }


initialModel : Model
initialModel =
    { yourState = 0
    , plotState = Plot.initialState
    }



-- UPDATE


type Msg
    = YourClick
    | PlotInteraction (Plot.Interaction Msg)


update : Msg -> Model -> Model
update msg model =
    case msg of
        YourClick ->
            { model | yourState = model.yourState + 1 }

        PlotInteraction interaction ->
            case interaction of
                Internal internalMsg ->
                    { model | plotState = Plot.update internalMsg model.plotState }

                Custom yourMsg ->
                    update yourMsg model



-- VIEW


data1 : List ( Float, Float )
data1 =
    [ ( 0, 2 ), ( 1, 4 ), ( 2, 5 ), ( 3, 10 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 0 ), ( 1, 5 ), ( 2, 7 ), ( 3, 15 ) ]


view : Model -> Html.Html Msg
view model =
    Html.div
        [ Html.Attributes.style [ ( "margin", "0 auto" ), ( "width", "600px" ), ( "text-align", "center" ) ] ]
        [ h1 [] [ text "Example with interactive plot!" ]
        , Html.map PlotInteraction (viewPlot model.plotState)
        , p [] [ text <| "You clicked a label " ++ toString model.yourState ++ " times! 🌟" ]
        , p [] [ text "P.S. No stylesheet is included here, so that's why the tooltip doesn't look very tooltipy." ]
        ]


viewPlot : Plot.State -> Svg.Svg (Interaction Msg)
viewPlot state =
    div
        []
        [ node "style" [] [ text ".elm-plot__hint { pointer-events: none; }" ]
        , plotInteractive
            [ size ( 600, 300 )
            , margin ( 100, 100, 40, 100 )
            , id "PlotHint"
            , style [ ( "position", "relative" ) ]
            ]
            [ line
                [ Line.stroke "blue"
                , Line.strokeWidth 2
                ]
                data1
            , line
                [ Line.stroke "red"
                , Line.strokeWidth 2
                ]
                data2
            , xAxis
                [ Axis.line
                    [ Line.stroke "grey" ]
                , Axis.tickDelta 1
                , Axis.label
                    [ Label.format (always "Click me!")
                    , Label.view
                        [ Label.customAttrs
                            [ Svg.Events.onClick (Custom YourClick)
                            , Svg.Attributes.style "cursor: pointer;"
                            ]
                        ]
                    ]
                ]
            , hint [] (getHoveredValue state)
            ]
        ]


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }
