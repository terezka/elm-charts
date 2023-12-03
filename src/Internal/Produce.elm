module Internal.Produce exposing (..)

import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Internal.Coordinates as Coord exposing (Point, Position, Plane)
import Dict exposing (Dict)
import Internal.Property as P exposing (Property)
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


toBarSeries : Int -> List (CA.Attribute (Bars data)) -> List (Property data String () S.Bar) -> List data -> List (M.Many (I.One data S.Bar))
toBarSeries elIndex barsAttrs properties data =
  let barsConfig =
        Helpers.apply barsAttrs defaultBars

      toBarConfig attrs =
        Helpers.apply attrs S.defaultBar

      forEachStack : List { datum : data, start : Float, end : Float } -> List (P.Config data String () S.Bar) -> ( Int, Int, List )


      toSeriesItem : List { datum : data, start : Float, end : Float } -> List (P.Config data String () S.Bar) -> Int -> Int -> P.Config data String () S.Bar -> Int -> Maybe (M.Many (I.One data S.Bar))
      toSeriesItem bins sections barIndex sectionIndex section colorIndex =
        case List.indexedMap (toBarItem sections barIndex sectionIndex section colorIndex) bins of
          [] ->
            Nothing

          first :: rest ->
            Just <| I.Rendered
              { config = { items = ( first, rest ) }
              , toLimits = \c -> Coord.foldPosition I.getLimits ((\(x, xs) -> x :: xs) c.items)
              , toPosition = \plane c -> Coord.foldPosition (I.getPosition plane) ((\(x, xs) -> x :: xs) c.items)
              , toSvg = \plane c _ -> S.g [ SA.class "elm-charts__bar-series" ] (List.map (I.toSvg plane) ((\(x, xs) -> x :: xs) c.items))
              , toHtml = \c -> [ H.table [ HA.style "margin" "0" ] (List.concatMap I.toHtml ((\(x, xs) -> x :: xs) c.items)) ]
              }

      toBarItem : List (P.Config data String () S.Bar) -> Int -> Int -> P.Config data String () S.Bar -> Int -> Int -> { datum : data, start : Float, end : Float } -> I.One data S.Bar
      toBarItem sections barIndex sectionIndex section colorIndex dataIndex bin =
        let numOfBars = if barsConfig.grouped then toFloat (List.length properties) else 1
            numOfSections = toFloat (List.length sections)

            start = bin.start
            end = bin.end
            visual = section.visual bin.datum
            value = section.value bin.datum

            length = end - start
            margin = length * barsConfig.margin
            spacing = length * barsConfig.spacing
            width = (length - margin * 2 - (numOfBars - 1) * spacing) / numOfBars
            offset = if barsConfig.grouped then toFloat barIndex * width + toFloat barIndex * spacing else 0

            x1 = start + margin + offset
            x2 = start + margin + offset + width
            minY = if numOfSections > 1 then max 0 else identity
            y1 = minY <| Maybe.withDefault 0 visual - Maybe.withDefault 0 value
            y2 = minY <| Maybe.withDefault 0 visual

            isFirst = sectionIndex == 0
            isLast = toFloat sectionIndex == numOfSections - 1
            isSingle = numOfSections == 1

            roundTop = if isSingle || isLast then barsConfig.roundTop else 0
            roundBottom = if isSingle || isFirst then barsConfig.roundBottom else 0

            defaultColor = Helpers.toDefaultColor colorIndex
            defaultAttrs = [ CA.roundTop roundTop, CA.roundBottom roundBottom, CA.color defaultColor, CA.border defaultColor ]
            attrs = defaultAttrs ++ section.attrs ++ section.extra barIndex sectionIndex dataIndex section.meta bin.datum
            productOrg = toBarConfig attrs
            product =
              productOrg
                |> (\p ->
                     case p.design of
                      Just (S.Gradient (color :: _)) -> if p.color == defaultColor then { p | color = color } else p
                      _ -> p)
                |> (\p -> if p.border == defaultColor then { p | border = p.color } else p)
        in
        I.Rendered
          { config =
              { product = product
              , values =
                  { datum = bin.datum
                  , x1 = start
                  , x2 = end
                  , y = Maybe.withDefault 0 value
                  , isReal =
                      case value of
                        Just _ -> True
                        Nothing -> False
                  }
              , tooltipInfo =
                  { property = barIndex
                  , stack = sectionIndex
                  , data = dataIndex
                  , index = colorIndex
                  , elIndex = elIndex
                  , name = section.meta
                  , color = product.color
                  , border = product.border
                  , borderWidth = product.borderWidth
                  , formatted = section.format bin.datum
                  }
              , toAny = I.Bar
              }
          , toLimits = \config -> { x1 = x1, x2 = x2, y1 = min y1 y2, y2 = max y1 y2 }
          , toPosition = \_ config -> { x1 = x1, x2 = x2, y1 = y1, y2 = y2 }
          , toSvg = \plane config position -> S.bar plane product position
          , toHtml = \c -> [ tooltipRow c.tooltipInfo.color (toDefaultName colorIndex c.tooltipInfo.name) (section.format bin.datum) ]
          }
  in
  Helpers.withSurround data (toBin barsConfig) |> \bins ->
    List.foldl forEachStack ( 0, 0, [] ) properties

    List.map P.toConfigs properties
      |> List.indexedMap (\barIndex stacks -> List.indexedMap (toSeriesItem bins stacks barIndex) (List.reverse stacks))
      |> List.concat
      |> List.indexedMap (\propIndex f -> f (elIndex + propIndex))
      |> List.filterMap identity


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



