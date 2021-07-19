module Examples.Frame.Offset exposing (..)


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
    [ C.xLabels [ CA.moveRight 5, CA.moveUp 20, CA.alignLeft, CA.withGrid ]
    ]


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Move labels"
  , description = "Change position of labels."
  , order = 4
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
    [ C.xLabels [ CA.moveRight 5, CA.moveUp 20, CA.alignLeft, CA.withGrid ]
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
    [ C.xLabels [ CA.moveRight 5, CA.moveUp 20, CA.alignLeft, CA.withGrid ]
    ]
  """