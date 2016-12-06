module Internal.Hint exposing (..)

import Internal.Types exposing (Point, Style, Orientation(..), Scale, Meta, HintInfo)
import Internal.Draw exposing (..)
import Svg
import Svg.Attributes
import Html
import Html.Attributes


type alias Config msg =
    { view : HintInfo -> Bool -> Html.Html msg
    , lineStyle : Style
    }


defaultConfig : Config msg
defaultConfig =
    { view = defaultView
    , lineStyle = []
    }


view : Meta -> Config msg -> ( Float, Float ) -> Html.Html msg
view { toSvgCoords, scale, getHintInfo } { lineStyle, view } position =
    let
        info =
            getHintInfo (Tuple.first position)

        ( xSvg, ySvg ) =
            toSvgCoords ( info.xValue, 0 )

        flipped =
            xSvg < scale.x.length / 2

        lineView =
            [ viewLine lineStyle scale.y.length ]
    in
        Html.div
            [ Html.Attributes.class "elm-plot__hint"
            , Html.Attributes.style
                [ ( "left", toPixels xSvg )
                , ( "top", toPixels scale.y.offset )
                ]
            ]
            ((view info flipped) :: lineView)


viewLine : Style -> Float -> Html.Html msg
viewLine style length =
    Html.div
        [ Html.Attributes.class "elm-plot__hint__line"
        , Html.Attributes.style <| [ ( "height", toPixels length ) ] ++ style
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
                    "~"
    in
        Html.div []
            [ Html.span [] [ Html.text ("Serie " ++ toString index ++ ": ") ]
            , Html.span [] [ Html.text yValueDisplayed ]
            ]
