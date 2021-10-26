module Ui.Code exposing (view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Html.Lazy as HL
import Element as E
import Element.Font as F
import Element.Border as B
import Element.Input as I
import Element.Background as BG

import SyntaxHighlight as SH


view : String -> E.Element msg
view code =
  HL.lazy viewCode code
    |> E.html
    |> E.el
        [ E.width E.fill
        , E.height E.fill
        , E.htmlAttribute (HA.style "white-space" "pre")
        , E.htmlAttribute (HA.style "padding" "0 20px")
        , E.htmlAttribute (HA.style "line-height" "1.3")
        , E.scrollbarX
        , F.size 14
        , F.family [ F.typeface "Source Code Pro", F.monospace ]
        , E.alignTop
        , BG.color (E.rgb255 250 250 250)
        ]


viewCode : String -> H.Html msg
viewCode code =
    H.div []
        [ SH.useTheme SH.gitHub
        , code
            |> fixIndent
            |> SH.elm
            |> Result.map (SH.toBlockHtml (Just 1))
            |> Result.withDefault (H.pre [] [ H.code [] [ H.text code ]])
        ]


fixIndent : String -> String
fixIndent code =
  code
    |> String.lines
    |> List.drop 1
    |> List.map (\x ->
        let trimmed = String.trimLeft x
            indent = String.length x - String.length trimmed
        in
        ( if String.length trimmed == 0 then Nothing else Just indent, x ))
    |> (\xs ->
        let smallest = Maybe.withDefault 0 <| List.minimum (List.filterMap Tuple.first xs) in
        List.map (\( _, x ) -> String.dropLeft smallest x) xs
          |> String.join "\n"
      )

