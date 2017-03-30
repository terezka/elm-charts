module Internal.Axis exposing (..)

import Svg exposing (Svg, Attribute, g)
import Svg.Attributes exposing (class, x1, x2, y1, y2, style)
import Internal.Base as Base
import Internal.Utils exposing (viewMaybe)
import Axis
import Plot



-- VIEWS


{-| -}
viewHorizontal : Base.Plot -> Maybe Axis.Customizations -> Svg Never
viewHorizontal plot sometimesAnAxis =
  viewMaybe sometimesAnAxis <| \axis ->
    let
      at y =
        { x = axis.position plot.x.min plot.x.max, y = y }

      viewMark { position, customizations } =
        g [ class "elm-plot__mark" ]
          [ viewMaybe customizations.tick (viewHorizontalTick plot axis (at position))
          , viewMaybe customizations.view (viewHorizontalLabel plot axis (at position))
          ]
    in
      g [ class "elm-plot__vertical-axis" ]
        [ viewMaybe axis.axisLine (viewAxisLine plot at)
        , g [ class "elm-plot__marks" ] (List.map viewMark axis.marks)
        ]


{-| -}
viewVertical : Base.Plot -> Maybe Axis.Customizations -> Svg Never
viewVertical plot sometimesAnAxis =
  viewMaybe sometimesAnAxis <| \axis ->
    let
      at y =
        { x = axis.position plot.x.min plot.x.max, y = y }

      viewMark { position, customizations } =
        g [ class "elm-plot__mark" ]
          [ viewMaybe customizations.tick (viewVerticalTick plot axis (at position))
          , viewMaybe customizations.view (viewVerticalLabel plot axis (at position))
          ]
    in
      g [ class "elm-plot__vertical-axis" ]
        [ viewMaybe axis.axisLine (viewAxisLine plot at)
        , g [ class "elm-plot__marks" ] (List.map viewMark axis.marks)
        ]


{-| -}
viewVerticals : Base.Plot -> List (Maybe Axis.Customizations) -> Svg Never
viewVerticals plot verticalAxes =
  g [ class "elm-plot__vertical-axes" ] (List.map (viewVertical plot) verticalAxes)


-- VIEW AXIS LINE


viewAxisLine : Base.Plot -> (Float -> Plot.Point) -> Axis.LineCustomizations -> Svg Never
viewAxisLine plot at { attributes, start, end } =
  Base.path attributes (Base.linear plot [ at start, at end ])



-- VIEW TICK


viewHorizontalTick : Base.Plot -> Axis.Customizations -> Plot.Point -> Axis.TickCustomizations -> Svg Never
viewHorizontalTick plot { flipAnchor } position { attributes, length } =
  let
    lengthOfTick length =
      if flipAnchor then -length else length
  in
    g [ Base.place plot position 0 0 ]
      [ viewTick attributes 0 (lengthOfTick length) ]


viewVerticalTick : Base.Plot -> Axis.Customizations -> Plot.Point -> Axis.TickCustomizations -> Svg Never
viewVerticalTick plot { flipAnchor } position { attributes, length } =
  let
    lengthOfTick length =
      if flipAnchor then length else -length
  in
    g [ Base.place plot position 0 0 ]
      [ viewTick attributes (lengthOfTick length) 0 ]


viewTick : List (Attribute msg) -> Float -> Float -> Svg msg
viewTick attributes width height =
  Svg.line (x2 (toString width) :: y2 (toString height) :: attributes) []



-- VIEW LABEL


viewHorizontalLabel : Base.Plot -> Axis.Customizations ->  Plot.Point -> Svg Never -> Svg Never
viewHorizontalLabel plot { flipAnchor } position view =
  let
    offset =
      if flipAnchor then -10 else 20
  in
    g [ Base.place plot position 0 offset
      , style "text-anchor: middle;"
      ]
      [ view ]


viewVerticalLabel : Base.Plot -> Axis.Customizations -> Plot.Point -> Svg Never -> Svg Never
viewVerticalLabel plot { flipAnchor } position view =
  let
    anchorOfLabel =
      if flipAnchor then "text-anchor: start;" else "text-anchor: end;"

    offset =
      if flipAnchor then -10 else 20
  in
    g [ Base.place plot position offset 5
      , style anchorOfLabel
      ]
      [ view ]


{-| -}
viewGrid : Base.Plot -> (Axis.MarkCustomizations -> Maybe Axis.LineCustomizations) -> List Axis.Mark -> List Axis.Mark -> Svg Never
viewGrid plot toGridLine verticals horizontals =
  let
    viewGridLine attributes coords =
      Base.path attributes (Base.linear plot coords)

    viewVertical position { attributes, start, end } =
      viewGridLine attributes [ { x = position, y = start }, { x = position, y = end } ]

    viewHorizontal position { attributes, start, end } =
      viewGridLine attributes [ { x = start, y = position }, { x = end, y = position } ]

    unfoldGridline view { position, customizations } =
      Maybe.map (view position) (toGridLine customizations)

    viewGridLines view =
      List.filterMap (unfoldGridline view)
  in
    g [ class "elm-plot__grid" ]
      [ g [ class "elm-plot__horizontal-grid" ] (viewGridLines viewHorizontal verticals)
      , g [ class "elm-plot__vertical-grid" ] (viewGridLines viewVertical horizontals)
      ]



-- HELPERS


{-| -}
composeAxis : (a -> Maybe Axis.Mark) -> List a -> { axis : Maybe Axis.Customizations } -> Maybe Axis.Customizations
composeAxis toMark dataPoints { axis } =
  Maybe.map (\axis -> { axis | marks = axis.marks ++ List.filterMap toMark dataPoints }) axis
