module Charts.SalaryDistBar exposing (Model, Msg, init, update, view)

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

import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS

import Element as E
import Element.Font as F
import Element.Border as B
import Element.Input as I
import Element.Background as BG
import Element.Events as EE

import Chart.Events


type alias Model =
  { hovering : List (CI.Many Binned CI.Bar)
  , binSize : Float
  , year : Float
  }


type alias Binned =
  { bin : Float
  , data : List GenderBin
  }


type alias GenderBin =
  { salary : Float
  , amount : Float
  , kind : String
  , sector : String
  }


init : Model
init =
  { hovering = []
  , binSize = 5000
  , year = 2019
  }


type Msg
  = OnHover (List (CI.Many Binned CI.Bar))
  | OnYear Float
  | OnBinSize Float


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hovering ->
      { model | hovering = hovering }

    OnYear year ->
      { model | year = year, hovering = [] }

    OnBinSize binSize ->
      { model | binSize = binSize, hovering = [] }


view : Model -> E.Element Msg
view model =
  E.column
    [ EE.onMouseLeave (OnHover [])
    , E.width (E.px 1000)
    , E.height E.fill
    ]
    [ I.slider
        [ E.height (E.px 30)
        , E.width (E.px 150)

        -- Here is where we're creating/styling the "track"
        , E.behindContent
            (E.el
                [ E.width E.fill
                , E.height (E.px 2)
                , E.centerY
                , BG.color (E.rgb255 180 180 180)
                , B.rounded 2
                ]
                E.none
            )
        ]
        { onChange = OnBinSize
        , label = I.labelAbove [] (E.text "Bin size")
        , min = 5000
        , max = 20000
        , step = Just 1000
        , value = model.binSize
        , thumb = I.defaultThumb
        }

    , E.el [ E.width E.fill ] <| E.html <| viewChart model

    , E.row
        [ E.width E.fill
        , E.spacing 20
        ]
        (List.concatMap viewTooltip model.hovering)
    ]


viewChart : Model -> H.Html Msg
viewChart model =
  let yearData =
        Salary.data
          |> List.filter (.year >> (==) model.year)

      womensData =
        yearData
          |> List.map (\datum -> { salary = datum.salaryWomen, amount = datum.numOfWomen, kind = "women", sector = datum.sector })
          |> List.sortBy .salary
          |> List.filter (\d -> d.salary /= 0)

      mensData =
        yearData
          |> List.map (\datum -> { salary = datum.salaryMen, amount = datum.numOfMen, kind = "men", sector = datum.sector })
          |> List.filter (\d -> d.salary /= 0)

      howMany kind bin =
        bin.data
          |> List.filter (\d -> d.kind == kind)
          |> List.map .amount
          |> List.sum
  in
  C.chart
    [ CA.height 430
    , CA.width 1000
    , CA.margin { top = 40, bottom = 50, left = 0, right = 0 }
    , CA.padding { top = 15, bottom = 0, left = 0, right = 0 }

    , CI.real
        |> CI.andThen CI.bars
        |> CI.andThen CI.bins
        |> CE.getNearest
        |> CE.onMouseMove OnHover
    ]
    [ C.grid []

    , C.withPlane <| \p ->
        let produceLabels current acc =
              if current > p.x.max then acc else
              produceLabels (current + model.binSize) (acc ++ viewLabels current)

            viewLabels value =
              [ C.xLabel
                  [ CA.fontSize 8
                  , CA.x value, CA.y 0, CA.moveUp 5
                  ]
                  [ S.text (String.fromFloat (value / 1000) ++ "k") ]
              , C.xTick
                  [ CA.x value, CA.y 0 ]
              ]
        in
        produceLabels p.x.min []

    , C.generate 5 C.floats .y [] <| \p y ->
        [ C.yLabel [ CA.fontSize 10, CA.x p.x.min, CA.y y ] [ S.text <| String.fromFloat (y / 1000) ++ "k" ] ]

    , C.bars
        [ CA.x1 .bin
        , CA.x2 (.bin >> (+) model.binSize)
        , CA.margin 0.25
        , CA.roundTop 0.2
        , CA.roundBottom 0.2
        ]
        [ C.bar (howMany "women") [ CA.color "#f56dbc", CA.gradient [ "#de74d7EE", "#f56dbc80" ] ]
            |> C.named "women"
        , C.bar (howMany "men") [ CA.color "#58a9f6", CA.gradient [ "#8a91f7EE", "#58a9f680" ] ]
            |> C.named "men"
        ]
        (C.binned model.binSize .salary (womensData ++ mensData))

    , C.withPlane <| \p ->
        let hoveredBars = List.concatMap CI.getMembers model.hovering
            highestValue = Maybe.withDefault 0 <| List.maximum (List.map CI.getY hoveredBars)
            amountOfBars = List.length hoveredBars
            viewLabel index bar =
              let offset = CS.lengthInCartesianY p <| 10 + toFloat (amountOfBars - index - 1) * 20 in
              [ C.line
                  [ CA.x1 (CI.getTop p bar).x
                  , CA.y1 (CI.getTop p bar).y
                  , CA.x2 (CI.getTop p bar).x
                  , CA.y2 <| highestValue + offset
                  , CA.color (CI.getColor bar)
                  ]

              , C.label
                  [ CA.alignLeft
                  , CA.moveLeft 3
                  , CA.moveUp 5
                  , CA.fontSize 10
                  , CA.color (CI.getColor bar)
                  ]
                  [ S.text (String.fromFloat <| CI.getY bar) ]
                  { x = (CI.getTop p bar).x, y = highestValue + offset }
              ]

        in
        List.indexedMap viewLabel hoveredBars
          |> List.concat

    , C.labelAt CA.middle .max [ CA.fontSize 14, CA.moveUp 20 ] [ S.text "How many women and men in each salary bracket?" ]
    , C.labelAt CA.middle .max [ CA.fontSize 11, CA.moveUp 5 ] [ S.text "Data from Danmarks Statestik" ]

    , C.labelAt .min .max [ CA.fontSize 10, CA.alignRight, CA.moveLeft 8, CA.moveUp 10 ] [ S.text "# of people" ]
    , C.labelAt CA.middle .min [ CA.fontSize 10, CA.moveDown 30 ] [ S.text "Salary brackets" ]

    , C.legendsAt .max .max [ CA.alignRight, CA.moveLeft 20 ] []

    , let viewYear year =
            H.div
              [ HE.onClick (OnYear year) ]
              [ H.text (if model.year == year then "→ " else "")
              , H.text (String.fromFloat year)
              ]
      in
      C.htmlAt .max .max -20 -30
        [ HA.style "color" "rgb(90 90 90)"
        , HA.style "cursor" "pointer"
        , HA.style "text-align" "right"
        , HA.style "transform" "translateX(-100%)"
        ]
        (List.map viewYear [ 2016, 2017, 2018, 2019 ])
    ]


viewTooltip chartBin =
  let viewJobs chartBar =
        let color = CI.getColor chartBar
            dataBin = CI.getData chartBar
            name = CI.getName chartBar
            title = "Sectors where " ++ name ++ " on average is payed within selected salary bracket."
        in
        E.textColumn
          [ E.alignTop
          , E.width E.fill
          , E.height E.fill
          ]
          (E.el [ F.size 14, E.paddingXY 0 10 ] (E.text title) :: List.map (viewJob color name) dataBin.data)

      viewJob color name datum =
        if datum.kind == name
          then E.paragraph [ E.htmlAttribute (HA.style "color" color) ] [ E.text datum.sector ]
          else E.none
  in
  List.map viewJobs (CI.getMembers chartBin)

