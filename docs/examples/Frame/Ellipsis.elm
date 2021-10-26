module Examples.Frame.Ellipsis exposing (..)

{-| @LARGE -}
import Html as H
import Html.Attributes as HA
import Svg as S
import Chart as C
import Chart.Attributes as CA


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.margin { top = 10, left = 45, bottom = 30, right = 15 }
    ]
    [ C.yAxis [ CA.noArrow ]
    , C.yTicks []
    , C.yLabels
        [ CA.format (\y -> String.fromFloat y ++ " yyyyyyy")
        , CA.ellipsis 35 20 -- width: 35, height: 10
        ]

    , C.xAxis [ CA.noArrow ]
    , C.xTicks []
    , C.xLabels
        [ CA.format (\x -> String.fromFloat x ++ " xxxxxxx")
        , CA.ellipsis 35 20
        ]
    ]
{-| @SMALL END -}
{-| @LARGE END -}


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Ellipsis"
  , description = "Add ellipsis to labels (Note: uses HTML labels)."
  , order = 8
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
