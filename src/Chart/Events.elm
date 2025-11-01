module Chart.Events exposing
  ( Attribute, Event
  , onMouseMove, onMouseLeave, onMouseUp, onMouseDown, onClick, onDoubleClick, on
  , Decoder, Point, getSvgCoords, getNearest, getNearestX, getNearestWithin, getNearestWithinX, getAllWithin, getNearestAndNearby
  , getCoords, getOffset, getCustom
  , map, map2, map3, map4
  )


{-| Add events.

# Event handlers
@docs Attribute, Event
@docs onMouseMove, onMouseLeave, onMouseUp, onMouseDown, onClick, onDoubleClick, on

## Decoders
@docs Decoder, Point
@docs getCoords, getSvgCoords, getOffset
@docs getNearest, getNearestX, getNearestWithin, getNearestWithinX, getAllWithin, getNearestAndNearby, getCustom
@docs map, map2, map3, map4

-}

import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Internal.Coordinates as C exposing (Point, Position, Plane)
import Chart.Attributes as CA
import Chart.Item as I
import Internal.Svg as CS
import Internal.Helpers as Helpers
import Internal.Many as M
import Internal.Events as IE



-- EVENTS


{-| An attribute for adding events.
-}
type alias Attribute x data msg =
  Helpers.Attribute { x | events : List (Event data msg) }


{-| Add a click event handler.

    C.chart
      [ CE.onClick Clicked C.getCoords ]
      [ .. ]

-}
onClick : (a -> msg) -> Decoder data a -> Attribute x data msg
onClick onMsg decoder =
  on "click" (map onMsg decoder)


{-| Add a double click event handler.
-}
onDoubleClick : (a -> msg) -> Decoder data a -> Attribute x data msg
onDoubleClick onMsg decoder =
  on "dblclick" (map onMsg decoder)


