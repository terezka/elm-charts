module Internal.Helpers exposing (..)


import Dict exposing (Dict)


{-| -}
type Attribute c =
  Attribute (c -> c)


apply : List (Attribute a) -> a -> a
apply attrs default =
  let apply_ (Attribute f) a = f a in
  List.foldl apply_ default attrs


noChange : Attribute x
noChange =
  Attribute identity 


withSurround : List a -> (Int -> Maybe a -> a -> Maybe a -> b) -> List b
withSurround all func =
  let fold index prev acc list =
        case list of
          a :: b :: rest -> fold (index + 1) (Just a) (acc ++ [ func index prev a (Just b) ]) (b :: rest)
          a :: [] -> acc ++ [ func index prev a Nothing ]
          [] -> acc
  in
  fold 0 Nothing [] all


withFirst : List a -> (a -> List a -> b) -> Maybe b 
withFirst xs func =
  case xs of 
    x :: rest -> Just (func x rest)
    [] -> Nothing
    

gatherWith : (a -> a -> Bool) -> List a -> List ( a, List a )
gatherWith testFn list =
    let helper scattered gathered =
          case scattered of
            [] -> List.reverse gathered
            toGather :: population ->
              let ( gathering, remaining ) = List.partition (testFn toGather) population in
              helper remaining <| ( toGather, gathering ) :: gathered
    in
    helper list []



-- DEFAULTS


toDefaultColor : Int -> String
toDefaultColor =
  toDefault pink [ purple, pink, blue, green, red, yellow, turquoise, orange, moss, brown ]


toDefault : a -> List a -> Int -> a
toDefault default items index =
  let dict = Dict.fromList (List.indexedMap Tuple.pair items)
      numOfItems = Dict.size dict
      itemIndex = remainderBy numOfItems index
  in
  Dict.get itemIndex dict
    |> Maybe.withDefault default



-- COLORS


{-| -}
pink : String
pink =
  "#ea60df"


{-| -}
purple : String
purple =
  "#7b4dff"


{-| -}
blue : String
blue =
  "#12A5ED"


{-| -}
moss : String
moss =
  "#92b42c"


{-| -}
green : String
green =
  "#71c614"


{-| -}
orange : String
orange =
  "#FF8400"


{-| -}
turquoise : String
turquoise =
  "#22d2ba"


{-| -}
red : String
red =
  "#F5325B"


{-| -}
darkYellow : String
darkYellow =
  "#eabd39"


{-| -}
darkBlue : String
darkBlue =
  "#7345f6"


{-| -}
coral : String
coral =
  "#ea7369"


{-| -}
magenta : String
magenta =
  "#db4cb2"


{-| -}
brown : String
brown =
  "#871c1c"


{-| -}
mint : String
mint =
  "#6df0d2"


{-| -}
yellow : String
yellow =
  "#FFCA00"


gray : String
gray =
  "#EFF2FA"


darkGray : String
darkGray =
  "rgb(200 200 200)"


labelGray : String
labelGray =
  "#808BAB"