-- SERIES


{-| -}
toDotSeries : Int -> (data -> Float) -> List (Property data String S.Interpolation S.Dot) -> List data -> List (M.Many (I.One data S.Dot))
toDotSeries elIndex toX properties data =
  let forEachStack property ( absoluteIndex, stackIndex, items ) =
        let lineItems =
              case property of 
                NotStacked lineConfig ->
                  forEachLine False absoluteIndex stackIndex 0 lineConfig

                Stacked lineConfigs ->
                  List.indexedMap (forEachLine True absoluteIndex stackIndex) lineConfigs
        in 
        ( absoluteIndex + List.length lineConfigs
        , stackIndex + 1
        , items ++ lineItems
        )

      forEachLine isStacked absoluteIndex stackIndex seriesIndex lineConfig =
        let defaultColor = Helpers.toDefaultColor absoluteIndex
            defaultOpacity = if isStacked then 0.4 else 0

            interpolationAttrs = [ CA.color defaultColor, CA.opacity defaultOpacity ] 
            interpolationConfig = Helpers.apply (interpolationAttrs ++ lineConfig.interpolation) S.defaultInterpolation 

            dotItems = List.indexedMap (forEachDataPoint absoluteIndex stackIndex seriesIndex lineConfig interpolationConfig defaultColor defaultOpacity) data
            
            viewSeries plane =
              let toBottom datum =
                    Maybe.map2 (\y ySum -> ySum - y) (lineConfig.toY datum) (lineConfig.toYSum datum)
              in
              S.g
                [ SA.class "elm-charts__series" ]
                [ S.area plane toX (Just toBottom) lineConfig.toYSum interpolationConfig data
                , S.interpolation plane toX lineConfig.toYSum interpolationConfig data
                , S.g [ SA.class "elm-charts__dots" ] (List.map (I.toSvg plane) dotItems)
                ]
        in
        Helpers.withFirst dotItems <| \first rest ->
          I.Rendered
            { config = { items = ( first, rest ) }
            , toSvg = \plane _ _ -> viewSeries plane
            , toLimits = \c -> Coord.foldPosition I.getLimits ((\(x, xs) -> x :: xs) c.items)
            , toPosition = \plane c -> Coord.foldPosition (I.getPosition plane) ((\(x, xs) -> x :: xs) c.items)
            , toHtml = \c -> [ H.table [ HA.style "margin" "0" ] (List.concatMap I.toHtml ((\(x, xs) -> x :: xs) c.items)) ]
            }
        
      forEachDataPoint absoluteIndex stackIndex seriesIndex lineConfig interpolationConfig defaultColor defaultOpacity dataIndex datum =
        let identification =
              { stackIndex = stackIndex
              , seriesIndex = seriesIndex
              , absoluteIndex = absoluteIndex
              , dataIndex = dataIndex
              }

            defaultAttrs = 
              [ CA.color defaultColor
              , CA.border defaultColor
              , if interpolationConfig.method == Nothing then CA.circle else identity 
              ]

            dotAttrs = 
              defaultAttrs ++ 
              lineConfig.decoration ++ 
              lineConfig.variation identification datum

            dotConfig = 
              Helpers.apply dotAttrs S.defaultDot 

            radius =
              Maybe.withDefault 0 <| Maybe.map (S.toRadius config.size) config.shape

            y = Maybe.withDefault 0 (lineConfig.toYSum datum)
            x = toX datum

            limits =
              { x1 = x, x2 = x
              , y1 = y, y2 = y 
              }
        in
        I.Rendered
          { toSvg = \plane _ _ ->
              case lineConfig.toY datum of
                Nothing -> S.text ""
                Just _ -> S.dot plane .x .y dotConfig { x = x, y = y }

          , toHtml = \c -> 
              [ tooltipRow c.tooltipInfo.color (toDefaultName colorIndex c.tooltipInfo.name) (prop.format datum) ]

          , toLimits = \_ -> limits

          , toPosition = \plane _ ->
              let radiusX = Coord.scaleCartesianX plane radius
                  radiusY = Coord.scaleCartesianY plane radius
              in
              { x1 = x - radiusX, x2 = x + radiusX
              , y1 = y - radiusY, y2 = y + radiusY
              }

          , config =
              { product = config
              , values =
                  { datum = datum
                  , x1 = x
                  , x2 = x
                  , y = y
                  , isReal = lineConfig.toY datum /= Nothing
                  }
              , tooltipInfo =
                  { property = identification.stackIndex
                  , stack = identification.seriesIndex
                  , data = identification.dataIndex
                  , index = identification.absoluteIndex
                  , elIndex = elIndex
                  , name = lineConfig.tooltipName
                  , color =
                      case lineConfig.color of
                        "white" -> interpolationConfig.color
                        _       -> lineConfig.color
                  , border = lineConfig.border
                  , borderWidth = lineConfig.borderWidth
                  , formatted = lineConfig.tooltipText datum
                  }
              , toAny = I.Dot
              }
          }
  in
  List.foldl forEachStack ( 0, 0, [] ) properties



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


toDefaultName : Int -> Maybe String -> String
toDefaultName index name =
  Maybe.withDefault ("Property #" ++ String.fromInt (index + 1)) name
