module Charts.Dashboard4 exposing (Model, Msg, init, update, view)

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
  { hovering : List (CI.One Datum CI.Bar)
  }


init : Model
init =
  { hovering = []
  }


type Msg
  = OnHover (List (CI.One Datum CI.Bar))


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hovering ->
      { model | hovering = hovering }


view : Model -> H.Html Msg
view model =
  C.chart
    [ CA.height 140
    , CA.width 490
    , CA.margin { top = 0, bottom = 0, left = 0, right = 20 }
    , CE.onMouseMove OnHover (CE.getNearestX CI.bars)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.grid []
    , C.yLabels [ CA.pinned .max, CA.amount 1, CA.flip, CA.fontSize 10 ]
    , C.line [ CA.y1 50, CA.dashed [ 5, 5 ] ]
    , C.bars
        [ CA.roundTop 1
        , CA.roundBottom 1
        , CA.margin 0.2
        , CA.noGrid
        ]
        [ C.barMaybe .score [ CA.opacity 0.5 ]
            |> C.variation (\i d -> [ CA.color (toColor d.score) ])
            |> C.amongst model.hovering (\_ -> [ CA.highlight 0.2, CA.highlightWidth 5 ])
        ]
        data

    , C.labelAt .max CA.middle [ CA.rotate 90, CA.moveRight 18 ] [ S.text "score" ]
    , C.each model.hovering <| \p bar ->
        let datum = CI.getData bar
            scoreText =
              case datum.score of
                Just score -> String.fromFloat score ++ "/100"
                Nothing -> "Absent"
        in
        [ C.tooltip bar
            [ CA.onTop ]
            [ HA.style "color" (CI.getColor bar) ]
            [ H.text datum.name, H.text ": ", H.text scoreText ]
        ]
    ]



type alias Datum =
  { score : Maybe Float
  , name : String
  }


data : List Datum
data =
  [ Datum (Just 23) "Alexander"
  , Datum (Just 48) "Anne"
  , Datum (Just 98) "Alice"
  , Datum (Just 85) "Brian"
  , Datum (Just 32) "Bobby"
  , Datum Nothing "Byron"
  , Datum (Just 72) "Cirkeline"
  , Datum (Just 56) "Diana"
  , Datum (Just 64) "Felicia"
  , Datum (Just 45) "Felipa"
  , Datum (Just 28) "Georgina"
  , Datum (Just 45) "Helena"
  , Datum (Just 56) "Irina"
  , Datum (Just 52) "Iris"
  , Datum (Just 68) "Jack"
  , Datum (Just 72) "Kristine"
  , Datum (Just 87) "Linea"
  , Datum (Just 92) "Mina"
  , Datum (Just 100) "Prudence"
  , Datum (Just 65) "Pauline"
  , Datum (Just 59) "Preston"
  , Datum (Just 47) "Regina"
  , Datum (Just 86) "Ruzena"
  , Datum (Just 37) "Regitze"
  , Datum (Just 59) "Selena"
  , Datum (Just 62) "Sylvia"
  , Datum (Just 76) "Tristen"
  , Datum (Just 79) "Ursula"
  , Datum (Just 65) "Virginia"
  , Datum (Just 35) "Winston"
  ]


toColor : Maybe Float -> String
toColor score =
  let key = floor (Maybe.withDefault 0 score / 10) in
  Dict.get key colors
    |> Maybe.withDefault "#00E58A"


colors : Dict.Dict Int String
colors =
  [ "#00E58A", "#00E1CC", "#00AFDD", "#006BD9", "#0029D5", "#1600D2", "#5300CE", "#8F00CA", "#C600C5", "#C20086" ]
    |> List.reverse
    |> List.indexedMap Tuple.pair
    |> Dict.fromList

