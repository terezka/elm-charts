module Examples.Interactivity.GetNearestAndNearby exposing (..)

{-| @LARGE -}
import Html as H
import Chart as C
import Chart.Attributes as CA
import Chart.Item as CI
import Chart.Events as CE
import Chart.Svg as CS
import Svg as S
import Svg.Attributes as SA


type alias Model =
  { coords : Maybe CE.Point
  , closest : List (CI.One Datum CI.Dot) 
  , surrounding : List (CI.One Datum CI.Dot) 
  }


init : Model
init =
  { coords = Nothing, closest = [], surrounding = [] }


type Msg
  = OnMouseMove CE.Point (List (CI.One Datum CI.Dot), List (CI.One Datum CI.Dot))
  | OnMouseLeave


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnMouseMove coords (nearest, nearby) ->
      { model | coords = Just coords, closest = nearest, surrounding = nearby }

    OnMouseLeave ->
      { model | coords = Nothing, closest = [], surrounding = [] }


view : Model -> H.Html Msg
view model =
  let radius = 30 in
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, left = 0, right = 0, bottom = 0 }
    , CA.margin { top = 0, left = 0, right = 0, bottom = 0 }
    , CE.on "mousemove" <|
        CE.map2 OnMouseMove
          CE.getCoords
          (CE.getNearestAndNearby radius CI.dots)
    , CE.onMouseLeave OnMouseLeave
    ]
    [ C.xLabels []
    , C.yLabels []
    , C.yAxis []
    , C.xAxis []
    , case model.closest of
        item :: _ ->
          C.svg <| \p ->
            let pointSvg =
                  CS.fromCartesian p { x = CI.getX item, y = CI.getY item }
            in
            S.g []
              [ S.circle
                  [ SA.r (String.fromFloat radius)
                  , SA.stroke "#EEE"
                  , SA.fillOpacity "0"
                  , SA.cx (String.fromFloat pointSvg.x)
                  , SA.cy (String.fromFloat pointSvg.y)
                  ]
                  []
              ]

        _ ->
          C.none

    , C.series .x
        [ C.scatter .y [ CA.circle, CA.borderWidth 0, CA.color CA.blue, CA.border CA.blue, CA.borderOpacity 0.7, CA.size 1 ] 
            |> C.amongst model.closest (\d -> [ CA.highlight 0.1 ])
            |> C.amongst model.surrounding (\d -> [ CA.color CA.darkGray ])
        ]
        data
    ]
{-| @SMALL END -}



type alias Datum =
  { x : Float
  , y : Float
  }


data : List Datum
data =
  [ Datum 0   0
  , Datum 1   1
  , Datum 2   2
  , Datum 3   3
  , Datum 4   4
  , Datum 4   5
  , Datum 4   5
  , Datum 4   5
  , Datum 4.5 5
  , Datum 5   5.5
  , Datum 5   6.5
  , Datum 5   6
  , Datum 5   5
  , Datum 5.5 5.5
  , Datum 5.5 5
  , Datum 6   5
  , Datum 6 6
  , Datum 7 7
  , Datum 8 8
  , Datum 9 9
  , Datum 10 10
  ] 

{-| @LARGE END -}



meta =
  { category = "Interactivity"
  , categoryOrder = 3
  , name = "Get nearest and nearby"
  , description = "Find nearest item and those within a certain range of it."
  , order = 17
  }
