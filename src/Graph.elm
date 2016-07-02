module Graph exposing (..)

import Svg exposing (g)
import Svg.Attributes exposing (height, width, style)

import Types exposing (DataSet, dataSet)
import Axis
import Data
import Config


type alias Model =
    { data : Data.Model
    , xAxis : Axis.Model
    , yAxis : Axis.Model
    , dimensions : Axis.Dimensions
    , config : Config.Model
    }


init : List (Int, Int) -> Model
init data =
    let unzipped = List.unzip data
        xAxis = Axis.init (fst unzipped)
        yAxis = Axis.init (snd unzipped) |> Axis.setVertical True
    in 
        { data = Data.init (dataSet data)
        , xAxis = xAxis
        , yAxis = yAxis
        , dimensions = Axis.initDimensions xAxis yAxis
        , config = Config.init
        }


view : Model -> Svg.Svg a
view model =
    Svg.svg
        [ width (toString model.xAxis.length)
        , height (toString model.yAxis.length) 
        , style "padding: 50px;"
        ]
        [ Axis.view model.xAxis model.dimensions
        , Axis.view model.yAxis model.dimensions
        , Data.view model.data model.dimensions
        ]
