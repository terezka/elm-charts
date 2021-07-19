module Examples.Frame.GridColor exposing (..)


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
    [ C.grid [ CA.color CA.blue ]
    , C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Color of grid"
  , description = "Change color of grid."
  , order = 14
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
    [ C.grid [ CA.color CA.blue ]
    , C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]
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
    [ C.grid [ CA.color CA.blue ]
    , C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]
    ]
  """