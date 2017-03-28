module Internal.Base exposing (..)


type alias Axis =
  { min : Float
  , max : Float
  , dataMin : Float
  , dataMax : Float
  , all : List Float
  , marginLower : Float
  , marginUpper : Float
  , length : Float
  }


type alias Plot =
  { x : Axis
  , y : Axis
  }


type alias Customizations =
  { width : Int
  , height : Int
  , margin :
    { top : Int
    , right : Int
    , bottom : Int
    , left : Int
    }
  , toDomainLowest : Float -> Float
  , toDomainHighest : Float -> Float
  , toRangeLowest : Float -> Float
  , toRangeHighest : Float -> Float
  }


type alias DataPoint =
  { x : Float
  , y : Float
  }


toSVGX : Plot -> Float -> Float
toSVGX _ a =
  a


defaultAxis : Axis
defaultAxis =
  { min = 0
  , max = 1
  , dataMin = 0
  , dataMax = 1
  , all = []
  , marginLower = 0
  , marginUpper = 0
  , length = 0
  }


plot : Customizations -> List DataPoint -> Plot
plot _ _ =
  { x = defaultAxis
  , y = defaultAxis
  }
