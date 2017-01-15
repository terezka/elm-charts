module Plot.Bars
    exposing
        ( Attribute
        , StyleAttribute
        , DataTransformers
        , Data
        , LabelInfo
        , stackByY
        , maxBarWidth
        , maxBarWidthPer
        , label
        , fill
        , opacity
        , customAttrs
        , toBarData
        )

{-|
  Attributes to alter the view of the bars.

    myBarsSerie : Plot.Element (Interaction YourMsg)
    myBarsSerie =
        bars
            [ Bars.maxBarWidthPer 85
            , Bars.stackByY
            , Bars.label
                [ Label.formatFromList [ "A", "B", "C" ] ]
            ]
            [ [ Bars.fill "blue", Bars.opacity 0.5 ]
            , [ Bars.fill "red" ]
            ]
            (Bars.toBarData
                { yValues = .revenueByYear
                , xValue = Just .quarter
                }
                [ { quarter = 1, revenueByYear = [ 10000, 30000, 20000 ] }
                , { quarter = 2, revenueByYear = [ 20000, 10000, 40000 ] }
                , { quarter = 3, revenueByYear = [ 40000, 20000, 10000 ] }
                , { quarter = 4, revenueByYear = [ 40000, 50000, 20000 ] }
                ]
            )

# Definition
@docs Attribute

# Attributes
@docs maxBarWidth, maxBarWidthPer, stackByY

## Labels
@docs LabelInfo, label

# Individual bar attributes
  These are the attributes which can be passed in the list of bar styles in the
  second argument of your series.

    myBarsSerie : Plot.Element msg
    myBarsSerie =
        bars
            []
            [ [ Bars.fill "blue", Bars.opacity 0.5 ]
            , [ Bars.fill "red" ]
            ]
            data

@docs StyleAttribute, fill, opacity, customAttrs

# Custom data
@docs Data, DataTransformers, toBarData

-}

import Svg
import Plot.Types exposing (Style, Point)
import Internal.Types exposing (Orientation(..), MaxWidth(..), Value, IndexedInfo)
import Internal.Bars as Internal
import Internal.Label as LabelInternal
import Plot.Label as Label


{-| -}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| -}
type alias StyleAttribute msg =
    Internal.StyleConfig msg -> Internal.StyleConfig msg


{-| The data format the bars element requires.
-}
type alias Data =
    Internal.Group


{-| The info your label format option will be passed.
-}
type alias LabelInfo =
    { index : Int
    , xValue : Value
    , yValue : Value
    }


{-| Set a fixed max width (in pixels) on your bars.
-}
maxBarWidth : Int -> Attribute msg
maxBarWidth max config =
    { config | maxWidth = Fixed max }


{-| Set a relative max width (in percentage) your bars.
-}
maxBarWidthPer : Int -> Attribute msg
maxBarWidthPer max config =
    { config | maxWidth = Percentage max }


{-| Alter the view of your label.

    myBarSeries : Plot.Element msg
    myBarSeries =
      bars
          [ Bars.label
              [ Label.classes [ "label-class" ]
              , Label.displace ( 12, 0 )
              ]
          ]
          barStyles
          data
-}
label : List (Label.Attribute LabelInfo msg) -> Attribute msg
label attributes config =
    { config | labelConfig = List.foldl (<|) LabelInternal.defaultConfig attributes }


{-| By default your bars are stacked by x. If you want to stack them y, add this attribute.
-}
stackByY : Attribute msg
stackByY config =
    { config | stackBy = Y }



-- STYLES


{-| Set the fill color.
-}
fill : String -> StyleAttribute msg
fill fill config =
    { config | style = ( "fill", fill ) :: config.style }


{-| Set the opacity.
-}
opacity : Float -> StyleAttribute msg
opacity opacity config =
    { config | style = ( "opacity", toString opacity ) :: config.style }


{-| Add your own attributes. For events, see [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm)
-}
customAttrs : List (Svg.Attribute msg) -> StyleAttribute msg
customAttrs attrs config =
    { config | customAttrs = attrs }


{-| The functions necessary to transform your data into the format the plot requires.
 If you provide the `xValue` with `Nothing`, the bars xValues will just be the index
 of the bar in the list.
-}
type alias DataTransformers data =
    { yValues : data -> List Value
    , xValue : Maybe (data -> Value)
    }


{-| This function can be used to transform your own data format
 into something the plot can understand.

    Bars.toBarData
        { yValues = .revenueByYear
        , xValue = Just .quarter
        }
        [ { quarter = 1, revenueByYear = [ 10000, 30000, 20000 ] }
        , { quarter = 2, revenueByYear = [ 20000, 10000, 40000 ] }
        , { quarter = 3, revenueByYear = [ 40000, 20000, 10000 ] }
        , { quarter = 4, revenueByYear = [ 40000, 50000, 20000 ] }
        ]
-}
toBarData : DataTransformers data -> List data -> List Data
toBarData transform allData =
    List.indexedMap
        (\index data ->
            { xValue = getXValue transform index data
            , yValues = transform.yValues data
            }
        )
        allData


getXValue : DataTransformers data -> Int -> data -> Value
getXValue { xValue } index data =
    case xValue of
        Just getXValue ->
            getXValue data

        Nothing ->
            toFloat index + 1
