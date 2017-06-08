module Main exposing (main)

import Html exposing (Html, div, span)
import Html.Attributes exposing (style)
import Svg exposing (Svg)
import Svg.Attributes as Attributes exposing (fill, stroke)
import Series exposing (..)
import Colors exposing (..)
import Axis exposing (..)



{-| -}
defaultMarkView : Float -> MarkView
defaultMarkView position =
  { grid = Nothing
  , junk = Nothing
  , tick = Just simpleTick
  , label = Nothing
  }


{-| -}
defaultMark : Float -> Mark
defaultMark position =
  { position = position
  , view = defaultMarkView position
  }


{-| -}
defaultYAxisView : AxisView
defaultYAxisView =
  { position = \min max -> min
  , line = Just simpleLine
  , marks = \_ -> List.map defaultMark [ 20, 40, 60, 80, 100 ]
  , mirror = False
  }


{-| -}
defaultXAxisView : AxisView
defaultXAxisView =
  { position = \min max -> min
  , line = Just simpleLine
  , marks = \_ -> List.map defaultMark [ 0, 3, 6, 9, 12 ]
  , mirror = False
  }

main : Html msg
main =
  div []
    [ div
        [ style [ ("padding", "40px" ) ] ]
        [ Series.viewCustom
            { independentAxis = defaultXAxisView
            , hint = Nothing
            }
            [ { axis = axis defaultYAxisView
              , interpolation = None
              , toDots = .first >> List.map (\(x, y) -> dot (viewCircle pinkStroke) x y)
              }
            ]
            data
        ]
    , div
        [ style [ ("padding", "40px" ) ] ]
        [ Series.viewCustom
          { independentAxis = defaultXAxisView
          , hint = Nothing
          }
          [ { axis = axis defaultYAxisView
            , interpolation = Linear [ fill pinkFill, stroke pinkStroke ]
            , toDots = .first >> List.map (\(x, y) -> dot (viewCircle pinkStroke) x y)
            }
          ]
          data
        ]
    , div
        [ style [ ("padding", "40px" ) ] ]
        [ Series.viewCustom
          { independentAxis = defaultXAxisView
          , hint = Nothing
          }
          [ { axis = axis defaultYAxisView
            , interpolation = Monotone [ fill pinkFill ]
            , toDots = .first >> List.map (\(x, y) -> dot (viewCircle pinkStroke) x y)
            }
          ]
          data
        ]
    ]


viewCircle : String -> Svg msg
viewCircle color =
  Svg.circle
    [ Attributes.r "5"
    , Attributes.stroke "transparent"
    , Attributes.fill color
    ]
    []



-- DATA


data : { first : List ( Float, Float ), second : List ( Float, Float ) }
data =
  { first =
    [ ( 0, 0 )
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
