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
    hintDot (viewCircle 5 "#ff9edf") hovering point.x point.y



-- VIEW

barData : List ( List Float )
barData =
  [ [ 1, 4, 6 ]
  , [ 1, 5, 6 ]
  , [ 2, 10, 6 ]
  , [ 4, -2, 6 ]
  , [ 5, 14, 6 ]
  ]


view : Model -> Html.Html Msg
view model =
    let
      settings =
        { defaultBarPlotCustomizations
        | onHover = Just Hover
        , viewHintContainer = Maybe.map normalHoverContainer model.hovering
        }
    in
      Plot.viewBarsCustom settings
        (grouped (List.map2 (hintGroup model.hovering) [ "g1", "g3", "g3" ]))
        barData


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }
