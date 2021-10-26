module Articles.GenderAndSalery.Bubble exposing (Model, Msg, init, update, view, viewChart, viewMini)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Svg as S
import Svg.Attributes as SA

import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS

import Element as E
import Element.Font as F
import Element.Input as I
import Element.Border as B
import Element.Background as BG

import Articles.GenderAndSalery.Data as Salary
import FeatherIcons as Icon


type alias Model =
  { hovering : List (CI.One Salary.Datum CI.Dot)
  , moving : Maybe ( CS.Point, CS.Point )
  , offset : CS.Point
  , center : CS.Point
  , percentage : Float
  }


init : Model
init =
  { hovering = []
  , moving = Nothing
  , offset = { x = 0, y = 0 }
  , center = { x = 0, y = 0 }
  , percentage = 100
  }


type Msg
  = OnMouseMove (List (CI.One Salary.Datum CI.Dot)) CS.Point
  | OnMouseDown CS.Point
  | OnMouseUp CS.Point
  | OnDoubleClick CS.Point
  | OnZoomIn
  | OnZoomOut
  | OnZoomReset
  | OnReset


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnMouseDown coords ->
      { model | moving = Just ( coords, coords ) }

    OnMouseMove hovering coords ->
      case model.moving of
        Nothing ->
          { model | hovering = hovering }

        Just ( start, _ ) ->
          { model | hovering = [], moving = Just ( start, coords ) }

    OnMouseUp coords ->
      case model.moving of
        Nothing ->
          model

        Just ( start, _ ) ->
          { model | moving = Nothing, offset =
              { x = model.offset.x + start.x - coords.x
              , y = model.offset.y + start.y - coords.y
              }
          }

    OnDoubleClick coords ->
      { model
      | percentage = model.percentage + 20
      , center = coords
      , offset = { x = 0, y = 0 }
      }

    OnZoomIn ->
      { model | percentage = model.percentage + 20 }

    OnZoomOut ->
      { model | percentage = model.percentage - 20 }

    OnZoomReset ->
      { model | percentage = 100, offset = { x = 0, y = 0 }, center = { x = 0, y = 0 } }

    OnReset ->
      { model | hovering = [], moving = Nothing }


view : Model -> Float -> E.Element Msg
view model year =
  E.column
    [ E.width E.fill
    , E.spacing 30
    ]
    [ E.row
        [ E.spacing 40
        , F.bold
        ]
        [ E.row
            [ E.spacing 20
            , F.size 12
            ] <|
            let circle color a b =
                  E.row [ E.spacing 5 ]
                    [ E.el
                        [ BG.color (color 0.4)
                        , B.color (color 1)
                        , B.width 1
                        , B.rounded 50
                        , E.width (E.px 10)
                        , E.height (E.px 10)
                        ]
                        E.none
                    , E.text (String.fromInt a ++ " - " ++ String.fromInt b ++ "%")
                    ]
            in
            [ E.text "Percentage of women in sector's workforce: "
            , circle (E.rgba255 88  169 246)  0 20  -- most blue
            , circle (E.rgba255 138 145 247) 20 40  -- blue
            , circle (E.rgba255 197 121 242) 40 60  -- middle
            , circle (E.rgba255 222 116 215) 60 80  -- pink
            , circle (E.rgba255 245 109 188) 80 100 -- most pink
            ]

        , E.row
            [ E.spacing 10 ]
            [ E.text "Zoom: "
            , E.text (String.fromFloat model.percentage ++ "%")
            , E.row
                [ B.width 1
                , B.rounded 5
                , B.color (E.rgb255 220 220 220)
                ]
                [ I.button
                    [ E.paddingXY 10 5
                    , B.widthEach { top = 0, right = 1, bottom = 0, left = 0 }
                    , B.color (E.rgb255 220 220 220)
                    ]
                    { onPress = Just OnZoomIn
                    , label = E.html (Icon.toHtml [] <| Icon.withSize 14 <| Icon.plus)
                    }
                , I.button
                    [ E.paddingXY 10 5
                    , B.widthEach { top = 0, right = 1, bottom = 0, left = 0 }
                    , B.color (E.rgb255 220 220 220)
                    ]
                    { onPress = Just OnZoomOut
                    , label = E.html (Icon.toHtml [] <| Icon.withSize 14 <| Icon.minus)
                    }
                , I.button
                    [ E.paddingXY 10 5
                    , B.widthEach { top = 0, right = 1, bottom = 0, left = 0 }
                    , B.color (E.rgb255 220 220 220)
                    , E.moveRight 1
                    ]
                    { onPress = Just OnZoomReset
                    , label = E.html (Icon.toHtml [] <| Icon.withSize 14 <| Icon.x)
                    }
                ]
            ]
        ]

    , E.el [ E.width E.fill ] (E.html (viewChart model year))
    ]


