module Series exposing (..)

{-| -}

import Html exposing (Html)
import Svg exposing (Svg, Attribute, g)
import Internal.Base
import Axis


type alias Series data msg =
  { axis : Maybe Axis.Customizations
  , interpolation : Interpolation
  , toDataPoints : data -> List (DataPoint msg)
  }


type Interpolation
  = None
  | Linear (Maybe String) (List (Attribute Never))
  | Monotone (Maybe String) (List (Attribute Never))


type alias DataPoint msg =
  { view : Maybe (Svg msg)
  , hint : Html Never
  , xMark : Axis.Summary -> Axis.Mark
  , yMark : Axis.Summary -> Axis.Mark
  , x : Float
  , y : Float
  }


view : Series data msg -> Svg msg
view _ =
  g [] []
