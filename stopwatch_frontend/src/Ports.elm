port module Ports exposing
    ( saveConfig
    , saveLaps
    , setPageTitle
    , triggerFullscreen
    , exitFullscreen
    , pushUrl
    , configReceiver
    )

import Json.Encode as Encode
import Json.Decode as Decode

-- --- AUSGEHEND (Elm -> JavaScript) ---

{-| Speichert die Konfiguration (Nachtmodus, Zeitformat, Schriftgröße) 
im localStorage (entspricht configC.save im Original).
-}
port saveConfig : Encode.Value -> Cmd msg

{-| Speichert die aktuelle Rundenliste im localStorage, 
damit sie beim Neuladen erhalten bleibt.
-}
port saveLaps : Encode.Value -> Cmd msg

{-| Aktualisiert den Browser-Tab Titel dynamisch (z.B. "00:12 - Stoppuhr").
Wichtig für die Sichtbarkeit im Hintergrund.
-}
port setPageTitle : String -> Cmd msg

{-| Aktiviert den Vollbildmodus für den Main-Container via Web API.
-}
port triggerFullscreen : () -> Cmd msg

{-| Beendet den Vollbildmodus.
-}
port exitFullscreen : () -> Cmd msg

{-| Ändert die URL-Hash oder History, falls wir Deeplinks 
für bestimmte Stoppuhr-Zustände unterstützen wollen.
-}
port pushUrl : String -> Cmd msg


-- --- EINGEHEND (JavaScript -> Elm) ---

{-| Empfängt beim App-Start die gespeicherten Daten aus dem localStorage.
-}
port configReceiver : (Decode.Value -> msg) -> Sub msg