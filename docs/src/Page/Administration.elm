module Page.Administration exposing (Model, Params, Msg, init, subscriptions, exit, update, view)


import Browser exposing (Document)
import Browser.Events as E
import Route exposing (Route)
import Session exposing (Session)
import Browser.Navigation as Navigation
import Html as H
import Html.Attributes as HA

import Element as E
import Element.Font as F
import Element.Input as I
import Element.Border as B
import Element.Background as BG

import Ui.Layout as Layout
import Ui.Menu as Menu



-- MODEL


type alias Model =
  { window : Session.Window
  , menu : Menu.Model
  }


type alias Params =
  ()



-- INIT


init : Navigation.Key -> Session -> Params -> ( Model, Cmd Msg )
init key session params =
  ( { window = session.window
    , menu = Menu.init
    }
  , Cmd.none
  )


exit : Model -> Session -> Session
exit model session =
  session



-- UPDATE


type Msg
  = OnResize Int Int
  | MenuMsg Menu.Msg


update : Navigation.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
  case msg of
    OnResize width height ->
      ( { model | window = { width = width, height = height } }, Cmd.none )

    MenuMsg subMsg ->
      ( { model | menu = Menu.update subMsg model.menu }, Cmd.none )



-- VIEW


view : Model -> Document Msg
view model =
    { title = "elm-charts"
    , body =
        Layout.view model.window
          [ Menu.small model.window model.menu
              |> E.map MenuMsg

          , E.textColumn
              [ E.width (E.maximum 600 E.fill) ]
              [ E.paragraph
                  [ F.size 32
                  , E.paddingXY 0 20
                  ]
                  [ E.text "Administration" ]

              , E.paragraph
                  [ E.paddingXY 0 10
                  , F.size 14
                  ]
                  [ E.text "This library is managed by "
                  , Layout.link "https://twitter.com/tereza_sokol" "Tereza Sokol"
                  , E.text ", with the support of various other contributors."
                  ]

              , E.paragraph
                  [ F.size 22
                  , E.paddingEach { top = 30, bottom = 5, left = 0, right = 0 }
                  ]
                  [ E.text "Contracting" ]

              , E.paragraph
                  [ E.paddingXY 0 10
                  , F.size 14
                  ]
                  [ E.text "If you or your company would like me to build you a chart with elm-charts or add "
                  , E.text "a specific feature to the library, feel free to contact me at "
                  , Layout.link "mailto:terezasokol@gmail.com" "terezasokol@gmail.com"
                  , E.text " and we can figure out the details."
                  ]

              , E.paragraph
                  [ F.size 22
                  , E.paddingEach { top = 30, bottom = 5, left = 0, right = 0 }
                  ]
                  [ E.text "Roadmap" ]

              , E.paragraph
                  [ E.paddingXY 0 10
                  , F.size 14
                  ]
                  [ E.text "Here are some upcoming features and improvements in approximate order of priority. "
                  , E.text "If you have more suggestions or have wishes regarding the priority, then "
                  , E.text "you're welcome to "
                  , Layout.link "https://github.com/terezka/charts/issues" "open an issue"
                  , E.text " or contact me directly."
                  ]

              , E.el [ F.size 14 ] <| E.html <|
                  let item text =
                        H.li [ HA.style "padding" "5px 0" ] [ H.text text ]
                  in
                  H.ul
                    [ HA.style "padding-left" "25px" ]
                    [ item "Heat maps charts"
                    , item "Horizontal bar charts"
                    , item "Logarithmic scales"
                    , item "Multiple scales"
                    , item "Relative stacked bars"
                    , item "Further improvements of automatic \"nice\" ticks"
                    , item "Pie charts"
                    , item "Confidence intervals"
                    , item "More interpolation options"
                    , item "Animations"
                    ]
              ]

          , E.row
              [ F.size 14
              , E.paddingXY 0 30
              , E.spacing 20
              ]
              [ Layout.link "https://github.com/terezka" "GitHub"
              , Layout.link "https://twitter.com/tereza_sokol" "Twitter"
              , Layout.link "https://github.com/terezka/charts/issues" "Report an issue"
              , Layout.link "mailto:terezasokol@gmail.com" "Contact"
              ]
          ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  E.onResize OnResize

