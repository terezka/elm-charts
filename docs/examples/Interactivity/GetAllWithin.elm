module Examples.Interactivity.GetAllWithin exposing (..)

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
  , within : List (CI.One Datum CI.Dot)
  }


init : Model
init =
  { coords = Nothing, within = [] }


type Msg
  = OnMouseMove CE.Point (List (CI.One Datum CI.Dot))
  | OnMouseLeave


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnMouseMove coords within ->
      { model | coords = Just coords, within = within }

    OnMouseLeave ->
      { model | coords = Nothing, within = [] }


view : Model -> H.Html Msg
view model =
  let radius = 30 in
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, left = 0, right = 0, bottom = 0 }
    , CA.margin { top = 0, left = 0, right = 0, bottom = 0 }
    , CE.on "mousemove" <| CE.map2 OnMouseMove CE.getCoords (CE.getAllWithin radius CI.dots)
    , CE.onMouseLeave OnMouseLeave
    ]
    [ C.xLabels []
    , C.yLabels []
    , C.yAxis []
    , C.xAxis []
    , case model.coords of
        Just point ->
          C.svg <| \p ->
            let pointSvg =
                  CS.fromCartesian p point
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
        [ C.scatter .y [ CA.circle ]
            |> C.variation (\i d -> [ CA.size (d.v * 2) ])
            |> C.amongst model.within (\_ ->
                [ CA.opacity 0, CA.borderWidth 2 ]
              )
        , C.scatter .z [ CA.circle, CA.size 8 ]
            |> C.variation (\i d -> [ CA.size (d.p * 3) ])
            |> C.amongst model.within (\_ ->
                [ CA.opacity 0, CA.borderWidth 2 ]
              )
        ]
        data
    ]
{-| @SMALL END -}



type alias Datum =
  { x : Float
  , y : Float
  , z : Float
  , v : Float
  , w : Float
  , p : Float
  , q : Float
  }



data : List Datum
data =
  [ Datum 1  2 1 4.6 6.9 7.3 8.0
  , Datum 2  3 2 5.2 6.2 7.0 8.7
  , Datum 3  4 3 5.5 5.2 7.2 8.1
  , Datum 4  3 4 5.3 5.7 6.2 7.8
  , Datum 5  2 3 4.9 5.9 6.7 8.2
  , Datum 6  4 1 4.8 5.4 7.2 8.3
  , Datum 7  5 2 5.3 5.1 7.8 7.1
  , Datum 8  6 3 5.4 3.9 7.6 8.5
  , Datum 9  5 4 5.8 4.6 6.5 6.9
  , Datum 10 4 3 4.5 5.3 6.3 7.0
  ]

{-| @LARGE END -}



meta =
  { category = "Interactivity"
  , categoryOrder = 3
  , name = "Get all within"
  , description = "Find all items within a certain radius."
  , order = 17
  }
