module Interactive exposing (..)

import Html exposing (h1, p, text, div, node)
import Svg.Plot as Plot exposing (..)


-- MODEL


type alias Model =
    { hovering : Maybe { x : Float, y : Float } }


initialModel : Model
initialModel =
    { hovering = Nothing }



-- UPDATE


type Msg
    = Hover (Maybe { x : Float, y : Float })


update : Msg -> Model -> Model
update msg model =
    case msg of
      Hover point ->
        { model | hovering = point }


myDot : Maybe { x : Float, y : Float } -> { x : Float, y : Float } -> DataPoint msg
myDot hovering point =
  case hovering of
    Just hovered ->
      if hovered.x == point.x then
        hintDot (viewCircle 5 "#ff9edf") point.x point.y
      else
        dot (viewCircle 5 "#ff9edf")  point.x point.y

    Nothing ->
      dot (viewCircle 5 "#ff9edf") point.x point.y



-- VIEW


view : Model -> Html.Html Msg
view model =
    let
      settings =
        { defaultSeriesPlotCustomizations
        | onHover = Just Hover
        , viewHintContainer = Maybe.map normalHoverContainer model.hovering
        }
    in
      Plot.viewSeriesCustom settings
          [ area (List.map (myDot model.hovering)) ]
          [ { x = -5, y = 2.2 }
          , { x = 2.2, y = 4.2 }
          , { x = 2.5, y = -1.6 }
          , { x = 3.4, y = -0.8 }
          , { x = 5, y = 2.3 }
          ]


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }
