module Plot.Tooltip exposing (..)

import Plot.Types exposing (Point, Style, Orientation(..), Scale, Meta, TooltipInfo)
import Helpers exposing (..)
import Svg
import Svg.Attributes
import Html
import Html.Attributes


type alias Config msg =
    { view : TooltipInfo -> Bool -> Html.Html msg
    , showLine : Bool
    , lineStyle : Style
    }


defaultConfig : Config msg
defaultConfig =
    { view = defaultView
    , showLine = True
    , lineStyle = []
    }


{-| The type representing a tooltip configuration.
-}
type alias Attribute msg =
    Config msg -> Config msg


{-| -}
removeLine : Attribute msg
removeLine config =
    { config | showLine = False }


{-| -}
viewCustom : (TooltipInfo -> Bool -> Html.Html msg) -> Attribute msg
viewCustom view config =
    { config | view = view }


view : Meta -> Config msg -> ( Float, Float ) -> Html.Html msg
view { toSvgCoords, scale, getTooltipInfo } { showLine, view } position =
    let
        info =
            getTooltipInfo (Tuple.first position)

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
            [ Html.Attributes.class "elm-plot__tooltip"
            , Html.Attributes.style [ ( "left", (toString xSvg) ++ "px" ) ]
            ]
            ((view info flipped) :: lineView)


viewLine : ( Float, Float ) -> Html.Html msg
viewLine ( x, y ) =
    Html.div
        [ Html.Attributes.class "elm-plot__tooltip__line"
        , Html.Attributes.style
            [ ( "height", toString y ++ "px" ) ]
        ]
        []


defaultView : TooltipInfo -> Bool -> Html.Html msg
defaultView { xValue, yValues } isLeftSide =
    let
        classes =
            [ ( "elm-plot__tooltip__default-view", True )
            , ( "elm-plot__tooltip__default-view--left", isLeftSide )
            , ( "elm-plot__tooltip__default-view--right", not isLeftSide )
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
