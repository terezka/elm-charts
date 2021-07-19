module Internal.Item exposing (..)

import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Internal.Coordinates as Coord exposing (Point, Position, Plane)
import Dict exposing (Dict)
import Internal.Property as P exposing (Property)
import Internal.Svg as S
import Internal.Helpers as Helpers


type Rendered a =
  Rendered
    { config : a
    , toLimits : a -> Position
    , toPosition : Plane -> a -> Position
    , toSvg : Plane -> a -> Position -> Svg Never
    , toHtml : a -> List (Html Never)
    }


{-| -}
type alias One data x =
  Rendered
    { product : x
    , tooltipInfo : TooltipInfo
    , values : Values data
    , toAny : x -> Any
    }


{-| -}
type Any
  = Dot S.Dot
  | Bar S.Bar
  | Custom


{-| -}
type alias TooltipInfo =
  { property : Int
  , stack : Int
  , data : Int
  , index : Int
  , elIndex : Int
  , name : Maybe String
  , color : String
  , border : String
  , borderWidth : Float
  , formatted : String
  }


{-| -}
type alias Values data =
  { datum : data
  , x1 : Float
  , x2 : Float
  , y : Float
  , isReal : Bool
  }



-- ITEM


{-| -}
toSvg : Plane -> Rendered x -> Svg Never
toSvg plane (Rendered item) =
  item.toSvg plane item.config (item.toPosition plane item.config)


{-| -}
toHtml : Rendered x -> List (Html Never)
toHtml (Rendered item) =
  item.toHtml item.config


{-| -}
getPosition : Plane -> Rendered x -> Position
getPosition plane (Rendered item) =
  item.toPosition plane item.config


{-| -}
getLimits : Rendered x -> Position
getLimits (Rendered item) =
  item.toLimits item.config



-- PRODUCT


{-| -}
getColor : One data x -> String
getColor (Rendered item) =
  item.config.tooltipInfo.color


{-| -}
getName : One data x -> String
getName (Rendered item) =
  case item.config.tooltipInfo.name of
    Just name -> name
    Nothing -> "Property #" ++ String.fromInt (item.config.tooltipInfo.index + 1)


{-| -}
getDatum : One data x -> data
getDatum (Rendered item) =
  item.config.values.datum


{-| -}
getX : One data x -> Float
getX (Rendered item) =
  item.config.values.x1


{-| -}
getX1 : One data x -> Float
getX1 (Rendered item) =
  item.config.values.x1


{-| -}
getX2 : One data x -> Float
getX2 (Rendered item) =
  item.config.values.x2


{-| -}
getY : One data x -> Float
getY (Rendered item) =
  item.config.values.y


{-| -}
isReal : One data x -> Bool
isReal (Rendered item) =
  item.config.values.isReal


{-| -}
getElIndex : One data x -> Int
getElIndex (Rendered item) =
  item.config.tooltipInfo.elIndex


{-| -}
getPropertyIndex : One data x -> Int
getPropertyIndex (Rendered item) =
  item.config.tooltipInfo.property


{-| -}
getStackIndex : One data x -> Int
getStackIndex (Rendered item) =
  item.config.tooltipInfo.stack


{-| -}
getDataIndex : One data x -> Int
getDataIndex (Rendered item) =
  item.config.tooltipInfo.data


{-| -}
getTooltipValue : One data x -> String
getTooltipValue (Rendered item) =
  item.config.tooltipInfo.formatted


{-| -}
getGeneral : One data x -> One data Any
getGeneral (Rendered item) =
  generalize item.config.toAny (Rendered item)


{-| -}
getSize : One data S.Dot -> Float
getSize (Rendered item) =
  item.config.product.size


{-| -}
isSame : One data x -> One data x -> Bool
isSame a b =
  getPropertyIndex a == getPropertyIndex b &&
  getStackIndex a == getStackIndex b &&
  getDataIndex a == getDataIndex b &&
  getElIndex a == getElIndex b


{-| -}
map : (a -> b) -> One a x -> One b x
map func (Rendered item) =
  Rendered
    { toLimits = \_ -> item.toLimits item.config
    , toPosition = \plane _ -> item.toPosition plane item.config
    , toSvg = \plane _ _ -> toSvg plane (Rendered item)
    , toHtml = \_ -> toHtml (Rendered item)
    , config =
        { product = item.config.product
        , values =
            { datum = func item.config.values.datum
            , x1 = item.config.values.x1
            , x2 = item.config.values.x2
            , y = item.config.values.y
            , isReal = item.config.values.isReal
            }
        , tooltipInfo = item.config.tooltipInfo
        , toAny = item.config.toAny
        }
    }


{-| -}
filterMap : (a -> Maybe b) -> List (One a x) -> List (One b x)
filterMap func =
  List.filterMap <| \(Rendered item) ->
    case func item.config.values.datum of
      Just b ->
        Rendered
          { toLimits = \_ -> item.toLimits item.config
          , toPosition = \plane _ -> item.toPosition plane item.config
          , toSvg = \plane _ _ -> toSvg plane (Rendered item)
          , toHtml = \_ -> toHtml (Rendered item)
          , config =
              { product = item.config.product
              , values =
                  { datum = b
                  , x1 = item.config.values.x1
                  , x2 = item.config.values.x2
                  , y = item.config.values.y
                  , isReal = item.config.values.isReal
                  }
              , tooltipInfo = item.config.tooltipInfo
              , toAny = item.config.toAny
              }
          }
          |> Just

      Nothing ->
        Nothing



-- GENERALIZATION


generalize : (x -> Any) -> One data x -> One data Any
generalize toAny (Rendered item) =
   -- TODO make sure changes are reflected in rendering
  Rendered
    { toLimits = \_ -> item.toLimits item.config
    , toPosition = \plane _ -> item.toPosition plane item.config
    , toSvg = \plane _ _ -> toSvg plane (Rendered item)
    , toHtml = \c -> toHtml (Rendered item)
    , config =
        { product = toAny item.config.product
        , values = item.config.values
        , tooltipInfo = item.config.tooltipInfo
        , toAny = identity
        }
    }


isBar : One data Any -> Maybe (One data S.Bar)
isBar (Rendered item) =
  case item.config.product of
    Bar bar ->
      Rendered
        { toLimits = \_ -> item.toLimits item.config
        , toPosition = \plane _ -> item.toPosition plane item.config
        , toSvg = \plane config -> S.bar plane config.product
        , toHtml = \c -> item.toHtml item.config
        , config =
            { product = bar
            , values = item.config.values
            , tooltipInfo = item.config.tooltipInfo
            , toAny = Bar
            }
        }
        |> Just

    _ ->
      Nothing


isDot : One data Any -> Maybe (One data S.Dot)
isDot (Rendered item) =
  case item.config.product of
    Dot dot ->
      Rendered
        { toLimits = \_ -> item.toLimits item.config
        , toPosition = \plane _ -> item.toPosition plane item.config
        , toSvg = \plane config pos ->
            if config.values.isReal
            then S.dot plane .x .y config.product { x = config.values.x1, y = config.values.y }
            else S.text ""
        , toHtml = \c -> item.toHtml item.config
        , config =
            { product = dot
            , values = item.config.values
            , tooltipInfo = item.config.tooltipInfo
            , toAny = Dot
            }
        }
        |> Just

    _ ->
      Nothing
