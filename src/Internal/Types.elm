module Internal.Types
    exposing
        ( Point
        , Style
        , Orientation(..)
        , Scale
        , Meta
        , HintInfo
        , Anchor(..)
        , PileMeta
        , Axis
        , Edges
        , MaxWidth(..)
        , Value
        )


type alias Value =
    Float


type alias Point =
    ( Float, Float )


type alias Style =
    List ( String, String )


type Orientation
    = X
    | Y


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


type alias Axis a =
    { x : a
    , y : a
    }


type alias PileMeta =
    { lowest : Float
    , highest : Float
    , numOfBarSeries : Int
    , pointCount : Int
    , stackBy : Orientation
    }


type alias Meta =
    { scale : Scale
    , ticks : List Float
    , toSvgCoords : Point -> Point
    , fromSvgCoords : Point -> Point
    , oppositeTicks : List Float
    , oppositeScale : Scale
    , oppositeToSvgCoords : Point -> Point
    , axisCrossings : List Float
    , oppositeAxisCrossings : List Float
    , getHintInfo : Float -> HintInfo
    , pileMetas : List PileMeta
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
