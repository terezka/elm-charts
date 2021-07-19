module Examples.Frame.GridFilter exposing (..)


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
    [ C.xLabels []
    , C.xTicks [ CA.noGrid ]
    , C.yLabels []
    , C.yTicks [ CA.noGrid ]
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Remove grid lines"
  , description = "Prevent automatically added gridlines."
  , order = 15
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
    [ C.xLabels []
    , C.xTicks [ CA.noGrid ]
    , C.yLabels []
    , C.yTicks [ CA.noGrid ]
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
    [ C.xLabels []
    , C.xTicks [ CA.noGrid ]
    , C.yLabels []
    , C.yTicks [ CA.noGrid ]
    ]
  """