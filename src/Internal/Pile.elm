module Internal.Pile
    exposing
        ( Config
        , Element(..)
        , defaultConfig
        , view
        , pileMetaInit
        , toPileEdges
        , toPileMeta
        , toPilePoints
        , toPoints
        )

import Svg
import Svg.Attributes
import Internal.Types exposing (Style, Orientation(..), MaxWidth(..), Meta, Point, PileMeta, Edges, Oriented)
import Internal.Draw exposing (..)
import Internal.Stuff exposing (..)
import Internal.Bars as BarsInternal


type alias Config =
    { stackBy : Orientation
    , maxWidth : MaxWidth
    }


type Element msg
    = Bars (BarsInternal.Config msg) (List Point)


defaultConfig : Config
defaultConfig =
    { stackBy = X
    , maxWidth = Percentage 100
    }


view : Meta -> PileMeta -> Config -> List (Element msg) -> Svg.Svg msg
view meta pileMeta ({ maxWidth } as config) bars =
    Svg.g [] (List.indexedMap (viewBars meta pileMeta maxWidth) bars)


viewBars : Meta -> PileMeta -> MaxWidth -> Int -> Element msg -> Svg.Svg msg
viewBars meta pileMeta maxWidth index (Bars config points) =
    BarsInternal.view meta pileMeta maxWidth index config points



-- Calculations


pileMetaInit : PileMeta
pileMetaInit =
    { lowest = 0
    , highest = 0
    , numOfBarSeries = 0
    , pointCount = 0
    , stackBy = X
    }


toPileMeta : Config -> List (Element msg) -> PileMeta
toPileMeta { stackBy } elements =
    List.foldl (foldPileMeta stackBy) pileMetaInit elements
        |> addPadding


foldPileMeta : Orientation -> Element msg -> PileMeta -> PileMeta
foldPileMeta stackBy element pileMeta =
    case element of
        Bars _ points ->
            getValues stackBy points
                |> getEdges
                |> formPileMeta stackBy points pileMeta


formPileMeta : Orientation -> List Point -> PileMeta -> ( Float, Float ) -> PileMeta
formPileMeta stackBy points ({ lowest, highest, numOfBarSeries, pointCount } as pileMeta) ( serieLowest, serieHighest ) =
    { pileMeta
        | lowest = min lowest serieLowest
        , highest = max highest serieHighest
        , numOfBarSeries = numOfBarSeries + 1
        , pointCount = max pointCount (List.length points)
        , stackBy = stackBy
    }


toPileEdges : List PileMeta -> Oriented (Maybe Edges)
toPileEdges =
    List.foldl foldPileEdges { x = Nothing, y = Nothing }


foldPileEdges : PileMeta -> Oriented (Maybe Edges) -> Oriented (Maybe Edges)
foldPileEdges ({ stackBy } as pileMeta) axisEdges =
    foldOriented (mergeEdges pileMeta) stackBy axisEdges


mergeEdges : PileMeta -> Maybe Edges -> Maybe Edges
mergeEdges { lowest, highest } edges =
    case edges of
        Just { lower, upper } ->
            Just { lower = min lowest lower, upper = max highest upper }

        Nothing ->
            Just { lower = lowest, upper = highest }


calcPilePadding : PileMeta -> Float
calcPilePadding { lowest, highest, pointCount } =
    (highest - lowest) / (toFloat <| (pointCount - 1) * 2)


addPadding : PileMeta -> PileMeta
addPadding ({ lowest, highest } as pileMeta) =
    let
        padding =
            calcPilePadding pileMeta
    in
        { pileMeta
            | lowest = lowest - padding
            , highest = highest + padding
        }


toPilePoints : List (Element msg) -> List Point
toPilePoints =
    List.foldr foldPoints []


foldPoints : Element msg -> List Point -> List Point
foldPoints (Bars _ points) allPoints =
    allPoints ++ points


toPoints : Element msg -> List Point
toPoints (Bars _ points) =
    points
