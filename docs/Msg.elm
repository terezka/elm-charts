module Msg exposing (Msg(..))
import Svg.Plot exposing (Point)

type Msg
    = FocusExample String
    | Hover1 (Maybe Point)
    | Hover2 (Maybe Point)
