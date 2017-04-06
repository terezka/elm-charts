module Hint exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes
import Internal.Base as Base
import Plot
import Colors exposing (..)

{-| A view located at the bottom left corner of you plot, holding the hint views you
  (maybe) added in your data points or groups.
-}
normalHintContainer : Base.Plot -> List (Html Never) -> Html Never
normalHintContainer plot =
  div [ Html.Attributes.style [ ( "margin-left", toString plot.x.marginLower ++ "px" ) ] ]


{-| A view holding your hint views which flies around on your plot following the hovered x.
-}
flyingHintContainer : (Bool -> List (Html Never) -> Html Never) -> Maybe Plot.Point -> Base.Plot -> List (Html Never) -> Html Never
flyingHintContainer inner hovering plot hints =
  case hovering of
    Nothing ->
      text ""

    Just point ->
      viewFlyingHintContainer inner point plot hints


viewFlyingHintContainer : (Bool -> List (Html Never) -> Html Never) -> Plot.Point -> Base.Plot -> List (Html Never) -> Html Never
viewFlyingHintContainer inner { x } plot hints =
    let
      xOffset =
        Base.toSVGX plot x

      isLeft =
        (x - plot.x.min) > (Base.range plot.x) / 2

      direction =
        if isLeft then
          "translateX(-100%)"
        else
          "translateX(0)"

      style =
        [ ( "position", "absolute" )
        , ( "top", "25%" )
        , ( "left", toString xOffset ++ "px" )
        , ( "transform", direction )
        , ( "pointer-events", "none" )
        ]
    in
      div [ Html.Attributes.style style ] [ inner isLeft hints ]


{-| The normal hint view.
-}
normalHintContainerInner : Bool -> List (Html Never) -> Html Never
normalHintContainerInner isLeft hints =
  let
    margin =
      if isLeft then
        10
      else
        10
  in
    div
      [ Html.Attributes.style
        [ ( "margin", "0 " ++ toString margin ++ "px" )
        , ( "padding", "5px 10px" )
        , ( "background", grey )
        , ( "border-radius", "2px" )
        , ( "color", "black" )
        ]
      ] hints
