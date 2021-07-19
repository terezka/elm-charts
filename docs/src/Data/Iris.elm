module Data.Iris exposing (Datum, Species(..), data, species, only, setosa, virginica, versicolor)


type alias Datum =
  { sepalLength : Float
  , sepalWidth : Float
  , petalLength : Float
  , petalWidth : Float
  , species : Species
  }


type Species
  = Setosa
  | Versicolor
  | Virginica


species : Datum -> String
species datum =
  case datum.species of
    Setosa -> "Setosa"
    Versicolor -> "Versicolor"
    Virginica -> "Virginica"


only : Species -> (Datum -> Float) -> Datum -> Maybe Float
only needed func datum =
  if datum.species == needed then Just (func datum) else Nothing


setosa : List Datum
setosa =
  [ Datum 5.1 3.5 1.4 0.2 Setosa
  , Datum 4.9 3.0 1.4 0.2 Setosa
  , Datum 4.7 3.2 1.3 0.2 Setosa
  , Datum 4.6 3.1 1.5 0.2 Setosa
  , Datum 5.0 3.6 1.4 0.2 Setosa
  , Datum 5.4 3.9 1.7 0.4 Setosa
  , Datum 4.6 3.4 1.4 0.3 Setosa
  , Datum 5.0 3.4 1.5 0.2 Setosa
  , Datum 4.4 2.9 1.4 0.2 Setosa
  , Datum 4.9 3.1 1.5 0.1 Setosa
  , Datum 5.4 3.7 1.5 0.2 Setosa
  , Datum 4.8 3.4 1.6 0.2 Setosa
  , Datum 4.8 3.0 1.4 0.1 Setosa
  , Datum 4.3 3.0 1.1 0.1 Setosa
  , Datum 5.8 4.0 1.2 0.2 Setosa
  , Datum 5.7 4.4 1.5 0.4 Setosa
  , Datum 5.4 3.9 1.3 0.4 Setosa
  , Datum 5.1 3.5 1.4 0.3 Setosa
  , Datum 5.7 3.8 1.7 0.3 Setosa
  , Datum 5.1 3.8 1.5 0.3 Setosa
  , Datum 5.4 3.4 1.7 0.2 Setosa
  , Datum 5.1 3.7 1.5 0.4 Setosa
  , Datum 4.6 3.6 1.0 0.2 Setosa
  , Datum 5.1 3.3 1.7 0.5 Setosa
  , Datum 4.8 3.4 1.9 0.2 Setosa
  , Datum 5.0 3.0 1.6 0.2 Setosa
  , Datum 5.0 3.4 1.6 0.4 Setosa
  , Datum 5.2 3.5 1.5 0.2 Setosa
  , Datum 5.2 3.4 1.4 0.2 Setosa
  , Datum 4.7 3.2 1.6 0.2 Setosa
  , Datum 4.8 3.1 1.6 0.2 Setosa
  , Datum 5.4 3.4 1.5 0.4 Setosa
  , Datum 5.2 4.1 1.5 0.1 Setosa
  , Datum 5.5 4.2 1.4 0.2 Setosa
  , Datum 4.9 3.1 1.5 0.1 Setosa
  , Datum 5.0 3.2 1.2 0.2 Setosa
  , Datum 5.5 3.5 1.3 0.2 Setosa
  , Datum 4.9 3.1 1.5 0.1 Setosa
  , Datum 4.4 3.0 1.3 0.2 Setosa
  , Datum 5.1 3.4 1.5 0.2 Setosa
  , Datum 5.0 3.5 1.3 0.3 Setosa
  , Datum 4.5 2.3 1.3 0.3 Setosa
  , Datum 4.4 3.2 1.3 0.2 Setosa
  , Datum 5.0 3.5 1.6 0.6 Setosa
  , Datum 5.1 3.8 1.9 0.4 Setosa
  , Datum 4.8 3.0 1.4 0.3 Setosa
  , Datum 5.1 3.8 1.6 0.2 Setosa
  , Datum 4.6 3.2 1.4 0.2 Setosa
  , Datum 5.3 3.7 1.5 0.2 Setosa
  , Datum 5.0 3.3 1.4 0.2 Setosa
  ]


