module Examples exposing (Id(..), Model, init, Msg, update, view, name, all, first, smallCode, largeCode, meta)


-- THIS IS A GENERATED MODULE!

import Html



import Examples.BarCharts.Gradient as Example0
import Examples.BarCharts.VariableWidth as Example1
import Examples.BarCharts.Title as Example2
import Examples.BarCharts.TooltipStack as Example3
import Examples.BarCharts.Tooltip as Example4
import Examples.BarCharts.BarLabels as Example5
import Examples.BarCharts.Pattern as Example6
import Examples.BarCharts.Histogram as Example7
import Examples.BarCharts.BinLabelsAdvanced as Example8
import Examples.BarCharts.Spacing as Example9
import Examples.BarCharts.Highlight as Example10
import Examples.BarCharts.DataDependent as Example11
import Examples.BarCharts.Color as Example12
import Examples.BarCharts.TooltipBin as Example13
import Examples.BarCharts.Corners as Example14
import Examples.BarCharts.Ungroup as Example15
import Examples.BarCharts.BinLabels as Example16
import Examples.BarCharts.Stacked as Example17
import Examples.BarCharts.Margin as Example18
import Examples.BarCharts.Borders as Example19
import Examples.BarCharts.Opacity as Example20
import Examples.BarCharts.Legends as Example21
import Examples.BarCharts.Basic as Example22
import Examples.Frame.Lines as Example23
import Examples.Frame.Position as Example24
import Examples.Frame.Coordinates as Example25
import Examples.Frame.GridFilter as Example26
import Examples.Frame.Dimensions as Example27
import Examples.Frame.CustomElements as Example28
import Examples.Frame.NoArrow as Example29
import Examples.Frame.Background as Example30
import Examples.Frame.Rect as Example31
import Examples.Frame.Padding as Example32
import Examples.Frame.Times as Example33
import Examples.Frame.OnlyInts as Example34
import Examples.Frame.GridColor as Example35
import Examples.Frame.Offset as Example36
import Examples.Frame.Color as Example37
import Examples.Frame.Amount as Example38
import Examples.Frame.Titles as Example39
import Examples.Frame.CustomLabels as Example40
import Examples.Frame.Margin as Example41
import Examples.Frame.LabelWithLine as Example42
import Examples.Frame.DotGrid as Example43
import Examples.Frame.CustomFormat as Example44
import Examples.Frame.AxisLength as Example45
import Examples.Frame.Arbitrary as Example46
import Examples.Frame.Legends as Example47
import Examples.Frame.Basic as Example48
import Examples.Interactivity.ChangeContent as Example49
import Examples.Interactivity.Direction as Example50
import Examples.Interactivity.ChangeDot as Example51
import Examples.Interactivity.Border as Example52
import Examples.Interactivity.Zoom as Example53
import Examples.Interactivity.BasicBin as Example54
import Examples.Interactivity.BasicStack as Example55
import Examples.Interactivity.Coordinates as Example56
import Examples.Interactivity.ChangeName as Example57
import Examples.Interactivity.NoArrow as Example58
import Examples.Interactivity.FilterSearch as Example59
import Examples.Interactivity.Background as Example60
import Examples.Interactivity.BasicBar as Example61
import Examples.Interactivity.BasicArea as Example62
import Examples.Interactivity.TrickyTooltip as Example63
import Examples.Interactivity.Multiple as Example64
import Examples.Interactivity.BasicLine as Example65
import Examples.Interactivity.Offset as Example66
import Examples.Interactivity.DoubleSearch as Example67
import Examples.Interactivity.ChangeUnit as Example68
import Examples.Interactivity.Focal as Example69
import Examples.LineCharts.Area as Example70
import Examples.LineCharts.Gradient as Example71
import Examples.LineCharts.Width as Example72
import Examples.LineCharts.TooltipStack as Example73
import Examples.LineCharts.Tooltip as Example74
import Examples.LineCharts.Montone as Example75
import Examples.LineCharts.Pattern as Example76
import Examples.LineCharts.Dots as Example77
import Examples.LineCharts.Dashed as Example78
import Examples.LineCharts.Color as Example79
import Examples.LineCharts.Stepped as Example80
import Examples.LineCharts.Stacked as Example81
import Examples.LineCharts.Labels as Example82
import Examples.LineCharts.Missing as Example83
import Examples.LineCharts.Legends as Example84
import Examples.LineCharts.Basic as Example85
import Examples.Frontpage.BasicBubble as Example86
import Examples.Frontpage.BasicNavigation as Example87
import Examples.Frontpage.BasicBar as Example88
import Examples.Frontpage.BasicArea as Example89
import Examples.Frontpage.Concise as Example90
import Examples.Frontpage.BasicLine as Example91
import Examples.Frontpage.BasicScatter as Example92
import Examples.Frontpage.Familiar as Example93
import Examples.ScatterCharts.Colors as Example94
import Examples.ScatterCharts.Shapes as Example95
import Examples.ScatterCharts.Tooltip as Example96
import Examples.ScatterCharts.Highlight as Example97
import Examples.ScatterCharts.DataDependent as Example98
import Examples.ScatterCharts.Borders as Example99
import Examples.ScatterCharts.Labels as Example100
import Examples.ScatterCharts.Opacity as Example101
import Examples.ScatterCharts.Sizes as Example102
import Examples.ScatterCharts.Legends as Example103
import Examples.ScatterCharts.Basic as Example104


type Id
  = BarCharts__Gradient
  | BarCharts__VariableWidth
  | BarCharts__Title
  | BarCharts__TooltipStack
  | BarCharts__Tooltip
  | BarCharts__BarLabels
  | BarCharts__Pattern
  | BarCharts__Histogram
  | BarCharts__BinLabelsAdvanced
  | BarCharts__Spacing
  | BarCharts__Highlight
  | BarCharts__DataDependent
  | BarCharts__Color
  | BarCharts__TooltipBin
  | BarCharts__Corners
  | BarCharts__Ungroup
  | BarCharts__BinLabels
  | BarCharts__Stacked
  | BarCharts__Margin
  | BarCharts__Borders
  | BarCharts__Opacity
  | BarCharts__Legends
  | BarCharts__Basic
  | Frame__Lines
  | Frame__Position
  | Frame__Coordinates
  | Frame__GridFilter
  | Frame__Dimensions
  | Frame__CustomElements
  | Frame__NoArrow
  | Frame__Background
  | Frame__Rect
  | Frame__Padding
  | Frame__Times
  | Frame__OnlyInts
  | Frame__GridColor
  | Frame__Offset
  | Frame__Color
  | Frame__Amount
  | Frame__Titles
  | Frame__CustomLabels
  | Frame__Margin
  | Frame__LabelWithLine
  | Frame__DotGrid
  | Frame__CustomFormat
  | Frame__AxisLength
  | Frame__Arbitrary
  | Frame__Legends
  | Frame__Basic
  | Interactivity__ChangeContent
  | Interactivity__Direction
  | Interactivity__ChangeDot
  | Interactivity__Border
  | Interactivity__Zoom
  | Interactivity__BasicBin
  | Interactivity__BasicStack
  | Interactivity__Coordinates
  | Interactivity__ChangeName
  | Interactivity__NoArrow
  | Interactivity__FilterSearch
  | Interactivity__Background
  | Interactivity__BasicBar
  | Interactivity__BasicArea
  | Interactivity__TrickyTooltip
  | Interactivity__Multiple
  | Interactivity__BasicLine
  | Interactivity__Offset
  | Interactivity__DoubleSearch
  | Interactivity__ChangeUnit
  | Interactivity__Focal
  | LineCharts__Area
  | LineCharts__Gradient
  | LineCharts__Width
  | LineCharts__TooltipStack
  | LineCharts__Tooltip
  | LineCharts__Montone
  | LineCharts__Pattern
  | LineCharts__Dots
  | LineCharts__Dashed
  | LineCharts__Color
  | LineCharts__Stepped
  | LineCharts__Stacked
  | LineCharts__Labels
  | LineCharts__Missing
  | LineCharts__Legends
  | LineCharts__Basic
  | Frontpage__BasicBubble
  | Frontpage__BasicNavigation
  | Frontpage__BasicBar
  | Frontpage__BasicArea
  | Frontpage__Concise
  | Frontpage__BasicLine
  | Frontpage__BasicScatter
  | Frontpage__Familiar
  | ScatterCharts__Colors
  | ScatterCharts__Shapes
  | ScatterCharts__Tooltip
  | ScatterCharts__Highlight
  | ScatterCharts__DataDependent
  | ScatterCharts__Borders
  | ScatterCharts__Labels
  | ScatterCharts__Opacity
  | ScatterCharts__Sizes
  | ScatterCharts__Legends
  | ScatterCharts__Basic


