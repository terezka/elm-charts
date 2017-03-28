module Axis exposing (..)

import Svg exposing (Svg, Attribute)
import Internal.Base



type alias Summary =
  { min : Float
  , max : Float
  , dataMin : Float
  , dataMax : Float
  }


type alias Customizations =
  { position : Float -> Float -> Float
  , axisLine : Maybe LineCustomizations
  , marks : List ( Float, Mark )
  , flipAnchor : Bool
  }


type alias Mark =
  { line : LineCustomizations
  , tick : TickCustomizations
  , view : Svg Never
  }


type alias LineCustomizations =
  { attributes : List (Attribute Never)
  , start : Float
  , end : Float
  }


type alias TickCustomizations =
  { attributes : List (Attribute Never)
  , length : Float
  }
