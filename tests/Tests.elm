module Tests exposing (all)

import Test exposing (..)
import Fuzz exposing (..)
import Expect
import HelperTests
import List exposing (append)
import Svg.Attributes exposing (..)
import Plot exposing (..)


all : Test
all =
    describe "elm-plot"
        [ HelperTests.all
        , testPadding
        , testSize
        , testPlotStyle
        , testPlotClasses
        , testTickLength
        , testTickWidth
        , testTickClasses
        , testTickStyle
        ]


baseMetaConfig =
    { size = ( 800, 500 )
    , padding = ( 0, 0 )
    , classes = []
    , attributes = [ style "padding: 30px;", stroke "#000" ]
    }


baseTickViewConfig =
    { length = 7
    , width = 1
    , attributes = []
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
    [ test "should return a valid metaConfig " <|
        \() ->
          let
            result = plotAttributes [Svg.Attributes.r "5"] baseMetaConfig
            expected = { baseMetaConfig | attributes = append [Svg.Attributes.r "5"] baseMetaConfig.attributes }
          in
          Expect.equal result expected
    ]


testPlotClasses : Test
testPlotClasses =
  describe "plotClasses"
    [ fuzz (list Fuzz.string)
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
    [ fuzz (list Fuzz.string)
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
  describe "tickStyle"
    [ test "should return a valid viewConfig" <|
        \() ->
          let
            result = tickAttributes [Svg.Attributes.r "5"] baseTickViewConfig
            expected = { baseTickViewConfig | attributes = [Svg.Attributes.r "5"] }
          in
          Expect.equal result expected
    ]
