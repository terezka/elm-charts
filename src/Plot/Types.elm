module Plot.Types exposing (Point, Style, Orientation(..), AxisScale, PlotProps, TooltipInfo)

{-| Convinience type to represent coordinates.
-}
type alias Point =
    ( Float, Float )


{-| Convinience type to represent style.
-}
type alias Style =
    List ( String, String )


type Orientation
    = X
    | Y


type alias AxisScale =
    { range : Float
    , lowest : Float
    , highest : Float
    , length : Float
    , offset : Float
    }


type alias PlotProps =
    { scale : AxisScale
    , oppositeScale : AxisScale
    , toSvgCoords : Point -> Point
    , oppositeToSvgCoords : Point -> Point
    , fromSvgCoords : Point -> Point
    , ticks : List Float
    , oppositeTicks : List Float
    , getTooltipInfo : Float -> TooltipInfo
    , toNearestX : Float -> Float
    , id : String
    }


type alias TooltipInfo =
    { xValue : Float
    , yValues : List (Maybe Float)
    }
