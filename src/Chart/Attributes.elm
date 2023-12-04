module Chart.Attributes exposing
  ( Attribute

  -- CONTAINER
  , width, height, attrs, htmlAttrs, events, margin, padding

  -- LIMITS
  , range, domain, limits
  , lowest, highest, orLower, orHigher, exactly, more, less, window, likeData
  , zoom, move, centerAt, pad
  , zero, middle, percent

  -- LABELS
  , fontSize, uppercase, format, position
  , alignLeft, alignRight, alignMiddle, ellipsis

  -- AXIS
  , amount, flip, pinned
  , ints, times

  -- COORDINATES
  , x, y, x1, x2Svg, y1, x2, y2, y2Svg, length
  , moveLeft, moveRight, moveUp, moveDown
  , hideOverflow

  -- DECORATION
  , border, borderWidth, color, opacity, highlight, highlightWidth, highlightColor, background, noArrow, rotate
  , striped, dotted, gradient

  -- BAR
  , ungroup, roundTop, roundBottom, spacing

  -- LINES
  , area, size, dashed, break, tickLength, tickDirection
  , linear, monotone, stepped
  , circle, triangle, square, diamond, plus, cross

  -- TOOLTIP
  , onTop, onBottom, onRight, onLeft, onLeftOrRight, onTopOrBottom
  , offset
  , focal
  , topLeft, topRight, topCenter
  , bottomLeft, bottomRight, bottomCenter
  , leftCenter, rightCenter
  , top, bottom, left, right, center

  -- LEGENDS
  , title, row, column

  -- GRID
  , noGrid, withGrid, dotGrid

  -- COLORS
  , pink, purple, blue, green, orange, turquoise, red
  , magenta, brown, mint, yellow, gray
  , darkYellow, darkBlue, darkGray, labelGray

  , noChange
  )


{-| This module contains attributes for editing elements in `Chart` and `Chart.Svg`. See
`Chart` for usage examples.

Often a single attribute can change several different configurations, so the categories
below are only guiding.

@docs Attribute

## Container
@docs width, height, attrs, htmlAttrs, events, margin, padding

## Limits
@docs range, domain, limits
@docs lowest, highest, orLower, orHigher, exactly, more, less, window, likeData
@docs zoom, move, centerAt, pad
@docs zero, middle, percent

## Labels
@docs fontSize, uppercase, format, position
@docs alignLeft, alignRight, alignMiddle, ellipsis

## Axis
@docs amount, flip, pinned
@docs ints, times

## Coordinates
@docs x, y, x1, y1, x2, y2, x2Svg, y2Svg, length
@docs moveLeft, moveRight, moveUp, moveDown
@docs hideOverflow

## Decoration
@docs border, borderWidth, color, opacity, highlight, highlightWidth, highlightColor, background, noArrow, rotate
@docs striped, dotted, gradient

## Bar
@docs ungroup, roundTop, roundBottom, spacing

## Lines
@docs area, size, dashed, break, tickLength, tickDirection
@docs linear, monotone, stepped
@docs circle, triangle, square, diamond, plus, cross

## Tooltip
@docs onTop, onBottom, onRight, onLeft, onLeftOrRight, onTopOrBottom
@docs offset
@docs focal
@docs topLeft, topRight, topCenter
@docs bottomLeft, bottomRight, bottomCenter
@docs leftCenter, rightCenter
@docs top, bottom, left, right, center

## Legends
@docs title, row, column

## Grid
@docs noGrid, withGrid, dotGrid

## Colors
@docs pink, purple, blue, green, orange, turquoise, red
@docs magenta, brown, mint, yellow, gray
@docs darkYellow, darkBlue, darkGray, labelGray


## Conditional helpers
@docs noChange

-}


import Time
import Internal.Coordinates as C
import Internal.Helpers as Helpers exposing (Attribute(..))
import Internal.Svg as CS


{-| -}
type alias Attribute x =
  Helpers.Attribute x