type alias Model =
  { example0 : Example0.Model
  , example1 : Example1.Model
  , example2 : Example2.Model
  , example3 : Example3.Model
  , example4 : Example4.Model
  , example5 : Example5.Model
  , example6 : Example6.Model
  , example7 : Example7.Model
  , example8 : Example8.Model
  , example9 : Example9.Model
  , example10 : Example10.Model
  , example11 : Example11.Model
  , example12 : Example12.Model
  , example13 : Example13.Model
  , example14 : Example14.Model
  , example15 : Example15.Model
  , example16 : Example16.Model
  , example17 : Example17.Model
  , example18 : Example18.Model
  , example19 : Example19.Model
  , example20 : Example20.Model
  , example21 : Example21.Model
  , example22 : Example22.Model
  , example23 : Example23.Model
  , example24 : Example24.Model
  , example25 : Example25.Model
  , example26 : Example26.Model
  , example27 : Example27.Model
  , example28 : Example28.Model
  , example29 : Example29.Model
  , example30 : Example30.Model
  , example31 : Example31.Model
  , example32 : Example32.Model
  , example33 : Example33.Model
  , example34 : Example34.Model
  , example35 : Example35.Model
  , example36 : Example36.Model
  , example37 : Example37.Model
  , example38 : Example38.Model
  , example39 : Example39.Model
  , example40 : Example40.Model
  , example41 : Example41.Model
  , example42 : Example42.Model
  , example43 : Example43.Model
  , example44 : Example44.Model
  , example45 : Example45.Model
  , example46 : Example46.Model
  , example47 : Example47.Model
  , example48 : Example48.Model
  , example49 : Example49.Model
  , example50 : Example50.Model
  , example51 : Example51.Model
  , example52 : Example52.Model
  , example53 : Example53.Model
  , example54 : Example54.Model
  , example55 : Example55.Model
  , example56 : Example56.Model
  , example57 : Example57.Model
  , example58 : Example58.Model
  , example59 : Example59.Model
  , example60 : Example60.Model
  , example61 : Example61.Model
  , example62 : Example62.Model
  , example63 : Example63.Model
  , example64 : Example64.Model
  , example65 : Example65.Model
  , example66 : Example66.Model
  , example67 : Example67.Model
  , example68 : Example68.Model
  , example69 : Example69.Model
  , example70 : Example70.Model
  , example71 : Example71.Model
  , example72 : Example72.Model
  , example73 : Example73.Model
  , example74 : Example74.Model
  , example75 : Example75.Model
  , example76 : Example76.Model
  , example77 : Example77.Model
  , example78 : Example78.Model
  , example79 : Example79.Model
  , example80 : Example80.Model
  , example81 : Example81.Model
  , example82 : Example82.Model
  , example83 : Example83.Model
  , example84 : Example84.Model
  , example85 : Example85.Model
  , example86 : Example86.Model
  , example87 : Example87.Model
  , example88 : Example88.Model
  , example89 : Example89.Model
  , example90 : Example90.Model
  , example91 : Example91.Model
  , example92 : Example92.Model
  , example93 : Example93.Model
  , example94 : Example94.Model
  , example95 : Example95.Model
  , example96 : Example96.Model
  , example97 : Example97.Model
  , example98 : Example98.Model
  , example99 : Example99.Model
  , example100 : Example100.Model
  , example101 : Example101.Model
  , example102 : Example102.Model
  , example103 : Example103.Model
  , example104 : Example104.Model
  }


init =
  { example0 = Example0.init
  , example1 = Example1.init
  , example2 = Example2.init
  , example3 = Example3.init
  , example4 = Example4.init
  , example5 = Example5.init
  , example6 = Example6.init
  , example7 = Example7.init
  , example8 = Example8.init
  , example9 = Example9.init
  , example10 = Example10.init
  , example11 = Example11.init
  , example12 = Example12.init
  , example13 = Example13.init
  , example14 = Example14.init
  , example15 = Example15.init
  , example16 = Example16.init
  , example17 = Example17.init
  , example18 = Example18.init
  , example19 = Example19.init
  , example20 = Example20.init
  , example21 = Example21.init
  , example22 = Example22.init
  , example23 = Example23.init
  , example24 = Example24.init
  , example25 = Example25.init
  , example26 = Example26.init
  , example27 = Example27.init
  , example28 = Example28.init
  , example29 = Example29.init
  , example30 = Example30.init
  , example31 = Example31.init
  , example32 = Example32.init
  , example33 = Example33.init
  , example34 = Example34.init
  , example35 = Example35.init
  , example36 = Example36.init
  , example37 = Example37.init
  , example38 = Example38.init
  , example39 = Example39.init
  , example40 = Example40.init
  , example41 = Example41.init
  , example42 = Example42.init
  , example43 = Example43.init
  , example44 = Example44.init
  , example45 = Example45.init
  , example46 = Example46.init
  , example47 = Example47.init
  , example48 = Example48.init
  , example49 = Example49.init
  , example50 = Example50.init
  , example51 = Example51.init
  , example52 = Example52.init
  , example53 = Example53.init
  , example54 = Example54.init
  , example55 = Example55.init
  , example56 = Example56.init
  , example57 = Example57.init
  , example58 = Example58.init
  , example59 = Example59.init
  , example60 = Example60.init
  , example61 = Example61.init
  , example62 = Example62.init
  , example63 = Example63.init
  , example64 = Example64.init
  , example65 = Example65.init
  , example66 = Example66.init
  , example67 = Example67.init
  , example68 = Example68.init
  , example69 = Example69.init
  , example70 = Example70.init
  , example71 = Example71.init
  , example72 = Example72.init
  , example73 = Example73.init
  , example74 = Example74.init
  , example75 = Example75.init
  , example76 = Example76.init
  , example77 = Example77.init
  , example78 = Example78.init
  , example79 = Example79.init
  , example80 = Example80.init
  , example81 = Example81.init
  , example82 = Example82.init
  , example83 = Example83.init
  , example84 = Example84.init
  , example85 = Example85.init
  , example86 = Example86.init
  , example87 = Example87.init
  , example88 = Example88.init
  , example89 = Example89.init
  , example90 = Example90.init
  , example91 = Example91.init
  , example92 = Example92.init
  , example93 = Example93.init
  , example94 = Example94.init
  , example95 = Example95.init
  , example96 = Example96.init
  , example97 = Example97.init
  , example98 = Example98.init
  , example99 = Example99.init
  , example100 = Example100.init
  , example101 = Example101.init
  , example102 = Example102.init
  , example103 = Example103.init
  , example104 = Example104.init
  }


