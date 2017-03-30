module Series exposing (..)

{-| -}

import Html exposing (Html, div)
import Svg exposing (Svg, Attribute, g)
import Svg.Attributes exposing (class)
import Axis
import Plot
import Internal.Base as Base
import Internal.Axis


{-| -}
type alias Series data msg =
  { axis : Maybe Axis.Customizations
  , interpolation : Interpolation
  , toDataPoints : data -> List (DataPoint msg)
  }


{-| -}
type Interpolation
  = None
  | Linear (Maybe String) (List (Attribute Never))
  | Monotone (Maybe String) (List (Attribute Never))


{-| -}
type alias DataPoint msg =
  { view : Maybe (Svg msg)
  , hint : Html Never
  , xMark : Axis.Summary -> Axis.Mark
  , yMark : Axis.Summary -> Axis.Mark
  , x : Float
  , y : Float
  }


{-| -}
defaultPlotCustomizations : Plot.Customizations msg
defaultPlotCustomizations =
  { attributes = []
  , defs = []
  , id = "elm-plot"
  , width = 647
  , height = 440
  , margin =
      { top = 20
      , right = 40
      , bottom = 20
      , left = 40
      }
  , onHover = Nothing
  , hintContainer = \_ _ -> div [] []
  , horizontalAxis = defaultAxis
  , junk = always []
  , toDomainLowest = identity
  , toDomainHighest = identity
  , toRangeLowest = identity
  , toRangeHighest = identity
  }


{-| -}
defaultAxis : Axis.Axis
defaultAxis =
  Just <| \summary ->
    { position = Axis.closestToZero
    , axisLine = Just (Axis.simpleLine summary)
    , marks = List.map (Axis.defaultMark summary) (Axis.decentPositions summary |> Axis.remove 0)
    , flipAnchor = False
    }


{-| -}
view : Series data msg -> data -> Svg msg
view =
  viewCustom defaultPlotCustomizations


{-| -}
viewCustom : Plot.Customizations msg -> Series data msg -> data -> Svg msg
viewCustom customizations series data =
  let
    dataPoints =
      List.map (.toDataPoints >> flip data) series

    allDataPoints =
      List.concat dataPoints

    nicify summary =
      List.foldl nicifySeries summary series

    plot =
      Base.plot customizations nicify allDataPoints

    horizontalAxis =
      Internal.Axis.composeAxis .xMark customizations.axis dataPoints

    verticalAxes =
      List.map2 (Internal.Axis.composeAxis .yMark) series dataPoints

    viewGridBelow =
      Internal.Axis.viewGrid plot .gridBelow horizontalAxis.marks (List.concatMap .marks verticalAxes)

    viewGridAbove =
      Internal.Axis.viewGrid plot .gridAbove horizontalAxis.marks (List.concatMap .marks verticalAxes)

    viewHorizontal =
      Internal.Axis.viewHorizontal plot horizontalAxis

    viewVerticals =
      Internal.Axis.viewVerticals verticalAxes
  in
    Internal.Plot.view
      [ viewGridBelow
      , viewSeries plot dataPoints series
      , viewHorizontal
      , viewVerticals
      , viewGridAbove
      , Internal.Plot.viewJunk
      ]


nicifySeries : Series data msg -> Base.PlotSummary -> Base.PlotSummary
nicifySeries series =
  case series.interpolation of
    None ->
      identity

    Linear fill _ ->
      nicifyArea fill

    Monotone fill _ ->
      nicifyArea fill


nicifyArea : Maybe String -> Base.PlotSummary -> Base.PlotSummary
nicifyArea area ({ y, x } as summary) =
  case area of
    Nothing ->
      summary

    Just _ ->
      { summary
      | x = x
      , y = { y | min = min y.min 0, max = y.max }
      }