{-| Change the lower bound of an axis.

    CA.lowest -5 CA.orLower initial  -- { initial | min = -5, max = 10 }
    CA.lowest -5 CA.orHigher initial -- { initial | min = 0, max = 10 }
    CA.lowest 2 CA.exactly initial   -- { initial | min = 2, max = 10 }
    CA.lowest 2 CA.less initial   -- { initial | min = -2, max = 10 }
    CA.lowest 3 CA.more initial   -- { initial | min = 3, max = 10 }

where

    initial : Chart.Svg.Axis
    initial =
      { .. | min = 0, max = 10 }

-}
lowest : Float -> (Float -> Float -> Float -> Float) -> Attribute C.Axis
lowest v edit =
  Attribute <| \b -> { b | min = edit v b.min b.dataMin }


{-| Same as `lowest`, but changes upper bound.

-}
highest : Float -> (Float -> Float -> Float -> Float) -> Attribute C.Axis
highest v edit =
  Attribute <| \b -> { b | max = edit v b.max b.dataMax }


{-| Resets axis to fit data bounds.

-}
likeData : Attribute C.Axis
likeData =
  Attribute <| \b -> { b | min = b.dataMin, max = b.dataMax }


{-| Set an axis to an exact window.

    CA.window 2 5 initial   -- { initial | min = 2, max = 5 }

where

    initial : Axis
    initial =
      { .. | min = 0, max = 10 }

-}
window : Float -> Float -> Attribute C.Axis
window min_ max_ =
  Attribute <| \b -> 
    { b | min = min_, max = max_ }


{-| See `lowest` for usage examples.

-}
exactly : Float -> Float -> Float -> Float
exactly exact _ _ =
  exact


{-| See `lowest` for usage examples.

-}
orLower : Float -> Float -> Float -> Float
orLower least real _ =
  if real > least then least else real


{-| See `lowest` for usage examples.

-}
orHigher : Float -> Float -> Float -> Float
orHigher most real _ =
  if real < most then most else real


{-| See `lowest` for usage examples.

-}
more : Float -> Float -> Float -> Float
more v o _ =
  o + v


{-| See `lowest` for usage examples.

-}
less : Float -> Float -> Float -> Float
less v o _ =
  o - v


{-| Zoom with a certain percentage.

    CA.range [ CA.zoom 150 ]

-}
zoom : Float -> Attribute C.Axis
zoom per =
  Attribute <| \axis ->
    let full = axis.max - axis.min
        zoomedFull = full / (max 1 per / 100)
        off = (full - zoomedFull) / 2
    in
    { axis | min = axis.min + off, max = axis.max - off }


{-| Offset entire range.

    CA.move 5 initial   -- { initial | min = 5, max = 15 }

where

    initial : Axis
    initial =
      { .. | min = 0, max = 10 }

-}
move : Float -> Attribute C.Axis
move v =
  Attribute <| \axis -> { axis | min = axis.min + v, max = axis.max + v }


{-| Add padding (in px) to range/domain.

    CA.range [ CA.pad 5 10 ]

-}
pad : Float -> Float -> Attribute C.Axis
pad minPad maxPad =
  Attribute <| \axis -> 
    let scale = C.scaleCartesian axis in
    { axis | min = axis.min - scale minPad, max = axis.max + scale maxPad }


{-| Center range/domain at certain point.

    CA.centerAt 20 initial -- { initial | min = -30, max = 70 }

where

    initial : Axis
    initial =
      { .. | min = 0, max = 100 }

-}
centerAt : Float -> Attribute C.Axis
centerAt v =
  Attribute <| \axis ->
    let full = axis.max - axis.min in
    { axis | min = v - full / 2, max = v + full / 2 }


{-| Given an axis, find the value within it closest to zero.

    CA.zero { dataMin = 0, dataMax = 10, min = 2, max = 5 } -- 2
    CA.zero { dataMin = 0, dataMax = 10, min = -5, max = 5 } -- 0
    CA.zero { dataMin = 0, dataMax = 10, min = -5, max = -2 } -- -2

-}
zero : C.Axis -> Float
zero b =
  clamp b.min b.max 0


{-| Get the middle value of your axis.

-}
middle : C.Axis -> Float
middle b =
  b.min + (b.max - b.min) / 2


{-| Get the value at a certain percentage of the length of your axis.

-}
percent : Float -> C.Axis -> Float
percent per b =
  b.min + (b.max - b.min) * (per / 100)


{-| -}
amount : Int -> Attribute { a | amount : Int }
amount value =
  Attribute <| \config ->
    { config | amount = value }


{-| -}
title : x -> Attribute { a | title : x }
title value =
  Attribute <| \config ->
    { config | title = value }


