module Types exposing (..)

import Json.Decode as Decode
import Time

-- --- CLOCK CONFIG ---

{-| Speichert die aktuell gewählten CSS-Stile für die analoge Uhr.
-}
type alias ClockConfig =
    { hour : String
    , hourText : String
    , hourDisplay : String
    , minute : String
    , minuteDisplay : String
    , minuteText : String
    , hand : String
    }

-- --- MODEL ---

type alias Model =
    { state : RunningState
    , currentTime : Float -- Aktuelle Differenz in ms (während es läuft)
    , startTime : Maybe Time.Posix -- Zeitpunkt des letzten Klicks auf "Start"
    , accumulatedTime : Float -- Summe der vergangenen Intervalle (vor Pausen)
    , laps : List Lap
    , title : String
    , sidebarOpen : Bool
    , nightMode : Bool
    , timeFormat : TimeFormat
    , fontSizeId : Int
    , clockConfig : ClockConfig -- Hinzugefügt für die Analog-Uhr
    }

type alias Flags =
    { backendUrl : String -- Bleibt für die Struktur erhalten, falls benötigt
    }

-- --- STOPWATCH TYPES ---

type RunningState
    = Stopped
    | Running
    | Paused

type alias Lap =
    { id : Int
    , lapTime : Float
    , totalTime : Float
    }

{-| Entspricht den Optionen im Original: 00:00.000, 00:00.00, etc. -}
type TimeFormat
    = FormatThreeDecimals
    | FormatTwoDecimals
    | FormatOneDecimal
    | FormatNoDecimals

-- --- MESSAGES ---

type Msg
    = NoOp
    -- Stopwatch Core logic
    | StartStopwatch
    | StartAt Time.Posix     -- Wird vom Task Time.now aufgerufen
    | PauseStopwatch
    | ResumeStopwatch
    | ResetStopwatch
    | TakeLap
    | Tick Time.Posix        -- Subscription-Event alle ~33ms
    -- UI State
    | ToggleSidebar
    | ToggleNightMode
    | SetTimeFormat TimeFormat
    | AdjustFontSize Int     -- Delta: +1 oder -1
    | SetPageTitle String    -- Falls wir den Port manuell triggern
    -- Inbound Ports
    | ReceiveConfig Decode.Value
    -- Analog Clock Style Logic
    | CycleClockStyle String -- Wechselt durch die Stile im Chooser