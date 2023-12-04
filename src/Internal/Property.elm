module Internal.Property exposing (..)

import Internal.Helpers exposing (Attribute)


{-| -}
type Property data interpolation presentation
  = NotStacked (Config data interpolation presentation)
  | Stacked (List (Config data interpolation presentation))


{-| -}
type alias Config data interpolation presentation =
  { toY : data -> Maybe Float                               -- The y value of the line
  , toYSum : data -> Maybe Float                            -- The y value of the line as stacked upon another line.
  , interpolation : List (Attribute interpolation)
  , presentation : List (Attribute presentation)
  , variation : Identification -> data -> List (Attribute presentation)
  , tooltipName : Maybe String
  , tooltipText : data -> String
  }


type alias Identification =
  { stackIndex : Int      -- Index of the stack.
  , seriesIndex : Int     -- Index of the series within a stack.
  , absoluteIndex : Int   -- Index of series within the total set of series.
  , dataIndex : Int       -- Index of data point within data.
  , elementIndex : Int    -- Index of element within chart.
  }


{-| -}
notStacked : (data -> Maybe Float) -> List (Attribute interpolation) -> List (Attribute presentation) -> Property data interpolation presentation
notStacked toY interpolation presentation =
  NotStacked
    { toY = toY
    , toYSum = toY
    , interpolation = interpolation
    , presentation = presentation
    , variation = \_ _ -> []
    , tooltipName = Nothing
    , tooltipText = \datum -> 
        toY datum
          |> Maybe.map String.fromFloat
          |> Maybe.withDefault "N/A"
    }


{-| -}
stacked : List (Property data interpolation presentation) -> Property data interpolation presentation
stacked properties =
  let configs =
        -- You cannot have a stack inside a stack. Collapse them if this is the case.
        List.concatMap toConfigs (List.reverse properties)

      stack : List (Config data interpolation presentation) -> List (data -> Maybe Float) -> List (Config data interpolation presentation) -> List (Config data interpolation presentation)
      stack list toYs result =
        -- Collect toY functions of properties below the current property in stack.
        -- Use these to create toYSum, which produces the stacked y value for the current property.
        -- TODO move this to .Produce
        case list of
          config :: rest ->
            let toYs_ = config.toY :: toYs in
            stack rest toYs_ ({ config | toYSum = toYSum toYs_ } :: result)

          [] ->
            result

      toYSum toYs datum =
        let yValues = List.filterMap (\toY -> toY datum) toYs 
            isYValueMissing = List.length yValues /= List.length toYs
        in
         -- If any value in the stack is missing, we cannot show it for this data point.
        if isYValueMissing then Nothing else Just (List.sum yValues)
  in
  Stacked (stack configs [] [])


{-| -}
tooltipText : (Maybe Float -> String) -> Property data interpolation presentation -> Property data interpolation presentation
tooltipText newTooltipText property =
  let update config =
        { config | tooltipText = \datum -> newTooltipText (config.toY datum) }
  in
  case property of
    NotStacked config -> NotStacked (update config)
    Stacked configs -> Stacked (List.map update configs)


{-| -}
name : String -> Property data interpolation presentation -> Property data interpolation presentation
name newName property =
  let update config =
        { config | tooltipName = Just newName }
  in
  case property of
    NotStacked config -> NotStacked (update config)
    Stacked configs -> Stacked (List.map update configs)


{-| -}
variation : (Identification -> data -> List (Attribute presentation)) -> Property data interpolation presentation -> Property data interpolation presentation
variation newVariation property =
  let update config =
        { config | variation = \ids datum -> config.variation ids datum ++ newVariation ids datum }
  in
  case property of
    NotStacked config -> NotStacked (update config)
    Stacked configs -> Stacked (List.map update configs)


toConfigs : Property data interpolation presentation -> List (Config data interpolation presentation)
toConfigs property =
  case property of
    NotStacked config -> [config]
    Stacked configs -> configs

      

