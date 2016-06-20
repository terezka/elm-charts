module Simple exposing (..)

import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Html exposing (Html, button, div, text)

import Graph
import Axis
import Container

main =
    App.beginnerProgram { model = init, view = view, update = update }


type alias Model =
    { dataset : Graph.Model
    , axisX : Axis.Model
    , axisY : Axis.Model
    }


init =
  { dataset = [ { x = 120, y = 170 }, { x = 140, y = 180 } ] 
  , axisX = Axis.init |> Axis.setVertical True
  , axisY = Axis.init
  }


type Msg
  = GraphEvent Graph.Msg
  | AxisEvent Axis.Msg


update : Msg -> Model -> Model
update msg model =
  case msg of
    GraphEvent graphMsg ->
      { model | dataset = Graph.update graphMsg model.dataset }

    AxisEvent axisMsg ->
      model


view : Model -> Html Msg
view model =
  div 
    [ style [ ("padding", "3em") ] ] 
    [ Container.view
      [ App.map AxisEvent (Axis.view model.axisX)
      , App.map AxisEvent (Axis.view model.axisY)
      , App.map GraphEvent (Graph.view model.dataset)
      ]
    ]
