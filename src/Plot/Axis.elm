module Plot.Axis exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..), AxisScale, PlotProps, TooltipInfo)
import Plot.Tick as Tick
import Plot.Label as Label
import Plot.Grid as Grid
import Helpers exposing (..)
import Round
import Svg
import Svg.Attributes


{-|
 Attributes for altering the view of your axis.

# Styling
@docs style, classes, lineStyle

# Ticks and labels
@docs tick, label

# Definitions
@docs Attribute

-}
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



{-| The type representing an axis attribute.
-}
type alias Attribute msg =
    Config msg -> Config msg


{-| -}
type alias StyleAttribute =
    StyleConfig -> StyleConfig


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


{-| Add classes to the container holding your axis.

    main =
        plot
            []
            [ xAxis [ Axis.classes [ "axis-class" ] ] ]
-}
classes : List String -> StyleAttribute
classes classes config =
    { config | classes = classes }


{-| Add style to the container holding your axis. Most properties are
 conveniently inherited by your ticks and labels.

    main =
        plot
            []
            [ xAxis [ Axis.style [ ( "stroke", "red" ) ] ] ]
-}
style : Style -> StyleAttribute
style style config =
    { config | baseStyle = style }


{-| Add styling to the axis line.

    main =
        plot
            []
            [ xAxis [ Axis.lineStyle [ ( "stroke", "blue" ) ] ] ]
-}
lineStyle : Style -> StyleAttribute
lineStyle style config =
    { config | lineStyle = style }



{-| -}
view : List StyleAttribute -> Attribute msg
view attributes config =
    { config | viewConfig = List.foldl (<|) defaultStyleConfig attributes }


{-| Provided a list of tick attributes to alter what values with be added a tick and how it will be displayed.

    main =
        plot
            []
            [ xAxis [
                Axis.tick
                    [ Tick.view
                        [ Tick.length 3 
                        , Tick.values [ 2, 4, 6 ]
                        ]
                    ]
                ]
            ]
-}
tick : List (Tick.Attribute msg) -> Attribute msg
tick attributes config =
    { config | tickConfig = List.foldl (<|) Tick.defaultConfig attributes }


{-| Provided a list of label attributes to alter what values with be added a label and how it will be displayed.

    main =
        plot
            []
            [ xAxis [
                Axis.label
                    [ Label.view
                        [ Label.displace (10, 0) 
                        , Label.values [ 3, 5, 7 ]
                        , Label.format (\index value -> "$" ++ toString value)
                        ]
                    ]
                ]
            ]
-}
label : List (Label.Attribute msg) -> Attribute msg
label attributes config =
    { config | labelConfig = List.foldl (<|) Label.defaultConfig attributes }



-- VIEW


defaultView : PlotProps -> Config msg -> Svg.Svg msg
defaultView ({ scale, toSvgCoords } as plotProps) { viewConfig, tickConfig, labelConfig, orientation } =
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
            [ Grid.viewLine plotProps viewConfig.lineStyle 0
            , viewTicks plotProps (Tick.toView tickConfig.viewConfig orientation) tickValues
            , viewTicks plotProps (Label.toView labelConfig.viewConfig orientation) labelValues
            ]


viewTicks : PlotProps -> (Int -> Float -> Svg.Svg msg) -> List ( Int, Float ) -> Svg.Svg msg
viewTicks plotProps view values =
    Svg.g [] (List.map (placeTick plotProps view) values)


placeTick : PlotProps -> (Int -> Float -> Svg.Svg msg) -> ( Int, Float ) -> Svg.Svg msg
placeTick { toSvgCoords } view ( index, tick ) =
    Svg.g
        [ Svg.Attributes.transform <| toTranslate <| toSvgCoords ( tick, 0 ) ]
        [ view index tick ]


