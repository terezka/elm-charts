module Plot.Types
    exposing
        ( Point
        , Style
        , HintInfo
        , Value
        , ValueOptions(..)
        )

{-|
 Convenience types.

# Types
@docs Point, Style, HintInfo, Value, ValueOptions

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


{-| Value types
-}
type ValueOptions
    = FromList (List Value)
    | FromBounds (Value -> Value -> List Value)
    | FromDefault
