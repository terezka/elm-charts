module Route exposing (Route(..), top, administration, documentation, section, example, gettingStarted, fromUrl, replaceUrl, toString)

import Browser.Navigation as Navigation
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s, string, int)
import Url.Parser.Query as Query
import Url.Builder as Builder


top : String
top =
  toString <| Top 


administration : String
administration =
  toString <| Administration 


documentation : String
documentation =
  toString <| Documentation 


section : { section : String } -> String
section params =
  toString <| Documentation_String_ params.section


example : { section : String, example : String } -> String
example params =
  toString <| Documentation_String__String_ params.section params.example


gettingStarted : String
gettingStarted =
  toString <| Getting_started 


type Route
    = Top 
    | Administration 
    | Documentation 
    | Documentation_String_ String
    | Documentation_String__String_ String String
    | Getting_started 


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


replaceUrl : Navigation.Key -> Route -> Cmd msg
replaceUrl key route =
    Navigation.replaceUrl key (toString route)


toString : Route -> String
toString route =
    case route of
        Top  ->
            Builder.absolute [] (List.filterMap identity [])

        Administration  ->
            Builder.absolute ["administration"] (List.filterMap identity [])

        Documentation  ->
            Builder.absolute ["documentation"] (List.filterMap identity [])

        Documentation_String_ p1 ->
            Builder.absolute ["documentation", p1] (List.filterMap identity [])

        Documentation_String__String_ p1 p2 ->
            Builder.absolute ["documentation", p1, p2] (List.filterMap identity [])

        Getting_started  ->
            Builder.absolute ["getting-started"] (List.filterMap identity [])


-- INTERNAL


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Top Parser.top
        , Parser.map Administration (s "administration")
        , Parser.map Documentation (s "documentation")
        , Parser.map Documentation_String_ (s "documentation" </> string)
        , Parser.map Documentation_String__String_ (s "documentation" </> string </> string)
        , Parser.map Getting_started (s "getting-started")
        ]