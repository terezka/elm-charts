module Internal.Item exposing 
  ( Rendered(..), One, Any(..)
  , render, tooltip, getPosition, getPositionIn, getLimits, getLimitsIn
  , getColor, getName, getDatum, getX1, getX2, getY, isReal
  , generalize, map, isDot, isBar, getX, getTooltipValue, getSize, isSame, filterMap
  , getIdentification
  , getLocalPlane, covert, getTopLevelLimits, getTopLevelPosition, getTopLevelPlane
  )


{-| An item is anything rendered on the chart which should be able to be found again later. 
You can think of is as a kind of virtual dom for the chart. You cannot search the chart for things
once they are rendered, so we need to store a map of all the things to be able to find them.
-}


import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Internal.Coordinates as Coord exposing (Point, Limits, Position, Plane)
import Dict exposing (Dict)
import Internal.Property as P exposing (Property)
import Internal.Svg as S
import Internal.Helpers as Helpers
import Internal.Property exposing (Identification)


type Rendered meta =
  Rendered meta
    { limits : Limits         -- Local scale limits
    , position : Position     -- Local scale position
    , localPlane : Plane      -- Local scale plane
    , limitsTop : Limits      -- Top level scale limits
    , positionTop : Position  -- Top level scale position
    , planeTop : Plane        -- Top level scale plane
    , render : () -> Svg Never
    , tooltip : () -> List (Html Never)
    }


{-| -}
type alias One data x =
  Rendered
    { presentation : x
    , color : String
    , datum : data
    , x1 : Float
    , x2 : Float
    , y : Float
    , isReal : Bool
    , tooltipText : String
    , name : Maybe String
    , identification : Identification
    , toAny : x -> Any
    }


{-| -}
type Any
  = Dot S.Dot
  | Bar S.Bar
  | Custom



-- ITEM


{-| -}
render : Rendered x -> Svg Never
render (Rendered _ item) =
  item.render ()


{-| -}
tooltip : Rendered x -> List (Html Never)
tooltip (Rendered _ item) =
  item.tooltip ()


{-| -}
getPosition : Rendered x -> Position
getPosition (Rendered _ item) =
  item.position


{-| -}
getTopLevelPosition : Rendered x -> Position
getTopLevelPosition (Rendered _ item) =
  item.positionTop


{-| -}
getTopLevelLimits : Rendered x -> Limits
getTopLevelLimits (Rendered _ item) =
  item.limitsTop


{-| -}
getTopLevelPlane : Rendered x -> Plane
getTopLevelPlane (Rendered _ item) =
  item.planeTop


{-| -}
getPositionIn : Plane -> Rendered x -> Position
getPositionIn plane (Rendered _ item) =
  Coord.convertPos plane item.localPlane item.position


{-| -}
getLimits : Rendered x -> Limits
getLimits (Rendered _ item) =
  item.limits


{-| -}
getLimitsIn : Plane -> Rendered x -> Position
getLimitsIn plane (Rendered _ item) =
  Coord.convertPos plane item.localPlane item.limits


{-| -}
getLocalPlane : Rendered x -> Plane
getLocalPlane (Rendered _ item) =
  item.localPlane


{-| -}
covert : Plane -> Rendered x -> Rendered x
covert plane (Rendered meta item) =
  Rendered meta
    { limits = Coord.convertPos plane item.localPlane item.limits
    , position = Coord.convertPos plane item.localPlane item.position
    , localPlane = plane
    , limitsTop = item.limitsTop
    , positionTop = item.positionTop
    , planeTop = item.planeTop
    , render = item.render
    , tooltip = item.tooltip
    }



-- PRODUCT


{-| -}
getColor : One data x -> String
getColor (Rendered meta _) =
  meta.color


{-| -}
getName : One data x -> String
getName (Rendered meta _) =
  case meta.name of
    Just name -> name
    Nothing -> "Property #" ++ String.fromInt (meta.identification.absoluteIndex + 1)


{-| -}
getDatum : One data x -> data
getDatum (Rendered meta _) =
  meta.datum


{-| -}
getX : One data x -> Float
getX (Rendered meta _) =
  meta.x1


{-| -}
getX1 : One data x -> Float
getX1 (Rendered meta _) =
  meta.x1


{-| -}
getX2 : One data x -> Float
getX2 (Rendered meta _) =
  meta.x2


{-| -}
getY : One data x -> Float
getY (Rendered meta _) =
  meta.y


{-| -}
isReal : One data x -> Bool
isReal (Rendered meta _) =
  meta.isReal


{-| -}
getIdentification : One data x -> Identification
getIdentification (Rendered meta _) =
  meta.identification


{-| -}
getTooltipValue : One data x -> String
getTooltipValue (Rendered meta _) =
  meta.tooltipText


{-| -}
getSize : One data S.Dot -> Float
getSize (Rendered meta _) =
  meta.presentation.size


{-| -}
isSame : One data x -> One data x -> Bool
isSame a b =
  getIdentification a == getIdentification b


{-| -}
map : (a -> b) -> One a x -> One b x
map func (Rendered meta item) =
  Rendered 
    { presentation = meta.presentation
    , color = meta.color
    , datum = func meta.datum
    , x1 = meta.x1
    , x2 = meta.x2
    , y = meta.y
    , isReal = meta.isReal
    , tooltipText = meta.tooltipText
    , name = meta.name
    , identification = meta.identification
    , toAny = meta.toAny
    }
    item


{-| -}
filterMap : (a -> Maybe b) -> List (One a x) -> List (One b x)
filterMap func =
  List.filterMap <| \(Rendered meta item) ->
    case func meta.datum of
      Just b ->
        Rendered
          { presentation = meta.presentation
          , color = meta.color
          , datum = b
          , x1 = meta.x1
          , x2 = meta.x2
          , y = meta.y
          , isReal = meta.isReal
          , tooltipText = meta.tooltipText
          , name = meta.name
          , identification = meta.identification
          , toAny = meta.toAny
          }
          item
          |> Just

      Nothing ->
        Nothing



-- GENERALIZATION


generalize : One data x -> One data Any
generalize (Rendered meta item) =
  Rendered
    { presentation = meta.toAny meta.presentation
    , color = meta.color
    , datum = meta.datum
    , x1 = meta.x1
    , x2 = meta.x2
    , y = meta.y
    , isReal = meta.isReal
    , tooltipText = meta.tooltipText
    , name = meta.name
    , identification = meta.identification
    , toAny = identity
    }
    item


isBar : One data Any -> Maybe (One data S.Bar)
isBar (Rendered meta item) =
  case meta.presentation of
    Bar bar ->
      Rendered
        { presentation = bar
        , color = meta.color
        , datum = meta.datum
        , x1 = meta.x1
        , x2 = meta.x2
        , y = meta.y
        , isReal = meta.isReal
        , tooltipText = meta.tooltipText
        , name = meta.name
        , identification = meta.identification
        , toAny = Bar
        }
        item
        |> Just

    _ ->
      Nothing


isDot : One data Any -> Maybe (One data S.Dot)
isDot (Rendered meta item) =
  case meta.presentation of
    Dot dot ->
      Rendered
        { presentation = dot
        , color = meta.color
        , datum = meta.datum
        , x1 = meta.x1
        , x2 = meta.x2
        , y = meta.y
        , isReal = meta.isReal
        , tooltipText = meta.tooltipText
        , name = meta.name
        , identification = meta.identification
        , toAny = Dot
        }
        item
        |> Just

    _ ->
      Nothing
