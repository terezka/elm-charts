module Examples.Interactivity.GetNearestAndSurrounding exposing (..)


-- THIS IS A GENERATED MODULE!

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
    OnMouseMove coords (closest, surrounding) ->
      { model | coords = Just coords, closest = closest, surrounding = surrounding }

    OnMouseLeave ->
      { model | coords = Nothing, closest = [], surrounding = [] }


view : Model -> H.Html Msg
view model =
  let radius = 30 in
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, left = 0, right = 0, bottom = 0 }
    , CA.margin { top = 0, left = 0, right = 0, bottom = 0 }
    , CE.on "mousemove" <|
        CE.map2 OnMouseMove
          CE.getCoords
          (CE.getNearestAndSurrounding radius CI.dots)
    , CE.onMouseLeave OnMouseLeave
    , CA.range [ CA.window 0 6 ]
    , CA.domain [ CA.window 0 5 ]
    ]
    [ C.xLabels []
    , C.yLabels []
    , C.yAxis []
    --, case model.coords of
    --    Just coords ->
    --      C.withPlane <| \p ->
    --        let pointSvg = CS.fromCartesian p coords 
    --            radiusScaled = getScaledRadius p radius
    --        in
    --        [ C.rect
    --            [ CA.x1 (coords.x - radiusScaled.x)
    --            , CA.x2 (coords.x + radiusScaled.x)
    --            , CA.y1 (coords.y - radiusScaled.y)
    --            , CA.y2 (coords.y + radiusScaled.y)
    --            , CA.color CA.gray
    --            , CA.opacity 0.1
    --            ]
    --        ]
    --    Nothing ->
    --      C.none


    --, case model.coords of
    --    Just coords ->
    --      C.svg <| \p ->
    --        let pointSvg = CS.fromCartesian p coords 
    --        in
    --        S.g []
    --          [ S.circle
    --              [ SA.r (String.fromFloat radius)
    --              , SA.fill "#EEE"
    --              , SA.fillOpacity "0.5"
    --              , SA.cx (String.fromFloat pointSvg.x)
    --              , SA.cy (String.fromFloat pointSvg.y)
    --              ]
    --              []
    --          ]

    --    Nothing ->
    --      C.none

    , case model.closest of
        item :: _ ->
          C.svg <| \p ->
            let pointSvg = CS.fromCartesian p { x = (CI.getLimits item).x1, y = (CI.getLimits item).y1 }
            in
            S.g []
              [ S.circle
                  [ SA.r (String.fromFloat radius)
                  , SA.fill "#EEE"
                  , SA.fillOpacity "0.5"
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
            |> C.amongst model.surrounding (\d -> [ CA.highlight 0.1, CA.color CA.green ])
        ]
        data
    ]


getScaledRadiusX : CS.Plane -> Float -> Float
getScaledRadiusX plane radius = 
  (range plane.x) * radius / plane.x.length


getScaledRadiusY : CS.Plane -> Float -> Float
getScaledRadiusY plane radius = 
  (range plane.y) * radius / plane.y.length


getScaledRadius : CS.Plane -> Float -> CS.Point
getScaledRadius plane radius =
  CS.Point (getScaledRadiusX plane radius) (getScaledRadiusY plane radius)

range : CS.Axis -> Float
range axis =
  let diff = axis.max - axis.min in
  if diff > 0 then diff else 1


type alias Datum =
  { x : Float
  , y : Float
  }


data : List Datum
data =
  [ Datum 2   3
  , Datum 2.4 2
  , Datum 2.5 2
  , Datum 2.5 2.2
  , Datum 2.6 2.3
  , Datum 3   2
  , Datum 3   2.4
  , Datum 3   2.5
  , Datum 3   2.51
  , Datum 3   2.7
  ]




meta =
  { category = "Interactivity"
  , categoryOrder = 3
  , name = "Get nearest and surrounding"
  , description = "Get nearest and surrounding."
  , order = 17
  }


smallCode : String
smallCode =
  """
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, left = 0, right = 0, bottom = 0 }
    , CA.margin { top = 0, left = 0, right = 0, bottom = 0 }
    , CE.on "mousemove" <|
        CE.map2 OnMouseMove
          CE.getCoords
          (CE.getNearestAndSurrounding radius CI.dots)
    , CE.onMouseLeave OnMouseLeave
    , CA.range [ CA.window 0 6 ]
    , CA.domain [ CA.window 0 5 ]
    ]
    [ C.xLabels []
    , C.yLabels []
    , C.yAxis []
    --, case model.coords of
    --    Just coords ->
    --      C.withPlane <| \\p ->
    --        let pointSvg = CS.fromCartesian p coords 
    --            radiusScaled = getScaledRadius p radius
    --        in
    --        [ C.rect
    --            [ CA.x1 (coords.x - radiusScaled.x)
    --            , CA.x2 (coords.x + radiusScaled.x)
    --            , CA.y1 (coords.y - radiusScaled.y)
    --            , CA.y2 (coords.y + radiusScaled.y)
    --            , CA.color CA.gray
    --            , CA.opacity 0.1
    --            ]
    --        ]
    --    Nothing ->
    --      C.none


    --, case model.coords of
    --    Just coords ->
    --      C.svg <| \\p ->
    --        let pointSvg = CS.fromCartesian p coords 
    --        in
    --        S.g []
    --          [ S.circle
    --              [ SA.r (String.fromFloat radius)
    --              , SA.fill "#EEE"
    --              , SA.fillOpacity "0.5"
    --              , SA.cx (String.fromFloat pointSvg.x)
    --              , SA.cy (String.fromFloat pointSvg.y)
    --              ]
    --              []
    --          ]

    --    Nothing ->
    --      C.none

    , case model.closest of
        item :: _ ->
          C.svg <| \\p ->
            let pointSvg = CS.fromCartesian p { x = (CI.getLimits item).x1, y = (CI.getLimits item).y1 }
            in
            S.g []
              [ S.circle
                  [ SA.r (String.fromFloat radius)
                  , SA.fill "#EEE"
                  , SA.fillOpacity "0.5"
                  , SA.cx (String.fromFloat pointSvg.x)
                  , SA.cy (String.fromFloat pointSvg.y)
                  ]
                  []
              ]

        _ ->
          C.none

    , C.series .x
        [ C.scatter .y [ CA.circle, CA.borderWidth 0, CA.color CA.blue, CA.border CA.blue, CA.borderOpacity 0.7, CA.size 1 ] 
            |> C.amongst model.closest (\\d -> [ CA.highlight 0.1 ])
            |> C.amongst model.surrounding (\\d -> [ CA.highlight 0.1, CA.color CA.green ])
        ]
        data
    ]
  """


largeCode : String
largeCode =
  """
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
    OnMouseMove coords (closest, surrounding) ->
      { model | coords = Just coords, closest = closest, surrounding = surrounding }

    OnMouseLeave ->
      { model | coords = Nothing, closest = [], surrounding = [] }


view : Model -> H.Html Msg
view model =
  let radius = 30 in
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 0, left = 0, right = 0, bottom = 0 }
    , CA.margin { top = 0, left = 0, right = 0, bottom = 0 }
    , CE.on "mousemove" <|
        CE.map2 OnMouseMove
          CE.getCoords
          (CE.getNearestAndSurrounding radius CI.dots)
    , CE.onMouseLeave OnMouseLeave
    , CA.range [ CA.window 0 6 ]
    , CA.domain [ CA.window 0 5 ]
    ]
    [ C.xLabels []
    , C.yLabels []
    , C.yAxis []
    --, case model.coords of
    --    Just coords ->
    --      C.withPlane <| \\p ->
    --        let pointSvg = CS.fromCartesian p coords 
    --            radiusScaled = getScaledRadius p radius
    --        in
    --        [ C.rect
    --            [ CA.x1 (coords.x - radiusScaled.x)
    --            , CA.x2 (coords.x + radiusScaled.x)
    --            , CA.y1 (coords.y - radiusScaled.y)
    --            , CA.y2 (coords.y + radiusScaled.y)
    --            , CA.color CA.gray
    --            , CA.opacity 0.1
    --            ]
    --        ]
    --    Nothing ->
    --      C.none


    --, case model.coords of
    --    Just coords ->
    --      C.svg <| \\p ->
    --        let pointSvg = CS.fromCartesian p coords 
    --        in
    --        S.g []
    --          [ S.circle
    --              [ SA.r (String.fromFloat radius)
    --              , SA.fill "#EEE"
    --              , SA.fillOpacity "0.5"
    --              , SA.cx (String.fromFloat pointSvg.x)
    --              , SA.cy (String.fromFloat pointSvg.y)
    --              ]
    --              []
    --          ]

    --    Nothing ->
    --      C.none

    , case model.closest of
        item :: _ ->
          C.svg <| \\p ->
            let pointSvg = CS.fromCartesian p { x = (CI.getLimits item).x1, y = (CI.getLimits item).y1 }
            in
            S.g []
              [ S.circle
                  [ SA.r (String.fromFloat radius)
                  , SA.fill "#EEE"
                  , SA.fillOpacity "0.5"
                  , SA.cx (String.fromFloat pointSvg.x)
                  , SA.cy (String.fromFloat pointSvg.y)
                  ]
                  []
              ]

        _ ->
          C.none

    , C.series .x
        [ C.scatter .y [ CA.circle, CA.borderWidth 0, CA.color CA.blue, CA.border CA.blue, CA.borderOpacity 0.7, CA.size 1 ] 
            |> C.amongst model.closest (\\d -> [ CA.highlight 0.1 ])
            |> C.amongst model.surrounding (\\d -> [ CA.highlight 0.1, CA.color CA.green ])
        ]
        data
    ]


getScaledRadiusX : CS.Plane -> Float -> Float
getScaledRadiusX plane radius = 
  (range plane.x) * radius / plane.x.length


getScaledRadiusY : CS.Plane -> Float -> Float
getScaledRadiusY plane radius = 
  (range plane.y) * radius / plane.y.length


getScaledRadius : CS.Plane -> Float -> CS.Point
getScaledRadius plane radius =
  CS.Point (getScaledRadiusX plane radius) (getScaledRadiusY plane radius)

range : CS.Axis -> Float
range axis =
  let diff = axis.max - axis.min in
  if diff > 0 then diff else 1


type alias Datum =
  { x : Float
  , y : Float
  }


data : List Datum
data =
  [ Datum 2   3
  , Datum 2.4 2
  , Datum 2.5 2
  , Datum 2.5 2.2
  , Datum 2.6 2.3
  , Datum 3   2
  , Datum 3   2.4
  , Datum 3   2.5
  , Datum 3   2.51
  , Datum 3   2.7
  ]

  """