{-| -}
ints : Attribute { a | generate : CS.TickType }
ints =
  Attribute <| \config ->
    { config | generate = CS.Ints }


{-| -}
times : Time.Zone -> Attribute { a | generate : CS.TickType }
times zone =
  Attribute <| \config ->
    { config | generate = CS.Times zone }


{-| -}
limits : x -> Attribute { a | limits : x }
limits value =
  Attribute <| \config ->
    { config | limits = value }


{-| -}
range : x -> Attribute { a | range : x }
range v =
  Attribute <| \config ->
    { config | range = v }


{-| -}
domain : x -> Attribute { a | domain : x }
domain v =
  Attribute <| \config ->
    { config | domain = v }


{-| -}
padding : x -> Attribute { a | padding : x }
padding value =
  Attribute <| \config ->
    { config | padding = value }


{-| -}
pinned : x -> Attribute { a | pinned : x }
pinned value =
  Attribute <| \config ->
    { config | pinned = value }


{-| -}
dotGrid : Attribute { a | dotGrid : Bool }
dotGrid =
  Attribute <| \config ->
    { config | dotGrid = True }


{-| -}
noArrow : Attribute { a | arrow : Bool }
noArrow =
  Attribute <| \config ->
    { config | arrow = False }


{-| -}
noGrid : Attribute { a | grid : Bool }
noGrid =
  Attribute <| \config ->
    { config | grid = False }


{-| -}
withGrid : Attribute { a | grid : Bool }
withGrid =
  Attribute <| \config ->
    { config | grid = True }


{-| -}
x : Float -> Attribute { a | x : Float }
x v =
  Attribute <| \config ->
    { config | x = v }


{-| -}
x1 : x -> Attribute { a | x1 : Maybe x }
x1 v =
  Attribute <| \config ->
    { config | x1 = Just v }


{-| -}
x2 : x -> Attribute { a | x2 : Maybe x }
x2 v =
  Attribute <| \config ->
    { config | x2 = Just v }


{-| -}
x2Svg : x -> Attribute { a | x2Svg : Maybe x }
x2Svg v =
  Attribute <| \config ->
    { config | x2Svg = Just v }


{-| -}
y : Float -> Attribute { a | y : Float }
y v =
  Attribute <| \config ->
    { config | y = v }


{-| -}
y1 : Float -> Attribute { a | y1 : Maybe Float }
y1 v =
  Attribute <| \config ->
    { config | y1 = Just v }


{-| -}
y2 : Float -> Attribute { a | y2 : Maybe Float }
y2 v =
  Attribute <| \config ->
    { config | y2 = Just v }


{-| -}
y2Svg : x -> Attribute { a | y2Svg : Maybe x }
y2Svg v =
  Attribute <| \config ->
    { config | y2Svg = Just v }


{-| -}
break : Attribute { a | break : Bool }
break =
  Attribute <| \config ->
    { config | break = True }


{-| -}
tickLength : Float -> Attribute { a | tickLength : Float }
tickLength v =
  Attribute <| \config ->
    { config | tickLength = v }


{-| -}
tickDirection : Float -> Attribute { a | tickDirection : Float }
tickDirection v =
  Attribute <| \config ->
    { config | tickDirection = v }


{-| -}
moveLeft : Float -> Attribute { a | xOff : Float }
moveLeft v =
  Attribute <| \config ->
    { config | xOff = config.xOff - v }


{-| -}
moveRight : Float -> Attribute { a | xOff : Float }
moveRight v =
  Attribute <| \config ->
    { config | xOff = config.xOff + v }


{-| -}
moveUp : Float -> Attribute { a | yOff : Float }
moveUp v =
  Attribute <| \config ->
    { config | yOff = config.yOff - v }


{-| -}
moveDown : Float -> Attribute { a | yOff : Float }
moveDown v =
  Attribute <| \config ->
    { config | yOff = config.yOff + v }


{-| -}
hideOverflow : Attribute { a | hideOverflow : Bool }
hideOverflow =
  Attribute <| \config ->
    { config | hideOverflow = True }


{-| -}
xOff : Float -> Attribute { a | xOff : Float }
xOff v =
  Attribute <| \config ->
    { config | xOff = config.xOff + v }


{-| -}
yOff : Float -> Attribute { a | yOff : Float }
yOff v =
  Attribute <| \config ->
    { config | yOff = config.yOff + v }


