module Internal.Many exposing (..)

import Html as H exposing (Html)
import Html.Attributes as HA
import Svg as S exposing (Svg)
import Svg.Attributes as SA
import Internal.Coordinates as Coord exposing (Point, Position, Plane)
import Dict exposing (Dict)
import Internal.Property as P exposing (Property)
import Chart.Svg as S
import Internal.Item as I
import Internal.Helpers as Helpers


{-| -}
type alias Many x =
  I.Rendered ( x, List x )


{-| -}
getMembers : Many x -> List x
getMembers (I.Rendered (x, xs) _) =
  x :: xs


{-| -}
getMember : Many x -> x
getMember (I.Rendered (x, xs) _) =
  x


{-| -}
generalize : Many (I.One data x) -> List (I.One data I.Any)
generalize many =
  List.map I.generalize (getMembers many)


{-| -}
getDatas : Many (I.One data x) -> List data
getDatas (I.Rendered (x, xs) _) =
  I.getDatum x :: List.map I.getDatum xs


{-| -}
getData : Many (I.One data x) -> data
getData (I.Rendered (x, xs) _) =
  I.getDatum x


mapData : (a -> b) -> Many (I.One a x) -> Many (I.One b x)
mapData func (I.Rendered (x, xs) _) =
  toGroup (I.map func x) (List.map (I.map func) xs)



-- GROUPING


type Remodel a b =
  Remodel
    (Plane -> b -> Position)
    (List a -> List b)


apply : Remodel a b -> List a -> List b
apply (Remodel _ func) items =
  func items


andThen : Remodel x y -> Remodel a x -> Remodel a y
andThen (Remodel toPos2 func2) (Remodel toPos1 func1) =
  Remodel toPos2 <| \items -> func2 (func1 items)



-- BASIC GROUPING


any : Remodel (I.One data I.Any) (I.One data I.Any)
any =
  Remodel I.getPosition identity


dots : Remodel (I.One data I.Any) (I.One data S.Dot)
dots =
  let centerPosition plane item =
        fromPoint (I.getPosition plane item |> Coord.center)
  in
  Remodel centerPosition (List.filterMap I.isDot)


bars : Remodel (I.One data I.Any) (I.One data S.Bar)
bars =
  Remodel I.getPosition (List.filterMap I.isBar)


real : Remodel (I.One data config) (I.One data config)
real =
  Remodel I.getPosition (List.filter I.isReal)


named : List String -> Remodel (I.One data config) (I.One data config)
named names =
  let onlyAcceptedNames i =
        List.member (I.getName i) names
  in
  Remodel I.getPosition (List.filter onlyAcceptedNames)



-- SAME X


sameX : Remodel (I.One data x) (Many (I.One data x))
sameX =
  let fullVertialPosition plane item =
        I.getPosition plane item
          |> \pos -> { pos | y1 = plane.y.min, y2 = plane.y.max }
  in
  Remodel fullVertialPosition <|
    groupingHelp
      { shared = \config -> { x1 = config.x1, x2 = config.x2 }
      , equality = \a b -> a.x1 == b.x1 && a.x2 == b.x2
      , edits = identity
      }



-- SAME STACK


stacks : Remodel (I.One data x) (Many (I.One data x))
stacks =
  Remodel I.getPosition <|
    groupingHelp
      { shared = \config ->
            { x1 = config.x1
            , x2 = config.x2
            , property = config.identification.stackIndex
            }
      , equality = \a b -> a.x1 == b.x1 && a.x2 == b.x2 && a.property == b.property
      , edits = identity
      }



-- SAME BIN


bins : Remodel (I.One data x) (Many (I.One data x))
bins =
  Remodel I.getPosition <|
    groupingHelp
      { shared = \config ->
          { x1 = config.x1
          , x2 = config.x2
          , elIndex = config.identification.elementIndex
          , dataIndex = config.identification.dataIndex
          }
      , equality = \a b -> a.x1 == b.x1 && a.x2 == b.x2 && a.elIndex == b.elIndex && a.dataIndex == b.dataIndex
      , edits = editLimits (\item pos -> { pos | x1 = I.getX1 item, x2 = I.getX2 item })
      }



-- HELPERS


groupingHelp :
  { shared : x -> a
  , equality : a -> a -> Bool
  , edits : Many (I.Rendered x) -> Many (I.Rendered x)
  }
  -> List (I.Rendered x)
  -> List (Many (I.Rendered x))
groupingHelp { shared, equality, edits } items =
  let toShared (I.Rendered meta item) = shared meta
      toEquality aO bO = equality (toShared aO) (toShared bO)
      toNewGroup ( i, is ) = toGroup i is |> edits
  in
  List.map toNewGroup (Helpers.gatherWith toEquality items)


editLimits : (x -> Position -> Position) -> Many x -> Many x
editLimits edit (I.Rendered ( x, xs ) rendering) =
  I.Rendered ( x, xs ) { rendering | limits = edit x rendering.limits }


toGroup : I.Rendered x -> List (I.Rendered x) -> Many (I.Rendered x)
toGroup first rest =
  let all = first :: rest in
  I.Rendered ( first, rest )
    { limits = Coord.foldPosition I.getLimits all
    , toPosition = \plane -> Coord.foldPosition (I.getPosition plane) all
    , render = \plane _ -> S.g [ SA.class "elm-charts__group" ] (List.map (I.render plane) all)
    , tooltip = \c -> [ H.table [] (List.concatMap I.tooltip all) ]
    }


fromPoint : Point -> Position
fromPoint point =
  { x1 = point.x, y1 = point.y, x2 = point.x, y2 = point.y }
