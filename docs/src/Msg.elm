module Msg exposing (Msg(..))
import Plot exposing (Point)


type Msg
    = FocusExample String
    | HoverRangeFrame (Maybe Point)
    | HoverBars (Maybe Point)
