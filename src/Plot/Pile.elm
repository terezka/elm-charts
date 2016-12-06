module Plot.Pile exposing (..)

{-|
 Attributes for altering the view of your area serie.

    myAreaSerie : Plot.Element (Interaction YourMsg)
    myAreaSerie =
        line
            [ stroke "deeppink"
            , strokeWidth 2
            , fill "red"
            , opacity 0.5
            , customAttrs
                [ Svg.Events.onClick <| Custom MyClickMsg
                , Svg.Events.onMouseOver <| Custom Glow
                ]
            ]
            areaDataPoints

# Definition
@docs Attribute

# Styling
@docs stroke, strokeWidth, opacity, fill, barsMaxWidth

# Other
@docs customAttrs

-}

import Svg
import Plot.Bars as Bars
import Internal.Bars as BarsInternal
import Internal.Pile as Internal
import Internal.Types exposing (Style, Point, Orientation(..), MaxWidth(..))


{-| -}
type alias Attribute =
    Internal.Config -> Internal.Config


type alias Element msg =
    Internal.Element msg


{-| Set the stacking by.
-}
stackByY : Attribute
stackByY config =
    { config | stackBy = Y }


{-| Set a fixed max width (in pixels) on your bars.
-}
maxBarWidth : Int -> Attribute
maxBarWidth max config =
    { config | maxWidth = Fixed max }


{-| Set a relative max width (in percentage) your bars.
-}
maxBarWidthPer : Int -> Attribute
maxBarWidthPer max config =
    { config | maxWidth = Percentage max }


{-| Add a barchart.
-}
bars : List (Bars.Attribute msg) -> List Point -> Element msg
bars attrs points =
    Internal.Bars (List.foldr (<|) BarsInternal.defaultConfig attrs) points
