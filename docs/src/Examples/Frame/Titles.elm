module Examples.Frame.Titles exposing (..)


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
    , CA.padding { top = 25, bottom = 0, left = 0, right = 10 }
    , CA.range [ CA.lowest 0 CA.exactly ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.ints ]
    , C.xLabels [ CA.ints ]
    , C.yAxis []
    , C.yTicks [ CA.ints ]
    , C.yLabels [ CA.ints ]
    , C.series .age
        [ C.scatter .toys [ CA.opacity 0, CA.borderWidth 1 ]
        ]
        data

    , C.labelAt .min CA.middle [ CA.moveLeft 35, CA.rotate 90 ]
        [ S.text "Fruits" ]
    , C.labelAt CA.middle .min [ CA.moveDown 30 ]
        [ S.text "Age" ]
    , C.labelAt CA.middle .max [ CA.fontSize 14 ]
        [ S.text "How many fruits do children eat? (2021)" ]
    , C.labelAt CA.middle .max [ CA.moveDown 15 ]
        [ S.text "Data from fruits.com" ]
    ]


type alias Datum =
  { age : Float
  , toys : Float
  }

data : List Datum
data =
  [ Datum 0.5 4
  , Datum 0.8 5
  , Datum 1.2 6
  , Datum 1.4 6
  , Datum 1.6 4
  , Datum 3 8
  , Datum 3 9
  , Datum 3.2 10
  , Datum 3.8 7
  , Datum 6 12
  , Datum 6.2 8
  , Datum 6 10
  , Datum 6 9
  , Datum 9.1 8
  , Datum 9.2 13
  , Datum 9.8 10
  , Datum 12 7
  , Datum 12.5 5
  , Datum 12.5 2
  ]




meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Titles"
  , description = "Add titles to chart."
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
    , CA.padding { top = 25, bottom = 0, left = 0, right = 10 }
    , CA.range [ CA.lowest 0 CA.exactly ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.ints ]
    , C.xLabels [ CA.ints ]
    , C.yAxis []
    , C.yTicks [ CA.ints ]
    , C.yLabels [ CA.ints ]
    , C.series .age
        [ C.scatter .toys [ CA.opacity 0, CA.borderWidth 1 ]
        ]
        data

    , C.labelAt .min CA.middle [ CA.moveLeft 35, CA.rotate 90 ]
        [ S.text "Fruits" ]
    , C.labelAt CA.middle .min [ CA.moveDown 30 ]
        [ S.text "Age" ]
    , C.labelAt CA.middle .max [ CA.fontSize 14 ]
        [ S.text "How many fruits do children eat? (2021)" ]
    , C.labelAt CA.middle .max [ CA.moveDown 15 ]
        [ S.text "Data from fruits.com" ]
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
    , CA.padding { top = 25, bottom = 0, left = 0, right = 10 }
    , CA.range [ CA.lowest 0 CA.exactly ]
    ]
    [ C.xAxis []
    , C.xTicks [ CA.ints ]
    , C.xLabels [ CA.ints ]
    , C.yAxis []
    , C.yTicks [ CA.ints ]
    , C.yLabels [ CA.ints ]
    , C.series .age
        [ C.scatter .toys [ CA.opacity 0, CA.borderWidth 1 ]
        ]
        data

    , C.labelAt .min CA.middle [ CA.moveLeft 35, CA.rotate 90 ]
        [ S.text "Fruits" ]
    , C.labelAt CA.middle .min [ CA.moveDown 30 ]
        [ S.text "Age" ]
    , C.labelAt CA.middle .max [ CA.fontSize 14 ]
        [ S.text "How many fruits do children eat? (2021)" ]
    , C.labelAt CA.middle .max [ CA.moveDown 15 ]
        [ S.text "Data from fruits.com" ]
    ]


type alias Datum =
  { age : Float
  , toys : Float
  }

data : List Datum
data =
  [ Datum 0.5 4
  , Datum 0.8 5
  , Datum 1.2 6
  , Datum 1.4 6
  , Datum 1.6 4
  , Datum 3 8
  , Datum 3 9
  , Datum 3.2 10
  , Datum 3.8 7
  , Datum 6 12
  , Datum 6.2 8
  , Datum 6 10
  , Datum 6 9
  , Datum 9.1 8
  , Datum 9.2 13
  , Datum 9.8 10
  , Datum 12 7
  , Datum 12.5 5
  , Datum 12.5 2
  ]


  """