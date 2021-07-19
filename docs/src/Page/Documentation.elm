module Page.Documentation exposing (Model, Params, Msg, init, subscriptions, exit, update, view)


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
import Page.Section



-- MODEL


type alias Model =
  Page.Section.Model


type alias Params =
  ()



-- INIT


init : Navigation.Key -> Session -> Params -> ( Model, Cmd Msg )
init key session params =
  Page.Section.init key session { section = Ui.Thumbnail.urlify Ui.Thumbnail.firstGroup.title }


exit : Model -> Session -> Session
exit model session =
  session



-- UPDATE


type alias Msg
  = Page.Section.Msg



update : Navigation.Key -> Msg -> Model -> ( Model, Cmd Msg )
update =
  Page.Section.update



subscriptions : Model -> Sub Msg
subscriptions =
  Page.Section.subscriptions



-- VIEW


view : Model -> Document Msg
view =
  Page.Section.view
