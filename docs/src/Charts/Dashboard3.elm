module Charts.Dashboard3 exposing (Model, Msg, init, update, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Svg as S exposing (Svg, svg, g, circle, text_, text)
import Svg.Attributes as SA exposing (width, height, stroke, fill, r, transform)
import Browser
import Time
import Data.Iris as Iris
import Data.Salary as Salary
import Data.Education as Education
import Dict
import Time

import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS

import Element as E
import Element.Font as F
import Element.Border as B
import Element.Background as BG

import Chart.Events


type alias Model =
  { hovering : List (CI.One Datum CI.Dot)
  }


init : Model
init =
  { hovering = []
  }


type Msg
  = OnHover (List (CI.One Datum CI.Dot))


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hovering ->
      { model | hovering = hovering }


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 135
    , CA.width 225
    , CA.margin { top = 0, bottom = 18, left = 0, right = 0 }
    , CA.padding { top = 10, bottom = 0, left = 8, right = 0 }
    , CE.onMouseMove OnHover (CE.getNearestX CI.dots)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.xLabels [ CA.times Time.utc, CA.uppercase, CA.fontSize 9, CA.amount 10 ]

    , C.each model.hovering <| \p dot ->
        [ C.line [ CA.x1 (CI.getX dot), CA.width 2, CA.dashed [ 5, 5 ] ] ]

    , C.series .x
        [ C.interpolatedMaybe .y
            [ CA.linear, CA.color CA.blue, CA.width 1.5, CA.opacity 0.4, CA.gradient [ CA.blue, "white" ] ]
            [ CA.diamond, CA.color "white", CA.borderWidth 1.5, CA.size 8 ]
            |> C.amongst model.hovering (\_ -> [ CA.size 14 ])
        ]
        lineData
    ]


type alias Datum =
  { x : Float
  , y : Maybe Float
  }


lineData : List Datum
lineData =
  [ Datum 1612137600000 (Just 80)
  , Datum 1614556800000 (Just 97)
  , Datum 1617235200000 (Just 65)
  , Datum 1617235200001 Nothing
  , Datum 1619827200000 (Just 72)
  , Datum 1622505600000 (Just 56)
  , Datum 1625097600000 (Just 82)
  , Datum 1627776000000 (Just 94)
  , Datum 1630454400000 (Just 76)
  , Datum 1633046400000 (Just 83)
  ]