type Msg
  = ExampleMsg0 Example0.Msg
  | ExampleMsg1 Example1.Msg
  | ExampleMsg2 Example2.Msg
  | ExampleMsg3 Example3.Msg
  | ExampleMsg4 Example4.Msg
  | ExampleMsg5 Example5.Msg
  | ExampleMsg6 Example6.Msg
  | ExampleMsg7 Example7.Msg
  | ExampleMsg8 Example8.Msg
  | ExampleMsg9 Example9.Msg
  | ExampleMsg10 Example10.Msg
  | ExampleMsg11 Example11.Msg
  | ExampleMsg12 Example12.Msg
  | ExampleMsg13 Example13.Msg
  | ExampleMsg14 Example14.Msg
  | ExampleMsg15 Example15.Msg
  | ExampleMsg16 Example16.Msg
  | ExampleMsg17 Example17.Msg
  | ExampleMsg18 Example18.Msg
  | ExampleMsg19 Example19.Msg
  | ExampleMsg20 Example20.Msg
  | ExampleMsg21 Example21.Msg
  | ExampleMsg22 Example22.Msg
  | ExampleMsg23 Example23.Msg
  | ExampleMsg24 Example24.Msg
  | ExampleMsg25 Example25.Msg
  | ExampleMsg26 Example26.Msg
  | ExampleMsg27 Example27.Msg
  | ExampleMsg28 Example28.Msg
  | ExampleMsg29 Example29.Msg
  | ExampleMsg30 Example30.Msg
  | ExampleMsg31 Example31.Msg
  | ExampleMsg32 Example32.Msg
  | ExampleMsg33 Example33.Msg
  | ExampleMsg34 Example34.Msg
  | ExampleMsg35 Example35.Msg
  | ExampleMsg36 Example36.Msg
  | ExampleMsg37 Example37.Msg
  | ExampleMsg38 Example38.Msg
  | ExampleMsg39 Example39.Msg
  | ExampleMsg40 Example40.Msg
  | ExampleMsg41 Example41.Msg
  | ExampleMsg42 Example42.Msg
  | ExampleMsg43 Example43.Msg
  | ExampleMsg44 Example44.Msg
  | ExampleMsg45 Example45.Msg
  | ExampleMsg46 Example46.Msg
  | ExampleMsg47 Example47.Msg
  | ExampleMsg48 Example48.Msg
  | ExampleMsg49 Example49.Msg
  | ExampleMsg50 Example50.Msg
  | ExampleMsg51 Example51.Msg
  | ExampleMsg52 Example52.Msg
  | ExampleMsg53 Example53.Msg
  | ExampleMsg54 Example54.Msg
  | ExampleMsg55 Example55.Msg
  | ExampleMsg56 Example56.Msg
  | ExampleMsg57 Example57.Msg
  | ExampleMsg58 Example58.Msg
  | ExampleMsg59 Example59.Msg
  | ExampleMsg60 Example60.Msg
  | ExampleMsg61 Example61.Msg
  | ExampleMsg62 Example62.Msg
  | ExampleMsg63 Example63.Msg
  | ExampleMsg64 Example64.Msg
  | ExampleMsg65 Example65.Msg
  | ExampleMsg66 Example66.Msg
  | ExampleMsg67 Example67.Msg
  | ExampleMsg68 Example68.Msg
  | ExampleMsg69 Example69.Msg
  | ExampleMsg70 Example70.Msg
  | ExampleMsg71 Example71.Msg
  | ExampleMsg72 Example72.Msg
  | ExampleMsg73 Example73.Msg
  | ExampleMsg74 Example74.Msg
  | ExampleMsg75 Example75.Msg
  | ExampleMsg76 Example76.Msg
  | ExampleMsg77 Example77.Msg
  | ExampleMsg78 Example78.Msg
  | ExampleMsg79 Example79.Msg
  | ExampleMsg80 Example80.Msg
  | ExampleMsg81 Example81.Msg
  | ExampleMsg82 Example82.Msg
  | ExampleMsg83 Example83.Msg
  | ExampleMsg84 Example84.Msg
  | ExampleMsg85 Example85.Msg
  | ExampleMsg86 Example86.Msg
  | ExampleMsg87 Example87.Msg
  | ExampleMsg88 Example88.Msg
  | ExampleMsg89 Example89.Msg
  | ExampleMsg90 Example90.Msg
  | ExampleMsg91 Example91.Msg
  | ExampleMsg92 Example92.Msg
  | ExampleMsg93 Example93.Msg
  | ExampleMsg94 Example94.Msg
  | ExampleMsg95 Example95.Msg
  | ExampleMsg96 Example96.Msg
  | ExampleMsg97 Example97.Msg
  | ExampleMsg98 Example98.Msg
  | ExampleMsg99 Example99.Msg
  | ExampleMsg100 Example100.Msg
  | ExampleMsg101 Example101.Msg
  | ExampleMsg102 Example102.Msg
  | ExampleMsg103 Example103.Msg
  | ExampleMsg104 Example104.Msg


update msg model =
  case msg of
    ExampleMsg0 sub -> { model | example0 = Example0.update sub model.example0 }
    ExampleMsg1 sub -> { model | example1 = Example1.update sub model.example1 }
    ExampleMsg2 sub -> { model | example2 = Example2.update sub model.example2 }
    ExampleMsg3 sub -> { model | example3 = Example3.update sub model.example3 }
    ExampleMsg4 sub -> { model | example4 = Example4.update sub model.example4 }
    ExampleMsg5 sub -> { model | example5 = Example5.update sub model.example5 }
    ExampleMsg6 sub -> { model | example6 = Example6.update sub model.example6 }
    ExampleMsg7 sub -> { model | example7 = Example7.update sub model.example7 }
    ExampleMsg8 sub -> { model | example8 = Example8.update sub model.example8 }
    ExampleMsg9 sub -> { model | example9 = Example9.update sub model.example9 }
    ExampleMsg10 sub -> { model | example10 = Example10.update sub model.example10 }
    ExampleMsg11 sub -> { model | example11 = Example11.update sub model.example11 }
    ExampleMsg12 sub -> { model | example12 = Example12.update sub model.example12 }
    ExampleMsg13 sub -> { model | example13 = Example13.update sub model.example13 }
    ExampleMsg14 sub -> { model | example14 = Example14.update sub model.example14 }
    ExampleMsg15 sub -> { model | example15 = Example15.update sub model.example15 }
    ExampleMsg16 sub -> { model | example16 = Example16.update sub model.example16 }
    ExampleMsg17 sub -> { model | example17 = Example17.update sub model.example17 }
    ExampleMsg18 sub -> { model | example18 = Example18.update sub model.example18 }
    ExampleMsg19 sub -> { model | example19 = Example19.update sub model.example19 }
    ExampleMsg20 sub -> { model | example20 = Example20.update sub model.example20 }
    ExampleMsg21 sub -> { model | example21 = Example21.update sub model.example21 }
    ExampleMsg22 sub -> { model | example22 = Example22.update sub model.example22 }
    ExampleMsg23 sub -> { model | example23 = Example23.update sub model.example23 }
    ExampleMsg24 sub -> { model | example24 = Example24.update sub model.example24 }
    ExampleMsg25 sub -> { model | example25 = Example25.update sub model.example25 }
    ExampleMsg26 sub -> { model | example26 = Example26.update sub model.example26 }
    ExampleMsg27 sub -> { model | example27 = Example27.update sub model.example27 }
    ExampleMsg28 sub -> { model | example28 = Example28.update sub model.example28 }
    ExampleMsg29 sub -> { model | example29 = Example29.update sub model.example29 }
    ExampleMsg30 sub -> { model | example30 = Example30.update sub model.example30 }
    ExampleMsg31 sub -> { model | example31 = Example31.update sub model.example31 }
    ExampleMsg32 sub -> { model | example32 = Example32.update sub model.example32 }
    ExampleMsg33 sub -> { model | example33 = Example33.update sub model.example33 }
    ExampleMsg34 sub -> { model | example34 = Example34.update sub model.example34 }
    ExampleMsg35 sub -> { model | example35 = Example35.update sub model.example35 }
    ExampleMsg36 sub -> { model | example36 = Example36.update sub model.example36 }
    ExampleMsg37 sub -> { model | example37 = Example37.update sub model.example37 }
    ExampleMsg38 sub -> { model | example38 = Example38.update sub model.example38 }
    ExampleMsg39 sub -> { model | example39 = Example39.update sub model.example39 }
    ExampleMsg40 sub -> { model | example40 = Example40.update sub model.example40 }
    ExampleMsg41 sub -> { model | example41 = Example41.update sub model.example41 }
    ExampleMsg42 sub -> { model | example42 = Example42.update sub model.example42 }
    ExampleMsg43 sub -> { model | example43 = Example43.update sub model.example43 }
    ExampleMsg44 sub -> { model | example44 = Example44.update sub model.example44 }
    ExampleMsg45 sub -> { model | example45 = Example45.update sub model.example45 }
    ExampleMsg46 sub -> { model | example46 = Example46.update sub model.example46 }
    ExampleMsg47 sub -> { model | example47 = Example47.update sub model.example47 }
    ExampleMsg48 sub -> { model | example48 = Example48.update sub model.example48 }
    ExampleMsg49 sub -> { model | example49 = Example49.update sub model.example49 }
    ExampleMsg50 sub -> { model | example50 = Example50.update sub model.example50 }
    ExampleMsg51 sub -> { model | example51 = Example51.update sub model.example51 }
    ExampleMsg52 sub -> { model | example52 = Example52.update sub model.example52 }
    ExampleMsg53 sub -> { model | example53 = Example53.update sub model.example53 }
    ExampleMsg54 sub -> { model | example54 = Example54.update sub model.example54 }
    ExampleMsg55 sub -> { model | example55 = Example55.update sub model.example55 }
    ExampleMsg56 sub -> { model | example56 = Example56.update sub model.example56 }
    ExampleMsg57 sub -> { model | example57 = Example57.update sub model.example57 }
    ExampleMsg58 sub -> { model | example58 = Example58.update sub model.example58 }
    ExampleMsg59 sub -> { model | example59 = Example59.update sub model.example59 }
    ExampleMsg60 sub -> { model | example60 = Example60.update sub model.example60 }
    ExampleMsg61 sub -> { model | example61 = Example61.update sub model.example61 }
    ExampleMsg62 sub -> { model | example62 = Example62.update sub model.example62 }
    ExampleMsg63 sub -> { model | example63 = Example63.update sub model.example63 }
    ExampleMsg64 sub -> { model | example64 = Example64.update sub model.example64 }
    ExampleMsg65 sub -> { model | example65 = Example65.update sub model.example65 }
    ExampleMsg66 sub -> { model | example66 = Example66.update sub model.example66 }
    ExampleMsg67 sub -> { model | example67 = Example67.update sub model.example67 }
    ExampleMsg68 sub -> { model | example68 = Example68.update sub model.example68 }
    ExampleMsg69 sub -> { model | example69 = Example69.update sub model.example69 }
    ExampleMsg70 sub -> { model | example70 = Example70.update sub model.example70 }
    ExampleMsg71 sub -> { model | example71 = Example71.update sub model.example71 }
    ExampleMsg72 sub -> { model | example72 = Example72.update sub model.example72 }
    ExampleMsg73 sub -> { model | example73 = Example73.update sub model.example73 }
    ExampleMsg74 sub -> { model | example74 = Example74.update sub model.example74 }
    ExampleMsg75 sub -> { model | example75 = Example75.update sub model.example75 }
    ExampleMsg76 sub -> { model | example76 = Example76.update sub model.example76 }
    ExampleMsg77 sub -> { model | example77 = Example77.update sub model.example77 }
    ExampleMsg78 sub -> { model | example78 = Example78.update sub model.example78 }
    ExampleMsg79 sub -> { model | example79 = Example79.update sub model.example79 }
    ExampleMsg80 sub -> { model | example80 = Example80.update sub model.example80 }
    ExampleMsg81 sub -> { model | example81 = Example81.update sub model.example81 }
    ExampleMsg82 sub -> { model | example82 = Example82.update sub model.example82 }
    ExampleMsg83 sub -> { model | example83 = Example83.update sub model.example83 }
    ExampleMsg84 sub -> { model | example84 = Example84.update sub model.example84 }
    ExampleMsg85 sub -> { model | example85 = Example85.update sub model.example85 }
    ExampleMsg86 sub -> { model | example86 = Example86.update sub model.example86 }
    ExampleMsg87 sub -> { model | example87 = Example87.update sub model.example87 }
    ExampleMsg88 sub -> { model | example88 = Example88.update sub model.example88 }
    ExampleMsg89 sub -> { model | example89 = Example89.update sub model.example89 }
    ExampleMsg90 sub -> { model | example90 = Example90.update sub model.example90 }
    ExampleMsg91 sub -> { model | example91 = Example91.update sub model.example91 }
    ExampleMsg92 sub -> { model | example92 = Example92.update sub model.example92 }
    ExampleMsg93 sub -> { model | example93 = Example93.update sub model.example93 }
    ExampleMsg94 sub -> { model | example94 = Example94.update sub model.example94 }
    ExampleMsg95 sub -> { model | example95 = Example95.update sub model.example95 }
    ExampleMsg96 sub -> { model | example96 = Example96.update sub model.example96 }
    ExampleMsg97 sub -> { model | example97 = Example97.update sub model.example97 }
    ExampleMsg98 sub -> { model | example98 = Example98.update sub model.example98 }
    ExampleMsg99 sub -> { model | example99 = Example99.update sub model.example99 }
    ExampleMsg100 sub -> { model | example100 = Example100.update sub model.example100 }
    ExampleMsg101 sub -> { model | example101 = Example101.update sub model.example101 }
    ExampleMsg102 sub -> { model | example102 = Example102.update sub model.example102 }
    ExampleMsg103 sub -> { model | example103 = Example103.update sub model.example103 }
    ExampleMsg104 sub -> { model | example104 = Example104.update sub model.example104 }


