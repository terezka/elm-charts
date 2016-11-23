module Plot.Axis exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..), AxisScale, PlotProps, TooltipInfo)
import Plot.Tick as Tick
import Plot.Label as Label
import Plot.Grid as Grid
import Helpers exposing (..)
import Round
import Svg
import Svg.Attributes


type alias Config msg =
    { tickConfig : Tick.Config msg
    , labelConfig : Label.Config msg
    , axisLineStyle : Style
    , axisCrossing : Bool
    , style : Style
    , classes : List String
    , orientation : Orientation
    }


{-| The type representing an axis configuration.
-}
type alias Attribute msg =
    Config msg -> Config msg


defaultConfigX : Config msg
defaultConfigX =
    { tickConfig = Tick.defaultConfig
    , labelConfig = Label.defaultConfig
    , style = []
    , classes = []
    , axisLineStyle = []
    , axisCrossing = False
    , orientation = X
    }


defaultConfigY : Config msg
defaultConfigY =
    { defaultConfigX | orientation = Y }


{-| Add style to the container holding your axis. Most properties are
 conveniently inherited by your ticks and labels.

    main =
        plot
            []
            [ xAxis [ axisStyle [ ( "stroke", "red" ) ] ] ]

 Default: `[]`
-}
style : Style -> Attribute msg
style style config =
    { config | style = style }


{-| Add classes to the container holding your axis.

    main =
        plot
            []
            [ xAxis [ axisClasses [ "my-class" ] ] ]

 Default: `[]`
-}
classes : List String -> Attribute msg
classes classes config =
    { config | classes = classes }


{-| Add styling to the axis line.

    main =
        plot
            []
            [ xAxis [ axisLineStyle [ ( "stroke", "blue" ) ] ] ]

 Default: `[]`
-}
lineStyle : Style -> Attribute msg
lineStyle style config =
    { config | axisLineStyle = style }



tick : List (Tick.Attribute msg) -> Config msg -> Config msg
tick attributes config =
    { config | tickConfig = List.foldl (<|) Tick.defaultConfig attributes }


label : List (Label.Attribute msg) -> Config msg -> Config msg
label attributes config =
    { config | labelConfig = List.foldl (<|) Label.defaultConfig attributes }




-- View



view : PlotProps -> Config msg -> Svg.Svg msg
view plotProps { tickConfig, labelConfig, style, classes, axisLineStyle, axisCrossing, orientation } =
    let
        { scale, oppositeScale, toSvgCoords, oppositeToSvgCoords } =
            plotProps

        tickValues =
            Tick.getValues tickConfig scale

        labelValues =
            Label.getValues labelConfig.valueConfig tickValues
    in
        Svg.g
            [ Svg.Attributes.style (toStyle style)
            , Svg.Attributes.class (String.join " " classes)
            ]
            [ Grid.viewLine plotProps axisLineStyle 0
            , Svg.g [] (List.map (placeTick plotProps (Tick.toView tickConfig.viewConfig orientation)) tickValues)
            , Svg.g [] (List.map (placeTick plotProps (Label.toView labelConfig.viewConfig orientation)) labelValues)
            ]


placeTick : PlotProps -> (Int -> Float -> Svg.Svg msg) -> ( Int, Float ) -> Svg.Svg msg
placeTick { toSvgCoords } view ( index, tick ) =
    Svg.g [ Svg.Attributes.transform (toTranslate (toSvgCoords ( tick, 0 ))) ] [ view index tick ]






