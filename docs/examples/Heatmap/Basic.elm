module Examples.Heatmap.Basic exposing (..)

{-| @LARGE -}
import Html as H
import Svg as S
import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Chart.Svg as CS
import Time exposing (Month(..))


view : Model -> H.Html Msg
view model =
{-| @SMALL -}
  C.chart
    [ CA.height 300
    , CA.width 300
    , CA.domain [ CA.highest 1 CA.more ]
    ]
    [ C.xTicks []
    , C.xLabels []
    , C.yTicks []
    , C.yLabels []
    , C.heatmap toMonthNumber toCountryNum .temperature [] data
    ]
{-| @SMALL END -}


type alias Datum =
  { country : Country
  , month : Month
  , temperature : Float
  }


type Country
  = Denmark
  | Sweden
  | Norway


toCountryNum : Datum -> Float
toCountryNum {country} =
  case country of 
    Denmark -> 0
    Norway -> 1
    Sweden -> 2


toMonthNumber : Datum -> Float
toMonthNumber {month} =
  case month of
    Jan -> 1
    Feb -> 2
    Mar -> 3
    Apr -> 4
    May -> 5
    Jun -> 6
    Jul -> 7
    Aug -> 8
    Sep -> 9
    Oct -> 10
    Nov -> 11
    Dec -> 12


data : List Datum
data =
  [ Datum Denmark Jan -1
  , Datum Denmark Feb 6
  , Datum Denmark Mar 10 
  , Datum Denmark Apr 14
  , Datum Denmark May 18
  , Datum Denmark Jun 20
  , Datum Denmark Jul 21
  , Datum Denmark Aug 21
  , Datum Denmark Sep 17
  , Datum Denmark Oct 9
  , Datum Denmark Nov 4
  , Datum Denmark Dec 0
  , Datum Sweden Jan -8
  , Datum Sweden Feb -2
  , Datum Sweden Mar 6
  , Datum Sweden Apr 10
  , Datum Sweden May 12
  , Datum Sweden Jun 18
  , Datum Sweden Jul 20
  , Datum Sweden Aug 19
  , Datum Sweden Sep 15
  , Datum Sweden Oct 4
  , Datum Sweden Nov 2
  , Datum Sweden Dec -5
  , Datum Norway Jan -10
  , Datum Norway Feb -5
  , Datum Norway Mar -2 
  , Datum Norway Apr 2
  , Datum Norway May 5
  , Datum Norway Jun 12
  , Datum Norway Jul 15
  , Datum Norway Aug 12
  , Datum Norway Sep 3
  , Datum Norway Oct -7
  , Datum Norway Nov -9
  , Datum Norway Dec -12
  ]
{-| @LARGE END -}


type alias Model =
  ()


init : Model
init =
  ()


type Msg
  = Msg


update : Msg -> Model -> Model
update msg model =
  model


meta =
  { category = "Heat maps"
  , categoryOrder = 4
  , name = "Custom chart elements"
  , description = "Add custom tracked elements"
  , order = 100
  }



--[ colors [ "#99D492", "#74C67A", "#1D9A6C", "#188977", "#137177", "#0E4D64"]
--, smoothScale
--, name "Temperature"
--, borderWidth 1
--, borderColor "white"
--, width
--, height
--]