module Internal.Types exposing (Point, Style, Orientation(..), Scale, Meta, HintInfo)


type alias Point =
    ( Float, Float )


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
    , getHintInfo : Float -> HintInfo
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


type alias HintInfo =
    { xValue : Float
    , yValues : List (Maybe Float)
    }