module Msg exposing (Msg(..))
import Svg.Plot exposing (Point)

type Msg
    = FocusExample String
    | Hover (Maybe Point)
