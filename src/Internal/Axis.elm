module Internal.Axis exposing (..)

import Internal.Types exposing (Point, Style, Orientation(..), Scale, Meta)
import Internal.Tick as Tick
import Internal.Label as Label
import Internal.Draw as Draw exposing (..)
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


view : Meta -> Config msg -> Svg.Svg msg
view ({ scale, toSvgCoords } as meta) { viewConfig, tickConfig, labelConfig, orientation } =
    let
        tickValues =
            Tick.getValuesIndexed tickConfig scale

        labelValues =
            Label.getValuesIndexed labelConfig.valueConfig tickValues
    in
        Svg.g
            [ Svg.Attributes.style (toStyle viewConfig.baseStyle)
            , Draw.classAttributeOriented "axis" orientation viewConfig.classes
            ]
            [ viewAxisLine viewConfig meta 0
            , viewTicks "tick" meta (Tick.toView tickConfig.viewConfig orientation) tickValues
            , viewTicks "label" meta (Label.toView labelConfig.viewConfig orientation) labelValues
            ]


viewAxisLine : StyleConfig -> Meta -> Float -> Svg.Svg a
viewAxisLine { lineStyle } =
    Draw.fullLine
        [ Svg.Attributes.style (toStyle lineStyle)
        , Svg.Attributes.class "elm-plot__axis__line"
        ]


viewTicks : String -> Meta -> (( Int, Float ) -> Svg.Svg msg) -> List ( Int, Float ) -> Svg.Svg msg
viewTicks class meta view values =
    Svg.g
        [ Svg.Attributes.class <| "elm-plot__axis__" ++ class ++ "s" ]
        (List.map (placeTick class meta view) values)


placeTick : String -> Meta -> (( Int, Float ) -> Svg.Svg msg) -> ( Int, Float ) -> Svg.Svg msg
placeTick class { toSvgCoords } view ( index, tick ) =
    Svg.g
        [ Svg.Attributes.transform <| toTranslate <| toSvgCoords ( tick, 0 )
        , Svg.Attributes.class <| "elm-plot__axis__" ++ class
        ]
        [ view ( index, tick ) ]
