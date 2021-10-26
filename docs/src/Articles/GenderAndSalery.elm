module Articles.GenderAndSalery exposing (meta, Model, Msg, init, update, view)

import Html as H
import Html.Attributes as HA
import Element as E
import Element.Font as F
import Element.Border as B
import Element.Input as I
import Element.Background as BG
import Ui.Article as Article
import Articles.GenderAndSalery.Data as Salary
import Articles.GenderAndSalery.Bubble as Bubble
import Articles.GenderAndSalery.Bars as Bars
import Articles.GenderAndSalery.EducationChart as Education


meta =
  { id = "gender-equality-in-denmark"
  }


type alias Model =
  { bubbles : Bubble.Model
  , bars : Bars.Model
  , education : Education.Model
  , year : Float
  }


init : Model
init  =
  { bubbles = Bubble.init
  , bars = Bars.init
  , education = Education.init
  , year = 2019
  }


type Msg
  = BubbleMsg Bubble.Msg
  | BarsMsg Bars.Msg
  | EducationMsg Education.Msg
  | OnYear Float


update : Msg -> Model -> Model
update msg model =
  case msg of
    BubbleMsg subMsg ->
      { model | bubbles = Bubble.update subMsg model.bubbles }

    BarsMsg subMsg ->
      { model | bars = Bars.update subMsg model.bars }

    EducationMsg subMsg ->
      { model | education = Education.update subMsg model.education }

    OnYear year ->
      { model | year = year
      , bubbles = Bubble.init
      , education = Education.reset model.education
      , bars = Bars.reset model.bars
      }


view : Model -> Article.Article Msg
view model =
  { title = "Gender equality in Denmark"
  , abstract = "Denmark is often praised for its gender equality. But even in one of the most equal countries in the world, how equal are men and women really?"
  , landing = \_ -> E.html <| H.map BubbleMsg (Bubble.viewChart model.bubbles 2019)
  , body = \_ ->
      [ E.paragraph
          [ E.width (E.maximum 600 E.fill)
          , F.size 14
          , F.italic
          ]
          [ E.text "Denmark is often praised for its gender equality. But even in one of the most equal countries in the world, how equal are men and women really?" ]

      , E.paragraph
          [ F.size 14
          , E.width (E.maximum 600 E.fill)
          ]
          [ E.text "Note that the data visualized here is already aggregated into averages. This means that there might "
          , E.text "be women or men earning more or less than what the numbers show. For example, there may well be a woman CEO being payed the "
          , E.text "same or more than her male counter part, but what the data shows is that "
          , E.el [ F.italic ] (E.text "on average")
          , E.text " this is not the case. This is particularily important to keep in mind when interpreting the second chart."
          ]

      , E.el [ F.size 18 ] (E.text "Women's percentage of men's salary")

      , E.row
          [ E.width E.fill
          , E.spacing 20
          ] <|
          let button year =
                I.button
                  [ E.width E.fill
                  , BG.color (E.rgb255 250 250 250)
                  , B.rounded 5
                  , B.width 1
                  , B.color (if year == model.year then E.rgb255 220 220 220 else E.rgb255 250 250 250)
                  , E.mouseOver [ BG.color (E.rgb255 245 245 245) ]
                  , E.focused [ BG.color (E.rgb255 245 245 245) ]
                  , E.htmlAttribute (HA.style "overflow" "hidden")
                  ]
                  { onPress = Just (OnYear year)
                  , label =
                      let avg =
                            Salary.avgSalaryWomen year / Salary.avgSalaryMen year
                      in
                      E.column
                        [ E.width E.fill
                        , E.spacing 10
                        , E.paddingXY 20 20
                        ]
                        [ E.el [ F.size 14 ] (E.text (String.fromFloat year))
                        , E.text <| "Women earn " ++ String.fromFloat (toFloat (round (avg * 1000)) / 10) ++ " per 100 DKK"
                        ]
                  }
          in
          [ button 2019
          , button 2018
          , button 2017
          , button 2016
          ]

      , E.el
          [ E.width (E.maximum 1000 E.fill)
          ]
          (E.map BubbleMsg (Bubble.view model.bubbles model.year))

      , E.el [ F.size 16 ] (E.text "Women in each salary bracket")

      , E.el
          [ E.width (E.maximum 1000 E.fill)
          ]
          (E.map BarsMsg (Bars.view model.bars model.year))

      , E.el [ F.size 18 ] (E.text "Women and men's education")

      , E.el
          [ E.width (E.maximum 1000 E.fill)
          ]
          (E.map EducationMsg (Education.view model.education))

      , E.el [ F.size 14 ] (E.text "Source: Danmarks Statestik.")
      ]
  }