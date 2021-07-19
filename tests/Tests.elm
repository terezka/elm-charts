module Tests exposing (..)

import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import Expect
import Fuzz exposing (Fuzzer, list, int, float, tuple, string, map)
import Html exposing (Html, div)
import Svg exposing (Svg, svg)
import Svg.Attributes
import Svg.Coordinates as Coordinates exposing (..)
import Svg.Chart exposing (..)
import Svg.Tiles exposing (..)


coordinates : Test
coordinates =
  describe "Cartesian translation"
    [ test "toSVGX" <|
        \() ->
          expectFloat 11 (toSVGX defaultPlane 1)
    , test "toSVGY" <|
        \() ->
          expectFloat 99 (toSVGY defaultPlane 1)
    --
    , test "toCartesianX" <|
        \() ->
          expectFloat 1 (toCartesianX defaultPlane 11)
    , test "toCartesianY" <|
        \() ->
          expectFloat 1 (toCartesianY defaultPlane 99)
    --
    , test "toSVGX with lower margin" <|
        \() ->
          expectFloat 20 (toSVGX { defaultPlane | x = updateMarginLower defaultPlane.x 10 } 1)
    , test "toSVGX with upper margin" <|
        \() ->
          expectFloat 10 (toSVGX { defaultPlane | x = updateMarginUpper defaultPlane.x 10 } 1)
    --
    , test "toSVGY with lower margin" <|
        \() ->
          expectFloat 90 (toSVGY { defaultPlane | y = updateMarginLower defaultPlane.y 10 } 1)
    , test "toSVGY with upper margin" <|
        \() ->
          expectFloat 100 (toSVGY { defaultPlane | y = updateMarginUpper defaultPlane.y 10 } 1)
    --
    , test "toCartesianY with lower margin" <|
        \() ->
          expectFloat 1 (toCartesianY { defaultPlane | y = updateMarginLower defaultPlane.y 10 } 90)
    , test "toCartesianY with upper margin" <|
        \() ->
          expectFloat 1 (toCartesianY { defaultPlane | y = updateMarginUpper defaultPlane.y 10 } 100)
    --
    , test "Length should default to 1" <|
        \() ->
          expectFloat 0.9 (toSVGY { defaultPlane | y = updatelength defaultPlane.y 0 } 1)
    , fuzz float "x-coordinate produced should always be a number" <|
        \number ->
          toSVGX defaultPlane number
            |> isNaN
            |> Expect.false "Coordinate should always be a number!"
    , fuzz float "y-coordinate produced should always be a number" <|
        \number ->
          toSVGY defaultPlane number
            |> isNaN
            |> Expect.false "Coordinate should always be a number!"
    ]


plots : Test
plots =
  describe "Plots"
    -- TODO: These doesn't have to be fuzz tests.
    [ fuzz randomPoints "User can set stroke for lines" <|
        \points ->
            case points of
              [] ->
                Expect.pass

              actualPoints ->
                wrapSvg [ monotone (planeFromPoints actualPoints) .x .y [ Svg.Attributes.stroke "red" ] (always clear) actualPoints ]
                  |> Query.fromHtml
                  |> Query.find [ Selector.tag "path" ]
                  |> Query.has [ Selector.attribute (Svg.Attributes.stroke "red") ]
    , fuzz randomPoints "User can set fill for areas" <|
        \points ->
            case points of
              [] ->
                Expect.pass

              actualPoints ->
                wrapSvg [ monotoneArea (planeFromPoints actualPoints) .x .y [ Svg.Attributes.fill "red" ] (always clear) actualPoints ]
                  |> Query.fromHtml
                  |> Query.find [ Selector.tag "path" ]
                  |> Query.has [ Selector.attribute (Svg.Attributes.fill "red") ]
    ]


maps : Test
maps =
  describe "Maps"
    [ test "tileWidth" <|
        \() ->
          Expect.equal 30 (tileWidth 300 10)
    , test "tileHeight" <|
        \() ->
          Expect.equal 30 (tileHeight 300 10 100)
    , test "tileXCoord" <|
        \() ->
          Expect.equal 60 (tileXCoord 30 10 2)
    , test "tileYCoord" <|
        \() ->
          Expect.equal 60 (tileYCoord 30 10 22)
    ]



-- HELPERS


wrapSvg : List (Svg msg) -> Html msg
wrapSvg children =
  div [] [ svg [] children ]


randomPoints : Fuzzer (List Point)
randomPoints =
  list (map (\( x, y ) -> Point x y) (tuple (float, float)))


planeFromPoints : List Point -> Plane
planeFromPoints points =
  { x =
    { marginLower = 10
    , marginUpper = 10
    , length = 300
    , min = minimum [.x] points
    , max = maximum [.x] points
    }
  , y =
    { marginLower = 10
    , marginUpper = 10
    , length = 300
    , min = minimum [.y] points
    , max = maximum [.y] points
    }
  }


defaultPlane : Plane
defaultPlane =
  { x = defaultAxis
  , y = defaultAxis
  }


defaultAxis : Axis
defaultAxis =
  { marginLower = 0
  , marginUpper = 0
  , length = 110
  , min = 0
  , max = 10
  }


updateMarginLower : Axis -> Float -> Axis
updateMarginLower config marginLower =
  { config | marginLower = marginLower }


updateMarginUpper : Axis -> Float -> Axis
updateMarginUpper config marginUpper =
  { config | marginUpper = marginUpper }


updatelength : Axis -> Float -> Axis
updatelength config length =
  { config | length = length }


type alias Point =
  { x : Float, y : Float }


expectFloat : Float -> Float -> Expect.Expectation
expectFloat =
  Expect.within (Expect.Absolute 0.1)
