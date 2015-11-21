module ChromeHtbComment where

import Html exposing (text)
import ChromeAPI exposing (..)
import Maybe exposing (withDefault)
import Debug exposing (log)
import Task exposing (..)
import Graphics.Element exposing (Element, show)
import Json.Decode as JD
import Json.Decode exposing ((:=))
import Result
import Http


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
  ChromeAPI.chromeTabsQuery { active = True, currentWindow = True }
  `andThen`
  \tab -> httpGet decoderHtbInfo (htbUrl (Debug.log "tab url" (decodeTab tab).url))
  `andThen`
  \a -> Signal.send htbGetMailBox.address (Debug.log "htbinfo" a.bookmarks)


main : Signal Element
main =
  Signal.map show getHtb


htbUrl : String -> String
htbUrl entryUrl =
  "http://b.hatena.ne.jp/entry/jsonlite/" ++ entryUrl


getHtb : Signal (List Bookmark)
getHtb =
  htbGetMailBox.signal


-- getTab : Signal Tab
-- getTab =
--   Signal.map decodeTab tabQueryMailBox.signal

decodeTab : String -> Tab
decodeTab =
  JD.decodeString decoderListTab
    >> Result.withDefault [dummyTab]
    >> List.head
    >> withDefault dummyTab


htbGetMailBox : Signal.Mailbox (List Bookmark)
htbGetMailBox =
  Signal.mailbox []


dummyTab : Tab
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