versicolor : List Datum
versicolor =
  [ Datum 7.0 3.2 4.7 1.4 Versicolor
  , Datum 6.4 3.2 4.5 1.5 Versicolor
  , Datum 6.9 3.1 4.9 1.5 Versicolor
  , Datum 5.5 2.3 4.0 1.3 Versicolor
  , Datum 6.5 2.8 4.6 1.5 Versicolor
  , Datum 5.7 2.8 4.5 1.3 Versicolor
  , Datum 6.3 3.3 4.7 1.6 Versicolor
  , Datum 4.9 2.4 3.3 1.0 Versicolor
  , Datum 6.6 2.9 4.6 1.3 Versicolor
  , Datum 5.2 2.7 3.9 1.4 Versicolor
  , Datum 5.0 2.0 3.5 1.0 Versicolor
  , Datum 5.9 3.0 4.2 1.5 Versicolor
  , Datum 6.0 2.2 4.0 1.0 Versicolor
  , Datum 6.1 2.9 4.7 1.4 Versicolor
  , Datum 5.6 2.9 3.6 1.3 Versicolor
  , Datum 6.7 3.1 4.4 1.4 Versicolor
  , Datum 5.6 3.0 4.5 1.5 Versicolor
  , Datum 5.8 2.7 4.1 1.0 Versicolor
  , Datum 6.2 2.2 4.5 1.5 Versicolor
  , Datum 5.6 2.5 3.9 1.1 Versicolor
  , Datum 5.9 3.2 4.8 1.8 Versicolor
  , Datum 6.1 2.8 4.0 1.3 Versicolor
  , Datum 6.3 2.5 4.9 1.5 Versicolor
  , Datum 6.1 2.8 4.7 1.2 Versicolor
  , Datum 6.4 2.9 4.3 1.3 Versicolor
  , Datum 6.6 3.0 4.4 1.4 Versicolor
  , Datum 6.8 2.8 4.8 1.4 Versicolor
  , Datum 6.7 3.0 5.0 1.7 Versicolor
  , Datum 6.0 2.9 4.5 1.5 Versicolor
  , Datum 5.7 2.6 3.5 1.0 Versicolor
  , Datum 5.5 2.4 3.8 1.1 Versicolor
  , Datum 5.5 2.4 3.7 1.0 Versicolor
  , Datum 5.8 2.7 3.9 1.2 Versicolor
  , Datum 6.0 2.7 5.1 1.6 Versicolor
  , Datum 5.4 3.0 4.5 1.5 Versicolor
  , Datum 6.0 3.4 4.5 1.6 Versicolor
  , Datum 6.7 3.1 4.7 1.5 Versicolor
  , Datum 6.3 2.3 4.4 1.3 Versicolor
  , Datum 5.6 3.0 4.1 1.3 Versicolor
  , Datum 5.5 2.5 4.0 1.3 Versicolor
  , Datum 5.5 2.6 4.4 1.2 Versicolor
  , Datum 6.1 3.0 4.6 1.4 Versicolor
  , Datum 5.8 2.6 4.0 1.2 Versicolor
  , Datum 5.0 2.3 3.3 1.0 Versicolor
  , Datum 5.6 2.7 4.2 1.3 Versicolor
  , Datum 5.7 3.0 4.2 1.2 Versicolor
  , Datum 5.7 2.9 4.2 1.3 Versicolor
  , Datum 6.2 2.9 4.3 1.3 Versicolor
  , Datum 5.1 2.5 3.0 1.1 Versicolor
  , Datum 5.7 2.8 4.1 1.3 Versicolor
  ]


