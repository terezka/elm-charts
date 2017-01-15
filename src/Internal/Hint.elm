module Internal.Hint exposing (..)

import Internal.Types exposing (Orientation(..), Scale, Meta, Value, HintInfo, Style)
import Internal.Draw exposing (..)
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

        isLeftSide =
            xSvg - scale.x.offset.lower < scale.x.length / 2

        lineView =
            [ viewLine lineStyle scale.y.length ]
    in
        Html.div
            [ Html.Attributes.class "elm-plot__hint"
            , Html.Attributes.style
                [ ( "left", toPixels xSvg )
                , ( "top", toPixels scale.y.offset.lower )
                , ( "position", "absolute" )
                ]
            ]
            ((view info isLeftSide) :: lineView)


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


viewYValue : Int -> Maybe (List Value) -> Html.Html msg
viewYValue index hintValue =
    let
        hintValueDisplayed =
            case hintValue of
                Just value ->
                    case value of
                        [ singleY ] ->
                            toString singleY

                        _ ->
                            toString value

                Nothing ->
                    "~"
    in
        Html.div []
            [ Html.span [] [ Html.text ("Serie " ++ toString index ++ ": ") ]
            , Html.span [] [ Html.text hintValueDisplayed ]
            ]
