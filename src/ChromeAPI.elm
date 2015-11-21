module ChromeAPI (
               chromeTabsQuery
             , Tab
             , print
             , decoderListTab
             ) where

{-| This module is bindings for ChromeAPI.js

# Tab Type
@docs Tab

# Tab api
@docs chromeTabsQuery, print, decoderListTab

-}

import Native.ChromeAPI exposing (..)
import Json.Encode as JE exposing (..)
import Json.Decode exposing ((:=), Decoder)
import Json.Decode as JD exposing (..)
import List as L exposing (..)
import Task exposing (Task)
import Debug

-- type ChromeAPI = ChromeAPI

{-| tabs Type

    QueryInfo
-}
type alias QueryInfo = { active : Bool, currentWindow : Bool }


{-| tabs Type

    Tab
-}
type alias Tab =
  { active: Bool
--   , audible: Bool
  , id: Int
  , windowId: Int
  , height: Int
  , width: Int
  , title: String
  , url: String
  , faviconUrl: String
--   , highlighted: Bool
--   , incognito: Bool
--   , index: Int
--   , mutedInfo: Object
--   , pinned: Bool
--   , selected: Bool
--   , status: String
  }

{-| tabs API

    chromeTabQuery { active = True, currentWindow = True }, \tabs -> ( (url (head tabs)))
-}
chromeTabsQuery : QueryInfo -> Task String a
chromeTabsQuery queryInfo =
  Native.ChromeAPI.chromeTabsQuery (encodeQueryInfo queryInfo)


encodeQueryInfo : QueryInfo -> String
encodeQueryInfo { active, currentWindow } =
  JE.encode 0 <| JE.object [("active", JE.bool active), ("currentWindow", JE.bool currentWindow)]


-- encodeTab : Tab -> String
-- encodeTab { url } =
--   JE.encode 0 <| JE.object [("url", JE.string url)]


-- decoderTab : Decoder a
decoderTab =
 JD.object8 Tab
     ("active" := JD.bool)
     ("id" := JD.int)
     ("windowId" := JD.int)
     ("height" := JD.int)
     ("width" := JD.int)
     ("title" := JD.string)
     ("url" := JD.string)
     ("favIconUrl" := JD.string) -- なぜかAPIからくる値が 'favIconUrl' になってる。。

-- encodeListTab : List Tab -> String
-- encodeListTab tabs =
--   JE.encode 0 <| JE.list <| (L.map (\t -> JE.object [("url", JE.string t.url)]) tabs)


{-| tabs API

    decoderListTab
-}
decoderListTab : Decoder (List Tab)
decoderListTab = JD.list decoderTab




{-| Take in any Elm value and produce a task. This task will display the value
in your browser's developer console.
-}
-- print : String -> Task x ()
print : a -> Task x ()
print value =
  Native.ChromeAPI.log (toString (Debug.log "value" value))
--   Native.ChromeAPI.log (toString (Debug.log "value" (JD.decodeString decoderListTab value)))