view model chosen =
  case chosen of
    BarCharts__Gradient -> Html.map ExampleMsg0 (Example0.view model.example0)
    BarCharts__VariableWidth -> Html.map ExampleMsg1 (Example1.view model.example1)
    BarCharts__Title -> Html.map ExampleMsg2 (Example2.view model.example2)
    BarCharts__TooltipStack -> Html.map ExampleMsg3 (Example3.view model.example3)
    BarCharts__Tooltip -> Html.map ExampleMsg4 (Example4.view model.example4)
    BarCharts__BarLabels -> Html.map ExampleMsg5 (Example5.view model.example5)
    BarCharts__Pattern -> Html.map ExampleMsg6 (Example6.view model.example6)
    BarCharts__Histogram -> Html.map ExampleMsg7 (Example7.view model.example7)
    BarCharts__BinLabelsAdvanced -> Html.map ExampleMsg8 (Example8.view model.example8)
    BarCharts__Spacing -> Html.map ExampleMsg9 (Example9.view model.example9)
    BarCharts__Highlight -> Html.map ExampleMsg10 (Example10.view model.example10)
    BarCharts__DataDependent -> Html.map ExampleMsg11 (Example11.view model.example11)
    BarCharts__Color -> Html.map ExampleMsg12 (Example12.view model.example12)
    BarCharts__TooltipBin -> Html.map ExampleMsg13 (Example13.view model.example13)
    BarCharts__Corners -> Html.map ExampleMsg14 (Example14.view model.example14)
    BarCharts__Ungroup -> Html.map ExampleMsg15 (Example15.view model.example15)
    BarCharts__BinLabels -> Html.map ExampleMsg16 (Example16.view model.example16)
    BarCharts__Stacked -> Html.map ExampleMsg17 (Example17.view model.example17)
    BarCharts__Margin -> Html.map ExampleMsg18 (Example18.view model.example18)
    BarCharts__Borders -> Html.map ExampleMsg19 (Example19.view model.example19)
    BarCharts__Opacity -> Html.map ExampleMsg20 (Example20.view model.example20)
    BarCharts__Legends -> Html.map ExampleMsg21 (Example21.view model.example21)
    BarCharts__Basic -> Html.map ExampleMsg22 (Example22.view model.example22)
    Frame__Lines -> Html.map ExampleMsg23 (Example23.view model.example23)
    Frame__Position -> Html.map ExampleMsg24 (Example24.view model.example24)
    Frame__Coordinates -> Html.map ExampleMsg25 (Example25.view model.example25)
    Frame__GridFilter -> Html.map ExampleMsg26 (Example26.view model.example26)
    Frame__Dimensions -> Html.map ExampleMsg27 (Example27.view model.example27)
    Frame__CustomElements -> Html.map ExampleMsg28 (Example28.view model.example28)
    Frame__NoArrow -> Html.map ExampleMsg29 (Example29.view model.example29)
    Frame__Background -> Html.map ExampleMsg30 (Example30.view model.example30)
    Frame__Rect -> Html.map ExampleMsg31 (Example31.view model.example31)
    Frame__Padding -> Html.map ExampleMsg32 (Example32.view model.example32)
    Frame__Times -> Html.map ExampleMsg33 (Example33.view model.example33)
    Frame__OnlyInts -> Html.map ExampleMsg34 (Example34.view model.example34)
    Frame__GridColor -> Html.map ExampleMsg35 (Example35.view model.example35)
    Frame__Offset -> Html.map ExampleMsg36 (Example36.view model.example36)
    Frame__Color -> Html.map ExampleMsg37 (Example37.view model.example37)
    Frame__Amount -> Html.map ExampleMsg38 (Example38.view model.example38)
    Frame__Titles -> Html.map ExampleMsg39 (Example39.view model.example39)
    Frame__CustomLabels -> Html.map ExampleMsg40 (Example40.view model.example40)
    Frame__Margin -> Html.map ExampleMsg41 (Example41.view model.example41)
    Frame__LabelWithLine -> Html.map ExampleMsg42 (Example42.view model.example42)
    Frame__DotGrid -> Html.map ExampleMsg43 (Example43.view model.example43)
    Frame__CustomFormat -> Html.map ExampleMsg44 (Example44.view model.example44)
    Frame__AxisLength -> Html.map ExampleMsg45 (Example45.view model.example45)
    Frame__Arbitrary -> Html.map ExampleMsg46 (Example46.view model.example46)
    Frame__Legends -> Html.map ExampleMsg47 (Example47.view model.example47)
    Frame__Basic -> Html.map ExampleMsg48 (Example48.view model.example48)
    Interactivity__ChangeContent -> Html.map ExampleMsg49 (Example49.view model.example49)
    Interactivity__Direction -> Html.map ExampleMsg50 (Example50.view model.example50)
    Interactivity__ChangeDot -> Html.map ExampleMsg51 (Example51.view model.example51)
    Interactivity__Border -> Html.map ExampleMsg52 (Example52.view model.example52)
    Interactivity__Zoom -> Html.map ExampleMsg53 (Example53.view model.example53)
    Interactivity__BasicBin -> Html.map ExampleMsg54 (Example54.view model.example54)
    Interactivity__BasicStack -> Html.map ExampleMsg55 (Example55.view model.example55)
    Interactivity__Coordinates -> Html.map ExampleMsg56 (Example56.view model.example56)
    Interactivity__ChangeName -> Html.map ExampleMsg57 (Example57.view model.example57)
    Interactivity__NoArrow -> Html.map ExampleMsg58 (Example58.view model.example58)
    Interactivity__FilterSearch -> Html.map ExampleMsg59 (Example59.view model.example59)
    Interactivity__Background -> Html.map ExampleMsg60 (Example60.view model.example60)
    Interactivity__BasicBar -> Html.map ExampleMsg61 (Example61.view model.example61)
    Interactivity__BasicArea -> Html.map ExampleMsg62 (Example62.view model.example62)
    Interactivity__TrickyTooltip -> Html.map ExampleMsg63 (Example63.view model.example63)
    Interactivity__Multiple -> Html.map ExampleMsg64 (Example64.view model.example64)
    Interactivity__BasicLine -> Html.map ExampleMsg65 (Example65.view model.example65)
    Interactivity__Offset -> Html.map ExampleMsg66 (Example66.view model.example66)
    Interactivity__DoubleSearch -> Html.map ExampleMsg67 (Example67.view model.example67)
    Interactivity__ChangeUnit -> Html.map ExampleMsg68 (Example68.view model.example68)
    Interactivity__Focal -> Html.map ExampleMsg69 (Example69.view model.example69)
    LineCharts__Area -> Html.map ExampleMsg70 (Example70.view model.example70)
    LineCharts__Gradient -> Html.map ExampleMsg71 (Example71.view model.example71)
    LineCharts__Width -> Html.map ExampleMsg72 (Example72.view model.example72)
    LineCharts__TooltipStack -> Html.map ExampleMsg73 (Example73.view model.example73)
    LineCharts__Tooltip -> Html.map ExampleMsg74 (Example74.view model.example74)
    LineCharts__Montone -> Html.map ExampleMsg75 (Example75.view model.example75)
    LineCharts__Pattern -> Html.map ExampleMsg76 (Example76.view model.example76)
    LineCharts__Dots -> Html.map ExampleMsg77 (Example77.view model.example77)
    LineCharts__Dashed -> Html.map ExampleMsg78 (Example78.view model.example78)
    LineCharts__Color -> Html.map ExampleMsg79 (Example79.view model.example79)
    LineCharts__Stepped -> Html.map ExampleMsg80 (Example80.view model.example80)
    LineCharts__Stacked -> Html.map ExampleMsg81 (Example81.view model.example81)
    LineCharts__Labels -> Html.map ExampleMsg82 (Example82.view model.example82)
    LineCharts__Missing -> Html.map ExampleMsg83 (Example83.view model.example83)
    LineCharts__Legends -> Html.map ExampleMsg84 (Example84.view model.example84)
    LineCharts__Basic -> Html.map ExampleMsg85 (Example85.view model.example85)
    Frontpage__BasicBubble -> Html.map ExampleMsg86 (Example86.view model.example86)
    Frontpage__BasicNavigation -> Html.map ExampleMsg87 (Example87.view model.example87)
    Frontpage__BasicBar -> Html.map ExampleMsg88 (Example88.view model.example88)
    Frontpage__BasicArea -> Html.map ExampleMsg89 (Example89.view model.example89)
    Frontpage__Concise -> Html.map ExampleMsg90 (Example90.view model.example90)
    Frontpage__BasicLine -> Html.map ExampleMsg91 (Example91.view model.example91)
    Frontpage__BasicScatter -> Html.map ExampleMsg92 (Example92.view model.example92)
    Frontpage__Familiar -> Html.map ExampleMsg93 (Example93.view model.example93)
    ScatterCharts__Colors -> Html.map ExampleMsg94 (Example94.view model.example94)
    ScatterCharts__Shapes -> Html.map ExampleMsg95 (Example95.view model.example95)
    ScatterCharts__Tooltip -> Html.map ExampleMsg96 (Example96.view model.example96)
    ScatterCharts__Highlight -> Html.map ExampleMsg97 (Example97.view model.example97)
    ScatterCharts__DataDependent -> Html.map ExampleMsg98 (Example98.view model.example98)
    ScatterCharts__Borders -> Html.map ExampleMsg99 (Example99.view model.example99)
    ScatterCharts__Labels -> Html.map ExampleMsg100 (Example100.view model.example100)
    ScatterCharts__Opacity -> Html.map ExampleMsg101 (Example101.view model.example101)
    ScatterCharts__Sizes -> Html.map ExampleMsg102 (Example102.view model.example102)
    ScatterCharts__Legends -> Html.map ExampleMsg103 (Example103.view model.example103)
    ScatterCharts__Basic -> Html.map ExampleMsg104 (Example104.view model.example104)


