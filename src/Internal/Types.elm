module Internal.Types
    exposing
        ( Orientation(..)
        , Scale
        , Meta
        , Anchor(..)
        , Oriented
        , Edges
        , MaxWidth(..)
        , Value
        , EdgesAny
        , IndexedInfo
        , Smoothing(..)
        , Style
        , Point
        , HintInfo
        )

{-| Convenience type to represent coordinates.
-}


type alias Point =
    ( Float, Float )


{-| Convenience type to represent style.
-}
type alias Style =
    List ( String, String )


type alias Value =
    Float


type alias IndexedInfo a =
    { a | index : Int, value : Float }


type Orientation
    = X
    | Y


type Smoothing
    = None
    | Bezier


type Anchor
    = Inner
    | Outer


type MaxWidth
    = Fixed Int
    | Percentage Int


type alias Edges =
    { lower : Float
    , upper : Float
    }


type alias EdgesAny a =
    { lower : a
    , upper : a
    }


type alias Oriented a =
    { x : a
    , y : a
    }


type alias Meta =
    { scale : Oriented Scale
    , ticks : List Float
    , toSvgCoords : Point -> Point
    , fromSvgCoords : Point -> Point
    , oppositeTicks : List Float
    , oppositeToSvgCoords : Point -> Point
    , axisCrossings : List Float
    , oppositeAxisCrossings : List Float
    , getHintInfo : Float -> HintInfo
    , toNearestX : Float -> Maybe Float
    , id : String
    }


type alias Scale =
    { range : Float
    , lowest : Float
    , highest : Float
    , length : Float
    , offset : Edges
    }


type alias HintInfo =
    { xValue : Float
    , yValues : List (Maybe (List Value))
    }
