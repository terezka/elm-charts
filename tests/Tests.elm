module Tests exposing (..)

import Test exposing (..)
import Expect
import String
import Helpers exposing (getHighest)


all : Test
all =
    describe "Helpers"
        [
            describe "getHighest"
                [ test "should return 11 when passing [2, 10, 11] " <|
                    \() ->
                        Expect.equal (getHighest [2, 10, 11]) 11
                , test "should return 1 in case of an empty list" <|
                    \() ->
                        Expect.equal (getHighest []) 1
                , test "should return when negative number are provided" <|
                    \() ->
                        Expect.equal (getHighest [-1, -2, -3]) -1
                ]
        ]
