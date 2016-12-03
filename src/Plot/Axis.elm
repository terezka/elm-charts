module Plot.Axis exposing (..)

{-|
 Attributes for altering the view of your axis.

# Definition
@docs Attribute

# Styling
@docs view

## Style attributes
@docs StyleAttribute, style, classes, lineStyle, positionLowest, positionHighest, cleanCrossings, anchorInside

# Ticks and labels
@docs tick, label

-}

import Internal.Types exposing (Style, Orientation(..), Anchor(..))
import Internal.Axis as Internal
import Internal.Label as LabelInternal
import Internal.Tick as TickInternal
import Plot.Tick as Tick
import Plot.Label as Label


{-| -}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| -}
type alias StyleAttribute =
    Internal.StyleConfig -> Internal.StyleConfig


{-| By providing a list of style attributes to this attribute,
 you may alter the styling of your axis.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view
                [ Axis.style [ ( "stroke", "red" ) ]
                , Axis.classes [ "axis--x" ]
                , Axis.lineStyle [ ( "stroke", "blue" ) ]
                ]
            ]
-}
view : List StyleAttribute -> Attribute msg
view attributes config =
    { config | viewConfig = List.foldl (<|) Internal.defaultStyleConfig attributes }


{-| Adds classes to the container holding your axis.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view
                [ Axis.classes [ "axis--x" ] ]
            ]
-}
classes : List String -> StyleAttribute
classes classes config =
    { config | classes = classes }


{-| Adds style to the container holding your axis.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view
                [ Axis.style [ ( "stroke", "red" ) ] ]
            ]
-}
style : Style -> StyleAttribute
style style config =
    { config | baseStyle = style }


{-| Adds styles to the axis line.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view
                [ Axis.lineStyle [ ( "stroke", "blue" ) ] ]
            ]
-}
lineStyle : Style -> StyleAttribute
lineStyle style config =
    { config | lineStyle = style }


{-| Anchor the ticks/labels on the inside of the plot. By default they are anchored on the outside.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view
                [ Axis.anchorInside ]
            ]
-}
anchorInside : StyleAttribute
anchorInside config =
    { config | anchor = Inner }


{-| Position this axis to the lowest value on the opposite axis. E.g. if
 this attribute is added on an y-axis, it will be positioned to the left.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view
                [ Axis.positionLowest ]
            ]
-}
positionLowest : StyleAttribute
positionLowest config =
    { config | position = Internal.Lowest }


{-| Position this axis to the highest value on the opposite axis. E.g. if
 this attribute is added on an y-axis, it will be positioned to the right.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view
                [ Axis.positionHighest ]
            ]
-}
positionHighest : StyleAttribute
positionHighest config =
    { config | position = Internal.Highest }


{-| Remove tick and value where the axis crosses the opposite axis.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view [ Axis.cleanCrossings ] ]
-}
cleanCrossings : StyleAttribute
cleanCrossings config =
    { config | cleanCrossings = True }


{-| By providing this attribute with a list of [tick attributes](http://package.elm-lang.org/packages/terezka/elm-plot/latest/Plot-Tick),
 you may alter the values and ticks displayed as your axis' ticks.

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.tick
                [ Tick.view [ Tick.length 3 ]
                , Tick.values [ 2, 4, 6 ]
                ]
            ]
-}
tick : List (Tick.Attribute msg) -> Attribute msg
tick attributes config =
    { config | tickConfig = List.foldl (<|) TickInternal.defaultConfig attributes }


{-| By providing this attribute with a list of [label attributes](http://package.elm-lang.org/packages/terezka/elm-plot/latest/Plot-Label),
 you may alter the values and ticks displayed as your axis' labels.

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.tick
                [ Label.view
                    [ Label.displace (10, 0)
                    , Label.format formatFunc
                    ]
                , Label.values [ 3, 5, 7 ]
                ]
            ]
-}
label : List (Label.Attribute msg) -> Attribute msg
label attributes config =
    { config | labelConfig = List.foldl (<|) LabelInternal.defaultConfig attributes }

