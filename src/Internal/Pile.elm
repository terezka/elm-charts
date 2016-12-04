module Internal.Pile exposing (Config, Element(..), defaultConfig, view)

import Svg
import Svg.Attributes
import Internal.Types exposing (Style, Orientation(..), Meta, Point)
import Internal.Draw exposing (..)
import Internal.Stuff exposing (..)
import Internal.Bars as BarsInternal


type alias Config =
    { stackBy : Orientation }


type Element msg
    = Bars (BarsInternal.Config msg) (List Point)


defaultConfig : Config
defaultConfig =
    { stackBy = X }


view : Meta -> Config -> List (Element msg) -> Svg.Svg msg
view ({ toSvgCoords, scale, barsMeta } as meta) ({ stackBy } as config) bars =
    Svg.g [] (List.indexedMap (viewBars meta) bars)
        

viewBars : Meta -> Int -> Element msg -> Svg.Svg msg
viewBars meta index (Bars config points) =
    BarsInternal.view meta index config points