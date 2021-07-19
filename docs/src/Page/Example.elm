module Page.Example exposing (Model, Params, Msg, init, subscriptions, exit, update, view)


import Browser.Events as E
import Browser exposing (Document)
import Route exposing (Route)
import Session exposing (Session)
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



-- MODEL


type alias Model =
  { examples : Examples.Model
  , showFullCode : Bool
  , selectedTab : String
  , selectedThumb : String
  , window : Session.Window
  , menu : Menu.Model
  }


type alias Params =
  { section : String
  , example : String
  }



-- INIT


init : Navigation.Key -> Session -> Params -> ( Model, Cmd Msg )
init key session params =
  ( { examples = Examples.init
    , showFullCode = False
    , selectedTab = params.section
    , selectedThumb = params.example
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
  | OnToggleCode


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

    OnToggleCode ->
      ( { model | showFullCode = not model.showFullCode }
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

        , viewContent model
        ]
  }



viewContent : Model -> E.Element Msg
viewContent model =
  let currentId =
        Examples.all
          |> List.map (\id ->
                ( ( Ui.Thumbnail.urlify (Examples.meta id).category
                  , Ui.Thumbnail.urlify (Examples.meta id).name
                  )
                , id
                )
            )
          |> Dict.fromList
          |> Dict.get ( model.selectedTab, model.selectedThumb )
          |> Maybe.withDefault Examples.first

      meta =
        Examples.meta currentId

      viewText =
        E.textColumn
          [ E.width E.fill, E.spacing 20 ]
          [ E.paragraph [ F.size 28 ] [ E.text meta.name ]
          , E.paragraph [ F.size 14 ] [ E.text meta.description ]
          ]

      viewChart isCenter =
        E.el
          [ E.width (E.fill |> E.maximum 320 |> E.minimum 300 )
          , if isCenter then E.centerX else E.alignTop
          , E.alignTop
          , E.paddingEach { top = 0, bottom = 40, left = 0, right = 0 }
          ]
          (E.map OnExampleMsg <| E.html <| Examples.view model.examples currentId)

      viewToggler =
        I.button
          [ E.alignRight ]
          { onPress = Just OnToggleCode
          , label = E.text <| if model.showFullCode then "Show essence" else "Show full code"
          }

      viewCode =
        E.el
          [ E.width E.fill
          , E.height E.fill
          , BG.color (E.rgb255 250 250 250)
          ] <|
          Code.view
              { template =
                  if model.showFullCode
                  then Examples.largeCode currentId
                  else Examples.smallCode currentId
              , edits = []
              }
  in
  case Layout.screen model.window of
    Layout.Large ->
      E.column
        [ E.width E.fill
        , E.height E.fill
        , E.paddingEach { top = 20, bottom = 0, left = 0, right = 0 }
        , E.spacing 30
        ]
        [ viewText
        , E.row
            [ E.width E.fill
            , E.height E.fill
            , E.spacing 50
            , E.alignTop
            ]
            [ viewChart False
            , E.column
                [ E.width (E.fillPortion 2)
                , E.height E.fill
                , E.spacing 20
                ]
                [ viewToggler
                , viewCode
                ]
              ]
        ]

    Layout.Medium ->
      E.column
        [ E.width E.fill
        , E.height E.fill
        , E.paddingEach { top = 20, bottom = 0, left = 0, right = 0 }
        , E.spacing 30
        ]
        [ viewText
        , E.row
            [ E.width E.fill
            , E.height E.fill
            , E.spacing 50
            , E.alignTop
            ]
            [ viewChart False
            , E.column
                [ E.width (E.fillPortion 2)
                , E.height E.fill
                , E.spacing 20
                ]
                [ viewToggler
                , viewCode
                ]
              ]
        ]

    Layout.Small ->
      E.column
        [ E.width E.fill
        , E.paddingEach { top = 20, bottom = 0, left = 0, right = 0 }
        , E.spacing 30
        ]
        [ viewText
        , viewChart True
        , viewToggler
        , E.column
              [ E.width E.fill
              , E.alignTop
              , E.centerX
              , E.spacing 20
              ]
              [ viewCode
              ]
        ]




getCategoryAndTitle : Examples.Id -> ( String, String )
getCategoryAndTitle id =
  case String.split "." (Examples.name id) of
    _ :: category :: title :: _ -> ( category, title )
    _ -> ( "NOT FOUND", Examples.name id )
