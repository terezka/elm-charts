module Dom.Position exposing (top, left)

{-| This module lets you choose one of these boundaries and then measure its size.
# Position
@docs top, left
-}

import Dom exposing (Error, Id)
import Native.Dom
import Task exposing (Task)


{-| Get the pixels from top relative to the window.
-}
top : Id -> Task Error Float
top =
    Native.Dom.top


{-| Get the width of a node, measured along a certain boundary.
If the node has the `hidden` attribute or the `display: none` style, this
will be zero.
-}
left : Id -> Task Error Float
left =
    Native.Dom.left
