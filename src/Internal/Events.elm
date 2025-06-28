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


{-| This has two planes. The first is the plane as calculated from
configuration and data. The second is the plane with adjusted height
and width as gathered from JS event. See Internal.Svg.decoder.
-}
type Decoder data msg =
  Decoder (List (I.One data I.Any) -> Plane -> Plane -> Point -> msg)


{-| -}
getCustom : (List (I.One data I.Any) -> Plane -> Plane -> Point -> msg) -> Decoder data msg
getCustom func =
  Decoder func


{-| -}
getCoords : Decoder data Point
getCoords =
  Decoder <| \_ _ _ searched -> searched


{-| -}
getOffset : Decoder data Point
getOffset =
  Decoder <| \_ _ plane searched ->
    { x = searched.x - (plane.x.min + C.range plane.x / 2)
    , y = searched.y - (plane.y.min + C.range plane.y / 2)
    }


{-| -}
getSvgCoords : Decoder data Point
getSvgCoords =
  Decoder <| \_ _ plane searched ->
    CS.fromCartesian plane searched


{-| -}
getNearest : M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getNearest (M.Remodel toPos _ as grouping) =
  Decoder <| \items oldPlane plane searched ->
    let groups = M.apply grouping items in
    CS.getNearest toPos groups oldPlane plane searched


getNearestAndNearby : Float -> M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data ( List (I.Rendered result), List (I.Rendered result) )
getNearestAndNearby radius (M.Remodel toPos _ as grouping) =
  Decoder <| \items oldPlane plane searched ->
    let groups = M.apply grouping items in
    CS.getNearestAndNearby radius toPos groups oldPlane plane searched


{-| -}
getNearestWithin : Float -> M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getNearestWithin radius (M.Remodel toPos _ as grouping) =
  Decoder <| \items oldPlane plane searched ->
    let groups = M.apply grouping items in
    CS.getNearestWithin radius toPos groups oldPlane plane searched


{-| -}
getNearestX : M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getNearestX (M.Remodel toPos _ as grouping) =
  Decoder <| \items oldPlane plane searched ->
    let groups = M.apply grouping items in
    CS.getNearestX toPos groups oldPlane plane searched


{-| -}
getNearestWithinX : Float -> M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getNearestWithinX radius (M.Remodel toPos _ as grouping) =
  Decoder <| \items oldPlane plane searched ->
    let groups = M.apply grouping items in
    CS.getNearestWithinX radius toPos groups oldPlane plane searched


{-| -}
map : (a -> msg) -> Decoder data a -> Decoder data msg
map f (Decoder a) =
  Decoder <| \ps s p1 p2 -> f (a ps s p1 p2)


{-| -}
map2 : (a -> b -> msg) -> Decoder data a -> Decoder data b -> Decoder data msg
map2 f (Decoder a) (Decoder b) =
  Decoder <| \ps s p1 p2 -> f (a ps s p1 p2) (b ps s p1 p2)


{-| -}
map3 : (a -> b -> c -> msg) -> Decoder data a -> Decoder data b -> Decoder data c -> Decoder data msg
map3 f (Decoder a) (Decoder b) (Decoder c) =
  Decoder <| \ps s p1 p2 -> f (a ps s p1 p2) (b ps s p1 p2) (c ps s p1 p2)


{-| -}
map4 : (a -> b -> c -> d -> msg) -> Decoder data a -> Decoder data b -> Decoder data c -> Decoder data d -> Decoder data msg
map4 f (Decoder a) (Decoder b) (Decoder c) (Decoder d) =
  Decoder <| \ps s p1 p2 -> f (a ps s p1 p2) (b ps s p1 p2) (c ps s p1 p2) (d ps s p1 p2)
