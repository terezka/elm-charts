module Interactive exposing (..)

import Html exposing (h1, p, text, div, node)
import Svg exposing (Svg)
import Svg.Attributes as Attributes exposing (fill, stroke)
import Series exposing (..)
import Colors exposing (..)


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

data : { first : List ( Float, Float ), second : List ( Float, Float ) }
data =
  { first =
    [ ( -2, -3 )
    , ( 0, 0 )
    , ( 3, 60 )
    , ( 6, 20 )
    , ( 9, 40 )
    , ( 12, 100 )
    ]
  , second =
    [ ( 1, 30 )
    , ( 2, 40 )
    , ( 5, 20 )
    , ( 7.8, 0 )
    ]
  }

view : Model -> Svg Msg
view model =
  Series.viewCustom
    { defaultConfig
    | hint = Just
        { proximity = Just 10
        , find = Single
        , msg = Hover
        }
    }
    [ { axis = axis defaultAxisView
      , interpolation = None
      , toDots = .first >> List.map (\(x, y) -> dot (viewCircle pinkStroke) x y)
      }
    ]
    data


viewCircle : String -> Svg msg
viewCircle color =
  Svg.circle
    [ Attributes.r "5"
    , Attributes.stroke "transparent"
    , Attributes.fill color
    ]
    []


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }
