module Articles.GenderAndSalery.Bars exposing (Model, Msg, init, reset, update, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Svg as S exposing (Svg, svg, g, circle, text_, text)
import Svg.Attributes as SA exposing (width, height, stroke, fill, r, transform)
import Browser
import Time
import Articles.GenderAndSalery.Data as Salary
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
  }


reset : Model -> Model
reset model =
  { model | hovering = [] }


type Msg
  = OnHover (List (CI.Many Binned CI.Bar))
  | OnBinSize Float


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hovering ->
      { model | hovering = hovering }

    OnBinSize binSize ->
      { model | binSize = binSize, hovering = [] }


view : Model -> Float -> E.Element Msg
view model year =
  E.column
    [ EE.onMouseLeave (OnHover [])
    , E.width (E.px 1000)
    , E.height E.fill
    , E.spacing 20
    ]
    [ E.row
        [ E.spacing 50
        , F.size 12
        , F.bold
        ] <|
        let circle color name =
              E.row [ E.spacing 5 ]
                [ E.el
                    [ BG.color (color 0.8)
                    , B.rounded 50
                    , E.width (E.px 10)
                    , E.height (E.px 10)
                    ]
                    E.none
                , E.text name
                ]
        in
        [ I.slider
            [ E.height (E.px 30)
            , E.width (E.px 100)
            , E.spacing 20
            , E.behindContent <|
                E.el
                    [ E.width E.fill
                    , E.height (E.px 10)
                    , E.centerY
                    , BG.color (E.rgb255 230 230 230)
                    , B.rounded 10
                    ]
                    E.none
            ]
            { onChange = OnBinSize
            , label =
                I.labelLeft
                  [ E.centerY
                  , F.size 12
                  , F.bold
                  ]
                  (E.text "Salery bracket size:")
            , min = 5000
            , max = 20000
            , step = Just 1000
            , value = model.binSize
            , thumb =
                I.thumb
                  [ E.height (E.px 15)
                  , E.width (E.px 15)
                  , BG.color (E.rgb255 255 255 255)
                  , B.color (E.rgb255 180 180 180)
                  , B.width 1
                  , B.rounded 10
                  ]
            }
        , E.row
            [ E.spacing 20 ]
            [ E.text "Workforce: "
            , circle (E.rgba255 222 116 215) "Women" -- most pink
            , circle (E.rgba255 138 145 247) "Men"  -- most blue
            ]
        ]

    , E.el [ E.width E.fill ] <| E.html <| viewChart model year

    --, E.row
    --    [ E.width E.fill
    --    , E.spacing 20
    --    ]
    --    (List.concatMap viewTooltip model.hovering)
    ]


viewChart : Model -> Float -> H.Html Msg
viewChart model year =
  let yearData =
        Salary.data
          |> List.filter (.year >> (==) year)

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
    [ CA.height 300
    , CA.width 1000
    , CA.margin { top = 0, bottom = 10, left = 0, right = 0 }
    , CA.padding { top = 20, bottom = 20, left = 40, right = 0 }

    , CI.real
        |> CI.andThen CI.bars
        |> CI.andThen CI.bins
        |> CE.getNearestX
        |> CE.onMouseMove OnHover
    ]
    [ C.grid []

    , C.eachBin <| \p bin ->
        let viewLabels value =
              [ C.xLabel
                  [ CA.fontSize 11
                  , CA.x value
                  , CA.y 0
                  , CA.alignLeft
                  , CA.moveRight 3
                  , CA.moveUp 3
                  ]
                  [ S.text (String.fromFloat (value / 1000) ++ "k") ]
              ]

            limits =
              CI.getLimits bin
        in
        viewLabels limits.x1

    , C.generate 5 C.floats .y [] <| \p y ->
        [ C.yLabel
            [ CA.fontSize 11
            , CA.x p.x.min
            , CA.y y
            , CA.withGrid
            , CA.alignLeft
            , CA.moveUp 10
            , CA.moveRight 10
            ]
            [ S.text <| String.fromFloat (y / 1000) ++ "k" ]
        ]

    , C.bars
        [ CA.x1 .bin
        , CA.x2 (.bin >> (+) model.binSize)
        , CA.margin 0.15
        , CA.roundTop 0.2
        , CA.roundBottom 0.2
        , CA.withGrid
        ]
        [ C.bar (howMany "women") [ CA.color "#f56dbc", CA.gradient [ "#de74d7CE", "#f56dbc80" ] ]
            |> C.named "women"
        , C.bar (howMany "men") [ CA.color "#58a9f6", CA.gradient [ "#8a91f7CE", "#58a9f680" ] ]
            |> C.named "men"
        ]
        (C.binned model.binSize .salary (womensData ++ mensData))

    , C.withPlane <| \p ->
        let hoveredBars = List.concatMap CI.getMembers model.hovering
            highestValue = Maybe.withDefault 0 <| List.maximum (List.map CI.getY hoveredBars)
            amountOfBars = List.length hoveredBars
            viewLabel index bar =
              let offset = CS.lengthInCartesianY p <| 5 + toFloat (amountOfBars - index - 1) * 15 in
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

    , C.labelAt .min .max [ CA.fontSize 12, CA.alignRight, CA.moveLeft 12, CA.moveDown 3, CA.rotate 90 ] [ S.text "Workforce" ]
    , C.labelAt .max .min [ CA.fontSize 12, CA.alignRight, CA.moveDown 15 ] [ S.text "Salary" ]

    --, C.legendsAt .max .max [ CA.alignRight, CA.moveLeft 20 ] []
    ]


viewTooltip : CI.Many Binned CI.Bar -> List (E.Element msg)
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

