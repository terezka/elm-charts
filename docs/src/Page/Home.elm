module Page.Home exposing (Model, Params, Msg, init, subscriptions, exit, update, view)


import Browser exposing (Document)
import Route exposing (Route)
import Session exposing (Session)
import Browser.Events as E
import Browser.Navigation as Navigation
import Charts.Landing as Landing
import Charts.Dashboard1 as Dashboard1
import Charts.Dashboard2 as Dashboard2
import Charts.Dashboard3 as Dashboard3
import Charts.Dashboard4 as Dashboard4
import Charts.Dashboard5 as Dashboard5
import Charts.Dashboard6 as Dashboard6
import Charts.Dashboard7 as Dashboard7
import Examples.Frontpage.Familiar as Familiar
import Examples.Frontpage.Concise as Concise
import Examples
import Html as H
import Element as E
import Element.Events as EE
import Element.Font as F
import Element.Input as I
import Element.Border as B
import Element.Background as BG
import Ui.Layout as Layout
import Ui.Code as Code
import Ui.Menu as Menu
import Ui.Thumbnail as Thumbnail

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Svg as S
import Svg.Attributes as SA

import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS


-- MODEL


type alias Model =
  { landing : Landing.Model
  , concise : Concise.Model
  , familiarToggle : Bool
  , hovering : List (CI.One { year : Float, income : Float} CI.Any)
  , window : Session.Window
  , menu : Menu.Model

  , dashboard1 : Dashboard1.Model
  , dashboard2 : Dashboard2.Model
  , dashboard3 : Dashboard3.Model
  , dashboard4 : Dashboard4.Model
  , dashboard5 : Dashboard5.Model
  }


type alias Params =
  ()



-- INIT


init : Navigation.Key -> Session -> Params -> ( Model, Cmd Msg )
init key session params =
  ( { landing = Landing.init
    , concise = Concise.init
    , familiarToggle = True
    , hovering = []
    , window = session.window
    , menu = Menu.init

    , dashboard1 = Dashboard1.init
    , dashboard2 = Dashboard2.init
    , dashboard3 = Dashboard3.init
    , dashboard4 = Dashboard4.init
    , dashboard5 = Dashboard5.init
    }
  , Cmd.none
  )


exit : Model -> Session -> Session
exit model session =
  { session | window = model.window }



-- UPDATE


type Msg
  = OnResize Int Int
  | MenuMsg Menu.Msg
  | LandingMsg Landing.Msg
  | ConciseMsg Concise.Msg
  | FamiliarToggle
  | OnHover (List (CI.One { year : Float, income : Float} CI.Any))
  | None
  | Dashboard1Msg Dashboard1.Msg
  | Dashboard2Msg Dashboard2.Msg
  | Dashboard3Msg Dashboard3.Msg
  | Dashboard4Msg Dashboard4.Msg
  | Dashboard5Msg Dashboard5.Msg


