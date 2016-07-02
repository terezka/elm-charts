module Simple exposing (..)

import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Html exposing (Html, button, div, text)

import Graph
import Types exposing (dataSet)

main =
    App.beginnerProgram { model = init, view = view, update = update }


type alias Model =
    { graph : Graph.Model }


init : Model 
init =
    let data = [ (-100, -20), (0, 300), (30, 50), (40, 40), (60, 75), (80, 60), (100, 63), (100, 300) ]
    in
        { graph = Graph.init data }


type Msg
  = GraphEvent


update : Msg -> Model -> Model
update msg model =
  model


view : Model -> Html Msg
view model =
  div 
    [ style [ ("padding", "3em") ] ] 
    [ Graph.view model.graph ]
