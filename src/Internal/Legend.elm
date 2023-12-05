module Internal.Legend exposing (..)

import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Internal.Coordinates as Coord exposing (Point, Position, Plane)
import Dict exposing (Dict)
import Internal.Property as P exposing (Property)
import Internal.Svg as S
import Chart.Attributes as CA
import Internal.Helpers as Helpers
import Internal.Produce as Produce



type Legend
  = BarLegend String (List (CA.Attribute S.Bar))
  | LineLegend String (List (CA.Attribute S.Interpolation)) (List (CA.Attribute S.Dot))


toBarLegends : Int -> List (CA.Attribute (Produce.Bars data)) -> List (Property data () S.Bar) -> List Legend
toBarLegends elIndex barsAttrs properties =
  let barsConfig =
        Helpers.apply barsAttrs Produce.defaultBars

      toBarConfig attrs =
        Helpers.apply attrs S.defaultBar

      toBarLegend colorIndex prop =
        let defaultName = "Property #" ++ String.fromInt (colorIndex + 1)
            defaultColor = Helpers.toDefaultColor colorIndex
            rounding = max barsConfig.roundTop barsConfig.roundBottom
            defaultAttrs = [ CA.roundTop rounding, CA.roundBottom rounding, CA.color defaultColor, CA.border defaultColor ]
            attrsOrg = defaultAttrs ++ prop.presentation
            productOrg = toBarConfig attrsOrg
            attrs = if productOrg.border == defaultColor then attrsOrg ++ [ CA.border productOrg.color ] else attrsOrg
        in
        BarLegend (Maybe.withDefault defaultName prop.tooltipName) attrs
  in
  List.concatMap P.toConfigs properties
    |> List.indexedMap (\propIndex -> toBarLegend (elIndex + propIndex))


toDotLegends : Int ->  List (Property data S.Interpolation S.Dot) -> List Legend
toDotLegends elIndex properties =
  let toInterConfig attrs =
        Helpers.apply attrs S.defaultInterpolation

      toDotLegend props prop colorIndex =
        let defaultOpacity = if List.length props > 1 then 0.4 else 0
            interAttr = [ CA.color (Helpers.toDefaultColor colorIndex), CA.opacity defaultOpacity ] ++ prop.interpolation
            interConfig = toInterConfig interAttr
            defaultAttrs = [ CA.color interConfig.color, CA.border interConfig.color, if interConfig.method == Nothing then CA.circle else Helpers.noChange ]
            dotAttrs = defaultAttrs ++ prop.presentation
            defaultName = "Property #" ++ String.fromInt (colorIndex + 1)
        in
        LineLegend (Maybe.withDefault defaultName prop.tooltipName) interAttr dotAttrs
  in
  List.map P.toConfigs properties
    |> List.concatMap (\ps -> List.map (toDotLegend ps) ps)
    |> List.indexedMap (\propIndex f -> f (elIndex + propIndex))

