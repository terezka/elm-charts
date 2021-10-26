module Internal.Events exposing (..)


import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Internal.Coordinates as C exposing (Point, Position, Plane)
import Chart.Attributes as CA exposing (Attribute)
import Internal.Svg as CS
import Internal.Item as I
import Internal.Helpers as Helpers
import Internal.Many as M



on : String -> Decoder data msg -> Attribute { x | events : List (Event data msg) }
on name decoder config =
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
getNearest : M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getNearest (M.Remodel toPos _ as grouping) =
  Decoder <| \items plane ->
    let groups = M.apply grouping items in
    CS.getNearest (toPos plane) groups plane


{-| -}
getWithin : Float -> M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getWithin radius (M.Remodel toPos _ as grouping) =
  Decoder <| \items plane ->
    let groups = M.apply grouping items in
    CS.getWithin radius (toPos plane) groups plane


{-| -}
getNearestX : M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getNearestX (M.Remodel toPos _ as grouping) =
  Decoder <| \items plane ->
    let groups = M.apply grouping items in
    CS.getNearestX (toPos plane) groups plane


{-| -}
getWithinX : Float -> M.Remodel (I.One data I.Any) (I.Rendered result) -> Decoder data (List (I.Rendered result))
getWithinX radius (M.Remodel toPos _ as grouping) =
  Decoder <| \items plane ->
    let groups = M.apply grouping items in
    CS.getWithinX radius (toPos plane) groups plane


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
