module Plot.Types
    exposing
        ( Point
        , Style
        , Smoothing (..)
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


type Smoothing
    = None
    | Cosmetic


type alias HintInfo =
    { xValue : Float
    , yValues : List (Maybe (List Float))
    }
