module TestPlot exposing (..)

baseMetaConfig =
    { size = ( 800, 500 )
    , padding = ( 0, 0 )
    , classes = []
    , style = [ ( "padding", "30px" ), ( "stroke", "#000" ) ]
    }


baseTickViewConfig =
    { length = 7
    , width = 1
    , style = []
    , classes = []
    }


testPadding : Test
testPadding =
  describe "padding"
    [ fuzz (tuple ( int, int ))
      "should return a valid metaConfig " <|
        \data ->
          let
            result =  padding data baseMetaConfig
            expected = { baseMetaConfig | padding = data }
          in
          Expect.equal result expected
    ]


testSize : Test
testSize =
  describe "size"
    [ fuzz (tuple ( int, int ))
      "should return a valid metaConfig " <|
        \data ->
          let
            result = size data baseMetaConfig
            expected = { baseMetaConfig | size = data }
          in
          Expect.equal result expected
    ]


testPlotStyle : Test
testPlotStyle =
  describe "plotStyle"
    [ fuzz (list (tuple ( string, string )))
      "should return a valid metaConfig " <|
        \data ->
          let
            result = plotStyle data baseMetaConfig
            expected = { baseMetaConfig | style = append data baseMetaConfig.style }
          in
          Expect.equal result expected
    ]


testPlotClasses : Test
testPlotClasses =
  describe "plotClasses"
    [ fuzz (list string)
      "should return a valid metaConfig " <|
        \data ->
          let
            result = plotClasses data baseMetaConfig
            expected = { baseMetaConfig | classes = data }
          in
          Expect.equal result expected
    ]


testTickLength : Test
testTickLength =
  describe "tickLength"
    [ fuzz (int)
      "should return a valid viewConfig" <|
        \data ->
          let
            result = tickLength data baseTickViewConfig
            expected = { baseTickViewConfig | length = data }
          in
          Expect.equal result expected
    ]


testTickWidth : Test
testTickWidth =
  describe "tickWidth"
    [ fuzz (int)
      "should return a valid viewConfig" <|
        \data ->
          let
            result = tickWidth data baseTickViewConfig
            expected = { baseTickViewConfig | width = data }
          in
          Expect.equal result expected
    ]


testTickClasses : Test
testTickClasses =
  describe "tickClasses"
    [ fuzz (list string)
      "should return a valid viewConfig" <|
        \data ->
          let
            result = tickClasses data baseTickViewConfig
            expected = { baseTickViewConfig | classes = data }
          in
          Expect.equal result expected
    ]


testTickStyle : Test
testTickStyle =
  describe "Tick.view"
    [ fuzz (list (tuple ( string, string )))
      "should return a valid viewConfig" <|
        \data ->
          let
            result = tickStyle data baseTickViewConfig
            expected = { baseTickViewConfig | style = data }
          in
          Expect.equal result expected
    ]
