module Internal.Axis exposing (..)

import Svg exposing (Svg, Attribute, g)
import Svg.Attributes exposing (class, x1, x2, y1, y2, style, fill)
import Svg.Coordinates as Coordinates exposing (Plane, Point, place, placeWithOffset)
import Svg.Plot exposing (linear, clear, xTick, yTick, horizontal, vertical, fullHorizontal, fullVertical)
import Internal.Utils exposing (viewMaybe)
import Axis exposing (Axis(..))



-- VIEWS


viewHorizontal : Plane -> Axis.View -> Svg Never
viewHorizontal plane axis =
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
    g [ class "elm-plot__axis--horizontal" ]
      [ viewMaybe axis.line (apply plane.x >> viewAxisLine)
      , g [ class "elm-plot__marks" ] (List.map viewMark (apply plane.x axis.marks))
      ]


viewVertical : Plane -> Axis.View -> Svg Never
viewVertical plane axis =
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
    g [ class "elm-plot__axis--vertical" ]
      [ viewMaybe axis.line (apply plane.y >> viewAxisLine)
      , g [ class "elm-plot__marks" ] (List.map viewMark (apply plane.y axis.marks))
      ]


viewVerticals : Plane -> List Axis.View -> Svg Never
viewVerticals plane axes =
  g [ class "elm-plot__axes--vertical" ] (List.map (viewVertical plane) axes)



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
viewHorizontalLabel plane { mirror } position view =
  let
    offset =
      if mirror then -10 else 20
  in
    g [ placeWithOffset plane position 0 offset, style "text-anchor: middle;" ]
      [ view ]


viewVerticalLabel : Plane -> Axis.View -> Point -> Svg Never -> Svg Never
viewVerticalLabel plane { mirror } position view =
  let
    anchorOfLabel =
      if mirror then "text-anchor: start;" else "text-anchor: end;"

    offset =
      if mirror then 20 else -10
  in
    g [ placeWithOffset plane position offset 5, style anchorOfLabel ]
      [ view ]



-- VIEW GRID


viewGrid : Plane -> List Axis.Mark -> List Axis.Mark -> Svg Never
viewGrid plane verticals horizontals =
  let
    unfoldHorizontal { position, view } =
      Maybe.map (\attributes -> fullHorizontal plane attributes position) view.grid

    unfoldVertical { position, view } =
      Maybe.map (\attributes -> fullVertical plane attributes position) view.grid
  in
    g [ class "elm-plot__grid" ]
      [ g [ class "elm-plot__grid--horizontal" ] (List.filterMap unfoldHorizontal horizontals)
      , g [ class "elm-plot__grid--vertical" ] (List.filterMap unfoldVertical horizontals)
      ]


viewBunchOfLines : Plane -> List Axis.Mark -> List Axis.Mark -> Svg Never
viewBunchOfLines plane verticals horizontals =
  let
    -- TODO: There gotta be a way to pipe this

    viewGridLine direction position { attributes, start, end } =
      direction plane attributes position start end

    unfold toAxis direction { position, view } =
      Maybe.map (\toView -> viewGridLine direction position (toView (raport (toAxis plane)))) view.junk

    viewGridLines toAxis direction =
      List.filterMap (unfold toAxis direction)
  in
    g [ class "elm-plot__junk-lines" ]
      [ g [ class "elm-plot__junk-lines--horizontal" ] (viewGridLines .x horizontal horizontals)
      , g [ class "elm-plot__junk-lines--vertical" ] (viewGridLines .y vertical verticals)
      ]



-- UTILS


raport : Coordinates.Axis -> Axis.Raport
raport axis =
  { min = axis.min
  , max = axis.max
  }


apply : Coordinates.Axis -> (Axis.Raport -> a) -> a
apply axis toStuff =
  toStuff (raport axis)


compose : Axis.View -> List Axis.Mark -> Axis.View
compose axisView marks =
  { axisView | marks = axisView.marks >> List.append marks }


maybeCompose : Axis.Axis -> List Axis.Mark -> Maybe Axis.View
maybeCompose sometimesAnAxis marks =
  case sometimesAnAxis of
    Axis axisView ->
      Just (compose axisView marks)

    SometimesYouDontHaveAnAxis ->
      Nothing
