module Chart.Item exposing
  ( Item
  , getCenter, getTop, getBottom, getLeft, getRight
  , getTopLeft, getTopRight, getBottomLeft, getBottomRight
  , getPosition, getLimits, getTooltip

  , One, Any, Bar, Dot
  , getData, getX, getX1, getX2, getY
  , getName, getColor, getSize, getTooltipValue
  , isReal, isSame, filter

  , Many, getMembers, getMember, getDatas, getOneData

  , Remodel, apply, andThen
  , any, dots, bars, real, named
  , bins, stacks, sameX
  --, customs
  )


{-| This is an interface for dealing with different chart items, such
as bars, dots, or groups of such, like bins or stacks. It comes in handy
when dealing with events:

    import Chart as C
    import Chart.Events as CE
    import Chart.Item as CI

    C.chart
      [ CE.onMouseMove OnHover (CE.getNearest CI.bars) ]
      [ C.bars [ C.bar .x [] ] data ]

Or when using functions like `C.eachBar` or `C.eachBin`:

    import Chart as C
    import Chart.Events as CE
    import Chart.Item as CI
    import Svg as S

    C.chart
      [ CE.onMouseMove OnHover (CE.getNearest CI.bars) ]
      [ C.bars [ C.bar .x [] ] data
      , C.eachBar <| \plane bar ->
          [ C.label [] [ S.text (String.fromFloat (CI.getY bar)) ] (CI.getTop plane bar) ]
      ]

# Single items
@docs One, Any, Bar, Dot
@docs getData, getX, getX1, getX2, getY
@docs getName, getColor, getSize, getTooltipValue
@docs isReal, isSame, filter

# Groups of items
@docs Many, getMembers, getMember, getDatas, getOneData

# Filtering and collecting
@docs Remodel, apply, andThen
## Filters
@docs any, dots, bars, real, named
## Collecters
@docs bins, stacks, sameX

# General
@docs Item
@docs getCenter, getTop, getBottom, getLeft, getRight
@docs getTopLeft, getTopRight, getBottomLeft, getBottomRight
@docs getPosition, getLimits, getTooltip


-}


import Html exposing (Html)
import Internal.Coordinates as C exposing (Point, Position, Plane)
import Internal.Item as I
import Internal.Many as M
import Internal.Svg as CS


{-| An "item" on the chart. A `One Data Bar` and `Many Data Bar` are both
instances on this type, so you can use all the fuctions below on those too.

-}
type alias Item x =
  I.Rendered x


{-| Get the default tooltip. -}
getTooltip : Item x -> List (Html Never)
getTooltip =
  I.toHtml


{-| -}
getCenter : Plane -> Item x -> Point
getCenter p =
  I.getPosition p >> C.center


{-| -}
getLeft : Plane -> Item x -> Point
getLeft p =
  I.getPosition p >> C.left


{-| -}
getRight : Plane -> Item x -> Point
getRight p =
  I.getPosition p >> C.right


{-| -}
getTop : Plane -> Item x -> Point
getTop p =
  I.getPosition p >> C.top


{-| -}
getTopLeft : Plane -> Item x -> Point
getTopLeft p =
  I.getPosition p >> C.topLeft


{-| -}
getTopRight : Plane -> Item x -> Point
getTopRight p =
  I.getPosition p >> C.topRight


{-| -}
getBottom : Plane -> Item x -> Point
getBottom p =
  I.getPosition p >> C.bottom


{-| -}
getBottomLeft : Plane -> Item x -> Point
getBottomLeft p =
  I.getPosition p >> C.bottomLeft


{-| -}
getBottomRight : Plane -> Item x -> Point
getBottomRight p =
  I.getPosition p >> C.bottomRight


{-| -}
getPosition : Plane -> Item x -> Position
getPosition =
  I.getPosition


{-| In a few cases, a rendered item's "position" and "limits" aren't the same.

In the case of a bin, the "position" is the area which the bins bars take up, not
inclusing any margin which may be around them. Its "limits" include the margin.

-}
getLimits : Item x -> Position
getLimits =
  I.getLimits



-- ONE


{-| A representation containing information about a certain item on the
chart, such as a bar or a dot.

    One data Bar -- representation of a single bar
    One data Dot -- representation of a single dot
    One data Any -- representation of either a dot or a bar

It allows us to know e.g. the exact position of the item, the color, what
data it was produced from, and whether it is a representation of missing data
or not.

-}
type alias One data x =
  I.One data x


