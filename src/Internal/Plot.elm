module Internal.Plot exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes
import Html.Events
import Svg exposing (Svg, Attribute, svg, g)
import Svg.Attributes as Attributes
import Internal.Base as Base
import Plot
import Internal.Axis
import Json.Decode as Json
import DOM


{-| -}
type alias DataPoint a =
  { a
  | hint : Maybe (Html Never)
  , x : Float
  , y : Float
  }


{-| -}
view : Base.Plot -> Plot.Customizations msg -> List (DataPoint a) -> List (Svg.Svg msg) -> Svg.Svg msg
view plot customizations dataPoints children =
  div
    (containerAttributes customizations plot)
    [ svg (innerAttributes customizations) children
    , viewHint plot customizations dataPoints
    ]


viewClipPath : Plot.Customizations msg -> Base.Plot -> Svg.Svg msg
viewClipPath customizations plot =
  let
    clipPath =
      Svg.clipPath [ Attributes.id (toClipPathId customizations) ]
        [ Svg.rect
          [ Attributes.x (toString plot.x.marginLower)
          , Attributes.y (toString plot.y.marginLower)
          , Attributes.width (toString (Base.length plot.x))
          , Attributes.height (toString (Base.length plot.y))
          ]
          []
        ]
  in
    Svg.defs [] (clipPath :: customizations.defs)


toClipPathId : Plot.Customizations msg -> String
toClipPathId { id } =
  "elm-plot__clip-path__" ++ id


containerAttributes : Plot.Customizations msg -> Base.Plot -> List (Attribute msg)
containerAttributes customizations plot =
  [ Attributes.id customizations.id
  , Html.Attributes.style
    [ ( "position", "relative" )
    , ( "margin", "0 auto" )
    , ( "width", toString customizations.width ++ "px" )
    , ( "height", toString customizations.height ++ "px" )
    ]
  ] ++
  (containerAttributesHint customizations plot)


containerAttributesHint : Plot.Customizations msg -> Base.Plot -> List (Attribute msg)
containerAttributesHint customizations plot =
  case customizations.onHover of
      Just toMsg ->
        [ Html.Events.on "mousemove" (onMouseOver plot toMsg)
        , Html.Events.onMouseLeave (toMsg Nothing)
        ]

      Nothing ->
        []


innerAttributes : Plot.Customizations msg -> List (Attribute msg)
innerAttributes customizations =
  customizations.attributes ++
    [ Attributes.width (toString customizations.width)
    , Attributes.height (toString customizations.height)
    ]


viewJunk : Base.Plot -> Plot.Junk msg -> Svg msg
viewJunk plot { x, y, view } =
  g [ Base.place plot { x = x, y = y } 0 0 ] [ view ]



-- HINT


viewHint : Base.Plot -> Plot.Customizations msg -> List (Base.DataPoint { a | hint : Maybe (Html Never) }) -> Html msg
viewHint plot customizations allDataPoints =
  case List.filterMap .hint allDataPoints of
    [] ->
      text ""

    views ->
      Html.map never <| customizations.hintContainer (toSummary plot) views


onMouseOver : Base.Plot -> (Maybe Plot.Point -> msg) -> Json.Decoder msg
onMouseOver plot toMsg =
    Json.map3
        (\x y r -> toMsg (unScalePoint plot x y r))
        (Json.field "clientX" Json.float)
        (Json.field "clientY" Json.float)
        (DOM.target plotPosition)


plotPosition : Json.Decoder DOM.Rectangle
plotPosition =
    Json.oneOf
        [ DOM.boundingClientRect
        , Json.lazy (\_ -> DOM.parentElement plotPosition)
        ]


unScalePoint : Base.Plot -> Float -> Float -> DOM.Rectangle -> Maybe Plot.Point
unScalePoint plot mouseX mouseY { left, top } =
    Just
      { x = toNearestX plot <| Base.unScaleValue plot.x (mouseX - left)
      , y = clamp plot.y.min plot.y.max <| Base.unScaleValue plot.y (plot.y.length - mouseY - top)
      }


toNearestX : Base.Plot -> Float -> Float
toNearestX plot exactX =
  let
    default =
      Maybe.withDefault 0 (List.head plot.x.all)

    updateIfCloser closest x =
      if diff x exactX > diff closest exactX then
        closest
      else
        x
  in
    List.foldl updateIfCloser default plot.x.all


diff : Float -> Float -> Float
diff a b =
  abs (a - b)


-- UTILS


toSummary : Base.Plot -> Plot.Summary
toSummary plot =
  { x = Internal.Axis.toSummary plot.x
  , y = Internal.Axis.toSummary plot.y
  }