{-| -}
flip : Attribute { a | flip : Bool }
flip =
  Attribute <| \config ->
    { config | flip = True }


{-| -}
border : String -> Attribute { a | border : String }
border v =
  Attribute <| \config ->
    { config | border = v }


{-| -}
borderWidth : Float -> Attribute { a | borderWidth : Float }
borderWidth v =
  Attribute <| \config ->
    { config | borderWidth = v }


{-| -}
background : String -> Attribute { a | background : String }
background v =
  Attribute <| \config ->
    { config | background = v }


{-| -}
fontSize : Int -> Attribute { a | fontSize : Maybe Int }
fontSize v =
  Attribute <| \config ->
    { config | fontSize = Just v }


{-| -}
uppercase : Attribute { a | uppercase : Bool }
uppercase =
  Attribute <| \config ->
    { config | uppercase = True }


{-| -}
format : x -> Attribute { a | format : Maybe x }
format v =
  Attribute <| \config ->
    { config | format = Just v }


{-| Note: There is no SVG feature for ellipsis, so this turns labels into HTML. -}
ellipsis : Float -> Float -> Attribute { a | ellipsis : Maybe { height : Float, width : Float } }
ellipsis w h =
  Attribute <| \config ->
    { config | ellipsis = Just { width = w, height = h } }


{-| -}
position : x -> Attribute { a | position : x }
position v =
  Attribute <| \config ->
    { config | position = v }


{-| -}
color : String -> Attribute { a | color : String }
color v =
  Attribute <| \config ->
    if v == "" then config else { config | color = v }


{-| -}
opacity : Float -> Attribute { a | opacity : Float }
opacity v =
  Attribute <| \config ->
    { config | opacity = v }


{-| -}
highlight : Float -> Attribute { a | highlight : Float }
highlight v =
  Attribute <| \config ->
    { config | highlight = v }


{-| -}
highlightWidth : Float -> Attribute { a | highlightWidth : Float }
highlightWidth v =
  Attribute <| \config ->
    { config | highlightWidth = v }


{-| -}
highlightColor : String -> Attribute { a | highlightColor : String }
highlightColor v =
  Attribute <| \config ->
    { config | highlightColor = v }


{-| -}
size : Float -> Attribute { a | size : Float }
size v =
  Attribute <| \config ->
    { config | size = v }


{-| -}
width : Float -> Attribute { a | width : Float }
width v =
  Attribute <| \config ->
    { config | width = v }


{-| -}
height : Float -> Attribute { a | height : Float }
height v =
  Attribute <| \config ->
    { config | height = v }


{-| -}
attrs : a -> Attribute { x | attrs : a }
attrs v =
  Attribute <| \config ->
    { config | attrs = v }


{-| -}
htmlAttrs : a -> Attribute { x | htmlAttrs : a }
htmlAttrs v =
  Attribute <| \config ->
    { config | htmlAttrs = v }


{-| -}
length : Float -> Attribute { a | length : Float }
length v =
  Attribute <| \config ->
    { config | length = v }


{-| -}
offset : Float -> Attribute { a | offset : Float }
offset v =
  Attribute <| \config ->
    { config | offset = v }


{-| -}
rotate : Float -> Attribute { a | rotate : Float }
rotate v =
  Attribute <| \config ->
    { config | rotate = config.rotate + v }


{-| -}
margin : x -> Attribute { a | margin : x }
margin v =
  Attribute <| \config ->
    { config | margin = v }


{-| -}
spacing : Float -> Attribute { a | spacing : Float }
spacing v =
  Attribute <| \config ->
    { config | spacing = v }


{-| -}
roundTop : Float -> Attribute { a | roundTop : Float }
roundTop v =
  Attribute <| \config ->
    { config | roundTop = v }


{-| -}
roundBottom : Float -> Attribute { a | roundBottom : Float }
roundBottom v =
  Attribute <| \config ->
    { config | roundBottom = v }


{-| -}
ungroup : Attribute { a | grouped : Bool }
ungroup =
  Attribute <| \config ->
    { config | grouped = False }


{-| -}
events : x -> Attribute { a | events : x }
events v =
  Attribute <| \config ->
    { config | events = v }


{-| -}
alignLeft : Attribute { a | anchor : Maybe CS.Anchor }
alignLeft =
  Attribute <| \config ->
    { config | anchor = Just CS.Start }


