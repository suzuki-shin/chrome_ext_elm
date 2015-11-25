module ChromeHtbComment where

import ChromeAPI
import Debug exposing (log)
import Graphics.Element exposing (Element, show)
import Html exposing (text, ul, li, Html, br)
import Html.Attributes exposing (style)
import Http
import Json.Decode as JD
import Json.Decode exposing ((:=))
import Maybe exposing (withDefault)
import Result
import Task exposing (..)
import Text

-- Errorの型をStringにしたHttp.get
httpGet : JD.Decoder value -> String -> Task String value
httpGet dec s =
  let
    f : Http.Error -> String
    f httpErr = case httpErr of
                 Http.Timeout -> "Timeout"
                 Http.NetworkError -> "NetworkError"
                 Http.UnexpectedPayload s -> "UnexpectedPayload " ++ s
                 Http.BadResponse n s -> "BadResponse " ++ s
  in
    mapError f (Http.get dec s)


port tabInfo : Task String ()
port tabInfo =
  ChromeAPI.tabsQuery { active = True, currentWindow = True }
  `andThen`
  \tab -> httpGet decoderHtbInfo (htbUrl (decodeTab tab).url)
  `andThen`
  \htb -> Signal.send htbGetMailBox.address htb.bookmarks


main : Signal Html
main =
  Signal.map showBookmarkComments getBookmarks


showBookmarkComments : List Bookmark -> Html
showBookmarkComments bs =
     List.filter (\t -> .comment t /= "") bs
  |> List.map ((\b -> "「" ++ .comment b ++ "」@" ++ .user b) >> text >> \a -> li [] [a])
  |> ul [style [("list-style-type" , "none"), ("width", "1000px")]]


htbUrl : String -> String
htbUrl entryUrl =
  "http://b.hatena.ne.jp/entry/jsonlite/" ++ entryUrl


getBookmarks : Signal (List Bookmark)
getBookmarks =
  htbGetMailBox.signal


decodeTab : String -> ChromeAPI.Tab
decodeTab =
  JD.decodeString ChromeAPI.decoderListTab
    >> Result.withDefault [dummyTab]
    >> List.head
    >> withDefault dummyTab


htbGetMailBox : Signal.Mailbox (List Bookmark)
htbGetMailBox =
  Signal.mailbox []


dummyTab : ChromeAPI.Tab
dummyTab =
  { active = False
  , id = 0
  , windowId = 0
  , height = 0
  , width = 0
  , title = "dummy"
  , url = "http://example.com/"
  , faviconUrl = "http://example.com/favicon"
  }


type alias Bookmark =
  { timestamp : String
  , comment : String
  , user : String
  , tags : List String
  }


type alias HtbInfo =
  { count : Int
  , bookmarks : List Bookmark
  , url : String
  , eid : Int
  , title : String
  , screenshot : String
  , entry_url : String
  }


decoderBookmark : JD.Decoder Bookmark
decoderBookmark =
  JD.object4 Bookmark
    ("timestamp" := JD.string)
    ("comment" := JD.string)
    ("user" := JD.string)
    ("tags" := JD.list JD.string)


decoderHtbInfo : JD.Decoder HtbInfo
decoderHtbInfo =
  JD.object7 HtbInfo
    ("count" := JD.int)
    ("bookmarks" := JD.list decoderBookmark)
    ("url" := JD.string)
    ("eid" := JD.int)
    ("title" := JD.string)
    ("screenshot" := JD.string)
    ("entry_url" := JD.string)
