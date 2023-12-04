

type Element x =
  Element x
    { limits : Limits
    , position : Plane -> Position
    , render : Plane -> Position -> Svg Never
    }
  

type One data x =
  One
    { presentation : x
    , identification : Identification
    }

limits : One data a -> Limits
render : One data a -> Svg Never
position : Plane -> One data a -> Html Never

identification : One data a -> Identification

toString : One data a -> String

map : (a -> b) -> One data a -> One data b
mapData : (a -> b) -> One a x -> One b x



type Many data x

compileBars : (data -> Float) -> Series data () Bar -> List data -> Many data Dot
compileDots : (data -> Float) -> Series data Interpolation Dot -> List data -> Many data Dot

limits : Many data a -> Limits
render : Many data a -> Svg Never
position : Plane -> Many data a -> Html Never

any : Many data Any -> Many data Any
dots : Many data Any -> Many data Dot
bars : Many data Any -> Many data Dot
real : Many data x -> Many data x
sameX : Many data x -> Many data x
stacks : Many data x -> Many data x
bins : Many data x -> Many data x

map : (a -> b) -> Many data a -> Many data b
mapData : (a -> b) -> Many a x -> Many b x
