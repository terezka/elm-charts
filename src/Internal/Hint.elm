module Internal.Hint exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..), Scale, Meta, HintInfo)
import Helpers exposing (..)
import Svg
import Svg.Attributes
import Html
import Html.Attributes


type alias Config msg =
    { view : HintInfo -> Bool -> Html.Html msg
    , showLine : Bool
    , lineStyle : Style
    }


defaultConfig : Config msg
defaultConfig =
    { view = defaultView
    , showLine = True
    , lineStyle = []
    }


view : Meta -> Config msg -> ( Float, Float ) -> Html.Html msg
view { toSvgCoords, scale, getHintInfo } { showLine, view } position =
    let
        info =
            getHintInfo (Tuple.first position)

        ( xSvg, ySvg ) =
            toSvgCoords ( info.xValue, 0 )

        flipped =
            xSvg < scale.length / 2

        lineView =
            if showLine then
                [ viewLine ( xSvg, ySvg ) ]
            else
                []
    in
        Html.div
            [ Html.Attributes.class "elm-plot__hint"
            , Html.Attributes.style [ ( "left", (toString xSvg) ++ "px" ) ]
            ]
            ((view info flipped) :: lineView)


viewLine : ( Float, Float ) -> Html.Html msg
viewLine ( x, y ) =
    Html.div
        [ Html.Attributes.class "elm-plot__hint__line"
        , Html.Attributes.style
            [ ( "height", toString y ++ "px" ) ]
        ]
        []


defaultView : HintInfo -> Bool -> Html.Html msg
defaultView { xValue, yValues } isLeftSide =
    let
        classes =
            [ ( "elm-plot__hint__default-view", True )
            , ( "elm-plot__hint__default-view--left", isLeftSide )
            , ( "elm-plot__hint__default-view--right", not isLeftSide )
            ]
    in
        Html.div
            [ Html.Attributes.classList classes ]
            [ Html.div [] [ Html.text ("X: " ++ toString xValue) ]
            , Html.div [] (List.indexedMap viewYValue yValues)
            ]


viewYValue : Int -> Maybe Float -> Html.Html msg
viewYValue index yValue =
    let
        yValueDisplayed =
            case yValue of
                Just value ->
                    toString value

                Nothing ->
                    "No data"
    in
        Html.div []
            [ Html.span [] [ Html.text ("Serie " ++ toString index ++ ": ") ]
            , Html.span [] [ Html.text yValueDisplayed ]
            ]
