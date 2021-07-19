module Examples.Frontpage.BasicBubble exposing (..)

{-| @LARGE -}
import Html as H
import Chart as C
import Chart.Attributes as CA


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.padding { top = 30, bottom = 5, left = 40, right = 40 }
    ]
    [ C.xLabels [ CA.withGrid ]
    , C.yLabels [ CA.withGrid ]
    , C.series .x
        [ C.scatter .y [ CA.opacity 0.3, CA.borderWidth 1 ]
            |> C.variation (\_ data -> [ CA.size data.size ])
        , C.scatter .z [ CA.opacity 0.3, CA.borderWidth 1 ]
            |> C.variation (\_ data -> [ CA.size data.size ])
        ]
        [ { x = 1, y = 2, z = 3, size = 450 }
        , { x = 2, y = 3, z = 5, size = 350 }
        , { x = 3, y = 4, z = 2, size = 150 }
        , { x = 4, y = 1, z = 3, size = 550 }
        , { x = 5, y = 4, z = 1, size = 450 }
        ]
    ]
{-| @SMALL END -}
{-| @LARGE END -}


meta =
  { category = "Basic"
  , categoryOrder = 3
  , name = "Bubble chart"
  , description = "Make a basic bubble chart."
  , order = 1
  }


type alias Model =
  ()


init : Model
init =
  ()


type Msg
  = Msg


update : Msg -> Model -> Model
update msg model =
  model