smallCode : Id -> String
smallCode chosen =
  case chosen of
    BarCharts__Gradient -> Example0.smallCode
    BarCharts__VariableWidth -> Example1.smallCode
    BarCharts__Title -> Example2.smallCode
    BarCharts__TooltipStack -> Example3.smallCode
    BarCharts__Tooltip -> Example4.smallCode
    BarCharts__BarLabels -> Example5.smallCode
    BarCharts__Pattern -> Example6.smallCode
    BarCharts__Histogram -> Example7.smallCode
    BarCharts__BinLabelsAdvanced -> Example8.smallCode
    BarCharts__Spacing -> Example9.smallCode
    BarCharts__Highlight -> Example10.smallCode
    BarCharts__DataDependent -> Example11.smallCode
    BarCharts__Color -> Example12.smallCode
    BarCharts__TooltipBin -> Example13.smallCode
    BarCharts__Corners -> Example14.smallCode
    BarCharts__Ungroup -> Example15.smallCode
    BarCharts__BinLabels -> Example16.smallCode
    BarCharts__Stacked -> Example17.smallCode
    BarCharts__Margin -> Example18.smallCode
    BarCharts__Borders -> Example19.smallCode
    BarCharts__Opacity -> Example20.smallCode
    BarCharts__Legends -> Example21.smallCode
    BarCharts__Basic -> Example22.smallCode
    Frame__Lines -> Example23.smallCode
    Frame__Position -> Example24.smallCode
    Frame__Coordinates -> Example25.smallCode
    Frame__GridFilter -> Example26.smallCode
    Frame__Dimensions -> Example27.smallCode
    Frame__CustomElements -> Example28.smallCode
    Frame__NoArrow -> Example29.smallCode
    Frame__Background -> Example30.smallCode
    Frame__Rect -> Example31.smallCode
    Frame__Padding -> Example32.smallCode
    Frame__Times -> Example33.smallCode
    Frame__OnlyInts -> Example34.smallCode
    Frame__GridColor -> Example35.smallCode
    Frame__Offset -> Example36.smallCode
    Frame__Color -> Example37.smallCode
    Frame__Amount -> Example38.smallCode
    Frame__Titles -> Example39.smallCode
    Frame__CustomLabels -> Example40.smallCode
    Frame__Margin -> Example41.smallCode
    Frame__LabelWithLine -> Example42.smallCode
    Frame__DotGrid -> Example43.smallCode
    Frame__CustomFormat -> Example44.smallCode
    Frame__AxisLength -> Example45.smallCode
    Frame__Arbitrary -> Example46.smallCode
    Frame__Legends -> Example47.smallCode
    Frame__Basic -> Example48.smallCode
    Interactivity__ChangeContent -> Example49.smallCode
    Interactivity__Direction -> Example50.smallCode
    Interactivity__ChangeDot -> Example51.smallCode
    Interactivity__Border -> Example52.smallCode
    Interactivity__Zoom -> Example53.smallCode
    Interactivity__BasicBin -> Example54.smallCode
    Interactivity__BasicStack -> Example55.smallCode
    Interactivity__Coordinates -> Example56.smallCode
    Interactivity__ChangeName -> Example57.smallCode
    Interactivity__NoArrow -> Example58.smallCode
    Interactivity__FilterSearch -> Example59.smallCode
    Interactivity__Background -> Example60.smallCode
    Interactivity__BasicBar -> Example61.smallCode
    Interactivity__BasicArea -> Example62.smallCode
    Interactivity__TrickyTooltip -> Example63.smallCode
    Interactivity__Multiple -> Example64.smallCode
    Interactivity__BasicLine -> Example65.smallCode
    Interactivity__Offset -> Example66.smallCode
    Interactivity__DoubleSearch -> Example67.smallCode
    Interactivity__ChangeUnit -> Example68.smallCode
    Interactivity__Focal -> Example69.smallCode
    LineCharts__Area -> Example70.smallCode
    LineCharts__Gradient -> Example71.smallCode
    LineCharts__Width -> Example72.smallCode
    LineCharts__TooltipStack -> Example73.smallCode
    LineCharts__Tooltip -> Example74.smallCode
    LineCharts__Montone -> Example75.smallCode
    LineCharts__Pattern -> Example76.smallCode
    LineCharts__Dots -> Example77.smallCode
    LineCharts__Dashed -> Example78.smallCode
    LineCharts__Color -> Example79.smallCode
    LineCharts__Stepped -> Example80.smallCode
    LineCharts__Stacked -> Example81.smallCode
    LineCharts__Labels -> Example82.smallCode
    LineCharts__Missing -> Example83.smallCode
    LineCharts__Legends -> Example84.smallCode
    LineCharts__Basic -> Example85.smallCode
    Frontpage__BasicBubble -> Example86.smallCode
    Frontpage__BasicNavigation -> Example87.smallCode
    Frontpage__BasicBar -> Example88.smallCode
    Frontpage__BasicArea -> Example89.smallCode
    Frontpage__Concise -> Example90.smallCode
    Frontpage__BasicLine -> Example91.smallCode
    Frontpage__BasicScatter -> Example92.smallCode
    Frontpage__Familiar -> Example93.smallCode
    ScatterCharts__Colors -> Example94.smallCode
    ScatterCharts__Shapes -> Example95.smallCode
    ScatterCharts__Tooltip -> Example96.smallCode
    ScatterCharts__Highlight -> Example97.smallCode
    ScatterCharts__DataDependent -> Example98.smallCode
    ScatterCharts__Borders -> Example99.smallCode
    ScatterCharts__Labels -> Example100.smallCode
    ScatterCharts__Opacity -> Example101.smallCode
    ScatterCharts__Sizes -> Example102.smallCode
    ScatterCharts__Legends -> Example103.smallCode
    ScatterCharts__Basic -> Example104.smallCode