update : Navigation.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
  case msg of
    OnResize width height ->
      ( { model | window = { width = width, height = height } }, Cmd.none )

    MenuMsg subMsg ->
      ( { model | menu = Menu.update subMsg model.menu }, Cmd.none )

    ConciseMsg subMsg ->
      ( { model | concise = Concise.update subMsg model.concise }, Cmd.none )

    FamiliarToggle ->
      ( { model | familiarToggle = not model.familiarToggle }, Cmd.none )

    LandingMsg subMsg ->
      ( { model | landing = Landing.update subMsg model.landing }, Cmd.none )

    OnHover hovering ->
      ( { model | hovering = hovering }, Cmd.none )

    Dashboard1Msg subMsg ->
      ( { model | dashboard1 = Dashboard1.update subMsg model.dashboard1 }, Cmd.none )

    Dashboard2Msg subMsg ->
      ( { model | dashboard2 = Dashboard2.update subMsg model.dashboard2 }, Cmd.none )

    Dashboard3Msg subMsg ->
      ( { model | dashboard3 = Dashboard3.update subMsg model.dashboard3 }, Cmd.none )

    Dashboard4Msg subMsg ->
      ( { model | dashboard4 = Dashboard4.update subMsg model.dashboard4 }, Cmd.none )

    Dashboard5Msg subMsg ->
      ( { model | dashboard5 = Dashboard5.update subMsg model.dashboard5 }, Cmd.none )

    None ->
      ( model, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  E.onResize OnResize



-- VIEW


view : Model -> Document Msg
view model =
    { title = "elm-charts"
    , body =
        Layout.view model.window
          [ Menu.small model.window model.menu
            |> E.map MenuMsg

          , viewLanding model

          , Layout.title model.window
              { title = "elm-charts"
              , tag = [ E.text "Compose your chart with delight." ]
              , padding = 30
              }

          , case Layout.screen model.window of
              Layout.Large ->
                E.column
                  [ E.width E.fill
                  , E.spacing 80
                  , E.paddingXY 0 40
                  ]
                  (List.map (viewFeature model.window) (features model))

              Layout.Medium ->
                E.column
                  [ E.width E.fill
                  , E.spacing 70
                  , E.paddingXY 0 40
                  ]
                  (List.map (viewFeature model.window) (features model))

              Layout.Small ->
                E.column
                  [ E.width E.fill
                  , E.spacing 60
                  , E.paddingXY 0 40
                  ]
                  (List.map (viewFeature model.window) (features model))
          ]
    }


viewLanding : Model -> E.Element Msg
viewLanding model =
  let viewChart func chart =
        E.el [ E.width E.fill ] <| E.html <| H.map func chart

      chart1 =
         viewChart Dashboard1Msg (Dashboard1.view model.dashboard1)

      chart2 =
        viewChart Dashboard2Msg (Dashboard2.view model.dashboard2)

      chart3 =
        viewChart Dashboard3Msg (Dashboard3.view model.dashboard3)

      chart4 =
        viewChart Dashboard4Msg (Dashboard4.view model.dashboard4)
  in
  case Layout.screen model.window of
    Layout.Large ->
      E.row
        [ E.width E.fill
        , E.spacing 20
        ]
        [ chart1
        , E.column
            [ E.width E.fill, E.spacing 20 ]
            [ E.row [ E.width E.fill, E.spacing 20 ] [ chart2, chart3 ]
            , chart4
            ]
        ]

    Layout.Medium ->
      E.row
        [ E.width E.fill
        , E.spacing 20
        ]
        [ chart1
        , E.column
            [ E.width E.fill, E.spacing 20 ]
            [ E.row [ E.width E.fill, E.spacing 20 ] [ chart2, chart3 ]
            , chart4
            ]
        ]

    Layout.Small ->
      E.column
        [ E.width E.fill
        , E.spacing 20
        ]
        [ chart4
        , E.row
            [ E.width E.fill, E.spacing 20 ]
            [ E.row [ E.width E.fill, E.spacing 20 ] [ chart2, chart3 ]
            ]
        ]



-- FEATURE


type alias Feature msg =
  { title : String
  , body : List (E.Element msg)
  , togglable : Maybe ( msg, Bool )
  , chart : E.Element msg
  , code : String
  , flipped : Bool
  }


viewFeature : Session.Window -> Feature msg  -> E.Element msg
viewFeature window config =
  let viewText =
        E.textColumn
          [ E.width E.fill
          , E.alignTop
          , E.alignLeft
          , E.spacing 10
          ]
          [ Layout.heading window config.title
          , E.paragraph
              [ F.size 16
              , F.color (E.rgb255 100 100 100)
              , E.paddingXY 0 10
              , E.width E.fill
              ]
              config.body
          ]

      viewImage =
        case config.togglable of
          Nothing ->
            viewChart

          Just ( onToggle, isToggled ) ->
            E.column
              [ E.width E.fill
              , E.alignTop
              , E.centerX
              , E.spacing 20
              ]
              [ viewToggler onToggle isToggled
              , if isToggled then
                  viewCode
                else
                  viewChart

              ]

      viewToggler onToggle isToggled =
        I.button
          [ E.alignRight
          , F.size 14
          ]
          { onPress = Just onToggle
          , label = E.text (if isToggled then "Show chart" else "Show code")
          }

      viewChart =
        E.el
          [ E.width E.fill
          , E.centerX
          , E.alignTop
          ]
          config.chart

      viewCode =
        E.el
          [ E.width E.fill
          , E.height E.fill
          , BG.color (E.rgb255 250 250 250)
          ]
          (Code.view { template = config.code, edits = [] })
  in
  case Layout.screen window of
    Layout.Large ->
      E.row
        [ E.width E.fill
        , E.height E.fill
        , E.spacing 60
        ] <|
        if config.flipped
        then [ viewImage, viewText ]
        else [ viewText, viewImage ]

    Layout.Medium ->
      E.column
        [ E.width (E.maximum 550 E.fill)
        , E.height E.fill
        , E.spacing 30
        , E.centerX
        ]
        [ viewText, viewImage ]

    Layout.Small ->
      E.column
        [ E.width E.fill
        , E.height E.fill
        , E.spacing 20
        ]
        [ viewText, viewImage ]



features : Model -> List (Feature Msg)
features model =
  [ { title = "Intuitive"
    , body =
        [ E.text "The interface of elm-charts mirrors the element and attribute pattern which "
        , E.text "you already know from regular HTML. "
        , Layout.link Route.gettingStarted "Get started"
        , E.text " composing your chart in minutes, then learn and add features gradually."
        ]
    , togglable = Just ( FamiliarToggle, model.familiarToggle )
    , chart = E.html <| H.map (\_ -> None) (Familiar.view ())
    , code = Familiar.smallCode
    , flipped = False
    }

  , { title = "Flexible, yet concise"
    , body =
        [ E.text "No clutter, even with tricky requirements. Great support for "
        , E.text "interactivity, advanced labeling, guidence lines, and "
        , E.text "irregular details."
        ]
    , togglable = Nothing
    , chart = E.html <| H.map ConciseMsg (Concise.view model.concise)
    , code = Concise.smallCode
    , flipped = True
    }

  , { title = "Learn by example"
    , body =
        [ E.text "Outside the regular elm documentation of the API, "
        , E.text "there are "
        , E.el [ F.bold ] (E.text "more than 100 examples ")
        , E.text "on this site to help you "
        , E.text "compose your exact chart. "
        , E.link [ F.underline ] { url = Route.documentation, label = E.text "Explore the catalog" }
        , E.text "."
        ]
    , togglable = Nothing
    , flipped = False
    , chart =
        let viewOne =
              case Layout.screen model.window of
                Layout.Large ->
                  E.link [ E.width (E.minimum 90 E.fill), E.height E.fill ]

                Layout.Medium ->
                  E.link [ E.width (E.minimum 90 E.fill), E.height E.fill ]

                Layout.Small ->
                  E.link [ E.width (E.minimum 50 E.fill), E.height E.fill ]
        in
        [ Examples.BarCharts__Histogram
        , Examples.BarCharts__TooltipStack
        , Examples.Interactivity__Zoom
        , Examples.Frame__Titles
        , Examples.LineCharts__Stepped
        , Examples.ScatterCharts__Labels
        , Examples.ScatterCharts__DataDependent
        , Examples.LineCharts__TooltipStack
        , Examples.LineCharts__Labels
        , Examples.BarCharts__BarLabels
        , Examples.BarCharts__Margin
        , Examples.ScatterCharts__Shapes
        ]
          |> List.map (\id -> { url = Thumbnail.toUrl id, label = E.el [ E.width E.fill ] <| E.html (Examples.view Examples.init id) })
          |> List.map viewOne
          |> E.wrappedRow
              [ E.spacing 30
              , E.alignTop
              , E.width E.fill
              ]
          |> E.map (\_ -> None)
    , code = ""
    }
  ]
