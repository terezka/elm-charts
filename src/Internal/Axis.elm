module Internal.Axis exposing (..)

import Svg exposing (Svg, Attribute, g)
import Svg.Attributes exposing (class, x1, x2, y1, y2, style, fill)
import Svg.Coordinates as Coordinates exposing (Plane, Point, place, placeWithOffset)
import Svg.Plot exposing (linear, clear, xTick, yTick, horizontal, vertical)
import Internal.Utils exposing (viewMaybe)
import Axis exposing (Axis(..))



-- VIEWS


viewHorizontal : Plane -> Maybe Axis.View -> Svg Never
viewHorizontal plane sometimesAnAxis =
  viewMaybe sometimesAnAxis <| \axis ->
    let
      axisPosition =
        axis.position plane.y.min plane.y.max

      at x =
        { x = x, y = axisPosition }

      viewAxisLine { attributes, start, end } =
        horizontal plane attributes axisPosition start end

      viewMark { position, view } =
        g [ class "elm-plot__mark" ]
          [ viewMaybe view.tick (viewHorizontalTick plane axis (at position))
          , viewMaybe view.label (viewHorizontalLabel plane axis (at position))
          ]
    in
      g [ class "elm-plot__horizontal-axis" ]
        [ viewMaybe axis.axisLine viewAxisLine
        , g [ class "elm-plot__marks" ] (List.map viewMark axis.marks)
        ]


viewVertical : Plane -> Maybe Axis.View -> Svg Never
viewVertical plane sometimesAnAxis =
  viewMaybe sometimesAnAxis <| \axis ->
    let
      axisPosition =
        axis.position plane.x.min plane.x.max

      at y =
        { x = axisPosition, y = y }

      viewAxisLine { attributes, start, end } =
        vertical plane attributes axisPosition start end

      viewMark { position, view } =
        g [ class "elm-plot__mark" ]
          [ viewMaybe view.tick (viewVerticalTick plane axis (at position))
          , viewMaybe view.label (viewVerticalLabel plane axis (at position))
          ]
    in
      g [ class "elm-plot__vertical-axis" ]
        [ viewMaybe axis.axisLine viewAxisLine
        , g [ class "elm-plot__marks" ] (List.map viewMark axis.marks)
        ]


viewAxes : (Maybe Axis.View -> Svg Never) -> List (Maybe Axis.View) -> Svg Never
viewAxes view axes =
  g [ class "elm-plot__independent-axes" ] (List.map view axes)



-- VIEW TICK


viewHorizontalTick : Plane -> Axis.View -> Point -> Axis.TickView -> Svg Never
viewHorizontalTick plane view { x, y } { attributes, length } =
  xTick plane (lengthOfTick view length) attributes y x


viewVerticalTick : Plane -> Axis.View -> Point -> Axis.TickView -> Svg Never
viewVerticalTick plane view { x, y } { attributes, length } =
  yTick plane (lengthOfTick view length) attributes x y


lengthOfTick : Axis.View -> Int -> Int
lengthOfTick { mirror } length =
  if mirror then -length else length



-- VIEW LABEL


viewHorizontalLabel : Plane -> Axis.View -> Point -> Svg Never -> Svg Never
viewHorizontalLabel plot { mirror } position view =
  let
    offset =
      if mirror then -10 else 20
  in
    g [ placeWithOffset plot position 0 offset , style "text-anchor: middle;" ]
      [ view ]


viewVerticalLabel : Plane -> Axis.View -> Point -> Svg Never -> Svg Never
viewVerticalLabel plot { mirror } position view =
  let
    anchorOfLabel =
      if mirror then "text-anchor: start;" else "text-anchor: end;"

    offset =
      if mirror then 20 else -10
  in
    g [ placeWithOffset plot position offset 5, style anchorOfLabel ]
      [ view ]



-- VIEW GRID


viewGrid : Plane -> (Axis.MarkView -> Maybe (Axis.Raport -> Axis.LineView)) -> List Axis.Mark -> List Axis.Mark -> Svg Never
viewGrid plane getGridLine verticals horizontals =
  let
    -- TODO: There gotta be a way to pipe this
    
    viewGridLine direction position { attributes, start, end } =
      direction plane attributes position start end

    assembleGridLine toAxis direction position creator =
      viewGridLine direction position (creator (raport (toAxis plane)))

    unfoldGridline toAxis viewDirectional { position, view } =
      Maybe.map (assembleGridLine toAxis viewDirectional position) (getGridLine view)

    viewGridLines axis viewDirectional =
      List.filterMap (unfoldGridline axis viewDirectional)
  in
    g [ class "elm-plot__grid" ]
      [ g [ class "elm-plot__horizontal-grid" ] (viewGridLines .x horizontal horizontals)
      , g [ class "elm-plot__vertical-grid" ] (viewGridLines .y vertical verticals)
      ]



-- UTILS


raport : Coordinates.Axis -> Axis.Raport
raport axis =
  { min = axis.min
  , max = axis.max
  }


composeAxisView : Coordinates.Axis -> (Axis.Raport -> Axis.View) -> List Axis.Mark -> Axis.View
composeAxisView axis creator marks =
  let
    axisView =
      creator (raport axis)
  in
    { axisView | marks = axisView.marks ++ marks }


maybeComposeAxisView : Coordinates.Axis -> Axis.Axis -> List Axis.Mark -> Maybe Axis.View
maybeComposeAxisView axis sometimesAnAxis marks =
  case sometimesAnAxis of
    Axis creator ->
      Just (composeAxisView axis creator marks)

    SometimesYouDontHaveAnAxis ->
      Nothing