largeCode : Id -> String
largeCode chosen =
  case chosen of
    BarCharts__Gradient -> Example0.largeCode
    BarCharts__VariableWidth -> Example1.largeCode
    BarCharts__Title -> Example2.largeCode
    BarCharts__TooltipStack -> Example3.largeCode
    BarCharts__Tooltip -> Example4.largeCode
    BarCharts__BarLabels -> Example5.largeCode
    BarCharts__Pattern -> Example6.largeCode
    BarCharts__Histogram -> Example7.largeCode
    BarCharts__BinLabelsAdvanced -> Example8.largeCode
    BarCharts__Spacing -> Example9.largeCode
    BarCharts__Highlight -> Example10.largeCode
    BarCharts__DataDependent -> Example11.largeCode
    BarCharts__Color -> Example12.largeCode
    BarCharts__TooltipBin -> Example13.largeCode
    BarCharts__Corners -> Example14.largeCode
    BarCharts__Ungroup -> Example15.largeCode
    BarCharts__BinLabels -> Example16.largeCode
    BarCharts__Stacked -> Example17.largeCode
    BarCharts__Margin -> Example18.largeCode
    BarCharts__Borders -> Example19.largeCode
    BarCharts__Opacity -> Example20.largeCode
    BarCharts__Legends -> Example21.largeCode
    BarCharts__Basic -> Example22.largeCode
    Frame__Lines -> Example23.largeCode
    Frame__Position -> Example24.largeCode
    Frame__Coordinates -> Example25.largeCode
    Frame__GridFilter -> Example26.largeCode
    Frame__Dimensions -> Example27.largeCode
    Frame__CustomElements -> Example28.largeCode
    Frame__NoArrow -> Example29.largeCode
    Frame__Background -> Example30.largeCode
    Frame__Rect -> Example31.largeCode
    Frame__Padding -> Example32.largeCode
    Frame__Times -> Example33.largeCode
    Frame__OnlyInts -> Example34.largeCode
    Frame__GridColor -> Example35.largeCode
    Frame__Offset -> Example36.largeCode
    Frame__Color -> Example37.largeCode
    Frame__Amount -> Example38.largeCode
    Frame__Titles -> Example39.largeCode
    Frame__CustomLabels -> Example40.largeCode
    Frame__Margin -> Example41.largeCode
    Frame__LabelWithLine -> Example42.largeCode
    Frame__DotGrid -> Example43.largeCode
    Frame__CustomFormat -> Example44.largeCode
    Frame__AxisLength -> Example45.largeCode
    Frame__Arbitrary -> Example46.largeCode
    Frame__Legends -> Example47.largeCode
    Frame__Basic -> Example48.largeCode
    Interactivity__ChangeContent -> Example49.largeCode
    Interactivity__Direction -> Example50.largeCode
    Interactivity__ChangeDot -> Example51.largeCode
    Interactivity__Border -> Example52.largeCode
    Interactivity__Zoom -> Example53.largeCode
    Interactivity__BasicBin -> Example54.largeCode
    Interactivity__BasicStack -> Example55.largeCode
    Interactivity__Coordinates -> Example56.largeCode
    Interactivity__ChangeName -> Example57.largeCode
    Interactivity__NoArrow -> Example58.largeCode
    Interactivity__FilterSearch -> Example59.largeCode
    Interactivity__Background -> Example60.largeCode
    Interactivity__BasicBar -> Example61.largeCode
    Interactivity__BasicArea -> Example62.largeCode
    Interactivity__TrickyTooltip -> Example63.largeCode
    Interactivity__Multiple -> Example64.largeCode
    Interactivity__BasicLine -> Example65.largeCode
    Interactivity__Offset -> Example66.largeCode
    Interactivity__DoubleSearch -> Example67.largeCode
    Interactivity__ChangeUnit -> Example68.largeCode
    Interactivity__Focal -> Example69.largeCode
    LineCharts__Area -> Example70.largeCode
    LineCharts__Gradient -> Example71.largeCode
    LineCharts__Width -> Example72.largeCode
    LineCharts__TooltipStack -> Example73.largeCode
    LineCharts__Tooltip -> Example74.largeCode
    LineCharts__Montone -> Example75.largeCode
    LineCharts__Pattern -> Example76.largeCode
    LineCharts__Dots -> Example77.largeCode
    LineCharts__Dashed -> Example78.largeCode
    LineCharts__Color -> Example79.largeCode
    LineCharts__Stepped -> Example80.largeCode
    LineCharts__Stacked -> Example81.largeCode
    LineCharts__Labels -> Example82.largeCode
    LineCharts__Missing -> Example83.largeCode
    LineCharts__Legends -> Example84.largeCode
    LineCharts__Basic -> Example85.largeCode
    Frontpage__BasicBubble -> Example86.largeCode
    Frontpage__BasicNavigation -> Example87.largeCode
    Frontpage__BasicBar -> Example88.largeCode
    Frontpage__BasicArea -> Example89.largeCode
    Frontpage__Concise -> Example90.largeCode
    Frontpage__BasicLine -> Example91.largeCode
    Frontpage__BasicScatter -> Example92.largeCode
    Frontpage__Familiar -> Example93.largeCode
    ScatterCharts__Colors -> Example94.largeCode
    ScatterCharts__Shapes -> Example95.largeCode
    ScatterCharts__Tooltip -> Example96.largeCode
    ScatterCharts__Highlight -> Example97.largeCode
    ScatterCharts__DataDependent -> Example98.largeCode
    ScatterCharts__Borders -> Example99.largeCode
    ScatterCharts__Labels -> Example100.largeCode
    ScatterCharts__Opacity -> Example101.largeCode
    ScatterCharts__Sizes -> Example102.largeCode
    ScatterCharts__Legends -> Example103.largeCode
    ScatterCharts__Basic -> Example104.largeCode


