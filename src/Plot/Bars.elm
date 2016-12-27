module Plot.Bars
    exposing
        ( Attribute
        , StyleAttribute
        , DataTransformers
        , Data
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
            [ Bars.maxBarWidthPer 85 ]
            [ [ Bars.fill "blue", Bars.opacity 0.5 ]
            , [ Bars.fill "red" ]
            ]
            [ [ 1, 4 ]
            , [ 2, 1 ]
            , [ 4, 5 ]
            , [ 4, 5 ]
            ]

# Definition
@docs Attribute, StyleAttribute, Data, DataTransformers

# Overall styling
@docs stackByY, maxBarWidth, maxBarWidthPer, label

# Individual bar styling
@docs fill, opacity, customAttrs

# General
@docs toBarData

-}

import Svg
import Internal.Bars as Internal
import Internal.Types exposing (Style, Point, Orientation(..), MaxWidth(..), Value)


{-| -}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| -}
type alias StyleAttribute msg =
    Internal.StyleConfig msg -> Internal.StyleConfig msg


{-| -}
type alias Data =
    Internal.Group


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


{-| Use your own view for your label on top of bar. Will be passed the y value as an argument!

    myBarSeries : Pile.Element msg
    myBarSeries =
      Pile.bars
          [ Bars.label (\_ _ -> Svg.text_ [] [ Svg.text "my bar" ])
          ]
          data
-}
label : (Int -> Float -> Svg.Svg a) -> Attribute a
label view config =
    { config | labelView = view }


{-| -}
stackByY : Attribute a
stackByY config =
    { config | stackBy = Y }



-- STYLES


{-| Set the fill color.
-}
fill : String -> StyleAttribute a
fill fill config =
    { config | style = ( "fill", fill ) :: config.style }


{-| Set the opacity.
-}
opacity : Float -> StyleAttribute a
opacity opacity config =
    { config | style = ( "opacity", toString opacity ) :: config.style }


{-| Add your own attributes. For events, see [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm)
-}
customAttrs : List (Svg.Attribute a) -> StyleAttribute a
customAttrs attrs config =
    { config | customAttrs = attrs }


{-| -}
type alias DataTransformers data =
    { yValues : data -> List Value
    , xValue : Maybe (data -> Value)
    }


{-| -}
toBarData : DataTransformers data -> List data -> List ( Value, List Value )
toBarData transform allData =
    List.indexedMap (\index data -> ( getXValue transform index data, transform.yValues data )) allData


getXValue : DataTransformers data -> Int -> data -> Value
getXValue { xValue } index data =
    case xValue of
        Just getXValue ->
            getXValue data

        Nothing ->
            toFloat index
