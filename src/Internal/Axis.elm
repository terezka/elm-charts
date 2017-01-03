module Internal.Axis exposing (..)

import Internal.Types exposing (Point, Style, Orientation(..), Scale, Meta, Anchor(..), Value, IndexedInfo)
import Internal.Tick as Tick
import Internal.Label as Label
import Internal.Line as Line
import Internal.Draw as Draw exposing (..)
import Svg
import Svg.Attributes


type alias Config msg =
    { tickConfig : Tick.Config LabelInfo msg
    , labelConfig : Label.Config LabelInfo msg
    , lineConfig : Line.Config msg
    , orientation : Orientation
    , anchor : Anchor
    , cleanCrossings : Bool
    , position : PositionOption
    , classes : List String
    }


type PositionOption
    = Lowest
    | Highest
    | AtZero


type alias LabelInfo =
    { value : Float
    , index : Int
    }


defaultConfigX : Config msg
defaultConfigX =
    { tickConfig = Tick.defaultConfig
    , labelConfig = Label.toDefaultConfig (.value >> toString)
    , lineConfig = Line.defaultConfig
    , orientation = X
    , cleanCrossings = False
    , anchor = Outer
    , position = AtZero
    , classes = []
    }


defaultConfigY : Config msg
defaultConfigY =
    { defaultConfigX | orientation = Y }


view : Meta -> Config msg -> Svg.Svg msg
view ({ scale, toSvgCoords, oppositeAxisCrossings } as meta) ({ lineConfig, tickConfig, labelConfig, orientation, cleanCrossings, position, anchor, classes } as config) =
    let
        tickValues =
            toTickValues meta config

        labelValues =
            Label.getValues labelConfig tickValues

        axisPosition =
            getAxisPosition scale.y position
    in
        Svg.g
            [ Draw.classAttributeOriented "axis" orientation classes ]
            [ viewAxisLine lineConfig meta axisPosition
            , Svg.g
                [ Svg.Attributes.class "elm-plot__axis__ticks" ]
                (List.map (placeTick meta config axisPosition (Tick.toView tickConfig orientation)) tickValues)
            , Svg.g
                [ Svg.Attributes.class "elm-plot__axis__labels"
                , Svg.Attributes.style <| toAnchorStyle anchor orientation
                ]
                (List.map (placeLabel meta config axisPosition (Label.toView labelConfig orientation)) labelValues)
            ]



-- View line


viewAxisLine : Line.Config msg -> Meta -> Float -> Svg.Svg msg
viewAxisLine { style, customAttrs } =
    Draw.fullLine
        ([ Svg.Attributes.style (toStyle style)
         , Svg.Attributes.class "elm-plot__axis__line"
         ]
            ++ customAttrs
        )



-- View labels


placeLabel : Meta -> Config msg -> Float -> (LabelInfo -> Svg.Svg msg) -> LabelInfo -> Svg.Svg msg
placeLabel { toSvgCoords } ({ orientation, anchor } as config) axisPosition view info =
    Svg.g
        [ Svg.Attributes.transform <| toTranslate <| addDisplacement (getDisplacement anchor orientation) <| toSvgCoords ( info.value, axisPosition )
        , Svg.Attributes.class "elm-plot__axis__label"
        ]
        [ view info ]



-- View ticks


placeTick : Meta -> Config msg -> Float -> (LabelInfo -> Svg.Svg msg) -> LabelInfo -> Svg.Svg msg
placeTick { toSvgCoords } ({ orientation, anchor } as config) axisPosition view info =
    Svg.g
        [ Svg.Attributes.transform <| (toTranslate <| toSvgCoords ( info.value, axisPosition )) ++ " " ++ (toRotate anchor orientation)
        , Svg.Attributes.class "elm-plot__axis__tick"
        ]
        [ view info ]


getAxisPosition : Scale -> PositionOption -> Float
getAxisPosition { lowest, highest } position =
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
        X ->
            "text-anchor: middle;"

        Y ->
            "text-anchor:" ++ getYAnchorStyle anchor ++ ";"


getYAnchorStyle : Anchor -> String
getYAnchorStyle anchor =
    case anchor of
        Inner ->
            "start"

        Outer ->
            "end"


{-| The displacements are just magic numbers, so science. (Just defaults)
-}
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
addDisplacement ( x, y ) ( dx, dy ) =
    ( x + dx, y + dy )


toRotate : Anchor -> Orientation -> String
toRotate anchor orientation =
    case orientation of
        X ->
            case anchor of
                Inner ->
                    "rotate(180 0 0)"

                Outer ->
                    "rotate(0 0 0)"

        Y ->
            case anchor of
                Inner ->
                    "rotate(-90 0 0)"

                Outer ->
                    "rotate(90 0 0)"


filterValues : Meta -> Config msg -> List Float -> List Float
filterValues meta config values =
    if config.cleanCrossings then
        List.filter (isCrossing meta.oppositeAxisCrossings) values
    else
        values


isCrossing : List Float -> Float -> Bool
isCrossing crossings value =
    not <| List.member value crossings


toTickValues : Meta -> Config msg -> List LabelInfo
toTickValues meta config =
    Tick.getValues config.tickConfig meta.scale.x
        |> filterValues meta config
        |> Tick.toIndexInfo
