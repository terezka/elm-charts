module Plot exposing (..)

{-|

@docs Point, Summary, Customizations, Junk
-}

import Html exposing (Html)
import Svg exposing (Svg, Attribute)
import Axis


{-| -}
type alias Point =
  { x : Float
  , y : Float
  }


{-| -}
type alias Summary =
  { x : Axis.Summary
  , y : Axis.Summary
  }


{-| -}
type alias Customizations msg =
  { attributes : List (Attribute msg)
  , defs : List (Svg msg)
  , id : String
  , width : Int
  , height : Int
  , margin :
    { top : Int
    , right : Int
    , bottom : Int
    , left : Int
    }
  , horizontalAxis : Maybe Axis.Customizations
  , onHover : Maybe (Maybe Point -> msg)
  , hintContainer : Summary -> List (Html Never) -> Html Never
  , junk : Summary -> List (Junk msg)
  , toDomainLowest : Float -> Float
  , toDomainHighest : Float -> Float
  , toRangeLowest : Float -> Float
  , toRangeHighest : Float -> Float
  }


{-| -}
type alias Junk msg =
  { x : Float
  , y : Float
  , view : Svg msg
  }
