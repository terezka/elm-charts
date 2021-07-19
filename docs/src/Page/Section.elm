module Page.Section exposing (Model, Params, Msg, init, subscriptions, exit, update, view)


import Browser exposing (Document)
import Route exposing (Route)
import Session exposing (Session)
import Browser.Events as E
import Browser.Navigation as Navigation
import Html
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
import Ui.Thumbnail
import Ui.Tabs
import Charts.Terminology



-- MODEL


type alias Model =
  { examples : Examples.Model
  , selectedTab : String
  , window : Session.Window
  , menu : Menu.Model
  }


type alias Params =
  { section : String
  }



-- INIT


init : Navigation.Key -> Session -> Params -> ( Model, Cmd Msg )
init key session params =
  ( { examples = Examples.init
    , selectedTab = params.section
    , window = session.window
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
  | OnExampleMsg Examples.Msg


update : Navigation.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
  case msg of
    OnResize width height ->
      ( { model | window = { width = width, height = height } }, Cmd.none )

    MenuMsg subMsg ->
      ( { model | menu = Menu.update subMsg model.menu }, Cmd.none )

    OnExampleMsg sub ->
      ( { model | examples = Examples.update sub model.examples }
      , Cmd.none
      )




-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  E.onResize OnResize



-- VIEW


view : Model -> Document Msg
view model =
  { title = "elm-charts | Documentation"
  , body =
      Layout.view model.window
        [ Menu.small model.window model.menu
            |> E.map MenuMsg

        , Layout.heading model.window "Documentation"

        , E.paragraph
            [ E.paddingXY 0 20
            , F.size 14
            , E.width (E.maximum 600 E.fill)
            ]
            [ E.text "This catalog is meant to document through example. For documentation of exact interface, see the "
            , E.link
                [ F.underline ]
                { url = "https://package.elm-lang.org/packages/terezka/charts/latest"
                , label = E.text "official Elm documentation"
                }
            , E.text "."
            ]

        , Ui.Tabs.view model.window
            { toUrl = Ui.Thumbnail.toUrlGroup << .title
            , toTitle = .title
            , selected = Route.documentation ++ "/" ++ model.selectedTab
            , all = Ui.Thumbnail.groups
            }

        , case model.selectedTab of
            "bar-charts" ->
              E.column
                [ E.width E.fill
                , E.height E.fill
                , E.spacing 25
                , E.paddingXY 0 20
                ]
                [ E.el [ F.size 24 ] (E.text "Terminology")
                , E.el [ E.width E.fill, E.height E.fill ] (E.html Charts.Terminology.view)
                , E.el [ F.size 24 ] (E.text "Examples")
                ]

            _ ->
              E.none

        , case Layout.screen model.window of
            Layout.Large ->
              E.map OnExampleMsg <|
                E.wrappedRow
                  [ E.width E.fill
                  , E.height E.fill
                  , E.centerX
                  , E.spacingXY 100 70
                  , E.paddingEach { top = 30, bottom = 100, left = 0, right = 0 }
                  ] <| List.map (E.el [ E.width (E.px 265) ])
                  (Ui.Thumbnail.viewSelected model.examples <| Route.documentation ++ "/" ++ model.selectedTab)

            Layout.Medium ->
              E.map OnExampleMsg <|
                E.wrappedRow
                  [ E.width E.fill
                  , E.height E.fill
                  , E.centerX
                  , E.spacingXY 100 70
                  , E.paddingEach { top = 30, bottom = 100, left = 0, right = 0 }
                  ]  <| List.map (E.el [ E.width (E.px 265) ])
                  (Ui.Thumbnail.viewSelected model.examples <| Route.documentation ++ "/" ++ model.selectedTab)

            Layout.Small ->
              E.map OnExampleMsg <|
                E.column
                  [ E.width E.fill
                  , E.height E.fill
                  , E.centerX
                  , E.spacingXY 100 70
                  , E.paddingEach { top = 30, bottom = 100, left = 20, right = 20 }
                  ]
                  (Ui.Thumbnail.viewSelected model.examples <| Route.documentation ++ "/" ++ model.selectedTab)

        ]
  }