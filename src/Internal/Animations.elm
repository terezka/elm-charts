module Internal.Animations exposing
  ( AnimationCustomizations
  , bottomToTop
  , leftToRight
  )

{-
# Animation Customizations
@docs AnimationCustomizations

-}

import Svg
import Svg.Attributes as Attributes
import Svg.Events as Events


{-| The animation configurations let you customize:
    - Svg.Attributes for the animate tag
    - onBegin, onEnd, and onRepeat do not have support in all browsers
-}
type alias AnimationCustomizations msg =
    { accumulate : String
    , additive : String
    , begin : String
    , calcMode : String
    , dur : String
    , fill : String
    , keySplines : String
    , keyTimes : String
    , onBegin : Maybe msg
    , onEnd : Maybe msg
    , onRepeat : Maybe msg
    , repeatCount : String
    , repeatDur : String
    , restart : String
    }


{-| Animate plot drawing from left to right
-}
leftToRight : AnimationCustomizations msg -> String -> Svg.Svg msg
leftToRight customizations width =
    Svg.animate
        ([ Attributes.attributeName "width"
         , Attributes.from "0"
         , Attributes.to width
         ]
            ++ animationCustomizationsToAttributes customizations
            ++ animationCustomizationsToEvents customizations
        )
        []


{-| Animate plot drawing from bottom to top
-}
bottomToTop : AnimationCustomizations msg -> String -> Svg.Svg msg
bottomToTop customizations height =
    Svg.animate
        ([ Attributes.attributeName "y"
         , Attributes.from height
         , Attributes.to "0"
         ]
            ++ animationCustomizationsToAttributes customizations
            ++ animationCustomizationsToEvents customizations
        )
        []


animationCustomizationsToAttributes : AnimationCustomizations msg -> List (Svg.Attribute msg)
animationCustomizationsToAttributes customizations =
    [ Attributes.accumulate customizations.accumulate
    , Attributes.additive customizations.additive
    , Attributes.begin customizations.begin
    , Attributes.calcMode customizations.calcMode
    , Attributes.dur customizations.dur
    , Attributes.fill customizations.fill
    , Attributes.keySplines customizations.keySplines
    , Attributes.keyTimes customizations.keyTimes
    , Attributes.repeatCount customizations.repeatCount
    , Attributes.repeatDur customizations.repeatDur
    , Attributes.restart customizations.restart
    ]


animationCustomizationsToEvents : AnimationCustomizations msg -> List (Svg.Attribute msg)
animationCustomizationsToEvents customizations =
    []
        ++ case customizations.onBegin of
            Just msg ->
                [ Events.onBegin msg ]

            _ ->
                []

        ++ case customizations.onEnd of
            Just msg ->
                [ Events.onEnd msg ]

            _ ->
                []

        ++ case customizations.onRepeat of
            Just msg ->
                [ Events.onRepeat msg ]

            _ ->
                []
