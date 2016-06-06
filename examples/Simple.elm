module Simple exposing (..)

import Html.App as App
import Html.Events exposing (onClick)
import Html exposing (Html, button, div, text)

import Graph

main =
    App.beginnerProgram { model = init, view = view, update = update }


type alias Model =
    { dataset : Graph.Model }


init =
  { dataset = [ {x = 20, y = 70}, {x = 40, y = 80} ] }


type Msg
  = GraphEvent Graph.Msg


update : Msg -> Model -> Model
update msg model =
  case msg of
    GraphEvent graphMsg ->
      { model | dataset = Graph.update graphMsg model.dataset }


view : Model -> Html Msg
view model =
  div [] [ App.map GraphEvent (Graph.view model.dataset) ]
