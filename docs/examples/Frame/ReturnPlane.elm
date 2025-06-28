module Examples.Frame.ReturnPlane exposing (..)

{-| @LARGE -}
import Html as H
import Html.Attributes as HA
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Chart.Svg as CS


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  let ( chart, plane ) =
        C.chartAndPlane
          [ CA.height 300
          , CA.width 300
          ]
          [ C.xAxis []
          , C.xTicks []
          , C.xLabels []
          , C.yAxis []
          , C.yTicks []
          , C.yLabels []
          ]
  in
  H.div
    [ HA.style "display" "grid"
    , HA.style "grid-template-columns" "8fr 1fr"
    , HA.style "grid-column-gap" "8px"
    , HA.style "position" "relative"
    ]
    [ chart
    , H.div
        [ HA.style "position" "relative"
        , HA.style "height" "100%"
        ]
        -- Use plane to position something outside the chart.
        -- Note: `plane` is not opaque, so you are not limited to
        -- library functions.
        [ CS.positionHtml plane 0 8 0 0 [] [ H.text "hello" ] ]
    ]
{-| @SMALL END -}
{-| @LARGE END -}


meta =
  { category = "Navigation"
  , categoryOrder = 4
  , name = "Return plane"
  , description = "Return the plane used by chart."
  , order = 110
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

