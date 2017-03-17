module PlotBars exposing (plotExample)

import Html
import Msg exposing (..)
import Svg.Plot exposing (..)
import Common exposing (..)


plotExample : Maybe Point -> PlotExample Msg
plotExample point =
    { title = "PlotBars"
    , code = code
    , view = view point
    , id = "PlotBars"
    }


barData : List ( List Float )
barData =
  [ [ 1, 2 ]
  , [ 1, 3 ]
  , [ 2, 6 ]
  , [ 4, 8 ]
  ]


bars : Maybe Point -> Bars (List ( List Float )) msg
bars hovering =
  groups (List.map2 (hintGroup hovering) [ "Q1", "Q2", "Q3", "Q4" ])


view : Maybe Point -> Html.Html Msg
view hovering =
    viewBarsCustom
      { defaultBarsPlotCustomizations
      | onHover = Just Hover2
      , viewHintContainer = flyingHintContainer normalHintContainerInner hovering
      }
      (bars hovering)
      barData


code : String
code =
    """
bars : Maybe Point -> Bars (List ( List Float )) msg
bars hovering =
  groups (List.map2 (hintGroup hovering) [ "Q1", "Q2", "Q3", "Q4" ])


view : Maybe Point -> Html.Html Msg
view hovering =
    viewBarsCustom
      { defaultBarsPlotCustomizations
      | onHover = Just Hover
      , viewHintContainer = flyingHintContainer normalHintContainerInner hovering
      }
      (bars hovering)
      barData
"""
