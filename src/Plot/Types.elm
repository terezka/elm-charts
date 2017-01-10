module Plot.Types
    exposing
        ( Point
        , Style
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


type alias HintInfo =
    { xValue : Float
    , yValues : List (Maybe (List Float))
    }
