module Plot.Bars exposing (..)

{-|
 The `pile` groups your bar series together and you can also
 add some attributes to alter the view of the bars.

    myBarsSerie : Plot.Element (Interaction YourMsg)
    myBarsSerie =
        pile
            [ Pile.maxBarWidthPer 85 ]
            [ Pile.bars
                [ Bars.fill Common.pinkFill ]
                data
            ]

# Definition
@docs Attribute, StyleAttribute

# Styling
@docs maxBarWidth, maxBarWidthPer, fill, label, opacity, view, customAttrs


-}

import Svg
import Internal.Bars as Internal
import Internal.Types exposing (Style, Point, Orientation(..), MaxWidth(..))


{-| -}
type alias Attribute msg =
    Internal.Config msg -> Internal.Config msg


{-| -}
type alias StyleAttribute msg =
    Internal.StyleConfig msg -> Internal.StyleConfig msg


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



-- STYLES


{-| Add a bar serie styles.
-}
view : List (StyleAttribute msg) -> Internal.StyleConfig msg
view attrs =
    List.foldr (<|) Internal.defaultStyleConfig attrs


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


{-| Use your own view for your label on top of bar. Will be passed the y value as an argument!

    myBarSeries : Pile.Element msg
    myBarSeries =
      Pile.bars
          [ Bars.label (\_ -> Svg.text_ [] [ Svg.text "my bar" ])
          ]
          data
-}
label : (Float -> Float -> Svg.Svg a) -> Attribute a
label view config =
    { config | labelView = view }


{-| Add your own attributes. For events, see [this example](https://github.com/terezka/elm-plot/blob/master/examples/Interactive.elm)
-}
customAttrs : List (Svg.Attribute a) -> StyleAttribute a
customAttrs attrs config =
    { config | customAttrs = attrs }
