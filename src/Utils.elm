module Utils exposing (..)

import Round
import Regex


toValue : Float -> Float -> Int -> Float
toValue delta firstValue index =
    firstValue
        + (toFloat index)
        * delta
        |> Round.round (getDeltaPrecision delta)
        |> String.toFloat
        |> Result.withDefault 0


getDeltaPrecision : Float -> Int
getDeltaPrecision delta =
    delta
        |> toString
        |> Regex.find (Regex.AtMost 1) (Regex.regex "\\.[0-9]*")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
        |> String.length
        |> (-) 1
        |> min 0
        |> abs


getFirstValue : Float -> Float -> Float
getFirstValue delta lowest =
    ceilToNearest delta lowest


ceilToNearest : Float -> Float -> Float
ceilToNearest precision value =
    toFloat (ceiling (value / precision)) * precision


toValuesFromDelta : Float -> Float -> Float -> List Float
toValuesFromDelta lowest highest delta =
    let
        range =
            highest - lowest

        firstValue =
            getFirstValue delta lowest

        tickCount =
            getCount delta lowest range firstValue
    in
        List.map (toValue delta firstValue) (List.range 0 tickCount)


getCount : Float -> Float -> Float -> Float -> Int
getCount delta lowest range firstValue =
    floor ((range - (abs lowest - abs firstValue)) / delta)


toDelta : Float -> Float -> Int -> Float
toDelta lower upper totalTicks =
    let
        range =
            upper - lower

        -- calculate an initial guess at step size
        delta0 =
            range / (toFloat totalTicks)

        -- get the magnitude of the step size
        mag =
            floor (logBase 10 delta0)

        magPow =
            toFloat (10 ^ mag)

        -- calculate most significant digit of the new step size
        magMsd =
            round (delta0 / magPow)

        -- promote the MSD to either 1, 2, or 5
        magMsdFinal =
            if magMsd > 5 then
                10
            else if magMsd > 2 then
                5
            else if magMsd > 1 then
                1
            else
                magMsd
    in
        (toFloat magMsdFinal) * magPow


toUpperDelta : Float -> Int -> Float
toUpperDelta highestValue totalNumOfSteps =
    let
        -- Calculate an initial guess at step size
        tempStep =
            highestValue / (toFloat totalNumOfSteps)

        -- Get the magnitude of the step size
        mag =
            floor (logBase 10 tempStep)

        magPow =
            mag ^ 10

        -- To avoid too much space between the ticks, approximate from second most significant digit
        leftMost =
            (floor (tempStep / (toFloat magPow))) * magPow

        sndMsg =
            ceiling (((tempStep - (toFloat leftMost)) * 10) / (toFloat magPow))

        niceValue =
            getNiceValue (toFloat sndMsg) magPow

        step =
            (toFloat leftMost) + (niceValue / 10) * (toFloat magPow)
    in
        if step > 0 then
            step
        else
            1


getNiceValue : Float -> Int -> Float
getNiceValue value magPow =
    if magPow < 10 then
        10
    else if magPow < 100 then
        if value > 5 then
            10
        else
            5
    else if value > 7.5 then
        10
    else if value > 5 then
        7.5
    else
        5