{-| -}
alignRight : Attribute { a | anchor : Maybe CS.Anchor }
alignRight =
  Attribute <| \config ->
    { config | anchor = Just CS.End }


{-| -}
alignMiddle : Attribute { a | anchor : Maybe CS.Anchor }
alignMiddle =
  Attribute <| \config ->
    { config | anchor = Just CS.Middle }



-- FOCAL


{-| -}
top : Attribute { a | focal : Maybe (C.Position -> C.Position) }
top =
  Attribute <| \config ->
    { config | focal = Just (\pos -> { pos | y1 = pos.y2 }) }


{-| -}
bottom : Attribute { a | focal : Maybe (C.Position -> C.Position) }
bottom =
  Attribute <| \config ->
    { config | focal = Just (\pos -> { pos | y2 = pos.y1 }) }


{-| -}
left : Attribute { a | focal : Maybe (C.Position -> C.Position) }
left =
  Attribute <| \config ->
    { config | focal = Just (\pos -> { pos | x2 = pos.x1 }) }


{-| -}
right : Attribute { a | focal : Maybe (C.Position -> C.Position) }
right =
  Attribute <| \config ->
    { config | focal = Just (\pos -> { pos | x1 = pos.x2 }) }


{-| -}
topCenter : Attribute { a | focal : Maybe (C.Position -> C.Position) }
topCenter =
  Attribute <| \config ->
    { config | focal = Just (C.top >> C.pointToPosition) }


{-| -}
bottomCenter : Attribute { a | focal : Maybe (C.Position -> C.Position) }
bottomCenter =
  Attribute <| \config ->
    { config | focal = Just (C.bottom >> C.pointToPosition) }


{-| -}
leftCenter : Attribute { a | focal : Maybe (C.Position -> C.Position) }
leftCenter =
  Attribute <| \config ->
    { config | focal = Just (C.left >> C.pointToPosition) }


{-| -}
rightCenter : Attribute { a | focal : Maybe (C.Position -> C.Position) }
rightCenter =
  Attribute <| \config ->
    { config | focal = Just (C.right >> C.pointToPosition) }


{-| -}
topLeft : Attribute { a | focal : Maybe (C.Position -> C.Position) }
topLeft =
  Attribute <| \config ->
    { config | focal = Just (C.topLeft >> C.pointToPosition) }


{-| -}
topRight : Attribute { a | focal : Maybe (C.Position -> C.Position) }
topRight =
  Attribute <| \config ->
    { config | focal = Just (C.topRight >> C.pointToPosition) }


{-| -}
bottomLeft : Attribute { a | focal : Maybe (C.Position -> C.Position) }
bottomLeft =
  Attribute <| \config ->
    { config | focal = Just (C.bottomLeft >> C.pointToPosition) }


{-| -}
bottomRight : Attribute { a | focal : Maybe (C.Position -> C.Position) }
bottomRight =
  Attribute <| \config ->
    { config | focal = Just (C.bottomRight >> C.pointToPosition) }


{-| -}
center : Attribute { a | focal : Maybe (C.Position -> C.Position) }
center =
  Attribute <| \config ->
    { config | focal = Just (C.center >> C.pointToPosition) }


{-| -}
focal : (C.Position -> C.Position) -> Attribute { a | focal : Maybe (C.Position -> C.Position) }
focal given =
  Attribute <| \config ->
    { config | focal = Just given }


{-| -}
linear : Attribute { a | method : Maybe CS.Method }
linear =
  Attribute <| \config ->
    { config | method = Just CS.Linear }


{-| -}
monotone : Attribute { a | method : Maybe CS.Method }
monotone =
  Attribute <| \config ->
    { config | method = Just CS.Monotone }


{-| -}
stepped : Attribute { a | method : Maybe CS.Method }
stepped =
  Attribute <| \config ->
    { config | method = Just CS.Stepped }


{-| -}
area : Float -> Attribute { a | area : Float, method : Maybe CS.Method }
area v =
  Attribute <| \config ->
    { config | area = v
  , method =
      case config.method of
        Just _ -> config.method
        Nothing -> Just CS.Linear
  }


{-| -}
striped : List (Attribute CS.Pattern) -> Attribute { a | design : Maybe CS.Design, opacity : Float }
striped attrs_ =
  Attribute <| \config ->
    { config | design = Just (CS.Striped attrs_), opacity = if config.opacity == 0 then 1 else config.opacity }


