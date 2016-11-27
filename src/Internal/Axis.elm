module Internal.Axis exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..), Scale, Meta, HintInfo)
import Internal.Tick as Tick
import Internal.Label as Label
import Internal.Grid as Grid
import Helpers exposing (..)
import Round
import Svg
import Svg.Attributes


type alias Config msg =
    { tickConfig : Tick.Config msg
    , labelConfig : Label.Config msg
    , viewConfig : StyleConfig
    , orientation : Orientation
    }


type alias StyleConfig =
    { lineStyle : Style
    , baseStyle : Style
    , classes : List String
    }


defaultStyleConfig : StyleConfig
defaultStyleConfig =
    { lineStyle = []
    , baseStyle = []
    , classes = []
    }


defaultConfigX : Config msg
defaultConfigX =
    { tickConfig = Tick.defaultConfig
    , labelConfig = Label.defaultConfig
    , viewConfig = defaultStyleConfig
    , orientation = X
    }


defaultConfigY : Config msg
defaultConfigY =
    { defaultConfigX | orientation = Y }


defaultView : Meta -> Config msg -> Svg.Svg msg
defaultView ({ scale, toSvgCoords } as meta) { viewConfig, tickConfig, labelConfig, orientation } =
    let
        tickValues =
            Tick.getValuesIndexed tickConfig scale

        labelValues =
            Label.getValuesIndexed labelConfig.valueConfig tickValues
    in
        Svg.g
            [ Svg.Attributes.style (toStyle viewConfig.baseStyle)
            , Svg.Attributes.class (String.join " " viewConfig.classes)
            ]
            [ Grid.viewLine meta viewConfig.lineStyle 0
            , viewTicks meta (Tick.toView tickConfig.viewConfig orientation) tickValues
            , viewTicks meta (Label.toView labelConfig.viewConfig orientation) labelValues
            ]


viewTicks : Meta -> (( Int, Float ) -> Svg.Svg msg) -> List ( Int, Float ) -> Svg.Svg msg
viewTicks meta view values =
    Svg.g [] (List.map (placeTick meta view) values)


placeTick : Meta -> (( Int, Float ) -> Svg.Svg msg) -> ( Int, Float ) -> Svg.Svg msg
placeTick { toSvgCoords } view ( index, tick ) =
    Svg.g
        [ Svg.Attributes.transform <| toTranslate <| toSvgCoords ( tick, 0 ) ]
        [ view ( index, tick ) ]
