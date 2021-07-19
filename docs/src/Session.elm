module Session exposing
  ( Session
  , Window
  , init
  )

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Json.Decode as D


-- MODEL


type alias Session =
  { window : Window }


type alias Window =
  { width : Int, height : Int }


init : D.Value -> Session
init json =
  case D.decodeValue decoder json of
    Ok flags -> Session flags
    Err _ -> Session { width = 1000, height = 800 }


decoder : D.Decoder Window
decoder =
  D.map2 Window
    (D.field "width" D.int)
    (D.field "height" D.int)