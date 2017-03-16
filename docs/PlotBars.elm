module PlotBars exposing (plotExample)

import Html
import Msg exposing (..)
import Svg.Plot exposing (..)
import Common exposing (..)


plotExample : Maybe Point -> PlotExample Msg
plotExample point =
    { title = "title"
    , code = code
    , view = view point
    , id = "id"
    }


barData : List ( List Float )
barData =
  [ [ 1, 2 ]
  , [ 1, 3 ]
  , [ 2, 6 ]
  , [ 4, 8 ]
  ]


view : Maybe Point -> Html.Html Msg
view hovering =
    let
      settings =
        { defaultBarsPlotCustomizations
        | onHover = Just Hover
        , viewHintContainer = flyingHintContainer normalHintContainerInner hovering
        }
    in
      viewBarsCustom settings
        (groups (List.map2 (hintGroup hovering) [ "Q1", "Q2", "Q3", "Q4" ]))
        barData


code : String
code =
    """
view : Maybe Point -> Html.Html Msg
view hovering =
    let
      settings =
        { defaultBarsPlotCustomizations
        | onHover = Just Hover
        , viewHintContainer = flyingHoverContainer hovering
        }
    in
      viewBarsCustom settings
        (groups (List.map2 (hintGroup hovering) [ "Q1", "Q2", "Q3", "Q4" ]))
        barData
"""
