module Interactive exposing (..)

import Html exposing (h1, p, text, div, node)
import Svg.Plot as Plot exposing (..)


-- MODEL


type alias Model =
    { hovering : Maybe { x : Float, y : Float } }


initialModel : Model
initialModel =
    { hovering = Nothing }



-- UPDATE


type Msg
    = Hover (Maybe { x : Float, y : Float })


update : Msg -> Model -> Model
update msg model =
    case msg of
        Hover point ->
            { model | hovering = point }



-- VIEW


data1 : List ( Float, Float )
data1 =
    [ ( 0, 2 ), ( 1, 4 ), ( 2, 5 ), ( 3, 10 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 0 ), ( 1, 5 ), ( 2, 7 ), ( 3, 15 ) ]


view : Model -> Html.Html Msg
view model =
    Plot.viewCustom { defaultPlotCustomizations | onHover = Just Hover }
        [ area (List.map (\{ x, y } -> diamond (x + 2) (y * 1.2)))
        , case model.hovering of
            Just point ->
              dots (always [ square point.x point.y ])

            Nothing ->
              dots (always [])
        ]
        [ { x = -3.1, y = 2.2 }
        , { x = 2.2, y = 4.2 }
        , { x = 3.5, y = -1.6 }
        , { x = 5.4, y = -0.8 }
        , { x = 6.8, y = 2.3 }
        ]


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }
