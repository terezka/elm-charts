module Articles.GenderAndSalery.EducationChart exposing (Model, Msg, init, reset, update, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Svg as S exposing (Svg, svg, g, circle, text_, text)
import Svg.Attributes as SA exposing (width, height, stroke, fill, r, transform)
import Browser
import Time
import Data.Education as Data
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
  { hovering : List (CI.Many Data.Year CI.Bar)
  , stacking : StackingOption
  , education : List Education
  }


type Education
  = Short
  | Medium
  | Long
  | Researcher


toEducationOrder : Education -> Int
toEducationOrder ed =
  case ed of
    Short -> 1
    Medium -> 2
    Long -> 3
    Researcher -> 4




init : Model
init =
  { hovering = []
  , stacking = Stacked
  , education = [ Short, Medium, Long, Researcher ]
  }


reset : Model -> Model
reset model =
  { model | hovering = [] }


type Msg
  = OnHover (List (CI.Many Data.Year CI.Bar))
  | OnStackingOption StackingOption
  | OnEducation Education Bool


type StackingOption
  = Stacked
  | Seperate


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hovering ->
      { model | hovering = hovering }

    OnStackingOption stacking ->
      { model | stacking = stacking }

    OnEducation education isChecked ->
      { model | education =
          List.sortBy toEducationOrder <|
            if isChecked
            then education :: model.education
            else List.filter (not << (==) education) model.education
      }


view : Model -> E.Element Msg
view model =
  E.column
    [ EE.onMouseLeave (OnHover [])
    , E.width (E.px 1000)
    , E.height E.fill
    , E.spacing 20
    ]
    [ E.row
        [ E.spacing 20
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
        [ E.row
            [ E.spacing 20 ]
            [ E.text "Students: "
            , circle (E.rgba255 222 116 215) "Women" -- most pink
            , circle (E.rgba255 138 145 247) "Men"  -- most blue
            ]

        , I.radioRow
            [ E.padding 10
            , E.spacing 20
            ]
            { onChange = OnStackingOption
            , selected = Just model.stacking
            , label = I.labelHidden "Stacked or not"
            , options =
                [ I.option Stacked (E.text "Stacked")
                , I.option Seperate (E.text "Seperate")
                ]
            }

        , E.row
          [ E.spacing 20 ]
          [ I.checkbox []
              { onChange = OnEducation Short
              , icon = I.defaultCheckbox
              , checked = List.member Short model.education
              , label = I.labelRight [] (E.text "Short")
              }
          , I.checkbox []
              { onChange = OnEducation Medium
              , icon = I.defaultCheckbox
              , checked = List.member Medium model.education
              , label = I.labelRight [] (E.text "Medium")
              }
          , I.checkbox []
              { onChange = OnEducation Long
              , icon = I.defaultCheckbox
              , checked = List.member Long model.education
              , label = I.labelRight [] (E.text "Long")
              }
          , I.checkbox []
              { onChange = OnEducation Researcher
              , icon = I.defaultCheckbox
              , checked = List.member Researcher model.education
              , label = I.labelRight [] (E.text "Researcher")
              }
          ]
        ]

    , E.el [ E.width E.fill ] <| E.html <| viewChart model
    ]


viewChart : Model -> H.Html Msg
viewChart model =
  C.chart
    [ CA.height 300
    , CA.width 1000
    , CA.margin { top = 0, bottom = 0, left = 0, right = 0 }
    , CA.padding { top = 20, bottom = 20, left = 40, right = 0 }

    , CI.real
        |> CI.andThen CI.bars
        |> CI.andThen CI.bins
        |> CE.getNearestX
        |> CE.onMouseMove OnHover
    ]
    [ C.each model.hovering <| \p bin ->
        let limits = CI.getLimits bin in
        [ C.rect [ CA.x1 limits.x1, CA.x2 limits.x2, CA.borderWidth 0, CA.color "#efefefaF" ] ]

    , let toWomen index ed =
            C.bar (.women >> toFunc ed) [ CA.color "#f56dbc", CA.opacity (toOpacity index) ]
              |> C.named ("Women " ++ toString ed)

          toMen index ed =
            C.bar (.men >> toFunc ed) [ CA.color "#58a9f6", CA.opacity (toOpacity index) ]
              |> C.named ("Men " ++ toString ed)

          toFunc ed =
            case ed of
              Short -> .short
              Medium -> .medium
              Long -> .long
              Researcher -> .researcher

          toString ed =
            case ed of
              Short -> "Short"
              Medium -> "Medium"
              Long -> "Long"
              Researcher -> "Researcher"

          toOpacity index =
            case index of
              0 -> 0.9
              1 -> 0.8
              2 -> 0.7
              3 -> 0.6
              _ -> 1

          womenBars =
            List.indexedMap toWomen model.education

          menBars =
            List.indexedMap toMen model.education

          bars =
            case model.stacking of
              Stacked ->
                [ C.stacked (List.reverse  womenBars)
                , C.stacked (List.reverse  menBars)
                ]

              Seperate ->
                womenBars ++ menBars
      in
      C.bars
        [ CA.x1 .year
        , CA.margin 0.1
        , CA.roundTop 0.2
        , CA.roundBottom 0.2
        , CA.withGrid
        ]
        bars
        Data.data

    , C.each model.hovering <| \_ bin ->
        [ C.tooltip bin [] [] [] ]

    , C.yLabels
        [ CA.withGrid
        , CA.moveUp 8
        , CA.moveRight 10
        , CA.alignLeft
        , CA.format (\y -> String.fromFloat (y / 1000) ++ "k")
        ]

    , C.binLabels (.year >> String.fromFloat) [ CA.moveDown 15 ]
    ]