virginica : List Datum
virginica =
  [ Datum 6.3 3.3 6.0 2.5 Virginica
  , Datum 5.8 2.7 5.1 1.9 Virginica
  , Datum 7.1 3.0 5.9 2.1 Virginica
  , Datum 6.3 2.9 5.6 1.8 Virginica
  , Datum 6.5 3.0 5.8 2.2 Virginica
  , Datum 7.6 3.0 6.6 2.1 Virginica
  , Datum 4.9 2.5 4.5 1.7 Virginica
  , Datum 7.3 2.9 6.3 1.8 Virginica
  , Datum 6.7 2.5 5.8 1.8 Virginica
  , Datum 7.2 3.6 6.1 2.5 Virginica
  , Datum 6.5 3.2 5.1 2.0 Virginica
  , Datum 6.4 2.7 5.3 1.9 Virginica
  , Datum 6.8 3.0 5.5 2.1 Virginica
  , Datum 5.7 2.5 5.0 2.0 Virginica
  , Datum 5.8 2.8 5.1 2.4 Virginica
  , Datum 6.4 3.2 5.3 2.3 Virginica
  , Datum 6.5 3.0 5.5 1.8 Virginica
  , Datum 7.7 3.8 6.7 2.2 Virginica
  , Datum 7.7 2.6 6.9 2.3 Virginica
  , Datum 6.0 2.2 5.0 1.5 Virginica
  , Datum 6.9 3.2 5.7 2.3 Virginica
  , Datum 5.6 2.8 4.9 2.0 Virginica
  , Datum 7.7 2.8 6.7 2.0 Virginica
  , Datum 6.3 2.7 4.9 1.8 Virginica
  , Datum 6.7 3.3 5.7 2.1 Virginica
  , Datum 7.2 3.2 6.0 1.8 Virginica
  , Datum 6.2 2.8 4.8 1.8 Virginica
  , Datum 6.1 3.0 4.9 1.8 Virginica
  , Datum 6.4 2.8 5.6 2.1 Virginica
  , Datum 7.2 3.0 5.8 1.6 Virginica
  , Datum 7.4 2.8 6.1 1.9 Virginica
  , Datum 7.9 3.8 6.4 2.0 Virginica
  , Datum 6.4 2.8 5.6 2.2 Virginica
  , Datum 6.3 2.8 5.1 1.5 Virginica
  , Datum 6.1 2.6 5.6 1.4 Virginica
  , Datum 7.7 3.0 6.1 2.3 Virginica
  , Datum 6.3 3.4 5.6 2.4 Virginica
  , Datum 6.4 3.1 5.5 1.8 Virginica
  , Datum 6.0 3.0 4.8 1.8 Virginica
  , Datum 6.9 3.1 5.4 2.1 Virginica
  , Datum 6.7 3.1 5.6 2.4 Virginica
  , Datum 6.9 3.1 5.1 2.3 Virginica
  , Datum 5.8 2.7 5.1 1.9 Virginica
  , Datum 6.8 3.2 5.9 2.3 Virginica
  , Datum 6.7 3.3 5.7 2.5 Virginica
  , Datum 6.7 3.0 5.2 2.3 Virginica
  , Datum 6.3 2.5 5.0 1.9 Virginica
  , Datum 6.5 3.0 5.2 2.0 Virginica
  , Datum 6.2 3.4 5.4 2.3 Virginica
  , Datum 5.9 3.0 5.1 1.8 Virginica
  ]


