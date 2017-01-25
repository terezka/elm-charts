module Plot.Types
    exposing
        ( Point
        , Style
        , HintInfo
        , Value
        , ValueOption(..)
        , SmoothingOption(..)
        )

{-|
 Convenience types.

# Types
@docs Point, Style, HintInfo, Value, ValueOption, SmoothingOption

-}


{-| -}
type alias Value =
    Float


{-| Convenience type to represent coordinates.
-}
type alias Point =
    ( Float, Float )


{-| Convenience type to represent style.
-}
type alias Style =
    List ( String, String )


{-| The info you from the hint.
-}
type alias HintInfo =
    { xValue : Float
    , yValues : List (Maybe (List Float))
    }


{-| These are the options you can choose from when specifying the values at which you place your ticks or labels.
-}
type ValueOption
    = FromList (List Value)
    | FromDelta Float
    | FromBounds (Value -> Value -> List Value)
    | FromDefault


{-| These are the options you can choose from when specifying a curve for your line or area.
-}
type SmoothingOption
    = None
    | Bezier