name : Id -> String
name chosen =
  case chosen of
    BarCharts__Gradient -> "Examples.BarCharts.Gradient"
    BarCharts__VariableWidth -> "Examples.BarCharts.VariableWidth"
    BarCharts__Title -> "Examples.BarCharts.Title"
    BarCharts__TooltipStack -> "Examples.BarCharts.TooltipStack"
    BarCharts__Tooltip -> "Examples.BarCharts.Tooltip"
    BarCharts__BarLabels -> "Examples.BarCharts.BarLabels"
    BarCharts__Pattern -> "Examples.BarCharts.Pattern"
    BarCharts__Histogram -> "Examples.BarCharts.Histogram"
    BarCharts__BinLabelsAdvanced -> "Examples.BarCharts.BinLabelsAdvanced"
    BarCharts__Spacing -> "Examples.BarCharts.Spacing"
    BarCharts__Highlight -> "Examples.BarCharts.Highlight"
    BarCharts__DataDependent -> "Examples.BarCharts.DataDependent"
    BarCharts__Color -> "Examples.BarCharts.Color"
    BarCharts__TooltipBin -> "Examples.BarCharts.TooltipBin"
    BarCharts__Corners -> "Examples.BarCharts.Corners"
    BarCharts__Ungroup -> "Examples.BarCharts.Ungroup"
    BarCharts__BinLabels -> "Examples.BarCharts.BinLabels"
    BarCharts__Stacked -> "Examples.BarCharts.Stacked"
    BarCharts__Margin -> "Examples.BarCharts.Margin"
    BarCharts__Borders -> "Examples.BarCharts.Borders"
    BarCharts__Opacity -> "Examples.BarCharts.Opacity"
    BarCharts__Legends -> "Examples.BarCharts.Legends"
    BarCharts__Basic -> "Examples.BarCharts.Basic"
    Frame__Lines -> "Examples.Frame.Lines"
    Frame__Position -> "Examples.Frame.Position"
    Frame__Coordinates -> "Examples.Frame.Coordinates"
    Frame__GridFilter -> "Examples.Frame.GridFilter"
    Frame__Dimensions -> "Examples.Frame.Dimensions"
    Frame__CustomElements -> "Examples.Frame.CustomElements"
    Frame__NoArrow -> "Examples.Frame.NoArrow"
    Frame__Background -> "Examples.Frame.Background"
    Frame__Rect -> "Examples.Frame.Rect"
    Frame__Padding -> "Examples.Frame.Padding"
    Frame__Times -> "Examples.Frame.Times"
    Frame__OnlyInts -> "Examples.Frame.OnlyInts"
    Frame__GridColor -> "Examples.Frame.GridColor"
    Frame__Offset -> "Examples.Frame.Offset"
    Frame__Color -> "Examples.Frame.Color"
    Frame__Amount -> "Examples.Frame.Amount"
    Frame__Titles -> "Examples.Frame.Titles"
    Frame__CustomLabels -> "Examples.Frame.CustomLabels"
    Frame__Margin -> "Examples.Frame.Margin"
    Frame__LabelWithLine -> "Examples.Frame.LabelWithLine"
    Frame__DotGrid -> "Examples.Frame.DotGrid"
    Frame__CustomFormat -> "Examples.Frame.CustomFormat"
    Frame__AxisLength -> "Examples.Frame.AxisLength"
    Frame__Arbitrary -> "Examples.Frame.Arbitrary"
    Frame__Legends -> "Examples.Frame.Legends"
    Frame__Basic -> "Examples.Frame.Basic"
    Interactivity__ChangeContent -> "Examples.Interactivity.ChangeContent"
    Interactivity__Direction -> "Examples.Interactivity.Direction"
    Interactivity__ChangeDot -> "Examples.Interactivity.ChangeDot"
    Interactivity__Border -> "Examples.Interactivity.Border"
    Interactivity__Zoom -> "Examples.Interactivity.Zoom"
    Interactivity__BasicBin -> "Examples.Interactivity.BasicBin"
    Interactivity__BasicStack -> "Examples.Interactivity.BasicStack"
    Interactivity__Coordinates -> "Examples.Interactivity.Coordinates"
    Interactivity__ChangeName -> "Examples.Interactivity.ChangeName"
    Interactivity__NoArrow -> "Examples.Interactivity.NoArrow"
    Interactivity__FilterSearch -> "Examples.Interactivity.FilterSearch"
    Interactivity__Background -> "Examples.Interactivity.Background"
    Interactivity__BasicBar -> "Examples.Interactivity.BasicBar"
    Interactivity__BasicArea -> "Examples.Interactivity.BasicArea"
    Interactivity__TrickyTooltip -> "Examples.Interactivity.TrickyTooltip"
    Interactivity__Multiple -> "Examples.Interactivity.Multiple"
    Interactivity__BasicLine -> "Examples.Interactivity.BasicLine"
    Interactivity__Offset -> "Examples.Interactivity.Offset"
    Interactivity__DoubleSearch -> "Examples.Interactivity.DoubleSearch"
    Interactivity__ChangeUnit -> "Examples.Interactivity.ChangeUnit"
    Interactivity__Focal -> "Examples.Interactivity.Focal"
    LineCharts__Area -> "Examples.LineCharts.Area"
    LineCharts__Gradient -> "Examples.LineCharts.Gradient"
    LineCharts__Width -> "Examples.LineCharts.Width"
    LineCharts__TooltipStack -> "Examples.LineCharts.TooltipStack"
    LineCharts__Tooltip -> "Examples.LineCharts.Tooltip"
    LineCharts__Montone -> "Examples.LineCharts.Montone"
    LineCharts__Pattern -> "Examples.LineCharts.Pattern"
    LineCharts__Dots -> "Examples.LineCharts.Dots"
    LineCharts__Dashed -> "Examples.LineCharts.Dashed"
    LineCharts__Color -> "Examples.LineCharts.Color"
    LineCharts__Stepped -> "Examples.LineCharts.Stepped"
    LineCharts__Stacked -> "Examples.LineCharts.Stacked"
    LineCharts__Labels -> "Examples.LineCharts.Labels"
    LineCharts__Missing -> "Examples.LineCharts.Missing"
    LineCharts__Legends -> "Examples.LineCharts.Legends"
    LineCharts__Basic -> "Examples.LineCharts.Basic"
    Frontpage__BasicBubble -> "Examples.Frontpage.BasicBubble"
    Frontpage__BasicNavigation -> "Examples.Frontpage.BasicNavigation"
    Frontpage__BasicBar -> "Examples.Frontpage.BasicBar"
    Frontpage__BasicArea -> "Examples.Frontpage.BasicArea"
    Frontpage__Concise -> "Examples.Frontpage.Concise"
    Frontpage__BasicLine -> "Examples.Frontpage.BasicLine"
    Frontpage__BasicScatter -> "Examples.Frontpage.BasicScatter"
    Frontpage__Familiar -> "Examples.Frontpage.Familiar"
    ScatterCharts__Colors -> "Examples.ScatterCharts.Colors"
    ScatterCharts__Shapes -> "Examples.ScatterCharts.Shapes"
    ScatterCharts__Tooltip -> "Examples.ScatterCharts.Tooltip"
    ScatterCharts__Highlight -> "Examples.ScatterCharts.Highlight"
    ScatterCharts__DataDependent -> "Examples.ScatterCharts.DataDependent"
    ScatterCharts__Borders -> "Examples.ScatterCharts.Borders"
    ScatterCharts__Labels -> "Examples.ScatterCharts.Labels"
    ScatterCharts__Opacity -> "Examples.ScatterCharts.Opacity"
    ScatterCharts__Sizes -> "Examples.ScatterCharts.Sizes"
    ScatterCharts__Legends -> "Examples.ScatterCharts.Legends"
    ScatterCharts__Basic -> "Examples.ScatterCharts.Basic"


