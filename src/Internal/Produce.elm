module Internal.Produce exposing (..)

import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Internal.Coordinates as Coord exposing (Point, Position, Plane)
import Dict exposing (Dict)
import Internal.Property as P exposing (Property(..))
import Chart.Attributes as CA
import Chart.Events as CE
import Internal.Svg as S
import Internal.Helpers as Helpers
import Internal.Many as M
import Internal.Item as I


{-| -}
type alias Bars data =
  { spacing : Float
  , margin : Float
  , roundTop : Float
  , roundBottom : Float
  , grouped : Bool
  , grid : Bool
  , x1 : Maybe (data -> Float)
  , x2 : Maybe (data -> Float)
  }


defaultBars : Bars data
defaultBars =
  { spacing = 0.05
  , margin = 0.1
  , roundTop = 0
  , roundBottom = 0
  , grouped = True
  , grid = False
  , x1 = Nothing
  , x2 = Nothing
  }


toBarSeries : Int -> List (CA.Attribute (Bars data)) -> List (Property data () S.Bar) -> List data -> List (M.Many (I.One data S.Bar))
toBarSeries elementIndex barsAttrs properties data =
  let barsConfig = Helpers.apply barsAttrs defaultBars
      numOfStacks = if barsConfig.grouped then toFloat (List.length properties) else 1

      forEachStackSeriesConfig bins stackSeriesConfig ( absoluteIndex, stackSeriesConfigIndex, items ) =
        let seriesItems =
              case stackSeriesConfig of 
                NotStacked barSeriesConfig ->
                  [ forEachBarSeriesConfig bins absoluteIndex stackSeriesConfigIndex 1 0 barSeriesConfig ]

                Stacked barSeriesConfigs ->
                  let numOfBarsInStack = List.length barSeriesConfigs in
                  List.indexedMap (forEachBarSeriesConfig bins absoluteIndex stackSeriesConfigIndex numOfBarsInStack) barSeriesConfigs
        in 
        ( absoluteIndex + List.length seriesItems
        , stackSeriesConfigIndex + 1
        , items ++ List.filterMap identity seriesItems
        )

      forEachBarSeriesConfig bins absoluteIndex stackSeriesConfigIndex numOfBarsInStack barSeriesConfigIndex barSeriesConfig =
        let absoluteIndexNew = absoluteIndex + barSeriesConfigIndex
            items = List.indexedMap (forEachDataPoint absoluteIndexNew stackSeriesConfigIndex barSeriesConfigIndex numOfBarsInStack barSeriesConfig) bins 
        in
        Helpers.withFirst items <| \first rest ->
          I.Rendered ( first, rest )
            { limits = Coord.foldPosition I.getLimits items
            , toPosition = \plane -> Coord.foldPosition (I.getPosition plane) items
            , render = \plane _ -> S.g [ SA.class "elm-charts__series" ] (List.map (I.render plane) items)
            , tooltip = \() -> [ H.table [ HA.style "margin" "0" ] (List.concatMap I.tooltip items) ]
            }

      forEachDataPoint absoluteIndex stackSeriesConfigIndex barSeriesConfigIndex numOfBarsInStack barSeriesConfig dataIndex bin =
        let identification =
              { stackIndex = stackSeriesConfigIndex -- The number this stack configuration is within the full list of stack configurations. If no stacks, this is equal to seriesIndex.
              , seriesIndex = barSeriesConfigIndex  -- The number this bar configuration is within its stack. If no stacks, this is equal to stackIndex.
              , absoluteIndex = absoluteIndex       -- The number this bar configuration is within the total set of bar configurations.
              , dataIndex = dataIndex               -- The number this data point is within the list of data.
              , elementIndex = elementIndex
              }

            start = bin.start
            end = bin.end
            ySum = barSeriesConfig.toYSum bin.datum
            y = barSeriesConfig.toY bin.datum

            length = end - start
            margin = length * barsConfig.margin
            spacing = length * barsConfig.spacing
            width = (length - margin * 2 - (numOfStacks - 1) * spacing) / numOfStacks
            offset = if barsConfig.grouped then toFloat identification.stackIndex * width + toFloat identification.stackIndex * spacing else 0

            x1 = start + margin + offset
            x2 = start + margin + offset + width
            minY = if numOfBarsInStack > 1 then max 0 else identity
            y1 = minY (Maybe.withDefault 0 ySum - Maybe.withDefault 0 y)
            y2 = minY (Maybe.withDefault 0 ySum)

            isTop = identification.seriesIndex == 0
            isBottom = identification.seriesIndex == numOfBarsInStack - 1
            isSingle = numOfBarsInStack == 1

            roundTop = if isSingle || isTop then barsConfig.roundTop else 0
            roundBottom = if isSingle || isBottom then barsConfig.roundBottom else 0

            defaultColor = Helpers.toDefaultColor identification.absoluteIndex
            basicAttributes = [ CA.roundTop roundTop, CA.roundBottom roundBottom, CA.color defaultColor, CA.border defaultColor ]

            barPresentationConfig = 
              Helpers.apply (basicAttributes ++ barSeriesConfig.presentation ++ barSeriesConfig.variation identification bin.datum) S.defaultBar
                |> updateColorIfGradientIsSet defaultColor
                |> updateBorder defaultColor
        in
        I.Rendered
          { presentation = barPresentationConfig
          , color = barPresentationConfig.color
          , datum = bin.datum
          , x1 = start
          , x2 = end
          , y = Maybe.withDefault 0 y
          , isReal = y /= Nothing
          , identification = identification
          , name = barSeriesConfig.tooltipName
          , tooltipText = barSeriesConfig.tooltipText bin.datum
          , toAny = I.Bar
          }
          { limits = { x1 = x1, x2 = x2, y1 = min y1 y2, y2 = max y1 y2 }
          , toPosition = \_ -> { x1 = x1, x2 = x2, y1 = y1, y2 = y2 }
          , render = \plane position -> S.bar plane barPresentationConfig position
          , tooltip = \() -> 
              [ tooltipRow 
                  barPresentationConfig.color 
                  (toDefaultName identification barSeriesConfig.tooltipName) 
                  (barSeriesConfig.tooltipText bin.datum) 
              ]
          }
  in
  Helpers.withSurround data (toBin barsConfig) |> \bins ->
    List.foldl (forEachStackSeriesConfig bins) ( elementIndex, 0, [] ) properties
      |> (\(_, _, items) -> items)


