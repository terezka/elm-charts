module Page.GettingStarted exposing (Model, Params, Msg, init, subscriptions, exit, update, view)


import Browser.Events as E
import Browser exposing (Document)
import Route exposing (Route)
import Session exposing (Session)
import Browser.Navigation as Navigation
import Html
import Html as H
import Element as E
import Element.Font as F
import Element.Border as B
import Element.Background as BG
import Ui.Layout as Layout
import Ui.Code as Code
import Ui.Menu as Menu

import Examples.Frontpage.BasicNavigation as BasicNavigation
import Examples.Frontpage.BasicArea as BasicArea
import Examples.Frontpage.BasicBar as BasicBar
import Examples.Frontpage.BasicLine as BasicLine
import Examples.Frontpage.BasicScatter as BasicScatter
import Examples.Frontpage.BasicBubble as BasicBubble



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
  | None


update : Navigation.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
  case msg of
    OnResize width height ->
      ( { model | window = { width = width, height = height } }, Cmd.none )

    MenuMsg subMsg ->
      ( { model | menu = Menu.update subMsg model.menu }, Cmd.none )

    None ->
      ( model, Cmd.none )




-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  E.onResize OnResize



-- VIEW


view : Model -> Document Msg
view model =
  { title = "elm-charts | Getting started"
  , body =
      Layout.view model.window
        [ Menu.small model.window model.menu
            |> E.map MenuMsg

        , Layout.heading model.window "Getting started"

        , E.paragraph
            [ E.paddingEach { top = 20, bottom = 50, left = 0, right = 0 }
            , F.size 14
            , E.width (E.maximum 600 E.fill)
            ]
            [ E.text "Here's how to make basic charts. If your needs exceed these, check out "
            , E.text "the "
            , E.link
                [ F.underline ]
                { url = Route.documentation
                , label = E.text "many other examples"
                }
            , E.text " or the "
            , E.link
                [ F.underline ]
                { url = "https://package.elm-lang.org/packages/terezka/charts/latest"
                , label = E.text "official Elm documentation"
                }
            , E.text "."
            ]

        , let frame title attr els =
                case Layout.screen model.window of
                  Layout.Large ->
                    E.column
                      [ E.width E.fill, E.spacing 40 ]
                      [ viewTitle title, E.row attr els ]

                  Layout.Medium ->
                    E.column
                      [ E.width E.fill, E.spacing 40 ]
                      [ viewTitle title, E.row attr els ]

                  Layout.Small ->
                    E.column attr (viewTitle title :: els)

              viewTitle title =
                E.paragraph [ F.size 24 ] [ E.text title ]

              viewExample ( chart, title, code ) =
                frame title
                  [ E.width E.fill
                  , E.spacing 50
                  ]
                  [ E.el
                      [ E.width (E.maximum 320 E.fill)
                      , E.paddingXY 15 0
                      , E.alignTop
                      , F.size 12
                      ] <| E.html chart

                  , E.el
                      [ E.width E.fill
                      , E.height E.fill
                      , E.alignTop
                      , F.size 12
                      , BG.color (E.rgb255 250 250 250)
                      ]
                      (Code.view { template = code, edits = [] })
                  ]
          in
          E.column
            [ E.width E.fill
            , E.height E.fill
            , E.spacing 90
            , E.paddingEach { top = 0, bottom = 50, left = 0, right = 0 }
            ]
            <| List.map viewExample
                [ ( Html.map (\_ -> None) <| BasicNavigation.view (), BasicNavigation.meta.name, BasicNavigation.smallCode )
                , ( Html.map (\_ -> None) <| BasicArea.view (), BasicArea.meta.name, BasicArea.smallCode )
                , ( Html.map (\_ -> None) <| BasicBar.view (), BasicBar.meta.name, BasicBar.smallCode )
                , ( Html.map (\_ -> None) <| BasicLine.view (), BasicLine.meta.name, BasicLine.smallCode )
                , ( Html.map (\_ -> None) <| BasicScatter.view (), BasicScatter.meta.name, BasicScatter.smallCode )
                , ( Html.map (\_ -> None) <| BasicBubble.view (), BasicBubble.meta.name, BasicBubble.smallCode )
                ]

        , E.paragraph
            [ F.underline
            , F.size 18
            , F.center
            , E.paddingXY 0 20
            ]
            [ E.link []
                { url = Route.documentation
                , label = E.text "See more examples →"
                }
            ]
        ]
  }