viewChart : Model -> Float -> H.Html Msg
viewChart model year =
  let ( xOff, yOff ) =
        case model.moving of
          Just ( a, b ) ->
            ( model.offset.x + a.x - b.x
            , model.offset.y + a.y - b.y
            )

          Nothing ->
            ( model.offset.x
            , model.offset.y
            )

      ( centerX, centerY ) =
        if model.center.x == 0 && model.center.y == 0
        then ( identity, identity )
        else ( CA.centerAt model.center.x, CA.centerAt model.center.y )
  in
  C.chart
    [ CA.height 550
    , CA.width 1000
    , CA.margin { top = 0, bottom = 20, left = 0, right = 0 }
    , CA.range [ CA.lowest 20000 CA.orHigher, CA.zoom model.percentage, centerX, CA.pad -xOff xOff ]
    , CA.domain [ CA.lowest 76 CA.orHigher, CA.zoom model.percentage, centerY, CA.pad yOff -yOff ]

    , CE.on "mousemove" (CE.map2 OnMouseMove (CE.getWithin 40 CI.dots) CE.getSvgCoords)
    , CE.onMouseDown OnMouseDown CE.getSvgCoords
    , CE.onMouseUp OnMouseUp CE.getSvgCoords
    , CE.onDoubleClick OnDoubleClick CE.getCoords
    , CE.onMouseLeave OnReset

    , CA.htmlAttrs
        [ HA.style "user-select" "none"
        , HA.style "cursor" <|
            case model.moving of
              Just _ -> "grabbing"
              Nothing -> "grab"
        ]
    ]
    [ C.generate 10 CS.ints .x [] <| \p t ->
        [ C.xLabel
            [ CA.alignLeft, CA.moveUp 22, CA.moveRight 7, CA.x (toFloat t), CA.withGrid
            , if t == 20000 then CA.noGrid else identity
            ]
            [ S.text (String.fromInt (t // 1000) ++ "k") ]
        ]

    , C.generate 8 CS.ints .y [] <| \p t ->
        [ C.yLabel
            [ CA.alignLeft
            , CA.withGrid
            , CA.moveUp 10
            , CA.moveRight 10
            , CA.y (toFloat t)
            , if t == 100 then CA.noGrid else identity
            ]
            [ S.text (String.fromInt t) ]
      ]

    , C.withPlane <| \p ->
        [ C.label [ CA.fontSize 12, CA.moveDown 17, CA.alignRight ] [ S.text "Average salary" ] { x = p.x.max, y = p.y.min }
        , C.label [ CA.fontSize 12, CA.moveLeft 12, CA.alignRight, CA.rotate 90 ] [ S.text "Womens % of mens salary" ] { x = p.x.min, y = p.y.max }
        , C.line [ CA.dashed [ 4, 2 ], CA.opacity 0.7, CA.color "#f56dbc", CA.x1 (Salary.avgSalaryWomen year) ]
        , C.line [ CA.dashed [ 4, 2 ], CA.opacity 0.7, CA.color "#58a9f6", CA.x1 (Salary.avgSalaryMen year) ]
        ]

    , C.line [ CA.dashed [ 3, 3 ], CA.y1 100 ]

    , salarySeries model year 0.9 5 150

    , C.eachItem <| \p product ->
        let datum = CI.getData product
            color = CI.getColor product
            top = CI.getTop p product
        in
        if String.startsWith "251 " datum.sector then
          [ C.line [ CA.color color, CA.break, CA.x1 top.x, CA.y1 top.y, CA.x2Svg 10, CA.y2Svg 10 ]
          , C.label [ CA.color color,CA.alignLeft, CA.moveRight 13, CA.moveUp 7 ] [ S.text "Software engineering" ] top
          ]
        else
          []

    , C.withPlane <| \p ->
        [ C.line [ CA.color "red", CA.y1 (CA.middle p.y) ]
        , C.line [ CA.color "red", CA.x1 (CA.middle p.x) ]
        ]

    --, case model.window of
    --    Just _ ->
    --     C.htmlAt .max .min -10 20
    --        [ HA.style "transform" "translate(-100%, -100%)"
    --        , HA.style "background" "white"
    --        , HA.style "border" "1px solid rgb(210, 210, 210)"
    --        , HA.style "cursor" "pointer"
    --        , HA.style "width" "167px"
    --        , HE.onClick OnExitWindow
    --        ]
    --        [ viewMini model year
    --        , H.button
    --            [ HA.style "position" "absolute"
    --            , HA.style "top" "0"
    --            , HA.style "right" "0"
    --            , HA.style "background" "transparent"
    --            , HA.style "color" "rgb(100, 100, 100)"
    --            , HA.style "border" "0"
    --            , HA.style "height" "30px"
    --            , HA.style "width" "30px"
    --            , HA.style "padding" "0"
    --            , HA.style "margin" "0"
    --            , HA.style "cursor" "pointer"
    --            ]
    --            [ H.span
    --                [ HA.style "font-size" "28px"
    --                , HA.style "position" "absolute"
    --                , HA.style "top" "40%"
    --                , HA.style "left" "50%"
    --                , HA.style "transform" "translate(-50%, -50%)"
    --                , HA.style "line-height" "10px"
    --                ]
    --                [ H.text "⨯" ]
    --            ]
    --        ]

        --Nothing ->
        --  C.none

    , C.each model.hovering <| \p item ->
        [ C.tooltip item [] [] [ tooltipContent item ] ]

    --, case model.selection of
    --    Just select -> C.rect [ CA.opacity 0.5, CA.x1 select.a.x, CA.x2 select.b.x, CA.y1 select.a.y, CA.y2 select.b.y ]
    --    Nothing -> C.none
    ]


viewMini : Model -> Float -> H.Html Msg
viewMini model year =
  C.chart
    [ CA.height 100
    , CA.width 167
    , CA.padding { top = 15, bottom = 0, left = 15, right = 15 }
    , CA.range [ CA.lowest 20000 CA.orHigher ]
    , CA.domain [ CA.lowest 76 CA.orHigher ]
    ]
    [ C.grid [ CA.width 0.5 ]
    , C.xTicks [ CA.height 0, CA.amount 8 ]
    , C.yTicks [ CA.height 0, CA.amount 8 ]
    , C.line [ CA.dashed [ 3, 3 ], CA.y1 100, CA.width 0.5 ]

    --, case model.window of
    --    Just select -> C.rect [ CA.color "#0000001F", CA.borderWidth 0, CA.x1 select.x1, CA.x2 select.x2, CA.y1 select.y1, CA.y2 select.y2 ]
    --    Nothing -> C.none

    , salarySeries model year 0.3 3 4000
    ]


salarySeries : Model -> Float -> Float -> Float -> Float -> C.Element Salary.Datum Msg
salarySeries model year border highlightSize size =
  C.series .salaryBoth
      [ C.scatterMaybe Salary.womenSalaryPerc
          [ CA.opacity 0.4, CA.circle, CA.border CA.blue, CA.borderWidth border ]
            |> C.variation (\i d ->
                  let precentOfWomen =
                        Salary.womenPerc d

                      color =
                        if precentOfWomen < 20
                        then [ CA.border "#58a9f6", CA.color "#58a9f6" ]
                        else if precentOfWomen < 40
                        then [ CA.border "#8a91f7", CA.color "#8a91f7" ]
                        else if precentOfWomen < 60
                        then [ CA.border "#c579f2", CA.color "#c579f2" ]
                        else if precentOfWomen < 80
                        then [ CA.border "#de74d7", CA.color "#de74d7" ]
                        else [ CA.border "#f56dbc", CA.color "#f56dbc" ]
                  in
                  [ CA.size ((d.numOfBoth / size) * model.percentage / 100) ] ++ color
                )
          |> C.amongst model.hovering (\d -> [ CA.highlight 0.4, CA.highlightWidth highlightSize, CA.opacity 0.6 ])
      ]
      (List.filter (.year >> (==) year) Salary.data)


tooltipContent : CI.One Salary.Datum CI.Dot -> H.Html msg
tooltipContent hovered =
  let datum = CI.getData hovered
      precentOfWomen = round (Salary.womenPerc datum)
      percentOfSalary = round (Maybe.withDefault 0 (Salary.womenSalaryPerc datum))
      percentOfSalaryMen = round (Maybe.withDefault 0 (Salary.menSalaryPerc datum))
  in
  H.div [ HA.style "user-select" "none" ]
    [ H.h4
        [ HA.style "width" "240px"
        , HA.style "margin-top" "5px"
        , HA.style "margin-bottom" "5px"
        , HA.style "line-break" "normal"
        , HA.style "white-space" "normal"
        , HA.style "line-height" "1.25"
        , HA.style "color" (CI.getColor hovered)
        ]
        [ H.text datum.sector ]

    , H.table
        [ HA.style "color" "rgb(90, 90, 90)"
        , HA.style "width" "100%"
        , HA.style "font-size" "11px"
        ]
        [ H.tr []
            [ H.th [] []
            , H.th [ HA.style "text-align" "right" ] [ H.text "Women" ]
            , H.th [ HA.style "text-align" "right" ] [ H.text "%" ]
            , H.th [ HA.style "text-align" "right" ] [ H.text "Men" ]
            , H.th [ HA.style "text-align" "right" ] [ H.text "%" ]
            ]
        , H.tr []
            [ H.th [ HA.style "text-align" "left" ] [ H.text "Salary" ]
            , H.th [ HA.style "text-align" "right" ] [ H.text (String.fromInt (round datum.salaryWomen)) ]
            , H.th [ HA.style "text-align" "right" ] [ H.text (String.fromInt percentOfSalary) ]
            , H.th [ HA.style "text-align" "right" ] [ H.text (String.fromInt (round datum.salaryMen)) ]
            , H.th [ HA.style "text-align" "right" ] [ H.text (String.fromInt percentOfSalaryMen) ]
            ]
        , H.tr []
            [ H.th [ HA.style "text-align" "left" ] [ H.text "Distribution" ]
            , H.th [ HA.style "text-align" "right" ] [ H.text (String.fromFloat datum.numOfWomen) ]
            , H.th [ HA.style "text-align" "right" ] [ H.text (String.fromInt precentOfWomen) ]
            , H.th [ HA.style "text-align" "right" ] [ H.text (String.fromFloat datum.numOfMen) ]
            , H.th [ HA.style "text-align" "right" ] [ H.text (String.fromInt (100 - precentOfWomen)) ]
            ]
        ]
    ]
