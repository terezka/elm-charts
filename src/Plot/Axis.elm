module Plot.Axis exposing (..)

{-|
 Attributes for altering the view of your axis.

# Styling
@docs style, classes, lineStyle

# Ticks and labels
@docs tick, label

# Definitions
@docs Attribute

-}

import Plot.Types exposing (Style, Orientation(..))
import Internal.Axis as Internal
import Internal.Label as LabelInternal
import Internal.Tick as TickInternal
import Plot.Tick as Tick
import Plot.Label as Label


{-| The type representing an axis attribute.
-}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| -}
type alias StyleAttribute =
    Internal.StyleConfig -> Internal.StyleConfig


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
    { config | viewConfig = List.foldl (<|) Internal.defaultStyleConfig attributes }


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
    { config | tickConfig = List.foldl (<|) TickInternal.defaultConfig attributes }


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
    { config | labelConfig = List.foldl (<|) LabelInternal.defaultConfig attributes }
