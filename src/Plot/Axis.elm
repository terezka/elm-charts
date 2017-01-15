module Plot.Axis exposing (..)

{-|
 Attributes for altering the view of your axis.

# Definition
@docs Attribute

# Attributes
@docs classes, line, positionLowest, positionHighest, cleanCrossings, anchorInside

## Ticks and labels
@docs LabelInfo, tick, tickValues, tickDelta, label, labelValues

-}

import Plot.Types exposing (Style)
import Internal.Types exposing (Orientation(..), Anchor(..), Value)
import Internal.Axis as Internal exposing (ValueConfig(..))
import Internal.Label as LabelInternal
import Internal.Tick as TickInternal
import Internal.Line as LineInternal
import Plot.Line as Line
import Plot.Tick as Tick
import Plot.Label as Label


{-| -}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| -}
type alias LabelInfo =
    { value : Float
    , index : Int
    }


{-| Adds classes to the container holding your axis.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view
                [ Axis.classes [ "axis--x" ] ]
            ]
-}
classes : List String -> Attribute msg
classes classes config =
    { config | classes = classes }


{-| Adds styles to the axis line.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view
                [ Axis.line [ Line.stroke "blue" ] ]
            ]
-}
line : List (Line.Attribute msg) -> Attribute msg
line attrs config =
    { config | lineConfig = List.foldr (<|) LineInternal.defaultConfig attrs }


{-| Anchor the ticks/labels on the inside of the plot. By default they are anchored on the outside.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view
                [ Axis.anchorInside ]
            ]
-}
anchorInside : Attribute msg
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
positionLowest : Attribute msg
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
positionHighest : Attribute msg
positionHighest config =
    { config | position = Internal.Highest }


{-| Remove tick and value where the axis crosses the opposite axis.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.view [ Axis.cleanCrossings ] ]
-}
cleanCrossings : Attribute msg
cleanCrossings config =
    { config | cleanCrossings = True }


{-| By providing this attribute with a list of [tick attributes](http://package.elm-lang.org/packages/terezka/elm-plot/latest/Plot-Tick),
 you may alter the values and ticks displayed as your axis' ticks.

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.tick
                [ Tick.view [ Tick.length 3 ] ]
            , Axis.tickValues [ 2, 4, 6 ]
            ]
-}
tick : List (Tick.Attribute LabelInfo msg) -> Attribute msg
tick attributes config =
    { config | tickConfig = List.foldl (<|) TickInternal.defaultConfig attributes }


{-| By providing this attribute with a list of [label attributes](http://package.elm-lang.org/packages/terezka/elm-plot/latest/Plot-Label),
 you may alter the values and ticks displayed as your axis' labels.

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.label
                [ Label.view
                    [ Label.displace (10, 0)
                    , Label.stroke "blue"
                    ]
                , Label.format (.value >> toString)
                ]
            ]
-}
label : List (Label.Attribute LabelInfo msg) -> Attribute msg
label attributes config =
    { config | labelConfig = List.foldl (<|) LabelInternal.defaultConfig attributes }


{-| Specify the values which you want a label for. If not specified, it will mirror
  the tick values.

    myYAxis : Plot.Element msg
    myYAxis =
        Plot.yAxis
            [ Axis.labelValues [ 0, 5, 10, 11 ] ]
-}
labelValues : List Value -> Attribute msg
labelValues values config =
    { config | labelValues = Just values }


{-| Specify at what values will be added a tick.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.tickValues [ 0, 1, 2, 4, 8 ] ]

 **Note:** If you add another attribute altering the values like `tickDelta` _after_ this attribute,
 then this attribute will have no effect.
-}
tickValues : List Float -> Attribute msg
tickValues values config =
    { config | tickValues = FromCustom values }


{-| Specify what values will be added a tick by specifying the space between each tick.

    myXAxis : Plot.Element msg
    myXAxis =
        Plot.xAxis
            [ Axis.tickDelta 4 ]

 **Note:** If you add another attribute altering the values like `tickValues` _after_ this attribute,
 then this attribute will have no effect.
-}
tickDelta : Float -> Attribute msg
tickDelta delta config =
    { config | tickValues = FromDelta delta }
