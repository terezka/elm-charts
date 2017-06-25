module Internal.Hint exposing (decoder, viewHint)

import Json.Decode as Json
import DOM
import Svg.Coordinates exposing (Plane, Point, minimum, maximum, toCartesianX, toCartesianY, toSVGX, toSVGY)
import Internal.Utils exposing (..)
import Hint exposing (..)
import Html exposing (Html)


-- DECODER


{-| -}
decoder : Plane -> (Maybe Point -> msg) -> Json.Decoder msg
decoder plane toMsg =
    Json.map3
        (hintMessage plane toMsg)
        (Json.field "clientX" Json.float)
        (Json.field "clientY" Json.float)
        (DOM.target plotPosition)


plotPosition : Json.Decoder DOM.Rectangle
plotPosition =
    Json.oneOf
        [ DOM.boundingClientRect
        , Json.lazy (\_ -> DOM.parentElement plotPosition)
        ]


hintMessage : Plane -> (Maybe Point -> msg) -> Float -> Float -> DOM.Rectangle -> msg
hintMessage plane toMsg mouseX mouseY { left, top } =
  toMsg <|
    Just
      { x = clamp plane.x.min plane.x.max <| toCartesianX plane (mouseX - left)
      , y = clamp plane.y.min plane.y.max <| toCartesianY plane (mouseY - top)
      }



-- VIEW


{-| -}
viewHint : Plane -> List (Positioned a) -> Hint msg -> Html Never
viewHint plane dots hint =
  case ( dots, hint.model ) of
    ( first :: rest, Just model ) ->
      viewHintPoint plane first dots hint model
        |> Maybe.withDefault (Html.text "")

    ( _, _ ) ->
      Html.text ""


viewHintPoint : Plane -> Positioned a -> List (Positioned a) -> Hint msg -> Point -> Maybe (Html Never)
viewHintPoint plane first dots hint hovered =
  let
    distanceX dot =
      toSVGX plane dot.x - toSVGX plane hovered.x

    distanceY dot =
      toSVGY plane dot.y - toSVGY plane hovered.y

    distance dot =
        sqrt <| (distanceX dot) ^ 2 + (distanceY dot) ^ 2

    withinProximity proximity dot =
      distance dot <= proximity

    withinProximityX proximity dot =
      abs (distanceX dot) <= proximity

    getClosest closest dot =
      if distance closest < distance dot then
        closest
      else
        dot

    getClosestByX dot allClosest =
      case List.head allClosest of
        Just closest ->
            if distanceX closest == distanceX dot then
              dot :: allClosest
            else if distanceX closest > distanceX dot then
              [ dot ]
            else
              allClosest

        Nothing ->
          [ dot ]
  in
    case ( hint.view, hint.proximity ) of
      ( Hint.Single view, Just proximity ) ->
        List.filter (withinProximity proximity) dots
          |> List.head
          |> Maybe.map (dotToPoint >> view)

      ( Hint.Single view, Nothing ) ->
        List.foldl getClosest first dots
          |> dotToPoint
          |> view
          |> Just

      ( Hint.Aligned view, Just proximity ) ->
        List.filter (withinProximityX proximity) dots
          |> List.foldl getClosestByX []
          |> List.map dotToPoint
          |> nonEmptyList
          |> Maybe.map view

      ( Hint.Aligned view, Nothing ) ->
        List.foldl getClosestByX [] dots
          |> List.map dotToPoint
          |> view
          |> Just


dotToPoint : Positioned a -> Point
dotToPoint dot =
  { x = dot.x, y = dot.y }
