module Examples.Frame.Color exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xAxis []
    , C.xTicks []
    , C.xLabels []
    , C.yAxis [ CA.color CA.pink ]
    , C.yTicks [ CA.color CA.pink ]
    , C.yLabels [ CA.color CA.pink ]
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Color"
  , description = "Change color of items."
  , order = 2
  }


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



smallCode : String
smallCode =
  """
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xAxis []
    , C.xTicks []
    , C.xLabels []
    , C.yAxis [ CA.color CA.pink ]
    , C.yTicks [ CA.color CA.pink ]
    , C.yLabels [ CA.color CA.pink ]
    ]
  """


largeCode : String
largeCode =
  """
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xAxis []
    , C.xTicks []
    , C.xLabels []
    , C.yAxis [ CA.color CA.pink ]
    , C.yTicks [ CA.color CA.pink ]
    , C.yLabels [ CA.color CA.pink ]
    ]
  """