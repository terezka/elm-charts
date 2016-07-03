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
    let data = [ (-1, -2), (0, 3), (3, 5), (4, 4), (6, 7), (8, 6), (1, 6), (1, 3) ]
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
