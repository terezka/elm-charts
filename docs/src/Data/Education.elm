module Data.Education exposing (Datum, Year, basic, data)

import Csv.Decode as Cvs
import Dict


type alias Datum =
  { year : Float
  , women : List Group
  , men : List Group
  }


type alias Group =
  { name : String
  , amount : Float
  }


type alias Year =
  { year : Float
  , women : Education
  , men : Education
  }


type alias Education =
  { short : Float
  , medium : Float
  , long : Float
  , bachelor : Float
  , researcher : Float
  }


data : List Year
data =
  let short = "Fuldfort kort videregaende uddannelse"
      medium = "Fuldfort mellemlange videregaende uddannelser"
      long = "Fuldfort lange videregaende uddannelser"
      bachelor = "Fuldfort bachelor"
      researcher = "Fuldfort forskeruddannelser"
      researcher2 = "Fuldført forskeruddannelser"
      ongoing = "Igangvarende korte videregaende uddannelser"

      findAmongst ns genderData =
        genderData
          |> List.filter (\g -> List.member g.name ns)
          |> List.head
          |> Maybe.map .amount
          |> Maybe.withDefault 0
  in
  List.filterMap (\d ->
      case
        [ findAmongst [short] d.women
        , findAmongst [medium] d.women
        , findAmongst [long] d.women
        , findAmongst [bachelor] d.women
        , findAmongst [researcher, researcher2] d.women

        , findAmongst [short] d.men
        , findAmongst [medium] d.men
        , findAmongst [long] d.men
        , findAmongst [bachelor] d.men
        , findAmongst [researcher, researcher2] d.men
        ]
      of
        [ shortWoman, mediumWoman, longWoman, bachelorWoman, researcherWoman, shortMen, mediumMen, longMen, bachelorMen, researcherMen ] ->
          Just
            { year = d.year
            , women = Education shortWoman mediumWoman longWoman bachelorWoman researcherWoman
            , men = Education shortMen mediumMen longMen bachelorMen researcherMen
            }

        e ->
          Nothing
    ) basic



-- DATA


basic : List Datum
basic =
  Cvs.decodeCustom { fieldSeparator = ';' } Cvs.FieldNamesFromFirstRow decoder csv
    |> Result.map process
    |> Result.withDefault []


process : List Raw -> List Datum
process =
  let fold raw acc =
        acc
          |> Dict.update 2005 (updateYear raw raw.y2005)
          |> Dict.update 2006 (updateYear raw raw.y2006)
          |> Dict.update 2007 (updateYear raw raw.y2007)
          |> Dict.update 2008 (updateYear raw raw.y2008)
          |> Dict.update 2009 (updateYear raw raw.y2009)
          |> Dict.update 2010 (updateYear raw raw.y2010)
          |> Dict.update 2011 (updateYear raw raw.y2011)
          |> Dict.update 2012 (updateYear raw raw.y2012)
          |> Dict.update 2013 (updateYear raw raw.y2013)
          |> Dict.update 2014 (updateYear raw raw.y2014)
          |> Dict.update 2015 (updateYear raw raw.y2015)
          |> Dict.update 2016 (updateYear raw raw.y2016)
          |> Dict.update 2017 (updateYear raw raw.y2017)
          |> Dict.update 2018 (updateYear raw raw.y2018)
          |> Dict.update 2019 (updateYear raw raw.y2019)

      updateYear raw num prev =
        case prev of
          Just datum -> updateGender datum raw num
          Nothing -> updateGender { men = [], women = [] } raw num

      updateGender datum raw num =
        case raw.gender of
          "Kvinder" -> Just { datum | women = Group raw.group num :: datum.women }
          "Mand" -> Just { datum | men = Group raw.group num :: datum.men }
          _ -> Nothing
  in
  List.foldl fold Dict.empty >> Dict.toList >> List.map (\(year, datum) ->
    { year = year
    , women = datum.women
    , men = datum.men
    }
  )


type alias Raw =
  { name : String
  , gender : String
  , group : String
  , y2005 : Float
  , y2006 : Float
  , y2007 : Float
  , y2008 : Float
  , y2009 : Float
  , y2010 : Float
  , y2011 : Float
  , y2012 : Float
  , y2013 : Float
  , y2014 : Float
  , y2015 : Float
  , y2016 : Float
  , y2017 : Float
  , y2018 : Float
  , y2019 : Float
  }


