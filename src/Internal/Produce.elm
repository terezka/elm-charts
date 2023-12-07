module Internal.Produce exposing (..)

import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Internal.Coordinates as Coord exposing (Point, Position, Limits, Plane)
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


toBarSeries : Int -> List (CA.Attribute (Bars data)) -> List (Property data () S.Bar) -> List data -> ( Int, List Limits, Plane -> Plane -> List (M.Many (I.One data I.Any)) )
toBarSeries elementIndex barsAttrs properties data =
  let barsConfig = Helpers.apply barsAttrs defaultBars
      numOfStacks = if barsConfig.grouped then toFloat (List.length properties) else 1

      forEachStackSeriesConfig bins stackSeriesConfig ( absoluteIndex, stackSeriesConfigIndex, (limits, items) ) =
        let ( newLimits, seriesItems ) =
              List.unzip <|
                case stackSeriesConfig of 
                  NotStacked barSeriesConfig ->
                    [ forEachBarSeriesConfig bins absoluteIndex stackSeriesConfigIndex 1 0 barSeriesConfig ]

                  Stacked barSeriesConfigs ->
                    let numOfBarsInStack = List.length barSeriesConfigs in
                    List.indexedMap (forEachBarSeriesConfig bins absoluteIndex stackSeriesConfigIndex numOfBarsInStack) barSeriesConfigs
        in 
        ( absoluteIndex + List.length seriesItems
        , stackSeriesConfigIndex + 1
        , ( limits ++ List.concat newLimits
          , \topLevel localPlane -> items topLevel localPlane ++ List.filterMap identity (List.map (\i -> i topLevel localPlane) seriesItems)
          )
        )

      forEachBarSeriesConfig bins absoluteIndex stackSeriesConfigIndex numOfBarsInStack barSeriesConfigIndex barSeriesConfig =
        let absoluteIndexNew = absoluteIndex + barSeriesConfigIndex
            (limits, toBarItems) = List.unzip <| List.indexedMap (forEachDataPoint absoluteIndexNew stackSeriesConfigIndex barSeriesConfigIndex numOfBarsInStack barSeriesConfig) bins 
        in
        ( limits
        , \topLevel localPlane -> 
            let barItems = List.map (\i -> i topLevel localPlane) toBarItems in
            Helpers.withFirst barItems <| \first rest ->
              let groupLimits = Coord.foldPosition I.getLimits barItems
                  groupPosition = Coord.foldPosition I.getPosition barItems
              in
              I.Rendered ( first, rest )
                { limits = groupLimits
                , position = groupPosition
                , localPlane = localPlane
                , limitsTop = Coord.convertPos topLevel localPlane groupLimits
                , positionTop = Coord.convertPos topLevel localPlane groupPosition
                , planeTop = topLevel
                , render = \() -> S.g [ SA.class "elm-charts__series" ] (List.map I.render barItems)
                , tooltip = \() -> [ H.table [ HA.style "margin" "0" ] (List.concatMap I.tooltip barItems) ]
                }
        )

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

            limits =
              { x1 = start, x2 = end, y1 = min y1 y2, y2 = max y1 y2 }

            position =
              { x1 = x1, x2 = x2, y1 = y1, y2 = y2 }
        in
        ( limits 
        , \topLevel localPlane -> 
            I.Rendered
              { presentation = I.Bar barPresentationConfig
              , color = barPresentationConfig.color
              , datum = bin.datum
              , x1 = start
              , x2 = end
              , y = Maybe.withDefault 0 y
              , isReal = y /= Nothing
              , identification = identification
              , name = barSeriesConfig.tooltipName
              , tooltipText = barSeriesConfig.tooltipText bin.datum
              , toAny = identity
              }
              { limits = limits
              , position = position
              , localPlane = localPlane
              , limitsTop = Coord.convertPos topLevel localPlane limits
              , positionTop = Coord.convertPos topLevel localPlane position
              , planeTop = topLevel
              , render = \() -> 
                  S.bar localPlane barPresentationConfig position
              , tooltip = \() -> 
                  [ tooltipRow 
                      barPresentationConfig.color 
                      (toDefaultName identification barSeriesConfig.tooltipName) 
                      (barSeriesConfig.tooltipText bin.datum) 
                  ]
              }
        )
        
  in
  Helpers.withSurround data (toBin barsConfig) |> \bins ->
    List.foldl (forEachStackSeriesConfig bins) ( elementIndex, 0, ([], \_ _ -> []) ) properties
    |> (\(newElementIndex, _, (limits,items)) -> ( newElementIndex, limits, items ) )


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
toDotSeries : Int -> (data -> Float) -> List (Property data S.Interpolation S.Dot) -> List data -> ( Int, List Limits, Plane -> Plane -> List (M.Many (I.One data I.Any)) )
toDotSeries elementIndex toX properties data =
  let forEachStackSeriesConfig stackSeriesConfig ( absoluteIndex, stackSeriesConfigIndex, ( limits, items ) ) =
        let ( newLimits, lineItems ) =
              List.unzip <|
                case stackSeriesConfig of 
                  NotStacked lineSeriesConfig ->
                    [ forEachLine False absoluteIndex stackSeriesConfigIndex 0 lineSeriesConfig ]

                  Stacked lineSeriesConfigs ->
                    List.indexedMap (forEachLine True absoluteIndex stackSeriesConfigIndex) lineSeriesConfigs
        in 
        ( absoluteIndex + List.length lineItems
        , stackSeriesConfigIndex + 1
        , ( limits ++ List.concat newLimits
          , \topLevel localPlane -> items topLevel localPlane ++ List.filterMap identity (List.map (\i -> i topLevel localPlane) lineItems)
          )
        )

      forEachLine isStacked absoluteIndex stackSeriesConfigIndex lineSeriesConfigIndex lineSeriesConfig =
        let absoluteIndexNew = absoluteIndex + lineSeriesConfigIndex
            defaultColor = Helpers.toDefaultColor absoluteIndexNew
            defaultOpacity = if isStacked then 0.4 else 0

            interpolationAttrs = [ CA.color defaultColor, CA.opacity defaultOpacity ] 
            interpolationConfig = Helpers.apply (interpolationAttrs ++ lineSeriesConfig.interpolation) S.defaultInterpolation 

            (limits, toDotItems) = List.unzip <| List.indexedMap (forEachDataPoint absoluteIndexNew stackSeriesConfigIndex lineSeriesConfigIndex lineSeriesConfig interpolationConfig defaultColor defaultOpacity) data
            
            viewSeries plane dotItems =
              let toBottom datum =
                    Maybe.map2 (\y ySum -> ySum - y) (lineSeriesConfig.toY datum) (lineSeriesConfig.toYSum datum)
              in
              S.g
                [ SA.class "elm-charts__series" ]
                [ S.area plane toX (Just toBottom) lineSeriesConfig.toYSum interpolationConfig data
                , S.interpolation plane toX lineSeriesConfig.toYSum interpolationConfig data
                , S.g [ SA.class "elm-charts__dots" ] (List.map I.render dotItems)
                ]
        in
        ( limits
        , \topLevel localPlane ->
            let dotItems = List.map (\i -> i topLevel localPlane) toDotItems in
            Helpers.withFirst dotItems <| \first rest ->
              let groupLimits = Coord.foldPosition I.getLimits dotItems
                  groupPosition = Coord.foldPosition I.getPosition dotItems
              in
              I.Rendered ( first, rest )
                { limits = groupLimits
                , position = groupPosition
                , localPlane = localPlane
                , limitsTop = Coord.convertPos topLevel localPlane groupLimits
                , positionTop = Coord.convertPos topLevel localPlane groupPosition
                , planeTop = topLevel
                , render = \() -> viewSeries localPlane dotItems
                , tooltip = \() -> [ H.table [ HA.style "margin" "0" ] (List.concatMap I.tooltip dotItems) ]
                }
        )
        
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

            limits =
              { x1 = x, x2 = x
              , y1 = y, y2 = y
              }
        in
        ( limits
        , \topLevel localPlane ->
            let radiusX = Coord.scaleCartesianX localPlane radius
                radiusY = Coord.scaleCartesianY localPlane radius
                position =
                  { x1 = x - radiusX, x2 = x + radiusX
                  , y1 = y - radiusY, y2 = y + radiusY
                  }
            in
            I.Rendered
              { presentation = I.Dot dotConfig
              , color = tooltipTextColor
              , datum = datum
              , x1 = x
              , x2 = x
              , y = y
              , isReal = lineSeriesConfig.toY datum /= Nothing
              , identification = identification
              , name = lineSeriesConfig.tooltipName
              , tooltipText = lineSeriesConfig.tooltipText datum
              , toAny = identity
              }
              { limits = limits
              , position = position
              , localPlane = localPlane

              , limitsTop = Coord.convertPos topLevel localPlane limits
              , positionTop = Coord.convertPos topLevel localPlane position
              , planeTop = topLevel
              , render = \() ->
                  case lineSeriesConfig.toY datum of
                    Nothing -> S.text ""
                    Just _ -> S.dot localPlane .x .y dotConfig (Point x y)
                    
              , tooltip = \() -> 
                  [ tooltipRow tooltipTextColor
                      (toDefaultName identification lineSeriesConfig.tooltipName) 
                      (lineSeriesConfig.tooltipText datum) 
                  ]
              }
        )
  in
  List.foldl forEachStackSeriesConfig ( elementIndex, 0, ([],\_ _ -> []) ) properties
    |> (\(newElementIndex, _, (limits,items)) -> ( newElementIndex, limits, items))



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
