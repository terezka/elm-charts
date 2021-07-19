module Charts.Dashboard6 exposing (Model, Msg, init, update, view)

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
    [ CA.height 300
    , CA.width 500
    , CA.margin { top = 0, bottom = 15, left = 20, right = 0 }
    , CE.onMouseMove OnHover (CE.getNearestX CI.bars)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.grid []

    , C.yTicks [ CA.height 0 ]

    --, C.generate 3 C.floats .y [] <| \p y ->
    --    [ C.yLabel [ CA.fontSize 12, CA.x p.x.min, CA.y y ] [ S.text (String.fromFloat (y / 1000000) ++ "M") ] ]

    , C.bars
        [ CA.roundTop 0.5
        , CA.margin 0.1
        , CA.spacing 0.05
        ]
        [ C.bar .denmark [ CA.color CA.pink, CA.opacity 0.9 ]
            |> C.variation (\_ d -> if d.year > 2021 then [ CA.striped [ CA.spacing 8 ], CA.opacity 1 ] else [])
            |> C.named "Denmark"
        , C.bar .norway [ CA.color CA.darkBlue, CA.opacity 0.8 ]
            |> C.variation (\_ d -> if d.year > 2021 then [ CA.striped [ CA.spacing 8 ], CA.opacity 1 ] else [])
            |> C.named "Norway"
        , C.bar .sweden [ CA.color CA.blue, CA.opacity 0.8 ]
            |> C.variation (\_ d -> if d.year > 2021 then [ CA.striped [ CA.spacing 8 ], CA.opacity 1 ] else [])
            |> C.named "Sweden"
        ]
        data

    , C.withBins <| \p bins ->
        case List.head bins of
          Nothing ->
            []

          Just first ->
            let toCountryLabel bar =
                  C.label
                    [ CA.rotate 90
                    , CA.alignLeft
                    , CA.color "white"
                    , CA.moveUp 10
                    , CA.moveRight 4
                    , CA.fontSize 16
                    , CA.uppercase
                    ]
                    [ S.text (CI.getName bar) ]
                    (CI.getBottom p bar)
            in
            List.map toCountryLabel (CI.getMembers first)

    , C.eachBin <| \p bin ->
        let datum = CI.getOneData bin in
        [ C.label [ CA.moveDown 20, CA.fontSize 16 ] [ S.text (String.fromFloat datum.year) ] (CI.getBottom p bin) ]
    ]



type alias Datum =
  { year : Float
  , denmark : Float
  , norway : Float
  , sweden : Float
  }


data : List Datum
data =
  [ Datum 1975 5054410 3997525 8176691
  , Datum 2005 5411405 4606363 9011392
  , Datum 2035 6240023 6891334 12457294
  ]

