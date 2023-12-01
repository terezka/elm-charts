module Examples.Frame.CustomElements exposing (..)

{-| @LARGE -}
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xTicks []
    , C.xLabels []
    , C.yTicks []
    , C.yLabels []
    , C.heatmap .x .y .value []
        --[ colors [ "#99D492", "#74C67A", "#1D9A6C", "#188977", "#137177", "#0E4D64"]
        --, smoothScale
        --, name "Temperature"
        --, borderWidth 1
        --, borderColor "white"
        --]
        data
    ]
{-| @SMALL END -}


type alias Datum =
  { country : String
  , month : Month
  , temperature : Float
  }


data : List Datum
data =
  [ { country = "Denmark", month = Jan, temperature = 2 }
  , { country = "Denmark", month = Feb, temperature = 2 }
  , { country = "Denmark", month = Mar, temperature = 2 }
  , { country = "Denmark", month = Apr, temperature = 2 }
  , { country = "Denmark", month = May, temperature = 2 }
  , { country = "Denmark", month = Jun, temperature = 2 }
  , { country = "Denmark", month = Jul, temperature = 2 }
  , { country = "Denmark", month = Aug, temperature = 2 }
  , { country = "Denmark", month = Sep, temperature = 2 }
  , { country = "Denmark", month = Oct, temperature = 2 }
  , { country = "Denmark", month = Nov, temperature = 2 }
  , { country = "Denmark", month = Dec, temperature = 2 }
  , { country = "Sweden", month = Jan, temperature = 2 }
  , { country = "Sweden", month = Feb, temperature = 2 }
  , { country = "Sweden", month = Mar, temperature = 2 }
  , { country = "Sweden", month = Apr, temperature = 2 }
  , { country = "Sweden", month = May, temperature = 2 }
  , { country = "Sweden", month = Jun, temperature = 2 }
  , { country = "Sweden", month = Jul, temperature = 2 }
  , { country = "Sweden", month = Aug, temperature = 2 }
  , { country = "Sweden", month = Sep, temperature = 2 }
  , { country = "Sweden", month = Oct, temperature = 2 }
  , { country = "Sweden", month = Nov, temperature = 2 }
  , { country = "Sweden", month = Dec, temperature = 2 }
  , { country = "Norway", month = Jan, temperature = 2 }
  , { country = "Norway", month = Feb, temperature = 2 }
  , { country = "Norway", month = Mar, temperature = 2 }
  , { country = "Norway", month = Apr, temperature = 2 }
  , { country = "Norway", month = May, temperature = 2 }
  , { country = "Norway", month = Jun, temperature = 2 }
  , { country = "Norway", month = Jul, temperature = 2 }
  , { country = "Norway", month = Aug, temperature = 2 }
  , { country = "Norway", month = Sep, temperature = 2 }
  , { country = "Norway", month = Oct, temperature = 2 }
  , { country = "Norway", month = Nov, temperature = 2 }
  , { country = "Norway", month = Dec, temperature = 2 }
  ]
{-| @LARGE END -}


type alias Model =
  ()


init : Model
init =
  ()


type Msg
  = Msg


update : Msg -> Model -> Model
update msg model =
  model


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Custom chart elements"
  , description = "Add custom tracked elements"
  , order = 100
  }

