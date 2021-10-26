module Ui.Article exposing (Article, map)


import Html as H
import Element as E
import Element.Font as F
import Element.Border as B
import Element.Background as BG


type alias Article msg =
  { title : String
  , abstract : String
  , landing : () -> E.Element msg
  , body : () -> List (E.Element msg)
  }


map : (a -> b) -> Article a -> Article b
map func a =
  { title = a.title
  , abstract = a.abstract
  , landing = \x -> E.map func (a.landing x)
  , body = \x -> List.map (E.map func) (a.body x)
  }