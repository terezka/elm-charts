module Plot.Types exposing (Point, Style, Orientation(..), Scale, Meta, TooltipInfo)


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


type alias Meta =
    { scale : Scale
    , ticks : List Float
    , toSvgCoords : Point -> Point
    , fromSvgCoords : Point -> Point
    , oppositeTicks : List Float
    , oppositeScale : Scale
    , oppositeToSvgCoords : Point -> Point
    , getTooltipInfo : Float -> TooltipInfo
    , toNearestX : Float -> Float
    , id : String
    }


type alias Scale =
    { range : Float
    , lowest : Float
    , highest : Float
    , length : Float
    , offset : Float
    }


type alias TooltipInfo =
    { xValue : Float
    , yValues : List (Maybe Float)
    }