meta chosen =
  case chosen of
    BarCharts__Gradient -> Example0.meta
    BarCharts__VariableWidth -> Example1.meta
    BarCharts__Title -> Example2.meta
    BarCharts__TooltipStack -> Example3.meta
    BarCharts__Tooltip -> Example4.meta
    BarCharts__BarLabels -> Example5.meta
    BarCharts__Pattern -> Example6.meta
    BarCharts__Histogram -> Example7.meta
    BarCharts__BinLabelsAdvanced -> Example8.meta
    BarCharts__Spacing -> Example9.meta
    BarCharts__Highlight -> Example10.meta
    BarCharts__DataDependent -> Example11.meta
    BarCharts__Color -> Example12.meta
    BarCharts__TooltipBin -> Example13.meta
    BarCharts__Corners -> Example14.meta
    BarCharts__Ungroup -> Example15.meta
    BarCharts__BinLabels -> Example16.meta
    BarCharts__Stacked -> Example17.meta
    BarCharts__Margin -> Example18.meta
    BarCharts__Borders -> Example19.meta
    BarCharts__Opacity -> Example20.meta
    BarCharts__Legends -> Example21.meta
    BarCharts__Basic -> Example22.meta
    Frame__Lines -> Example23.meta
    Frame__Position -> Example24.meta
    Frame__Coordinates -> Example25.meta
    Frame__GridFilter -> Example26.meta
    Frame__Dimensions -> Example27.meta
    Frame__CustomElements -> Example28.meta
    Frame__NoArrow -> Example29.meta
    Frame__Background -> Example30.meta
    Frame__Rect -> Example31.meta
    Frame__Padding -> Example32.meta
    Frame__Times -> Example33.meta
    Frame__OnlyInts -> Example34.meta
    Frame__GridColor -> Example35.meta
    Frame__Offset -> Example36.meta
    Frame__Color -> Example37.meta
    Frame__Amount -> Example38.meta
    Frame__Titles -> Example39.meta
    Frame__CustomLabels -> Example40.meta
    Frame__Margin -> Example41.meta
    Frame__LabelWithLine -> Example42.meta
    Frame__DotGrid -> Example43.meta
    Frame__CustomFormat -> Example44.meta
    Frame__AxisLength -> Example45.meta
    Frame__Arbitrary -> Example46.meta
    Frame__Legends -> Example47.meta
    Frame__Basic -> Example48.meta
    Interactivity__ChangeContent -> Example49.meta
    Interactivity__Direction -> Example50.meta
    Interactivity__ChangeDot -> Example51.meta
    Interactivity__Border -> Example52.meta
    Interactivity__Zoom -> Example53.meta
    Interactivity__BasicBin -> Example54.meta
    Interactivity__BasicStack -> Example55.meta
    Interactivity__Coordinates -> Example56.meta
    Interactivity__ChangeName -> Example57.meta
    Interactivity__NoArrow -> Example58.meta
    Interactivity__FilterSearch -> Example59.meta
    Interactivity__Background -> Example60.meta
    Interactivity__BasicBar -> Example61.meta
    Interactivity__BasicArea -> Example62.meta
    Interactivity__TrickyTooltip -> Example63.meta
    Interactivity__Multiple -> Example64.meta
    Interactivity__BasicLine -> Example65.meta
    Interactivity__Offset -> Example66.meta
    Interactivity__DoubleSearch -> Example67.meta
    Interactivity__ChangeUnit -> Example68.meta
    Interactivity__Focal -> Example69.meta
    LineCharts__Area -> Example70.meta
    LineCharts__Gradient -> Example71.meta
    LineCharts__Width -> Example72.meta
    LineCharts__TooltipStack -> Example73.meta
    LineCharts__Tooltip -> Example74.meta
    LineCharts__Montone -> Example75.meta
    LineCharts__Pattern -> Example76.meta
    LineCharts__Dots -> Example77.meta
    LineCharts__Dashed -> Example78.meta
    LineCharts__Color -> Example79.meta
    LineCharts__Stepped -> Example80.meta
    LineCharts__Stacked -> Example81.meta
    LineCharts__Labels -> Example82.meta
    LineCharts__Missing -> Example83.meta
    LineCharts__Legends -> Example84.meta
    LineCharts__Basic -> Example85.meta
    Frontpage__BasicBubble -> Example86.meta
    Frontpage__BasicNavigation -> Example87.meta
    Frontpage__BasicBar -> Example88.meta
    Frontpage__BasicArea -> Example89.meta
    Frontpage__Concise -> Example90.meta
    Frontpage__BasicLine -> Example91.meta
    Frontpage__BasicScatter -> Example92.meta
    Frontpage__Familiar -> Example93.meta
    ScatterCharts__Colors -> Example94.meta
    ScatterCharts__Shapes -> Example95.meta
    ScatterCharts__Tooltip -> Example96.meta
    ScatterCharts__Highlight -> Example97.meta
    ScatterCharts__DataDependent -> Example98.meta
    ScatterCharts__Borders -> Example99.meta
    ScatterCharts__Labels -> Example100.meta
    ScatterCharts__Opacity -> Example101.meta
    ScatterCharts__Sizes -> Example102.meta
    ScatterCharts__Legends -> Example103.meta
    ScatterCharts__Basic -> Example104.meta


all : List Id
all =
  [ BarCharts__Gradient
  , BarCharts__VariableWidth
  , BarCharts__Title
  , BarCharts__TooltipStack
  , BarCharts__Tooltip
  , BarCharts__BarLabels
  , BarCharts__Pattern
  , BarCharts__Histogram
  , BarCharts__BinLabelsAdvanced
  , BarCharts__Spacing
  , BarCharts__Highlight
  , BarCharts__DataDependent
  , BarCharts__Color
  , BarCharts__TooltipBin
  , BarCharts__Corners
  , BarCharts__Ungroup
  , BarCharts__BinLabels
  , BarCharts__Stacked
  , BarCharts__Margin
  , BarCharts__Borders
  , BarCharts__Opacity
  , BarCharts__Legends
  , BarCharts__Basic
  , Frame__Lines
  , Frame__Position
  , Frame__Coordinates
  , Frame__GridFilter
  , Frame__Dimensions
  , Frame__CustomElements
  , Frame__NoArrow
  , Frame__Background
  , Frame__Rect
  , Frame__Padding
  , Frame__Times
  , Frame__OnlyInts
  , Frame__GridColor
  , Frame__Offset
  , Frame__Color
  , Frame__Amount
  , Frame__Titles
  , Frame__CustomLabels
  , Frame__Margin
  , Frame__LabelWithLine
  , Frame__DotGrid
  , Frame__CustomFormat
  , Frame__AxisLength
  , Frame__Arbitrary
  , Frame__Legends
  , Frame__Basic
  , Interactivity__ChangeContent
  , Interactivity__Direction
  , Interactivity__ChangeDot
  , Interactivity__Border
  , Interactivity__Zoom
  , Interactivity__BasicBin
  , Interactivity__BasicStack
  , Interactivity__Coordinates
  , Interactivity__ChangeName
  , Interactivity__NoArrow
  , Interactivity__FilterSearch
  , Interactivity__Background
  , Interactivity__BasicBar
  , Interactivity__BasicArea
  , Interactivity__TrickyTooltip
  , Interactivity__Multiple
  , Interactivity__BasicLine
  , Interactivity__Offset
  , Interactivity__DoubleSearch
  , Interactivity__ChangeUnit
  , Interactivity__Focal
  , LineCharts__Area
  , LineCharts__Gradient
  , LineCharts__Width
  , LineCharts__TooltipStack
  , LineCharts__Tooltip
  , LineCharts__Montone
  , LineCharts__Pattern
  , LineCharts__Dots
  , LineCharts__Dashed
  , LineCharts__Color
  , LineCharts__Stepped
  , LineCharts__Stacked
  , LineCharts__Labels
  , LineCharts__Missing
  , LineCharts__Legends
  , LineCharts__Basic
  , Frontpage__BasicBubble
  , Frontpage__BasicNavigation
  , Frontpage__BasicBar
  , Frontpage__BasicArea
  , Frontpage__Concise
  , Frontpage__BasicLine
  , Frontpage__BasicScatter
  , Frontpage__Familiar
  , ScatterCharts__Colors
  , ScatterCharts__Shapes
  , ScatterCharts__Tooltip
  , ScatterCharts__Highlight
  , ScatterCharts__DataDependent
  , ScatterCharts__Borders
  , ScatterCharts__Labels
  , ScatterCharts__Opacity
  , ScatterCharts__Sizes
  , ScatterCharts__Legends
  , ScatterCharts__Basic
  ]


first : Id
first =
  BarCharts__Gradient

