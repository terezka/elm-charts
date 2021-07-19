module Examples.Frame.LabelWithLine exposing (..)


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
    , CA.padding { top = 25, bottom = 0, left = 10, right = 10 }
    , CA.range [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    , CA.domain [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    ]
    [ C.xAxis []
    , C.xTicks []
    , C.xLabels []
    , C.yAxis []
    , C.yTicks []
    , C.yLabels []
    , C.series .age [ C.scatter .toys [] ] data

    , C.label
        [ CA.moveRight 14, CA.moveUp 8, CA.alignLeft ]
        [ S.text "The dot in question" ]
        { x = 5, y = 6 }
    , C.line
        [ CA.break
        , CA.x1 5, CA.y1 6
        , CA.x2Svg 10, CA.y2Svg 13
        , CA.color CA.purple
        ]
    ]


type alias Datum =
  { age : Float
  , toys : Float
  }

data : List Datum
data =
  [ Datum 5 6
  ]




meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Label with line"
  , description = "Add a label and line to chart."
  , order = 20
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
    , CA.padding { top = 25, bottom = 0, left = 10, right = 10 }
    , CA.range [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    , CA.domain [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    ]
    [ C.xAxis []
    , C.xTicks []
    , C.xLabels []
    , C.yAxis []
    , C.yTicks []
    , C.yLabels []
    , C.series .age [ C.scatter .toys [] ] data

    , C.label
        [ CA.moveRight 14, CA.moveUp 8, CA.alignLeft ]
        [ S.text "The dot in question" ]
        { x = 5, y = 6 }
    , C.line
        [ CA.break
        , CA.x1 5, CA.y1 6
        , CA.x2Svg 10, CA.y2Svg 13
        , CA.color CA.purple
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
    , CA.padding { top = 25, bottom = 0, left = 10, right = 10 }
    , CA.range [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    , CA.domain [ CA.lowest 0 CA.exactly, CA.highest 10 CA.exactly ]
    ]
    [ C.xAxis []
    , C.xTicks []
    , C.xLabels []
    , C.yAxis []
    , C.yTicks []
    , C.yLabels []
    , C.series .age [ C.scatter .toys [] ] data

    , C.label
        [ CA.moveRight 14, CA.moveUp 8, CA.alignLeft ]
        [ S.text "The dot in question" ]
        { x = 5, y = 6 }
    , C.line
        [ CA.break
        , CA.x1 5, CA.y1 6
        , CA.x2Svg 10, CA.y2Svg 13
        , CA.color CA.purple
        ]
    ]


type alias Datum =
  { age : Float
  , toys : Float
  }

data : List Datum
data =
  [ Datum 5 6
  ]


  """