module Internal.Property exposing (..)


{-| -}
type Property data meta inter deco
  = Property (Config data meta inter deco)
  | Stacked (List (Config data meta inter deco))


{-| -}
type alias Config data meta inter deco =
  { value : data -> Maybe Float
  , visual : data -> Maybe Float
  , format : data -> String
  , meta : Maybe meta
  , inter : List (inter -> inter)
  , attrs : List (deco -> deco)
  , extra : Int -> Int -> Int -> Maybe meta -> data -> List (deco -> deco)
  }


{-| -}
property : (data -> Maybe Float) -> List (inter -> inter) -> List (deco -> deco) -> Property data meta inter deco
property value inter attrs =
  Property
    { value = value
    , visual = value
    , format = value >> Maybe.map String.fromFloat >> Maybe.withDefault "N/A"
    , meta = Nothing
    , inter = inter
    , attrs = attrs
    , extra = \_ _ _ _ _ -> []
    }


{-| -}
format : (Maybe Float -> String) -> Property data meta inter deco -> Property data meta inter deco
format value prop =
  case prop of
    Property con -> Property { con | format = con.value >> value }
    Stacked cons -> Stacked (List.map (\con -> { con | format = con.value >> value }) cons)


{-| -}
meta : meta -> Property data meta inter deco -> Property data meta inter deco
meta value prop =
  case prop of
    Property con -> Property { con | meta = Just value }
    Stacked cons -> Stacked (List.map (\con -> { con | meta = Just value }) cons)


{-| -}
variation : (Int -> Int -> Int -> Maybe meta -> data -> List (deco -> deco)) -> Property data meta inter deco -> Property data meta inter deco
variation attrs prop =
  case prop of
    Property c ->  Property { c | extra = \p s i m d -> c.extra p s i m d ++ attrs p s i m d }
    Stacked cs -> Stacked (List.map (\c -> { c | extra = \p s i m d -> c.extra p s i m d ++ attrs p s i m d }) cs)


{-| -}
stacked : List (Property data meta inter deco) -> Property data meta inter deco
stacked properties =
  let configs =
        List.concatMap toConfigs (List.reverse properties)

      stack list prev result =
        case list of
          one :: rest ->
            let toYs_ = one.value :: prev in
            stack rest toYs_ ({ one | visual = toVisual toYs_ } :: result)

          [] ->
            result

      toVisual toYs_ datum =
        let vs = List.filterMap (\toY -> toY datum) toYs_ in
        if List.length vs /= List.length toYs_ then Nothing else Just (List.sum vs)
  in
  Stacked (stack configs [] [])


{-| -}
toYs : List (Property data meta inter deco) -> List (data -> Maybe Float)
toYs properties =
  let each prop =
        case prop of
          Property config -> [ config.visual ]
          Stacked configs -> List.map .visual configs
  in
  List.concatMap each properties


{-| -}
toConfigs : Property data meta inter deco -> List (Config data meta inter deco)
toConfigs prop =
  case prop of
    Property config -> [ config ]
    Stacked configs -> configs
