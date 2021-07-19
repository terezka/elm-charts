module Examples.Frame.Coordinates exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Html.Attributes as HA
import Svg as S
import Svg.Attributes as SA
import Chart as C
import Chart.Attributes as CA
import Chart.Svg as CS


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

    , C.svg <| \p ->
        let point = { x = 6, y = 4 }
            pointSvg = CS.fromCartesian p point
            color = if CS.fromSvg p pointSvg == point then "purple" else "blue"
        in
        S.g []
          [ S.circle
              [ SA.r "10"
              , SA.fill color
              , SA.cx (String.fromFloat pointSvg.x)
              , SA.cy (String.fromFloat pointSvg.y)
              ]
              []
          ]
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Coordinates"
  , description = "Using the low level coordinate system."
  , order = 39
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

    , C.svg <| \\p ->
        let point = { x = 6, y = 4 }
            pointSvg = CS.fromCartesian p point
            color = if CS.fromSvg p pointSvg == point then "purple" else "blue"
        in
        S.g []
          [ S.circle
              [ SA.r "10"
              , SA.fill color
              , SA.cx (String.fromFloat pointSvg.x)
              , SA.cy (String.fromFloat pointSvg.y)
              ]
              []
          ]
    ]
  """


largeCode : String
largeCode =
  """
import Html as H
import Html.Attributes as HA
import Svg as S
import Svg.Attributes as SA
import Chart as C
import Chart.Attributes as CA
import Chart.Svg as CS


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

    , C.svg <| \\p ->
        let point = { x = 6, y = 4 }
            pointSvg = CS.fromCartesian p point
            color = if CS.fromSvg p pointSvg == point then "purple" else "blue"
        in
        S.g []
          [ S.circle
              [ SA.r "10"
              , SA.fill color
              , SA.cx (String.fromFloat pointSvg.x)
              , SA.cy (String.fromFloat pointSvg.y)
              ]
              []
          ]
    ]
  """