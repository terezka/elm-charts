module Types exposing (..)


type alias DataSet = List Point


dataSet : List (Int, Int) -> DataSet
dataSet coords =
    List.map (\(x, y) -> dataPoint x y) coords


type alias DataSetSingle = List Int


-- The Point type is a point relative to the svg base point 

type alias Point
  = { x : Int, y : Int }


point : Int -> Int -> Point
point x y =
  { x = x, y = y }


-- The DataPoint type is a point relative to the base point (0,0) in the drawn graph

type alias DataPoint
  = { x : Int, y : Int }


dataPoint : Int -> Int -> DataPoint
dataPoint x y =
  { x = x, y = y }


