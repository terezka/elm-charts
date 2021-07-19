module Ui.Tabs exposing (..)

import Html.Attributes as HA
import Ui.Layout as Layout
import Ui.Menu as Menu
import Ui.Code as Code
import SyntaxHighlight as SH
import Dict
import Element as E
import Element.Font as F
import Element.Input as I
import Element.Border as B
import Element.Background as BG
import Examples
import Session


type alias Config a =
  { toUrl : a -> String
  , toTitle : a -> String
  , selected : String
  , all : List a
  }


view : Session.Window -> Config a -> E.Element msg
view window config =
  let contianerAttrs =
        case Layout.screen window of
          Layout.Large ->
            [ B.color (E.rgb255 220 220 220)
            , B.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
            ]

          Layout.Medium ->
            [ BG.color (E.rgb255 250 250 250), E.scrollbarX ]

          Layout.Small ->
            [ BG.color (E.rgb255 250 250 250), E.scrollbarX ]
  in
  E.el
    [ E.width E.fill
    , E.height E.fill
    , E.paddingXY 0 30
    ] <|
    E.row
      ([ E.width E.fill
      , E.height E.fill
      ] ++ contianerAttrs )
      (List.map (viewOne window config) <| List.filter (\a -> config.toTitle a /= "Front page" && config.toTitle a /= "Basic") config.all)


viewOne : Session.Window -> Config a -> a -> E.Element msg
viewOne window config item =
  let offset =
        case Layout.screen window of
          Layout.Large ->
            if isSelected then E.moveDown 1 else E.moveDown 0

          Layout.Medium ->
            E.moveDown 0

          Layout.Small ->
            E.moveDown 0

      isSelected =
        config.selected == config.toUrl item
  in
  E.link
    [ F.size 14
    , F.color (if isSelected then E.rgb255 123 77 255 else E.rgb255 120 120 120)
    , offset
    , E.paddingXY 25 10
    , B.color (E.rgb255 123 77 255)
    , B.widthEach { top = 0, bottom = if isSelected then 1 else 0, left = 0, right = 0 }
    , E.mouseOver
        [ BG.color (E.rgba255 123 77 255 0.05)
        ]
    , E.focused
        [ BG.color (if isSelected then E.rgba255 123 77 255 0.1 else E.rgb255 250 250 250)
        ]
    ]
    { url = config.toUrl item
    , label = E.text (config.toTitle item)
    }