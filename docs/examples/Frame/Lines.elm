module Examples.Frame.Lines exposing (..)

{-| @LARGE -}
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
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
        [ C.line
            [ CA.x1 p.x.min
            , CA.y1 5
            , CA.x2 p.x.max
            , CA.dashed [ 5, 5 ]
            , CA.color CA.red
            ]
        , C.line
            [ CA.x1 3
            , CA.y1 p.y.min
            , CA.y2 p.y.max
            , CA.dashed [ 5, 5 ]
            , CA.color CA.blue
            ]
        ]
    ]
{-| @SMALL END -}
{-| @LARGE END -}


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Lines"
  , description = "Add a guidence line."
  , order = 30
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

