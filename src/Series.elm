module Series exposing (..)

{-| -}

import Html exposing (Html, div)
import Svg exposing (Svg, Attribute, g)
import Svg.Attributes as Attributes exposing (class)
import Colors exposing (..)
import Axis
import Plot
import Internal.Base as Base
import Internal.Plot
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
  , xMark : Maybe (Axis.Summary -> Axis.MarkCustomizations)
  , yMark : Maybe (Axis.Summary -> Axis.MarkCustomizations)
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
view : List (Series data msg) -> data -> Svg msg
view =
  viewCustom defaultPlotCustomizations


{-| -}
viewCustom : Plot.Customizations msg -> List (Series data msg) -> data -> Svg msg
viewCustom customizations series data =
  let
    dataPoints =
      List.map (flip .toDataPoints data) series

    allDataPoints =
      List.concat dataPoints

    nicify summary =
      List.foldl nicifySeries summary series

    plot =
      Base.plot customizations nicify allDataPoints

    horizontalAxis =
      Internal.Axis.composeAxis plot.x xMark allDataPoints customizations.horizontalAxis

    verticalAxes =
      List.map2 (Internal.Axis.composeAxis plot.y yMark) dataPoints series

    viewGridBelow =
      Internal.Axis.viewGrid plot .gridBelow
        (Maybe.map .marks horizontalAxis |> Maybe.withDefault [])
        (List.concatMap .marks (List.filterMap identity verticalAxes))

    viewGridAbove =
      Internal.Axis.viewGrid plot .gridAbove
        (Maybe.map .marks horizontalAxis |> Maybe.withDefault [])
        (List.concatMap .marks (List.filterMap identity verticalAxes))
        
    viewHorizontal =
      Internal.Axis.viewHorizontal plot horizontalAxis

    viewVerticals =
      Internal.Axis.viewVerticals plot verticalAxes

    viewAllSeries =
      g [ class "elm-plot__all-series" ]
        (List.map2 (viewSeries customizations plot) series dataPoints)
  in
    Internal.Plot.view plot customizations allDataPoints
      [ viewGridBelow
      , viewAllSeries
      , viewHorizontal
      , viewVerticals
      , viewGridAbove
      , Internal.Plot.viewJunk
      ]


xMark : Base.Plot -> DataPoint msg -> Maybe Axis.Mark
xMark plot dataPoint =
  Maybe.map (\mark -> { position = dataPoint.x, customizations = mark (Internal.Axis.toSummary plot.x) }) dataPoint.xMark


yMark : Base.Plot -> DataPoint msg -> Maybe Axis.Mark
yMark plot dataPoint =
  Maybe.map (\mark -> { position = dataPoint.y, customizations = mark (Internal.Axis.toSummary plot.y) }) dataPoint.yMark


viewSeries : Plot.Customizations msg -> Base.Plot -> Series data msg -> List (DataPoint msg) -> Svg msg
viewSeries customizations plotSummary { axis, interpolation } dataPoints =
  g [ class "elm-plot__series" ]
    [ Svg.map never (viewPath customizations plotSummary interpolation dataPoints)
    , viewDataPoints plotSummary dataPoints
    ]


viewPath : Plot.Customizations msg -> Base.Plot -> Interpolation -> List (DataPoint msg) -> Svg Never
viewPath customizations plotSummary interpolation dataPoints =
  case interpolation of
    None ->
      Svg.path [] []

    Linear fill attributes ->
      viewInterpolation customizations plotSummary Base.linear Base.linearArea fill attributes dataPoints

    Monotone fill attributes ->
      viewInterpolation customizations plotSummary Base.monotoneX Base.monotoneXArea fill attributes dataPoints


viewInterpolation :
  Plot.Customizations msg
  -> Base.Plot
  -> (Base.Plot -> List Plot.Point -> List Base.Command)
  -> (Base.Plot -> List Plot.Point -> List Base.Command)
  -> Maybe String
  -> List (Attribute Never)
  -> List (DataPoint msg)
  -> Svg Never
viewInterpolation customizations summary toLine toArea area attributes dataPoints =
  case area of
    Nothing ->
      Base.path
        (Attributes.fill transparent
        :: Attributes.stroke pinkStroke
        :: Attributes.class "elm-plot__series__interpolation"
        :: Attributes.clipPath ("url(#" ++ Internal.Plot.toClipPathId customizations ++ ")")
        :: attributes)
        (toLine summary dataPoints)

    Just color ->
      Base.path
        (Attributes.fill color
        :: Attributes.stroke pinkStroke
        :: Attributes.class "elm-plot__series__interpolation"
        :: Attributes.clipPath ("url(#" ++ Internal.Plot.toClipPathId customizations ++ ")")
        :: attributes)
        (toArea summary dataPoints)



-- DOT VIEWS


viewDataPoints : Base.Plot -> List (DataPoint msg) -> Svg msg
viewDataPoints plotSummary dataPoints =
  dataPoints
    |> List.map (viewDataPoint plotSummary)
    |> List.filterMap identity
    |> g [ class "elm-plot__series__points" ]


viewDataPoint : Base.Plot -> DataPoint msg -> Maybe (Svg msg)
viewDataPoint plotSummary { x, y, view } =
  case view of
    Nothing ->
      Nothing

    Just svgView ->
      Just <| g [ Base.place plotSummary { x = x, y = y } 0 0 ] [ svgView ]



{-| Pass radius and color to make a circle!
-}
viewCircle : Float -> String -> Svg msg
viewCircle radius color =
  Svg.circle
    [ Attributes.r (toString radius)
    , Attributes.stroke "transparent"
    , Attributes.fill color
    ]
    []


{-| Pass width and color to make a square!
-}
viewSquare : Float -> String -> Svg msg
viewSquare width color =
  Svg.rect
    [ Attributes.width (toString width)
    , Attributes.height (toString width)
    , Attributes.x (toString (-width / 2))
    , Attributes.y (toString (-width / 2))
    , Attributes.stroke "transparent"
    , Attributes.fill color
    ]
    []


{-| Pass width, height and color to make a diamond and impress with your
  classy plot!
-}
viewDiamond : Float -> Float -> String -> Svg msg
viewDiamond width height color =
  Svg.rect
    [ Attributes.width (toString width)
    , Attributes.height (toString height)
    , Attributes.transform "rotate(45)"
    , Attributes.x (toString (-width / 2))
    , Attributes.y (toString (-height / 2))
    , Attributes.stroke "transparent"
    , Attributes.fill color
    ]
    []


{-| Pass a color to make a triangle! Great for academic looking plots.
-}
viewTriangle : String -> Svg msg
viewTriangle color =
  Svg.polygon
    [ Attributes.points "0,-5 5,5 -5,5"
    , Attributes.transform "translate(0, -2.5)"
    , Attributes.fill color
    ]
    []



-- REACH HELPERS


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
      { x = x
      , y = { y | min = min y.min 0, max = y.max }
      }
