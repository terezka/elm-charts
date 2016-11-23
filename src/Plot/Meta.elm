module Plot.Meta exposing (..)

import Plot.Types exposing (..)

--## Meta configuration
--@docs MetaAttr, plotSize, plotPadding, plotMargin, plotClasses, plotStyle


type alias Config =
    { size : ( Float, Float )
    , padding : ( Float, Float )
    , margin : ( Float, Float, Float, Float )
    , classes : List String
    , style : Style
    , id : String
    }


{-| The type representing an a meta configuration.
-}
type alias Attribute =
    Config -> Config



{-| Add padding to your plot, meaning extra space below
 and above the lowest and highest point in your plot.
 The unit is pixels.

 Default: `( 0, 0 )`
-}
padding : ( Int, Int ) -> Attribute
padding ( bottom, top ) config =
    { config | padding = ( toFloat bottom, toFloat top ) }


{-| Specify the size of your plot in pixels.

 Default: `( 800, 500 )`
-}
size : ( Int, Int ) -> Attribute
size ( width, height ) config =
    { config | size = ( toFloat width, toFloat height ) }


{-| Specify margin around the plot. Useful when your ticks are outside the
 plot and you would like to add space to see them! Values are in pixels and
 in the format of ( top, right, bottom, left ).

 Default: `( 0, 0, 0, 0 )`
-}
margin : ( Int, Int, Int, Int ) -> Attribute
margin ( t, r, b, l ) config =
    { config | margin = ( toFloat t, toFloat r, toFloat b, toFloat l ) }


{-| Add styles to the svg element.

 Default: `[ ( "padding", "30px" ), ( "stroke", "#000" ) ]`
-}
style : Style -> Attribute
style style config =
    { config | style = defaultConfig.style ++ style ++ [ ( "padding", "0" ) ] }


{-| Add classes to the svg element.

 Default: `[]`
-}
classes : List String -> Attribute
classes classes config =
    { config | classes = classes }


toConfig : List Attribute -> Config
toConfig attrs =
    List.foldr (<|) defaultConfig attrs


defaultConfig : Config
defaultConfig =
    { size = ( 800, 500 )
    , padding = ( 0, 0 )
    , margin = ( 0, 0, 0, 0 )
    , classes = []
    , style = [ ( "padding", "0" ), ( "stroke", "#000" ) ]
    , id = "elm-plot"
    }
