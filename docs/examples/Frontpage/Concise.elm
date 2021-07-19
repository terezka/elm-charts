module Examples.Frontpage.Concise exposing (..)

{-| @LARGE -}
import Html as H
import Svg as S
import Chart as C
import Chart.Svg as CS
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Item as CI


type alias Model =
  { hovering : List (CI.Many Datum CI.Any) }


init : Model
init =
  { hovering = [] }


type Msg
  = OnHover (List (CI.Many Datum CI.Any))


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnHover hovering ->
      { model | hovering = hovering }


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 500
    , CA.margin { top = 10, left = 40, right = 0, bottom = 25 }
    , CE.onMouseMove OnHover (CE.getNearest CI.stacks)
    , CE.onMouseLeave (OnHover [])
    ]
    [ C.yLabels [ CA.withGrid, CA.format (\y -> String.fromFloat y ++ "M")]

    , C.bars
        [ CA.roundTop 0.2
        , CA.margin 0.2
        , CA.spacing 0.05
        , CA.noGrid
        ]
        [ C.stacked
            [ C.bar .cats
                [ CA.gradient [ mint1, mint2 ] ]
                |> C.named "Cats"
            , C.bar .dogs
                [ CA.gradient [ blue1, blue2 ] ]
                |> C.named "Dogs"
            ]
        , C.bar .people
            [ CA.gradient [ purple1, purple2 ] ]
                |> C.named "People"
        ]
        data

    , C.labelAt (CA.percent 30) .max
        [ CA.moveDown 3, CA.fontSize 15 ]
        [ S.text "Populations in Scandinavia" ]

    , C.labelAt (CA.percent 30) .max
        [ CA.moveDown 20, CA.fontSize 12 ]
        [ S.text "Note: Based on made up data." ]

    , C.binLabels .country [ CA.moveDown 18 ]
    , C.barLabels [ CA.moveDown 18, CA.color weakWhite ]
    , C.legendsAt .max .max [ CA.alignRight, CA.column, CA.spacing 7 ] []

    , let
        toBrightLabel =
          C.productLabel [ CA.moveDown 18, CA.color white ]
      in
      C.each model.hovering <| \p stack ->
        List.map toBrightLabel (CI.getMembers stack)

    , C.eachBin <| \p bin ->
        let bar = CI.getMember bin
            datum = CI.getOneData bin
            yPos = (CI.getTop p bin).y
            xMid = (CI.getCenter p bin).x
        in
        if datum.country == "Finland" then
          [ C.line
              [ CA.x1 (CI.getX1 bar)
              , CA.x2 (CI.getX2 bar)
              , CA.y1 yPos
              , CA.moveUp 15
              , CA.tickLength 5
              ]
          , C.label
              [ CA.moveUp 22, CA.fontSize 10 ]
              [ S.text "Most pets per person"]
              { x = xMid, y = yPos }
          ]
        else
          []
    ]
{-| @SMALL END -}

mint1 = "#54c8ddD0"
mint2 = "#54c8dd90"
blue1 = "#0f9ff0D0"
blue2 = "#0f9ff090"
purple1 = "#653bf4B0"
purple2 = "#653bf470"
weakWhite = "rgba(255, 255, 255, 0.7)"
white = "white"

{-| @LARGE END -}


meta =
  { category = "Front page"
  , categoryOrder = 1
  , name = "Labels for bars"
  , description = "Add custom bar labels."
  , order = 15
  }


type alias Datum =
  { cats : Float
  , dogs : Float
  , people : Float
  , country : String
  }


data : List Datum
data =
  [ Datum 2.4 1.2 5.3 "Norway"
  , Datum 2.2 2.4 5.8 "Denmark"
  , Datum 3.6 2.2 10.2 "Sweden"
  , Datum 3.4 1.2 5.5 "Finland"
  ]

