module Internal.Animation exposing (..)

import Svg
import Svg.Attributes


type alias DirectionConfig =
    { id : String
    , height : Float
    , width : Float
    , interval : Int
    }


type alias RadiusConfig =
    { id : String
    , radius : Int
    , interval : Int
    }


leftToRight : DirectionConfig -> Svg.Svg a
leftToRight { id, height, width, interval } =
    Svg.defs []
        [ Svg.clipPath [ Svg.Attributes.id id ]
            [ Svg.rect
                [ Svg.Attributes.height (toString height)
                , Svg.Attributes.width "0"
                ]
                [ Svg.animate
                    [ Svg.Attributes.attributeName "width"
                    , Svg.Attributes.dur (toString interval ++ "ms")
                    , Svg.Attributes.fill "freeze"
                    , Svg.Attributes.values ("0;" ++ toString width)
                    ]
                    []
                ]
            ]
        ]


bottomToTop : DirectionConfig -> Svg.Svg a
bottomToTop { id, height, width, interval } =
    Svg.defs []
        [ Svg.clipPath [ Svg.Attributes.id id ]
            [ Svg.rect
                [ Svg.Attributes.height (toString height)
                , Svg.Attributes.width (toString width)
                , Svg.Attributes.y (toString height)
                ]
                [ Svg.animate
                    [ Svg.Attributes.attributeName "y"
                    , Svg.Attributes.dur (toString interval ++ "ms")
                    , Svg.Attributes.fill "freeze"
                    , Svg.Attributes.values (toString height ++ ";0")
                    ]
                    []
                ]
            ]
        ]


radiusGrowth : RadiusConfig -> Svg.Svg a
radiusGrowth { id, radius, interval } =
    Svg.animate
        [ Svg.Attributes.attributeName "r"
        , Svg.Attributes.dur (toString interval ++ "ms")
        , Svg.Attributes.from "0"
        , Svg.Attributes.to (toString radius)
        ]
        []
