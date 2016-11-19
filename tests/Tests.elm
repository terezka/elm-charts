module Tests exposing (all)

import Test exposing (..)
import Fuzz exposing (..)
import Expect
import HelperTests
import List exposing (append)
import Plot exposing (..)


all : Test
all =
    describe "elm-plot"
        [ HelperTests.all
        , testPadding
        , testSize
        , testPlotStyle
        , testPlotClasses
        ]


baseMetaConfig =
  { size = ( 1, 2 )
  , padding = (0, 0)
  , classes = ["foobar"]
  , style = [("padding","30px"),("stroke","#000")]
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
  describe "size"
    [ fuzz (list string)
      "should return a valid metaConfig " <|
        \data ->
          let
            result = plotClasses data baseMetaConfig
            expected = { baseMetaConfig | classes = data }
          in
          Expect.equal result expected
    ]
