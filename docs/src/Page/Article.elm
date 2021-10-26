module Page.Article exposing (Model, Params, Msg, init, subscriptions, exit, update, view)


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
import Articles



-- MODEL


type alias Model =
  { window : Session.Window
  , menu : Menu.Model
  , articleId : Maybe Articles.Id
  , article : Articles.Model
  }


type alias Params =
  { id : String }



-- INIT


init : Navigation.Key -> Session -> Params -> ( Model, Cmd Msg )
init key session params =
  let isCorrectId article =
        (Articles.meta article).id == params.id

      articleId =
        List.head (List.filter isCorrectId Articles.all)
  in
  ( { window = session.window
    , menu = Menu.init
    , articleId = articleId
    , article = Articles.init
    }
  , Cmd.none
  )


exit : Model -> Session -> Session
exit model session =
  session



-- UPDATE


type Msg
  = MenuMsg Menu.Msg
  | ArticleMsg Articles.Msg


update : Navigation.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
  case msg of
    MenuMsg subMsg ->
      ( { model | menu = Menu.update subMsg model.menu }, Cmd.none )

    ArticleMsg subMsg ->
      ( { model | article = Articles.update subMsg model.article }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Document Msg
view model =
  { title = "elm-charts"
    , body =
        Layout.view model.window
          [ Menu.small model.window model.menu
              |> E.map MenuMsg

          , case model.articleId of
              Nothing ->
                Layout.heading model.window "Article not found."

              Just id ->
                let form = Articles.view model.article id in
                E.column [ E.spacing 40 ]
                  [ Layout.heading model.window form.title
                  , E.column [ E.spacing 30 ] (List.map (E.map ArticleMsg) (form.body ()))
                  ]
          ]
    }