toBin : Bars data -> Int -> Maybe data -> data -> Maybe data -> { datum : data, start : Float, end : Float }
toBin barsConfig index prevM curr nextM =
  case ( barsConfig.x1, barsConfig.x2 ) of
    ( Nothing, Nothing ) ->
      { datum = curr
      , start = toFloat (index + 1) - 0.5
      , end = toFloat (index + 1) + 0.5 
      }

    ( Just toX1, Nothing ) ->
      case ( prevM, nextM ) of
        ( _, Just next ) ->
          { datum = curr
          , start = toX1 curr
          , end = toX1 next 
          }

        ( Just prev, Nothing ) ->
          { datum = curr
          , start = toX1 curr
          , end = toX1 curr + (toX1 curr - toX1 prev) 
          }

        ( Nothing, Nothing ) ->
          { datum = curr
          , start = toX1 curr
          , end = toX1 curr + 1 
          }

    ( Nothing, Just toX2 ) ->
      case ( prevM, nextM ) of
        ( Just prev, _ ) ->
          { datum = curr
          , start = toX2 prev
          , end = toX2 curr 
          }

        ( Nothing, Just next ) ->
          { datum = curr
          , start = toX2 curr - (toX2 next - toX2 curr)
          , end = toX2 curr 
          }

        ( Nothing, Nothing ) ->
          { datum = curr
          , start = toX2 curr - 1
          , end = toX2 curr 
          }

    ( Just toX1, Just toX2 ) ->
      { datum = curr
      , start = toX1 curr
      , end = toX2 curr 
      }


updateColorIfGradientIsSet : String -> S.Bar -> S.Bar
updateColorIfGradientIsSet defaultColor product =
  case product.design of
    Just (S.Gradient (first :: _)) -> 
      if product.color == defaultColor 
        then { product | color = first } 
        else product

    _ ->
      product


updateBorder : String -> S.Bar -> S.Bar
updateBorder defaultColor product =
  if product.border == defaultColor 
    then { product | border = product.color } 
    else product



-- SERIES