data : List Datum
data =
  [ Datum 5.1 3.5 1.4 0.2 Setosa
  , Datum 4.9 3.0 1.4 0.2 Setosa
  , Datum 4.7 3.2 1.3 0.2 Setosa
  , Datum 4.6 3.1 1.5 0.2 Setosa
  , Datum 5.0 3.6 1.4 0.2 Setosa
  , Datum 5.4 3.9 1.7 0.4 Setosa
  , Datum 4.6 3.4 1.4 0.3 Setosa
  , Datum 5.0 3.4 1.5 0.2 Setosa
  , Datum 4.4 2.9 1.4 0.2 Setosa
  , Datum 4.9 3.1 1.5 0.1 Setosa
  , Datum 5.4 3.7 1.5 0.2 Setosa
  , Datum 4.8 3.4 1.6 0.2 Setosa
  , Datum 4.8 3.0 1.4 0.1 Setosa
  , Datum 4.3 3.0 1.1 0.1 Setosa
  , Datum 5.8 4.0 1.2 0.2 Setosa
  , Datum 5.7 4.4 1.5 0.4 Setosa
  , Datum 5.4 3.9 1.3 0.4 Setosa
  , Datum 5.1 3.5 1.4 0.3 Setosa
  , Datum 5.7 3.8 1.7 0.3 Setosa
  , Datum 5.1 3.8 1.5 0.3 Setosa
  , Datum 5.4 3.4 1.7 0.2 Setosa
  , Datum 5.1 3.7 1.5 0.4 Setosa
  , Datum 4.6 3.6 1.0 0.2 Setosa
  , Datum 5.1 3.3 1.7 0.5 Setosa
  , Datum 4.8 3.4 1.9 0.2 Setosa
  , Datum 5.0 3.0 1.6 0.2 Setosa
  , Datum 5.0 3.4 1.6 0.4 Setosa
  , Datum 5.2 3.5 1.5 0.2 Setosa
  , Datum 5.2 3.4 1.4 0.2 Setosa
  , Datum 4.7 3.2 1.6 0.2 Setosa
  , Datum 4.8 3.1 1.6 0.2 Setosa
  , Datum 5.4 3.4 1.5 0.4 Setosa
  , Datum 5.2 4.1 1.5 0.1 Setosa
  , Datum 5.5 4.2 1.4 0.2 Setosa
  , Datum 4.9 3.1 1.5 0.1 Setosa
  , Datum 5.0 3.2 1.2 0.2 Setosa
  , Datum 5.5 3.5 1.3 0.2 Setosa
  , Datum 4.9 3.1 1.5 0.1 Setosa
  , Datum 4.4 3.0 1.3 0.2 Setosa
  , Datum 5.1 3.4 1.5 0.2 Setosa
  , Datum 5.0 3.5 1.3 0.3 Setosa
  , Datum 4.5 2.3 1.3 0.3 Setosa
  , Datum 4.4 3.2 1.3 0.2 Setosa
  , Datum 5.0 3.5 1.6 0.6 Setosa
  , Datum 5.1 3.8 1.9 0.4 Setosa
  , Datum 4.8 3.0 1.4 0.3 Setosa
  , Datum 5.1 3.8 1.6 0.2 Setosa
  , Datum 4.6 3.2 1.4 0.2 Setosa
  , Datum 5.3 3.7 1.5 0.2 Setosa
  , Datum 5.0 3.3 1.4 0.2 Setosa
  , Datum 7.0 3.2 4.7 1.4 Versicolor
  , Datum 6.4 3.2 4.5 1.5 Versicolor
  , Datum 6.9 3.1 4.9 1.5 Versicolor
  , Datum 5.5 2.3 4.0 1.3 Versicolor
  , Datum 6.5 2.8 4.6 1.5 Versicolor
  , Datum 5.7 2.8 4.5 1.3 Versicolor
  , Datum 6.3 3.3 4.7 1.6 Versicolor
  , Datum 4.9 2.4 3.3 1.0 Versicolor
  , Datum 6.6 2.9 4.6 1.3 Versicolor
  , Datum 5.2 2.7 3.9 1.4 Versicolor
  , Datum 5.0 2.0 3.5 1.0 Versicolor
  , Datum 5.9 3.0 4.2 1.5 Versicolor
  , Datum 6.0 2.2 4.0 1.0 Versicolor
  , Datum 6.1 2.9 4.7 1.4 Versicolor
  , Datum 5.6 2.9 3.6 1.3 Versicolor
  , Datum 6.7 3.1 4.4 1.4 Versicolor
  , Datum 5.6 3.0 4.5 1.5 Versicolor
  , Datum 5.8 2.7 4.1 1.0 Versicolor
  , Datum 6.2 2.2 4.5 1.5 Versicolor
  , Datum 5.6 2.5 3.9 1.1 Versicolor
  , Datum 5.9 3.2 4.8 1.8 Versicolor
  , Datum 6.1 2.8 4.0 1.3 Versicolor
  , Datum 6.3 2.5 4.9 1.5 Versicolor
  , Datum 6.1 2.8 4.7 1.2 Versicolor
  , Datum 6.4 2.9 4.3 1.3 Versicolor
  , Datum 6.6 3.0 4.4 1.4 Versicolor
  , Datum 6.8 2.8 4.8 1.4 Versicolor
  , Datum 6.7 3.0 5.0 1.7 Versicolor
  , Datum 6.0 2.9 4.5 1.5 Versicolor
  , Datum 5.7 2.6 3.5 1.0 Versicolor
  , Datum 5.5 2.4 3.8 1.1 Versicolor
  , Datum 5.5 2.4 3.7 1.0 Versicolor
  , Datum 5.8 2.7 3.9 1.2 Versicolor
  , Datum 6.0 2.7 5.1 1.6 Versicolor
  , Datum 5.4 3.0 4.5 1.5 Versicolor
  , Datum 6.0 3.4 4.5 1.6 Versicolor
  , Datum 6.7 3.1 4.7 1.5 Versicolor
  , Datum 6.3 2.3 4.4 1.3 Versicolor
  , Datum 5.6 3.0 4.1 1.3 Versicolor
  , Datum 5.5 2.5 4.0 1.3 Versicolor
  , Datum 5.5 2.6 4.4 1.2 Versicolor
  , Datum 6.1 3.0 4.6 1.4 Versicolor
  , Datum 5.8 2.6 4.0 1.2 Versicolor
  , Datum 5.0 2.3 3.3 1.0 Versicolor
  , Datum 5.6 2.7 4.2 1.3 Versicolor
  , Datum 5.7 3.0 4.2 1.2 Versicolor
  , Datum 5.7 2.9 4.2 1.3 Versicolor
  , Datum 6.2 2.9 4.3 1.3 Versicolor
  , Datum 5.1 2.5 3.0 1.1 Versicolor
  , Datum 5.7 2.8 4.1 1.3 Versicolor
  , Datum 6.3 3.3 6.0 2.5 Virginica
  , Datum 5.8 2.7 5.1 1.9 Virginica
  , Datum 7.1 3.0 5.9 2.1 Virginica
  , Datum 6.3 2.9 5.6 1.8 Virginica
  , Datum 6.5 3.0 5.8 2.2 Virginica
  , Datum 7.6 3.0 6.6 2.1 Virginica
  , Datum 4.9 2.5 4.5 1.7 Virginica
  , Datum 7.3 2.9 6.3 1.8 Virginica
  , Datum 6.7 2.5 5.8 1.8 Virginica
  , Datum 7.2 3.6 6.1 2.5 Virginica
  , Datum 6.5 3.2 5.1 2.0 Virginica
  , Datum 6.4 2.7 5.3 1.9 Virginica
  , Datum 6.8 3.0 5.5 2.1 Virginica
  , Datum 5.7 2.5 5.0 2.0 Virginica
  , Datum 5.8 2.8 5.1 2.4 Virginica
  , Datum 6.4 3.2 5.3 2.3 Virginica
  , Datum 6.5 3.0 5.5 1.8 Virginica
  , Datum 7.7 3.8 6.7 2.2 Virginica
  , Datum 7.7 2.6 6.9 2.3 Virginica
  , Datum 6.0 2.2 5.0 1.5 Virginica
  , Datum 6.9 3.2 5.7 2.3 Virginica
  , Datum 5.6 2.8 4.9 2.0 Virginica
  , Datum 7.7 2.8 6.7 2.0 Virginica
  , Datum 6.3 2.7 4.9 1.8 Virginica
  , Datum 6.7 3.3 5.7 2.1 Virginica
  , Datum 7.2 3.2 6.0 1.8 Virginica
  , Datum 6.2 2.8 4.8 1.8 Virginica
  , Datum 6.1 3.0 4.9 1.8 Virginica
  , Datum 6.4 2.8 5.6 2.1 Virginica
  , Datum 7.2 3.0 5.8 1.6 Virginica
  , Datum 7.4 2.8 6.1 1.9 Virginica
  , Datum 7.9 3.8 6.4 2.0 Virginica
  , Datum 6.4 2.8 5.6 2.2 Virginica
  , Datum 6.3 2.8 5.1 1.5 Virginica
  , Datum 6.1 2.6 5.6 1.4 Virginica
  , Datum 7.7 3.0 6.1 2.3 Virginica
  , Datum 6.3 3.4 5.6 2.4 Virginica
  , Datum 6.4 3.1 5.5 1.8 Virginica
  , Datum 6.0 3.0 4.8 1.8 Virginica
  , Datum 6.9 3.1 5.4 2.1 Virginica
  , Datum 6.7 3.1 5.6 2.4 Virginica
  , Datum 6.9 3.1 5.1 2.3 Virginica
  , Datum 5.8 2.7 5.1 1.9 Virginica
  , Datum 6.8 3.2 5.9 2.3 Virginica
  , Datum 6.7 3.3 5.7 2.5 Virginica
  , Datum 6.7 3.0 5.2 2.3 Virginica
  , Datum 6.3 2.5 5.0 1.9 Virginica
  , Datum 6.5 3.0 5.2 2.0 Virginica
  , Datum 6.2 3.4 5.4 2.3 Virginica
  , Datum 5.9 3.0 5.1 1.8 Virginica
  ]
