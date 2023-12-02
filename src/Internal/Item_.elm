module Internal.Item exposing


{-| An item is anything rendered on the chart which should be able to be found again later. 
You can think of is as a kind of virtual dom for the chart. You cannot search the chart for things
once they are rendered, so we need to store a map of all the things to be able to find them.

-}
type Item data x
  = Item data Ids TooltipText x


type Any data
  = Bin    (List Bar)
  | Stack  (List Bar)
  | Series (List Dot)
  | Bar    Missing CS.Bar Position
  | Dot    Missing CS.Dot Position
  | Custom CS.General (Plane -> S.Svg) (Plane -> H.Html)


type Bin    = OnlyBin    (List Bar)
type Stack  = OnlyStack  (List Bar)
type Series = OnlySeries (List Dot)
type Bar    = OnlyBar    Missing CS.Bar
type Dot    = OnlyDot    Missing CS.Dot 


{-| -}
type alias Ids =
  { elementIndex : Int
  , binIndex : Int
  , propertyIndex : Int
  , dataIndex : Int
  , name : Maybe String
  }


{-| The string representation of an Item as used in tooltips. -}
type alias TooltipText =
  String


type Missing 
  = Given   -- For all normal data points.
  | Missing -- For a missing data point.


toLimits : Plane -> Item data x -> Limits
toLimits plane item =


toPosition : Plane -> Item data x -> Position
toPosition plane item =


viewItem : Plane -> Item data x -> Svg Never
viewItem plane (Item data ids tooltipText any) =
  case any of 
    Bin    bars           -> S.g [ SA.class "elm-charts__bin" ]    (List.map (viewItem plane) bars)
    Stack  bars           -> S.g [ SA.class "elm-charts__stack" ]  (List.map (viewItem plane) bars)
    Series dots           -> S.g [ SA.class "elm-charts__series" ] (List.map (viewItem plane) dots)
    Bar    _ bar pos      -> CS.bar plane bar pos
    Dot    _ dot pos      -> CS.dot plane dot pos
    Custom general view _ -> view plane


viewTooltip : Plane -> Item data x -> Html Never
viewTooltip plane (Item data ids tooltipText any) =
  case any of 
    Bin    bars           -> IHtml.tooltip plane (List.map (viewTooltip plane) bars)
    Stack  bars           -> IHtml.tooltip plane (List.map (viewTooltip plane) bars)
    Series dots           -> IHtml.tooltip plane (List.map (viewTooltip plane) dots)
    Bar    _ bar pos      -> IHtml.tooltipRow plane bar tooltipText
    Dot    _ dot pos      -> IHtml.tooltipRow plane dot tooltipText
    Custom general _ view -> view plane


isEqual : Item data x -> Item data x -> Bool
isEqual (Item _ a _ _) (Item _ b _ _) =
  a.elementIndex  == b.elementIndex &&
  a.binIndex      == b.binIndex &&
  a.propertyIndex == b.propertyIndex &&
  a.dataIndex     == b.dataIndex



-- FILTERING


onlyBin : Item data x -> Maybe (Item data Bin)
onlyBin (Item data ids tooltipText any) =
  case any of 
    Bin    x     -> Just (Item data ids tooltipText (OnlyBin x))
    Stack  _     -> Nothing
    Series _     -> Nothing
    Bar    _ _ _ -> Nothing
    Dot    _ _ _ -> Nothing
    Custom _ _ _ -> Nothing


onlyStack : Item data x -> Maybe (Item data Stack)
onlyStack (Item data ids tooltipText any) =
  case any of 
    Stack  x     -> Just ((Item data ids tooltipText (OnlyStack x))
    Bin    _     -> Nothing
    Series _     -> Nothing
    Bar    _ _ _ -> Nothing
    Dot    _ _ _ -> Nothing
    Custom _ _ _ -> Nothing


onlySeries : Item data x -> Maybe (Item data Series)
onlySeries (Item data ids tooltipText any) =
  case any of 
    Stack  _     -> Nothing
    Bin    _     -> Nothing
    Series x     -> Just (Item data ids tooltipText (OnlySeries x))
    Bar    _ _ _ -> Nothing
    Dot    _ _ _ -> Nothing
    Custom _ _ _ -> Nothing


onlyBar : Item data x -> Maybe (Item data Bar)
onlyBar (Item data ids tooltipText any) =
  case any of 
    Stack  _     -> Nothing
    Bin    _     -> Nothing
    Series _     -> Nothing
    Bar    m x p -> Just (Item data ids tooltipText (OnlyBar m x p))
    Dot    _ _ _ -> Nothing
    Custom _ _ _ -> Nothing


onlyDot : Item data x -> Maybe (Item data Dot)
onlyDot (Item data ids tooltipText any) =
  case any of 
    Stack  _     -> Nothing
    Bin    _     -> Nothing
    Series _     -> Nothing
    Bar    _ _ _ -> Nothing
    Dot    m x p -> Just (Item data ids tooltipText (OnlyDot m x p))
    Custom _ _ _ -> Nothing





