module Examples.Frame.CustomLabels exposing (..)


-- THIS IS A GENERATED MODULE!

import Html as H
import Svg as S
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
    , C.generate 12 CS.ints .x [] <| \p num ->
        let isEven = remainderBy 2 num == 0 in
        [ C.xLabel
            [ CA.x (toFloat num)
            , CA.withGrid
            , if isEven then identity else CA.y p.y.max
            , if isEven then identity else CA.moveUp 28
            , if isEven then identity else CA.fontSize 10
            , if isEven then identity else CA.color CA.blue
            ]
            [ S.text (String.fromInt num ++ "°") ]
        ]
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Custom labels"
  , description = "Control labels entirely."
  , order = 9
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
    , C.generate 12 CS.ints .x [] <| \\p num ->
        let isEven = remainderBy 2 num == 0 in
        [ C.xLabel
            [ CA.x (toFloat num)
            , CA.withGrid
            , if isEven then identity else CA.y p.y.max
            , if isEven then identity else CA.moveUp 28
            , if isEven then identity else CA.fontSize 10
            , if isEven then identity else CA.color CA.blue
            ]
            [ S.text (String.fromInt num ++ "°") ]
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
import Chart.Svg as CS


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 300
    , CA.width 300
    ]
    [ C.xAxis []
    , C.generate 12 CS.ints .x [] <| \\p num ->
        let isEven = remainderBy 2 num == 0 in
        [ C.xLabel
            [ CA.x (toFloat num)
            , CA.withGrid
            , if isEven then identity else CA.y p.y.max
            , if isEven then identity else CA.moveUp 28
            , if isEven then identity else CA.fontSize 10
            , if isEven then identity else CA.color CA.blue
            ]
            [ S.text (String.fromInt num ++ "°") ]
        ]
    ]
  """