{-| -}
dotted : List (Attribute CS.Pattern) -> Attribute { a | design : Maybe CS.Design, opacity : Float }
dotted attrs_ =
  Attribute <| \config ->
    { config | design = Just (CS.Dotted attrs_), opacity = if config.opacity == 0 then 1 else config.opacity }


{-| -}
gradient : List String -> Attribute { a | design : Maybe CS.Design, opacity : Float }
gradient colors =
  Attribute <| \config ->
    { config | design = Just (CS.Gradient colors), opacity = if config.opacity == 0 then 1 else config.opacity }


{-| -}
dashed : x -> Attribute { a | dashed : x }
dashed value =
  Attribute <| \config ->
    { config | dashed = value }


{-| -}
circle : Attribute { a | shape : Maybe CS.Shape }
circle =
  Attribute <| \config ->
    { config | shape = Just CS.Circle }


{-| -}
triangle : Attribute { a | shape : Maybe CS.Shape }
triangle =
  Attribute <| \config ->
    { config | shape = Just CS.Triangle }


{-| -}
square : Attribute { a | shape : Maybe CS.Shape }
square =
  Attribute <| \config ->
    { config | shape = Just CS.Square }


{-| -}
diamond : Attribute { a | shape : Maybe CS.Shape }
diamond =
  Attribute <| \config ->
    { config | shape = Just CS.Diamond }


{-| -}
plus : Attribute { a | shape : Maybe CS.Shape }
plus =
  Attribute <| \config ->
    { config | shape = Just CS.Plus }


{-| -}
cross : Attribute { a | shape : Maybe CS.Shape }
cross =
  Attribute <| \config ->
    { config | shape = Just CS.Cross }


{-| -}
onTop : Attribute { a | direction : Maybe CS.Direction }
onTop =
  Attribute <| \config ->
    { config | direction = Just CS.Top }


{-| -}
onBottom : Attribute { a | direction : Maybe CS.Direction }
onBottom =
  Attribute <| \config ->
    { config | direction = Just CS.Bottom }


{-| -}
onRight : Attribute { a | direction : Maybe CS.Direction }
onRight =
  Attribute <| \config ->
    { config | direction = Just CS.Right }


{-| -}
onLeft : Attribute { a | direction : Maybe CS.Direction }
onLeft =
  Attribute <| \config ->
    { config | direction = Just CS.Left }


{-| -}
onLeftOrRight : Attribute { a | direction : Maybe CS.Direction }
onLeftOrRight =
  Attribute <| \config ->
    { config | direction = Just CS.LeftOrRight }


{-| -}
onTopOrBottom : Attribute { a | direction : Maybe CS.Direction }
onTopOrBottom =
  Attribute <| \config ->
    { config | direction = Just CS.TopOrBottom }


{-| -}
row : Attribute { a | alignment : CS.Alignment }
row =
  Attribute <| \config ->
    { config | alignment = CS.Row }


{-| -}
column : Attribute { a | alignment : CS.Alignment }
column =
  Attribute <| \config ->
    { config | alignment = CS.Column }


{-| -}
noChange : Attribute a
noChange =
  Attribute identity



-- COLORS


{-| -}
pink : String
pink =
  Helpers.pink


{-| -}
purple : String
purple =
  Helpers.purple


{-| -}
blue : String
blue =
  Helpers.blue


{-| -}
green : String
green =
  Helpers.green


{-| -}
orange : String
orange =
  Helpers.orange


{-| -}
turquoise : String
turquoise =
  Helpers.turquoise


{-| -}
red : String
red =
  Helpers.red


{-| -}
darkYellow : String
darkYellow =
  Helpers.darkYellow


{-| -}
darkBlue : String
darkBlue =
  Helpers.darkBlue


{-| -}
magenta : String
magenta =
  Helpers.magenta


{-| -}
brown : String
brown =
  Helpers.brown


{-| -}
mint : String
mint =
  Helpers.mint


{-| -}
yellow : String
yellow =
  Helpers.yellow


{-| -}
gray : String
gray =
  Helpers.gray


{-| -}
darkGray : String
darkGray =
  Helpers.darkGray


{-| -}
labelGray : String
labelGray =
  Helpers.labelGray