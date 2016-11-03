module GridChart exposing (gridChart)

import Svg
import Svg.Attributes
import Plot exposing (..)


data : List ( Float, Float )
data =
    [ ( 0, 8 ), ( 1, 13 ), ( 2, 14 ), ( 3, 12 ), ( 4, 11 ), ( 5, 16 ), ( 6, 22 ), ( 7, 32 ), ( 8, 31 ), ( 9, 37 ), ( 10, 42 ) ]


gridChart : Svg.Svg a
gridChart =
    plot
        { meta = [ size ( 600, 250 ) ]
        , xGrid = [ gridAutoValues ]
        , yGrid = []
        , xTicks = [ autoTickValues, tickValues [], tickSequence (0, 0.25), tickStyle (2, 4, []), tickCustomView view ]
        , yTicks = [ autoTickValues, tickValues [], tickSequence (0, 0.25), tickStyle (2, 4, []), tickCustomView view ]
        , series = [ line [ lineStyle [ ( "stroke", "#b6c9ef" ), ( "stroke-width", "2px" ) ] ] data ]
        }