decoder : Cvs.Decoder Raw
decoder =
  Cvs.into Raw
    |> Cvs.pipeline (Cvs.field "NAME" Cvs.string)
    |> Cvs.pipeline (Cvs.field "GENDER" Cvs.string)
    |> Cvs.pipeline (Cvs.field "GROUP" Cvs.string)
    |> Cvs.pipeline (Cvs.field "2005" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2006" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2007" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2008" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2009" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2010" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2011" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2012" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2013" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2014" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2015" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2016" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2017" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2018" Cvs.float)
    |> Cvs.pipeline (Cvs.field "2019" Cvs.float)


csv : String
csv =
  "NAME;GENDER;GROUP;2005;2006;2007;2008;2009;2010;2011;2012;2013;2014;2015;2016;2017;2018;2019;I alt;Mand;I ALT;811789;803830;798631;792918;781488;771967;761618;751681;748482;751398;760693;766521;770366;772843;774637\nI alt;Mand;FULDFORT VIDEREGAENDE UDDANNELSE;191338;194395;197446;200221;202674;204402;205575;206872;209984;214574;221123;228572;234990;241256;247919\nI alt;Mand;Fuldfort kort videregaende uddannelse;41226;41390;41420;41415;41199;40940;40386;39714;39072;38474;38112;41866;41748;41610;41888\nI alt;Mand;Fuldfort mellemlange videregaende uddannelser;63893;63755;63940;63893;63925;63844;63585;63430;64328;66154;68347;66809;69011;71518;74027\nI alt;Mand;Fuldfort bachelor;21126;21741;21990;22568;22818;23049;23537;23783;24507;25368;26619;26058;25710;25828;26245\nI alt;Mand;Fuldfort lange videregaende uddannelser;59934;62252;64666;66729;68955;70573;71828;73476;75310;77348;80450;85887;90261;93855;97705\nI alt;Mand;Fuldfort forskeruddannelser;5159;5257;5430;5616;5777;5996;6239;6469;6767;7230;7595;7952;8260;8445;8054\nI alt;Mand;IGANGV∆RENDE VIDEREGAENDE UDDANNELSE;28299;27464;25680;23947;23308;23905;25284;27205;28843;30178;30440;30100;30248;30311;29888\nI alt;Mand;Igangvarende korte videregaende uddannelser;3128;3174;2953;2859;3080;3432;3563;3682;3906;4368;4458;4829;5045;5078;5043\nI alt;Mand;Igangvarende mellemlange videregaende uddannelser;12165;12030;11316;10638;10449;10887;11768;12857;13501;14155;14641;14505;14621;14666;14772\nI alt;Mand;Igangvarende bachelor;7197;7149;7077;6672;6307;6055;6239;6641;7139;7293;7116;6642;6570;6403;6403\nI alt;Mand;Igangvarende lange videregaende uddannelser;5519;4813;3984;3316;2835;2715;2762;2964;3195;3248;3075;2974;2903;3084;2680\nI alt;Mand;Igangvarende forskeruddannelser;290;298;350;462;637;816;952;1061;1102;1114;1150;1150;1109;1080;990\nI alt;Mand;INGEN VIDEREGAENDE UDDANNELSE;592152;581971;575505;568750;555506;543660;530759;517604;509655;506646;509130;507849;505128;501276;496830\nI alt;Mand;Afbrudt videregaende uddannelse;40340;40583;41146;41538;41226;40984;40316;39784;39538;39929;40748;41666;42507;43223;44054\nI alt;Mand;Registreret uden videregaende uddannelse;498031;486212;475360;463710;451060;438097;424851;410655;399375;390310;383198;375948;369267;362239;356860\nI alt;Mand;Uoplyst;53781;55176;58999;63502;63220;64579;65592;67165;70742;76407;85184;90235;93354;95814;95916\nI alt;Kvinder;I ALT;794659;788300;783350;778266;769895;762226;752512;742726;738587;738915;744633;749059;752191;753273;755058\nI alt;Kvinder;FULDFØRT VIDEREGAENDE UDDANNELSE;252301;258584;264566;270251;275873;281598;286260;289908;295403;303201;312460;322413;331023;338674;347337\nI alt;Kvinder;Fuldfort kort videregaende uddannelse;29131;29247;29419;29493;29498;29827;29983;29997;29925;29872;30042;30949;31248;31589;32121\nI alt;Kvinder;Fuldfort mellemlange videregaende uddannelser;140201;141869;142970;143742;144471;145159;145203;144611;145202;147883;150147;151541;153167;154638;156612\nI alt;Kvinder;Fuldfort bachelor;25072;25782;26104;26789;27419;28480;29343;29775;30501;30851;31932;30922;30400;30272;30540\nI alt;Kvinder;Fuldfort lange videregaende uddannelser;54977;58560;62789;66756;70865;74229;77538;81016;84934;89282;94466;102667;109526;115186;121322\nI alt;Kvinder;Fuldført forskeruddannelser;2920;3126;3284;3471;3620;3903;4193;4509;4841;5313;5873;6334;6682;6989;6742\nI alt;Kvinder;IGANGV∆RENDE VIDEREGAENDE UDDANNELSE;36318;35286;33417;30956;29302;28448;28664;29874;30854;31647;32041;31874;33133;34611;35149\nI alt;Kvinder;Igangvarende korte videregaende uddannelser;2571;2578;2327;2123;2290;2459;2620;2761;2891;3130;3300;3353;3455;3530;3474\nI alt;Kvinder;Igangvarende mellemlange videregaende uddannelser;21690;21103;20057;18542;17275;16636;16935;17590;18143;18586;18856;19260;20328;21314;22135\nI alt;Kvinder;Igangvarende bachelor;6753;6738;6632;6394;6117;5801;5647;5794;5900;5944;5877;5493;5585;5817;5923\nI alt;Kvinder;Igangvarende lange videregaende uddannelser;5078;4628;4123;3547;3135;2921;2753;2954;3115;3170;3167;2927;2862;3024;2734\nI alt;Kvinder;Igangværende forskeruddannelser;226;239;278;350;485;631;709;775;805;817;841;841;903;926;883\nI alt;Kvinder;INGEN VIDEREGÅENDE UDDANNELSE;506040;494430;485367;477059;464720;452180;437588;422944;412330;404067;400132;394772;388035;379988;372572\nI alt;Kvinder;Afbrudt videregaende uddannelse;35065;35484;36243;36973;36904;36644;36003;35383;35152;35139;35539;35896;36342;36559;37241\nI alt;Kvinder;Registreret uden videregående uddannelse;413743;400901;388608;376151;362518;348841;334533;319468;306942;296785;287509;277792;267934;258029;249616\nI alt;Kvinder;Uoplyst;57232;58045;60516;63935;65298;66695;67052;68093;70236;72143;77084;81084;83759;85400;85715\n"


