module Dom.Position exposing (top, left)

{-| This module lets you measure the position of an element relative to the viewport.

# Position
@docs top, left

-}

import Dom exposing (Error, Id)
import Native.Dom
import Task exposing (Task)


{-| Get the amount of pixels between the top boundary edge of an element and the viewport.
-}
top : Id -> Task Error Float
top =
    Native.Dom.top


{-| Get the amount of pixels between the left boundary edge of an element and the viewport.
-}
left : Id -> Task Error Float
left =
    Native.Dom.left
