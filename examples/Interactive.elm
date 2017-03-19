module Interactive exposing (..)

import Html exposing (h1, p, text, div, node)
import Plot exposing (..)


-- MODEL


type alias Model =
    { hovering : Maybe Point }


initialModel : Model
initialModel =
    { hovering = Nothing }



-- UPDATE


type Msg
    = Hover (Maybe Point)


update : Msg -> Model -> Model
update msg model =
    case msg of
      Hover point ->
        { model | hovering = point }


myDot : Maybe Point -> Point -> DataPoint msg
myDot hovering point =
    hintDot (viewCircle 5 "#ff9edf") hovering point.x point.y



-- VIEW

barData : List ( List Float )
barData =
  [ [ 1, 4 ]
  , [ 1, 5 ]
  , [ 2, 10 ]
  , [ 4, -2 ]
  , [ 5, 14 ]
  ]


view : Model -> Html.Html Msg
view model =
    let
      settings =
        { defaultBarsPlotCustomizations
        | onHover = Just Hover
        , margin = { top = 20, bottom = 30, left = 40, right = 40 }
        }
    in
      Plot.viewBarsCustom settings
        (groups (List.map2 (hintGroup model.hovering) [ "g1", "g3", "g3" ]))
        barData


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }
