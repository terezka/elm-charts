module Examples.Frame.AxisCustomAttributes exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Svg as S
import Svg.Attributes as SA
import Chart as C
import Chart.Attributes as CA


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xAxis [ CA.attrs [ SA.strokeDasharray "3 8" ] ]
    , C.xTicks []
    , C.xLabels []
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Custom attributes on axis"
  , description = "Add custom attributes to an axis line."
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
    ]
    [ C.xAxis [ CA.attrs [ SA.strokeDasharray "3 8" ] ]
    , C.xTicks []
    , C.xLabels []
    ]
  """


largeCode : String
largeCode =
  """
import Html as H
import Svg as S
import Svg.Attributes as SA
import Chart as C
import Chart.Attributes as CA


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xAxis [ CA.attrs [ SA.strokeDasharray "3 8" ] ]
    , C.xTicks []
    , C.xLabels []
    ]
  """