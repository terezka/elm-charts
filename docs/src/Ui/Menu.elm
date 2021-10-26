module Ui.Menu exposing (Link, small, links, Model, Msg, update, init)


import Html as H
import Element as E
import Element.Input as I
import Element.Font as F
import Element.Border as B
import Element.Background as BG
import Session
import FeatherIcons
import Route


type alias Model =
  { isOpen : Bool }


init : Model
init =
  { isOpen = False }


type Msg
  = OnToggle


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnToggle ->
      { model | isOpen = not model.isOpen }



-- VIEW


small : Session.Window -> Model -> E.Element Msg
small window model =
  E.column
    [ E.width E.fill
    , E.paddingEach { top = 0, bottom = 40, left = 0, right = 0 }
    ]
    [ E.row
        [ E.width E.fill
        ]
        [ E.column
            [ E.alignTop
            , E.spacing 5
            , E.alignLeft
            , E.width (E.maximum 300 E.fill)
            ]
            [ E.link []
                { url = "/"
                , label =
                    E.row [ F.size 20 ] [ E.text "elm-charts" ]
                }
            ]
        , E.row
            [ E.spacing 40
            , E.alignRight
            , F.size 13
            ] <|
            if window.width > 700
              then links
              else
                [ I.button []
                    { onPress = Just OnToggle
                    , label = E.html (FeatherIcons.toHtml [] (if model.isOpen then FeatherIcons.x else FeatherIcons.menu))
                    }
                ]
        ]
    , if model.isOpen then
        E.column
          [ E.centerX
          , E.spacing 15
          , E.paddingEach { top = 30, bottom = 20, left = 0, right = 0 }
          , F.size 16
          ] links
      else
        E.none
    ]


type alias Link =
  { url : String
  , title : String
  }


links : List (E.Element msg)
links =
  List.map viewLink
    [ Link Route.gettingStarted "Getting started"
    , Link Route.documentation "Documentation"
    --, Link Route.articles "Articles"
    , Link Route.administration "Administration"
    ]


viewLink : Link -> E.Element msg
viewLink link =
  E.link []
    { url = link.url
    , label = E.text link.title
    }

