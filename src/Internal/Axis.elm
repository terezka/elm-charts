module Internal.Axis exposing (..)

import Internal.Types exposing (Point, Style, Orientation(..), Scale, Meta, Anchor(..))
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
    , position : PositionOption
    }


type PositionOption
    = Lowest
    | Highest
    | AtZero


type alias StyleConfig =
    { lineStyle : Style
    , baseStyle : Style
    , anchorTicks : Anchor
    , cleanCrossing : Bool
    , classes : List String
    }


defaultStyleConfig : StyleConfig
defaultStyleConfig =
    { lineStyle = []
    , baseStyle = []
    , anchorTicks = Outer
    , cleanCrossing = False
    , classes = []
    }


defaultConfigX : Config msg
defaultConfigX =
    { tickConfig = Tick.defaultConfig
    , labelConfig = Label.defaultConfig
    , viewConfig = defaultStyleConfig
    , orientation = X
    , position = Lowest
    }


defaultConfigY : Config msg
defaultConfigY =
    { defaultConfigX | orientation = Y }


view : Meta -> Config msg -> Svg.Svg msg
view ({ scale, toSvgCoords, oppositeScale } as meta) ({ viewConfig, tickConfig, labelConfig, orientation, position } as config) =
    let
        tickValues =
            Tick.getValuesIndexed tickConfig scale

        labelValues =
            Label.getValuesIndexed labelConfig.valueConfig tickValues

        axisPosition =
            getAxisPosition position oppositeScale
    in
        Svg.g
            [ Svg.Attributes.style (toStyle viewConfig.baseStyle)
            , Draw.classAttributeOriented "axis" orientation viewConfig.classes
            ]
            [ viewAxisLine viewConfig meta axisPosition
            , Svg.g
                [ Svg.Attributes.class "elm-plot__axis__ticks" ]
                (List.map (\value -> placeTick meta config axisPosition (Tick.toView tickConfig.viewConfig orientation) value) tickValues)
            , Svg.g
                [ Svg.Attributes.class "elm-plot__axis__labels"
                , Svg.Attributes.style <| toAnchorStyle viewConfig.anchorTicks orientation
                ]
                (List.map (\value -> placeLabel meta config axisPosition (Label.toView labelConfig.viewConfig orientation) value) labelValues)
            ]



-- View line


viewAxisLine : StyleConfig -> Meta -> Float -> Svg.Svg a
viewAxisLine { lineStyle } =
    Draw.fullLine
        [ Svg.Attributes.style (toStyle lineStyle)
        , Svg.Attributes.class "elm-plot__axis__line"
        ]



-- View labels


placeLabel : Meta -> Config msg -> Float -> (( Int, Float ) -> Svg.Svg msg) -> ( Int, Float ) -> Svg.Svg msg
placeLabel { toSvgCoords } ({ orientation, viewConfig } as config) axisPosition view ( index, tick ) =
    Svg.g
        [ Svg.Attributes.transform <| toTranslate <| addDisplacement (getDisplacement viewConfig.anchorTicks orientation) <| toSvgCoords ( tick, axisPosition )
        , Svg.Attributes.class "elm-plot__axis__label"
        ]
        [ view ( index, tick ) ]



-- View ticks


placeTick : Meta -> Config msg -> Float -> (( Int, Float ) -> Svg.Svg msg) -> ( Int, Float ) -> Svg.Svg msg
placeTick { toSvgCoords } ({ orientation, viewConfig } as config) axisPosition view ( index, tick ) =
    Svg.g
        [ Svg.Attributes.transform <| (toTranslate <| toSvgCoords ( tick, axisPosition )) ++ " " ++ (toRotate viewConfig.anchorTicks orientation)
        , Svg.Attributes.class "elm-plot__axis__tick"
        ]
        [ view ( index, tick ) ]



getAxisPosition : PositionOption -> Scale -> Float
getAxisPosition position { lowest, highest } =
    case position of
        AtZero ->
            clamp lowest highest 0

        Lowest ->
            lowest

        Highest ->
            highest


toAnchorStyle : Anchor -> Orientation -> String
toAnchorStyle anchor orientation =
    case orientation of
        X -> "text-anchor: middle;"
        Y -> "text-anchor:" ++ getYAnchorStyle anchor ++ ";"


getYAnchorStyle : Anchor -> String
getYAnchorStyle anchor =
    case anchor of
        Inner ->
            "start"
        Outer ->
            "end"


{-| The displacements are just magic numbers, so science. (Just defaults) -}
getDisplacement : Anchor -> Orientation -> Point
getDisplacement anchor orientation =
    case orientation of
        X -> 
            case anchor of
                Inner ->
                    ( 0, -15 )

                Outer ->
                    ( 0, 25 )

        Y ->
            case anchor of
                Inner ->
                    ( 10, 5 )

                Outer ->
                    ( -10, 5 )


addDisplacement : Point -> Point -> Point
addDisplacement (x, y) (dx, dy) =
    (x + dx, y + dy)



toRotate : Anchor -> Orientation -> String
toRotate anchor orientation =
    case orientation of
        X -> 
            case anchor of
                Inner -> "rotate(180 0 0)"
                Outer -> "rotate(0 0 0)"

        Y ->
            case anchor of
                Inner -> "rotate(-90 0 0)"
                Outer -> "rotate(90 0 0)"


filterValues : Bool -> List Float -> List Float
filterValues removeZero values =
    if removeZero then
        List.filter (\p -> p /= 0) values
    else
        values