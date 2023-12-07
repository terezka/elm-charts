module Internal.Events exposing (..)


import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Internal.Coordinates as C exposing (Point, Position, Plane)
import Chart.Attributes as CA
import Internal.Svg as CS
import Internal.Item as I
import Internal.Helpers as Helpers exposing (Attribute(..))
import Internal.Many as M



on : String -> Decoder data msg -> Attribute { x | events : List (Event data msg) }
on name decoder =
  Attribute <| \config ->
    { config | events = Event { name = name, decoder = decoder } :: config.events }



{-| -}
type Event data msg =
  Event
    { name : String
    , decoder : Decoder data msg
    }


type Decoder data msg =
  Decoder (List (I.One data I.Any) -> Plane -> Point -> msg)


{-| -}
getCustom : (List (I.One data I.Any) -> Plane -> Point -> msg) -> Decoder data msg
getCustom func =
  Decoder func


{-| -}
getCoords : Decoder data Point
getCoords =
  Decoder <| \_ plane searched -> searched


{-| -}
getOffset : Decoder data Point
getOffset =
  Decoder <| \_ plane searched ->
    { x = searched.x - (plane.x.min + C.range plane.x / 2)
    , y = searched.y - (plane.y.min + C.range plane.y / 2)
    }


{-| -}
getSvgCoords : Decoder data Point
getSvgCoords =
  Decoder <| \_ plane searched ->
    CS.fromCartesian plane searched


{-| -}
getNearest : Float -> M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getNearest errorMargin (M.Remodel toPos _ as grouping) =
  Decoder <| \items plane searched ->
    let groups = M.apply grouping items in
    CS.getNearest errorMargin toPos groups plane (C.convertPoint C.neutralPlane plane searched)


{-| -}
getWithin : Float -> M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getWithin errorMargin (M.Remodel toPos _ as grouping) =
  Decoder <| \items plane searched ->
    let groups = M.apply grouping items in
    CS.getWithin errorMargin toPos groups plane (C.convertPoint C.neutralPlane plane searched)


{-| -}
getNearestX : Float -> M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getNearestX errorMargin (M.Remodel toPos _ as grouping) =
  Decoder <| \items plane searched ->
    let groups = M.apply grouping items in
    CS.getNearestX errorMargin toPos groups plane (C.convertPoint C.neutralPlane plane searched)


{-| -}
getWithinX : Float -> M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getWithinX errorMargin (M.Remodel toPos _ as grouping) =
  Decoder <| \items plane searched ->
    let groups = M.apply grouping items in
    CS.getWithinX errorMargin toPos groups plane (C.convertPoint C.neutralPlane plane searched)


{-| -}
map : (a -> msg) -> Decoder data a -> Decoder data msg
map f (Decoder a) =
  Decoder <| \ps s p -> f (a ps s p)


{-| -}
map2 : (a -> b -> msg) -> Decoder data a -> Decoder data b -> Decoder data msg
map2 f (Decoder a) (Decoder b) =
  Decoder <| \ps s p -> f (a ps s p) (b ps s p)


{-| -}
map3 : (a -> b -> c -> msg) -> Decoder data a -> Decoder data b -> Decoder data c -> Decoder data msg
map3 f (Decoder a) (Decoder b) (Decoder c) =
  Decoder <| \ps s p -> f (a ps s p) (b ps s p) (c ps s p)


{-| -}
map4 : (a -> b -> c -> d -> msg) -> Decoder data a -> Decoder data b -> Decoder data c -> Decoder data d -> Decoder data msg
map4 f (Decoder a) (Decoder b) (Decoder c) (Decoder d) =
  Decoder <| \ps s p -> f (a ps s p) (b ps s p) (c ps s p) (d ps s p)
