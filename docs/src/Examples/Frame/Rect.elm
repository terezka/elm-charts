module Examples.Frame.Rect exposing (..)


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
    , C.yAxis []
    , C.yTicks []
    , C.yLabels []
    , C.withPlane <| \p ->
        [ C.rect
            [ CA.x1 3
            , CA.y1 3
            , CA.x2 7
            , CA.y2 9
            , CA.color "rgb(210, 210, 210)"
            , CA.opacity 0.3
            ]
        ]
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Rectangle"
  , description = "Add a rectangle."
  , order = 31
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
    , C.yAxis []
    , C.yTicks []
    , C.yLabels []
    , C.withPlane <| \\p ->
        [ C.rect
            [ CA.x1 3
            , CA.y1 3
            , CA.x2 7
            , CA.y2 9
            , CA.color "rgb(210, 210, 210)"
            , CA.opacity 0.3
            ]
        ]
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
    , C.yAxis []
    , C.yTicks []
    , C.yLabels []
    , C.withPlane <| \\p ->
        [ C.rect
            [ CA.x1 3
            , CA.y1 3
            , CA.x2 7
            , CA.y2 9
            , CA.color "rgb(210, 210, 210)"
            , CA.opacity 0.3
            ]
        ]
    ]
  """