{-| -}
toDotSeries : Int -> (data -> Float) -> List (Property data S.Interpolation S.Dot) -> List data -> List (M.Many (I.One data S.Dot))
toDotSeries elementIndex toX properties data =
  let forEachStackSeriesConfig stackSeriesConfig ( absoluteIndex, stackSeriesConfigIndex, items ) =
        let lineItems =
              case stackSeriesConfig of 
                NotStacked lineSeriesConfig ->
                  [ forEachLine False absoluteIndex stackSeriesConfigIndex 0 lineSeriesConfig ]

                Stacked lineSeriesConfigs ->
                  List.indexedMap (forEachLine True absoluteIndex stackSeriesConfigIndex) lineSeriesConfigs
        in 
        ( absoluteIndex + List.length lineItems
        , stackSeriesConfigIndex + 1
        , items ++ List.filterMap identity lineItems
        )

      forEachLine isStacked absoluteIndex stackSeriesConfigIndex lineSeriesConfigIndex lineSeriesConfig =
        let absoluteIndexNew = absoluteIndex + lineSeriesConfigIndex
            defaultColor = Helpers.toDefaultColor absoluteIndexNew
            defaultOpacity = if isStacked then 0.4 else 0

            interpolationAttrs = [ CA.color defaultColor, CA.opacity defaultOpacity ] 
            interpolationConfig = Helpers.apply (interpolationAttrs ++ lineSeriesConfig.interpolation) S.defaultInterpolation 

            dotItems = List.indexedMap (forEachDataPoint absoluteIndexNew stackSeriesConfigIndex lineSeriesConfigIndex lineSeriesConfig interpolationConfig defaultColor defaultOpacity) data
            
            viewSeries plane =
              let toBottom datum =
                    Maybe.map2 (\y ySum -> ySum - y) (lineSeriesConfig.toY datum) (lineSeriesConfig.toYSum datum)
              in
              S.g
                [ SA.class "elm-charts__series" ]
                [ S.area plane toX (Just toBottom) lineSeriesConfig.toYSum interpolationConfig data
                , S.interpolation plane toX lineSeriesConfig.toYSum interpolationConfig data
                , S.g [ SA.class "elm-charts__dots" ] (List.map (I.render plane) dotItems)
                ]
        in
        Helpers.withFirst dotItems <| \first rest ->
          I.Rendered ( first, rest )
            { render = \plane _ -> viewSeries plane
            , limits = Coord.foldPosition I.getLimits dotItems
            , toPosition = \plane -> Coord.foldPosition (I.getPosition plane) dotItems
            , tooltip = \() -> [ H.table [ HA.style "margin" "0" ] (List.concatMap I.tooltip dotItems) ]
            }
        
      forEachDataPoint absoluteIndex stackSeriesConfigIndex lineSeriesConfigIndex lineSeriesConfig interpolationConfig defaultColor defaultOpacity dataIndex datum =
        let identification =
              { stackIndex = stackSeriesConfigIndex -- The number this stack configuration is within the full list of stack configurations. If no stacks, this is equal to seriesIndex.
              , seriesIndex = lineSeriesConfigIndex -- The number this line configuration is within its stack. If no stacks, this is equal to stackIndex.
              , absoluteIndex = absoluteIndex       -- The number this line configuration is within the total set of line configurations. TODO FIX
              , dataIndex = dataIndex               -- The number this data point is within the list of data.
              , elementIndex = elementIndex
              }

            defaultAttrs = 
              [ CA.color interpolationConfig.color
              , CA.border interpolationConfig.color
              , if interpolationConfig.method == Nothing then CA.circle else Helpers.noChange
              ]

            dotAttrs = 
              defaultAttrs ++ 
              lineSeriesConfig.presentation ++ 
              lineSeriesConfig.variation identification datum

            dotConfig = 
              Helpers.apply dotAttrs S.defaultDot

            radius =
              Maybe.withDefault 0 <| Maybe.map (S.toRadius dotConfig.size) dotConfig.shape

            y = Maybe.withDefault 0 (lineSeriesConfig.toYSum datum)
            x = toX datum

            tooltipTextColor =
              if dotConfig.color == "white" then 
                if dotConfig.border == "white" then interpolationConfig.color else dotConfig.border
              else
                dotConfig.color
        in
        I.Rendered
          { presentation = dotConfig
          , color = tooltipTextColor
          , datum = datum
          , x1 = x
          , x2 = x
          , y = y
          , isReal = lineSeriesConfig.toY datum /= Nothing
          , identification = identification
          , name = lineSeriesConfig.tooltipName
          , tooltipText = lineSeriesConfig.tooltipText datum
          , toAny = I.Dot
          }
          { limits = 
              { x1 = x, x2 = x
              , y1 = y, y2 = y
              }

          , toPosition = \plane ->
              let radiusX = Coord.scaleCartesianX plane radius
                  radiusY = Coord.scaleCartesianY plane radius
              in
              { x1 = x - radiusX, x2 = x + radiusX
              , y1 = y - radiusY, y2 = y + radiusY
              }

          , render = \plane _ ->
              case lineSeriesConfig.toY datum of
                Nothing -> S.text ""
                Just _ -> S.dot plane .x .y dotConfig { x = x, y = y }
                
          , tooltip = \() -> 
              [ tooltipRow tooltipTextColor
                  (toDefaultName identification lineSeriesConfig.tooltipName) 
                  (lineSeriesConfig.tooltipText datum) 
              ]
          }
  in
  List.foldl forEachStackSeriesConfig ( elementIndex, 0, [] ) properties
    |> (\(_, _, items) -> items)



-- RENDER


tooltipRow : String -> String -> String -> H.Html msg
tooltipRow color title text =
  H.tr
    []
    [ H.td
        [ HA.style "color" color
        , HA.style "padding" "0"
        , HA.style "padding-right" "3px"
        ]
        [ H.text (title ++ ":") ]
    , H.td
        [ HA.style "text-align" "right"
        , HA.style "padding" "0"
        ]
        [ H.text text ]
    ]


toDefaultName : P.Identification -> Maybe String -> String
toDefaultName ids name =
  Maybe.withDefault ("Property #" ++ String.fromInt (ids.absoluteIndex + 1)) name