{-| Add a mouse move event handler.

    C.chart
      [ CE.onMouseMove (CE.getNearest CI.bars) ]
      [ .. ]

See example at [elm-charts.org](https://www.elm-charts.org/documentation/interactivity/basic-bar-tooltip).
-}
onMouseMove : (a -> msg) -> Decoder data a -> Attribute x data msg
onMouseMove onMsg decoder =
  on "mousemove" (map onMsg decoder)


{-| Add a mouse up event handler. See example at [elm-charts.org](https://www.elm-charts.org/documentation/interactivity/zoom).
-}
onMouseUp : (a -> msg) -> Decoder data a -> Attribute x data msg
onMouseUp onMsg decoder =
  on "mouseup" (map onMsg decoder)


{-| Add a mouse down event handler. See example at [elm-charts.org](https://www.elm-charts.org/documentation/interactivity/zoom).
-}
onMouseDown : (a -> msg) -> Decoder data a -> Attribute x data msg
onMouseDown onMsg decoder =
  on "mousedown" (map onMsg decoder)


{-| Add a mouse leave event handler. See example at [elm-charts.org](https://www.elm-charts.org/documentation/interactivity/basic-bar-tooltip).
-}
onMouseLeave : msg -> Attribute x data msg
onMouseLeave onMsg =
  on "mouseleave" (map (always onMsg) getCoords)


{-| Add any event handler.

    C.chart
      [ CE.on "mousemove" <|
          CE.map2 OnMouseMove
            (CE.getNearest CI.bars)
            (CE.getNearest CI.dots)

      ]
      [ .. ]

See example at [elm-charts.org](https://www.elm-charts.org/documentation/interactivity/multiple-tooltips).

-}
on : String -> Decoder data msg -> Attribute x data msg
on =
  IE.on



-- DECODER


{-| -}
type alias Event data msg =
  IE.Event data msg


{-| -}
type alias Decoder data msg =
  IE.Decoder data msg


{-| -}
type alias Point =
  { x : Float
  , y : Float
  }


{-| Decode to get the cartesian coordinates of the event.

-}
getCoords : Decoder data Point
getCoords =
  IE.getCoords


{-| Decode to get the SVG coordinates of the event.

-}
getSvgCoords : Decoder data Point
getSvgCoords =
  IE.getSvgCoords



{-| Decode to get the event offset from center in cartesian coordinates.

-}
getOffset : Decoder data Point
getOffset =
  IE.getOffset


{-| Using the list of chart items, then top level scale, and the event point, produce
your own event decoder.

Note that this has two planes. The first is the plane as calculated from
configuration and data. The second is the plane with adjusted height
and width as gathered from JS event. See
[Internal.Svg.decoder](https://github.com/terezka/elm-charts/blob/master/src/Internal/Svg.elm#L1770) to see implementation.

-}
getCustom : (List (I.One data I.Any) -> Plane -> Plane -> Point -> msg) -> Decoder data msg
getCustom =
  IE.getCustom



{-| Decode to get the nearest item to the event. Use the `Remodel` functions in `Chart.Item`
to filter down what items or groups of items you will be searching for.

    import Chart as C
    import Chart.Attributes as CA
    import Chart.Events as CE
    import Chart.Item as CI

    type alias Model =
      { hovering : List (CI.One Datum CI.Bar) }

    init : Model
    init =
      { hovering = [] }

    type Msg
      = OnHover (List (CI.One Datum CI.Bar))

    update : Msg -> Model -> Model
    update msg model =
      case msg of
        OnHover hovering ->
          { model | hovering = hovering }

    view : Model -> H.Html Msg
    view model =
      C.chart
        [ CA.height 300
        , CA.width 300
        , CE.onMouseMove OnHover (CE.getNearest CI.bars)
        , CE.onMouseLeave (OnHover [])
        ]
        [ C.xLabels []
        , C.yLabels []
        , C.bars []
            [ C.bar .z []
            , C.bar .y []
            ]
            data

        , C.each model.hovering <| \p bar ->
            [ C.tooltip bar [] [] [] ]
        ]

See example at [elm-charts.org](https://www.elm-charts.org/documentation/interactivity/basic-bar-tooltip).
-}
getNearest : I.Remodel (I.One data I.Any) (I.Item result) -> Decoder data (List (I.Item result))
getNearest =
  IE.getNearest


{-| Find the nearest item and collect all other items around that item within the specified radius.
Use the `Remodel` functions in `Chart.Item` to filter down what items or groups of items you will be searching for.

    CE.onMouseMove OnHover (CE.getNearestAndNearby 10 CI.dots)

-}
getNearestAndNearby : Float -> I.Remodel (I.One data I.Any) (I.Item result) -> Decoder data (List (I.Item result), List (I.Item result))
getNearestAndNearby =
  IE.getNearestAndNearby


{-| Decode to get the nearest item within certain radius to the event. Use the `Remodel` functions in `Chart.Item`
to filter down what items or groups of items you will be searching for.

    CE.onMouseMove OnHover (CE.getNearestWithin 10 CI.dots)

-}
getNearestWithin : Float -> I.Remodel (I.One data I.Any) (I.Item result) -> Decoder data (List (I.Item result))
getNearestWithin =
  IE.getNearestWithin


{-| Like `getNearest`, but only takes x coordiante into account. Use the `Remodel` functions in `Chart.Item`
to filter down what items or groups of items you will be searching for.

    CE.onMouseMove OnHover (CE.getNearestX CI.dots)

Note: This use to return just one item unless coordinates were identical. This has been updated to
return all items with same x coordinates as the closest item found.

-}
getNearestX : I.Remodel (I.One data I.Any) (I.Item result) -> Decoder data (List (I.Item result))
getNearestX =
  IE.getNearestX


{-| Like `getNearestWithin`, but only takes x coordiante into account. Use the `Remodel` functions in `Chart.Item`
to filter down what items or groups of items you will be searching for.

    CE.onMouseMove OnHover (CE.getNearestWithinX 10 CI.dots)

-}
getNearestWithinX : Float -> I.Remodel (I.One data I.Any) (I.Item result) -> Decoder data (List (I.Item result))
getNearestWithinX =
  IE.getNearestWithinX


{-| Find all items within the specified radius. Use the `Remodel` functions in `Chart.Item`
to filter down what items or groups of items you will be searching for.

    CE.onMouseMove OnHover (CE.getAllWithin 10 CI.dots)

-}
getAllWithin : Float -> I.Remodel (I.One data I.Any) (I.Item result) -> Decoder data (List (I.Item result))
getAllWithin =
  IE.getAllWithin



-- MAPS


{-| -}
map : (a -> msg) -> Decoder data a -> Decoder data msg
map =
  IE.map


{-| -}
map2 : (a -> b -> msg) -> Decoder data a -> Decoder data b -> Decoder data msg
map2 =
  IE.map2


{-| -}
map3 : (a -> b -> c -> msg) -> Decoder data a -> Decoder data b -> Decoder data c -> Decoder data msg
map3 =
  IE.map3


{-| -}
map4 : (a -> b -> c -> d -> msg) -> Decoder data a -> Decoder data b -> Decoder data c -> Decoder data d -> Decoder data msg
map4 =
  IE.map4


