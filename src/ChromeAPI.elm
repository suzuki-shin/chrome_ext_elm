module ChromeAPI (
               tabsQuery
             , Tab
             , print
             , decoderListTab
             ) where

{-| This module is bindings for ChromeAPI.js

# Tab Type
@docs Tab

# Tab api
@docs tabsQuery, print, decoderListTab

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
tabsQuery : QueryInfo -> Task String a
tabsQuery queryInfo =
  Native.ChromeAPI.tabsQuery (encodeQueryInfo queryInfo)


encodeQueryInfo : QueryInfo -> String
encodeQueryInfo { active, currentWindow } =
  JE.encode 0 <| JE.object [("active", JE.bool active), ("currentWindow", JE.bool currentWindow)]


decoderTab : Decoder Tab
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


{-| tabs API

    decoderListTab
-}
decoderListTab : Decoder (List Tab)
decoderListTab = JD.list decoderTab


{-| Take in any Elm value and produce a task. This task will display the value
in your browser's developer console.
-}
print : a -> Task x ()
print value =
  Native.ChromeAPI.log (toString (Debug.log "value" value))
