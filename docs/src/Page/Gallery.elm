module Page.Gallery exposing (Model, Params, Msg, init, subscriptions, exit, update, view)


import Browser exposing (Document)
import Route exposing (Route)
import Session exposing (Session)
import Browser.Navigation as Navigation
import Html
import Charts.SalaryDist as SalaryDist
import Charts.SalaryDistBar as SalaryDistBar
import Html as H
import Element as E
import Element.Font as F
import Element.Border as B
import Element.Background as BG
import Ui.Layout as Layout
import Ui.Code as Code
import Ui.Menu as Menu




-- MODEL


type alias Model =
  { salaryDist : SalaryDist.Model
  , salaryDistBar : SalaryDistBar.Model
  , window : Session.Window
  , menu : Menu.Model
  }


type alias Params =
  ()



-- INIT


init : Navigation.Key -> Session -> Params -> ( Model, Cmd Msg )
init key session params =
  ( { salaryDist = SalaryDist.init
    , salaryDistBar = SalaryDistBar.init
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
  = MenuMsg Menu.Msg
  | SalaryDistMsg SalaryDist.Msg
  | SalaryDistBarMsg SalaryDistBar.Msg



update : Navigation.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
  case msg of
    MenuMsg subMsg ->
      ( { model | menu = Menu.update subMsg model.menu }, Cmd.none )

    SalaryDistMsg subMsg ->
      ( { model | salaryDist = SalaryDist.update subMsg model.salaryDist }, Cmd.none )

    SalaryDistBarMsg subMsg ->
      ( { model | salaryDistBar = SalaryDistBar.update subMsg model.salaryDistBar }, Cmd.none )




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
          , E.el
              [ F.size 32
              , E.paddingXY 0 10
              ]
              (E.text "Gallery")

          , E.paragraph
              [ E.paddingEach { top = 10, bottom = 40, left = 0, right = 0 }
              , F.size 14
              , E.width (E.px 600)
              ]
              [ E.text "Examples of charts build with elm-charts using real data."
              ]

          , E.el
              [ F.size 20
              , E.paddingXY 0 10
              ]
              (E.text "Salary distribution in Denmark")

          , E.paragraph
              [ E.paddingEach { top = 10, bottom = 10, left = 0, right = 0 }
              , F.size 14
              , E.width (E.px 600)
              ]
              [ E.text "Note that the data visualized here is already aggregated into averages. This means that there might "
              , E.text "be women or men earning more or less than what the numbers show. For example, there may well be a woman CEO being payed the "
              , E.text "same or more than her male counter part, but what the data shows is that "
              , E.el [ F.italic ] (E.text "on average")
              , E.text " this is not the case. This is particularily important to keep in mind when interpreting the second chart."
              ]

          , E.el
              [ E.paddingEach { top = 50, bottom = 40, left = 0, right = 0 }
              , E.width (E.px 1000)
              ]
              (E.html <| H.map SalaryDistMsg (SalaryDist.view model.salaryDist))

          , E.el
              [ E.paddingEach { top = 0, bottom = 80, left = 0, right = 0 }
              , E.width (E.px 1000)
              ]
              (E.map SalaryDistBarMsg (SalaryDistBar.view model.salaryDistBar))
          ]
    }

