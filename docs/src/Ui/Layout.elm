module Ui.Layout exposing (..)


import Html as H
import Element as E
import Element.Font as F
import Element.Border as B
import Element.Background as BG
import Session


type Screen
  = Small
  | Medium
  | Large


screen : Session.Window -> Screen
screen window =
  if window.width > 950 then Large
  else if window.width > 760 then Medium
  else Small


title : Session.Window -> { title : String, tag : List (E.Element msg), padding : Int } -> E.Element msg
title window config =
  E.textColumn
    [ E.width E.fill
    , F.center
    , E.paddingXY 0 config.padding
    , E.spacing 10
    ]
    [ E.paragraph
        [ F.size <|
            case screen window of
              Large -> 120
              Medium -> 80
              Small -> 52
        ]
        [ E.text config.title ]
    , E.paragraph
        [ F.size <|
            case screen window of
              Large -> 28
              Medium -> 28
              Small -> 20
        ]
        config.tag
    ]


heading : Session.Window -> String -> E.Element msg
heading window text =
  E.paragraph
    [ F.size <|
        case screen window of
          Large -> 32
          Medium -> 28
          Small -> 24
    ]
    [ E.text text ]



-- CONTAINER


view : Session.Window -> List (E.Element msg) -> List (H.Html msg)
view window children =
  List.singleton <|
    E.layout
      [ E.width E.fill
      , F.family [ F.typeface "IBM Plex Sans", F.sansSerif ]
      ] <|
      E.column
        [ E.width (E.maximum 1060 E.fill)
        , E.paddingEach { top = 30, bottom = 20, left = 30, right = 30 }
        , E.centerX
        , F.size 12
        , F.color (E.rgb255 80 80 80)
        ]
        (children ++ [ copyright window ])


copyright : Session.Window -> E.Element msg
copyright window =
  E.el
    [ F.size 12
    , F.color (E.rgb255 180 180 180)
    , E.paddingEach { top = 30, bottom = 20, left = 0, right = 0 }
    , case screen window of
        Large -> E.alignRight
        Medium -> E.centerX
        Small -> E.centerX
    ]
    (E.text "Designed and developed by Tereza Sokol © 2021")


link : String -> String -> E.Element msg
link url label =
  E.link
    [ F.underline ]
    { url = url
    , label = E.text label
    }