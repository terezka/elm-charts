module Interactive exposing (..)

import Html exposing (h1, p, text, div, node)
import Svg exposing (Svg)
import Svg.Attributes as Attributes exposing (fill, stroke)
import Axis exposing (..)
import Series exposing (..)
import Colors exposing (..)
import Hint exposing (..)

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


view : Model -> Svg Msg
view model =
  Series.viewCustom
    { defaultConfig
    | independentAxis = axisView
    , hint = Just
        { proximity = Just 10
        , view = Aligned (toString >> Svg.text)
        , msg = Hover
        , model = model.hovering
        }
    }
    [ { axis = axis defaultAxisView
      , interpolation = None
      , toDots = .first >> List.map (\(x, y) -> dot (viewCircle pinkStroke) x y)
      }
    ]
    data


axisView : AxisView
axisView =
  { position = \min max -> min
  , line = Just simpleLine
  , marks = decentPositions >> List.map gridMark
  , mirror = False
  }



viewCircle : String -> Svg msg
viewCircle color =
  Svg.circle
    [ Attributes.r "10"
    , Attributes.stroke "transparent"
    , Attributes.fill color
    ]
    []



-- Boring stuff


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }


data : { first : List ( Float, Float ), second : List ( Float, Float ) }
data =
  { first =
    [ ( 3, 20 )
    , ( 4, 50 )
    , ( 4, 30 )
    , ( 12, 100 )
    ]
  , second =
    [ ( 1, 30 )
    , ( 2, 40 )
    , ( 5, 20 )
    , ( 7.8, 0 )
    ]
  }
