module Examples.Frame.Arbitrary exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Html.Attributes as HA
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
    [ C.xAxis []
    , C.xTicks []
    , C.xLabels []
    , C.yAxis []
    , C.yTicks []
    , C.yLabels []
    , C.svg <| \p ->
        S.g [] [ star 200 40, star 250 50 ]

    , C.svgAt (CA.percent 80) (CA.percent 20) 0 0
        [ S.circle [ SA.r "10", SA.fill "blue" ] [] ]

    , C.htmlAt .min CA.middle 30 0
        [ HA.style "border" "1px solid gray"
        , HA.style "padding" "5px"
        , HA.style "background" "white"
        ]
        [ H.text "My arbitrary HTML" ]
    ]


star : Float -> Float -> S.Svg msg
star x y =
  S.polygon
    [ SA.points "100,10 40,198 190,78 10,78 160,198"
    , SA.fill CA.red
    , SA.transform <|
        String.concat
          [ "translate("
          , String.fromFloat x
          , " "
          , String.fromFloat y
          , ") scale(0.1 0.1)"
          ]
    ]
    []



meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Arbitrary SVG and HTML"
  , description = "Add custom SVG/HTML to your chart."
  , order = 35
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
        S.g [] [ star 200 40, star 250 50 ]

    , C.svgAt (CA.percent 80) (CA.percent 20) 0 0
        [ S.circle [ SA.r "10", SA.fill "blue" ] [] ]

    , C.htmlAt .min CA.middle 30 0
        [ HA.style "border" "1px solid gray"
        , HA.style "padding" "5px"
        , HA.style "background" "white"
        ]
        [ H.text "My arbitrary HTML" ]
    ]


star : Float -> Float -> S.Svg msg
star x y =
  S.polygon
    [ SA.points "100,10 40,198 190,78 10,78 160,198"
    , SA.fill CA.red
    , SA.transform <|
        String.concat
          [ "translate("
          , String.fromFloat x
          , " "
          , String.fromFloat y
          , ") scale(0.1 0.1)"
          ]
    ]
    []

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
        S.g [] [ star 200 40, star 250 50 ]

    , C.svgAt (CA.percent 80) (CA.percent 20) 0 0
        [ S.circle [ SA.r "10", SA.fill "blue" ] [] ]

    , C.htmlAt .min CA.middle 30 0
        [ HA.style "border" "1px solid gray"
        , HA.style "padding" "5px"
        , HA.style "background" "white"
        ]
        [ H.text "My arbitrary HTML" ]
    ]


star : Float -> Float -> S.Svg msg
star x y =
  S.polygon
    [ SA.points "100,10 40,198 190,78 10,78 160,198"
    , SA.fill CA.red
    , SA.transform <|
        String.concat
          [ "translate("
          , String.fromFloat x
          , " "
          , String.fromFloat y
          , ") scale(0.1 0.1)"
          ]
    ]
    []

  """