{-| Information about a dot or a bar. -}
type alias Any =
  I.Any


{-| Information about the configuration of a bar. -}
type alias Bar =
  CS.Bar


{-| Information about the configuration of a dot. -}
type alias Dot =
  CS.Dot


{-| Get the data the item was produced from. -}
getData : One data x -> data
getData =
  I.getDatum


{-| Get the x value of the item. -}
getX : One data x -> Float
getX =
  I.getX


{-| Get the x1 value of the item. -}
getX1 : One data x -> Float
getX1 =
  I.getX1


{-| Get the x2 value of the item. -}
getX2 : One data x -> Float
getX2 =
  I.getX2


{-| Get the y value of the item. -}
getY : One data x -> Float
getY =
  I.getY


{-| Get the name of the series which produced the item. -}
getName : One data x -> String
getName =
  I.getName


{-| Get the color of the item. -}
getColor : One data x -> String
getColor =
  I.getColor


{-| Get the formatted y value. -}
getTooltipValue  : One data x -> String
getTooltipValue =
  I.getTooltipValue


{-| Get the size of a dot. -}
getSize : One data Dot -> Float
getSize =
  I.getSize


{-| Is the item a representation of missing data? This may be
the case if you used e.g. `C.scatterMaybe` or `C.barMaybe`.
-}
isReal : One data x -> Bool
isReal =
  I.isReal


{-| Is this item the exact same as the other? -}
isSame : One data x -> One data x -> Bool
isSame =
  I.isSame


{-| Filter for a certain data type. -}
filter : (a -> Maybe b) -> List (One a x) -> List (One b x)
filter =
  I.filterMap



-- MANY


{-| A collection of many items.

    Many data Bar -- representation of several bars
    Many data Dot -- representation of several dots
    Many data Any -- representation of several dos or bars

Sometimes it's neccessary to work with a group of items, rather
than a single. For example, if you'd like a tooltip to show up
on top of a stacked bar, it's helpful to be able to treat all
the pieces of that stack at the same time.

-}
type alias Many data x =
  M.Many (One data x)


{-| Get all members of the group. -}
getMembers : Many data x -> List (One data x)
getMembers =
  M.getMembers


{-| Get the first members of the group.

This is useful when you know all members of the group
share some of the same characteristics. For example, if
you have a vertical stack of bars, they will all have the
same x values. If you'd like to access those x values, it
doesn't matter which one you pick as they are all the
same, so the first one is thus fine.

-}
getMember : Many data x -> One data x
getMember =
  M.getMember


{-| Get the data from each member in the group. -}
getDatas : Many data x -> List data
getDatas =
  M.getDatas


{-| Get the data from the first member in the group. -}
getOneData : Many data x -> data
getOneData =
  M.getData



-- REMODELLING


{-| Remodeling offers a way to filter and group chart items. For example,
if you have a variable `items` of type `List (One Data Any)`, you can
filter it such that it only contains bars:

    CI.apply CI.bars items -- List (One Data Bar)

This is the interface used in the events api too. If you'd like to get
the nearest bar on mouse move, you'd say:

    CE.onMouseMove OnHovering (CE.getNearest CI.bars)

-}
type alias Remodel a b =
  M.Remodel a b


{-| Apply a remodelling. -}
apply : Remodel a b -> List a -> List b
apply =
  M.apply


{-| Chain a remodelling. -}
andThen : Remodel b c -> Remodel a b -> Remodel a c
andThen =
  M.andThen


{-| Keep anything. -}
any : Remodel (One data Any) (One data Any)
any =
  M.any


{-| Keep only dots. -}
dots : Remodel (One data Any) (One data Dot)
dots =
  M.dots


{-| Keep only bars. -}
bars : Remodel (One data Any) (One data Bar)
bars =
  M.bars


{-| Remove representations of missing data. -}
real : Remodel (One data x) (One data x)
real =
  M.real


{-| Keep only items coming from series with the names listed. -}
named : List String -> Remodel (One data x) (One data x)
named =
  M.named


{-| Group into bins. Items are in the same bin
if they are produced from the same element and the
same data point.

-}
bins : Remodel (One data x) (Many data x)
bins =
  M.bins


{-| Group into bins. Items are in the same stack
if they are produced from the same `C.stacked` property.

-}
stacks : Remodel (One data x) (Many data x)
stacks =
  M.stacks


{-| Group into items with the same x value.

-}
sameX : Remodel (One data x) (Many data x)
sameX =
  M.sameX



--customs : Remodel (Any data) (Custom data)


