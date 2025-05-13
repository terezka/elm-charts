module Examples.Frame.FlipAxis exposing (..)


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
    , CA.padding { top = 16, right = 16, bottom = 0, left = 0 }
    , CA.domain [ CA.flip ]
    , CA.range [ CA.flip ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.flip ]
    , C.xLabels [ CA.flip ]
    , C.yAxis []
    , C.yTicks [ CA.flip ]
    , C.yLabels [ CA.flip ]
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Flip axis"
  , description = "Flip the direction of an axis."
  , order = 5
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
    , CA.padding { top = 16, right = 16, bottom = 0, left = 0 }
    , CA.domain [ CA.flip ]
    , CA.range [ CA.flip ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.flip ]
    , C.xLabels [ CA.flip ]
    , C.yAxis []
    , C.yTicks [ CA.flip ]
    , C.yLabels [ CA.flip ]
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
    , CA.padding { top = 16, right = 16, bottom = 0, left = 0 }
    , CA.domain [ CA.flip ]
    , CA.range [ CA.flip ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.flip ]
    , C.xLabels [ CA.flip ]
    , C.yAxis []
    , C.yTicks [ CA.flip ]
    , C.yLabels [ CA.flip ]
    ]
  """