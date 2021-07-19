module Ui.Thumbnail exposing (..)

import Html.Attributes as HA
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


type alias Group =
  { title : String
  , order : Int
  , ids : List Examples.Id
  }


toUrl : Examples.Id -> String
toUrl id =
  let meta = Examples.meta id in
  "/documentation/" ++ urlify meta.category ++ "/" ++ urlify meta.name


toUrlGroup : String -> String
toUrlGroup title =
  "/documentation/" ++ urlify title


urlify : String -> String
urlify =
  String.replace " " "-" >> String.replace "/" "-" >> String.toLower


groups : List Group
groups =
  Dict.values dictGroups
    |> List.sortBy .order


firstGroup : Group
firstGroup =
  List.head groups
    |> Maybe.withDefault (Group "" 1 [])


dictGroups : Dict.Dict String Group
dictGroups =
  let groupBy id =
        let meta = Examples.meta id in
        Dict.update (toUrlGroup meta.category) (updateCat meta id)

      updateCat meta id maybeIds =
        case maybeIds of
          Just group -> Just { group | ids = id :: group.ids }
          Nothing -> Just (Group meta.category meta.categoryOrder [ id ])
  in
  List.foldl groupBy Dict.empty Examples.all


viewSelected : Examples.Model -> String -> List (E.Element Examples.Msg)
viewSelected model selected =
  dictGroups
    |> Dict.get selected
    |> Maybe.withDefault firstGroup
    |> viewGroup model


viewGroup : Examples.Model -> Group -> List (E.Element Examples.Msg)
viewGroup model group =
  group.ids
    |> List.sortBy (Examples.meta >> .order)
    |> List.map (viewOne model)


viewOne : Examples.Model -> Examples.Id -> E.Element Examples.Msg
viewOne model id =
  let view meta =
        E.column
          [ E.width E.fill
          , E.height E.fill
          , E.spacing 5
          ]
          [ E.el [ F.size 16 ] (E.text meta.name)
          , E.el [ F.size 12 ] (E.text meta.description)
          , E.html (Examples.view model id)
              |> E.el
                  [ E.width E.fill
                  , E.height E.fill
                  , E.paddingXY 0 15
                  ]
          ]
  in
  E.link
    [ E.width E.fill
    , E.centerX
    ]
    { url = toUrl id
    , label =
        let meta = Examples.meta id in
        if String.contains "Zoom" meta.name
        then E.el [ E.htmlAttribute (HA.style "pointer-events" "none"), E.width E.fill ] (view meta)
        else view meta
    }