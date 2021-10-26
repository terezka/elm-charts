module Articles exposing (Id(..), Model, init, Msg, update, view, name, all, first, meta)


-- THIS IS A GENERATED MODULE!

import Ui.Article



import Articles.GenderAndSalery as Example0


type Id
  = GenderAndSalery


type alias Model =
  { example0 : Example0.Model
  }


init =
  { example0 = Example0.init
  }


type Msg
  = ExampleMsg0 Example0.Msg


update msg model =
  case msg of
    ExampleMsg0 sub -> { model | example0 = Example0.update sub model.example0 }


view model chosen =
  case chosen of
    GenderAndSalery -> Ui.Article.map ExampleMsg0 (Example0.view model.example0)




name : Id -> String
name chosen =
  case chosen of
    GenderAndSalery -> "Articles.GenderAndSalery"


meta chosen =
  case chosen of
    GenderAndSalery -> Example0.meta


all : List Id
all =
  [ GenderAndSalery
  ]


first : Id
first =
  GenderAndSalery

