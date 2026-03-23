module Main exposing (main)

import Browser
import Decoders
import Html exposing (..)
import Json.Decode as Decode
import Ports
import Task
import Time
import Types exposing (..)

-- Layout & Organism Imports
import View.Layouts.MainLayout as MainLayout


-- --- PROGRAM ---


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- --- INIT ---


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { state = Stopped
      , currentTime = 0.0
      , startTime = Nothing
      , accumulatedTime = 0.0
      , laps = []
      , title = ""
      , sidebarOpen = False
      , nightMode = False
      , timeFormat = FormatTwoDecimals
      , fontSizeId = 1
      , clockConfig = 
            { hour = "text"              -- Geändert von pill
            , hourText = "small"          -- Geändert von large
            , hourDisplay = "all"
            , minute = "line"
            , minuteDisplay = "fine"      -- Geändert von fine-2
            , minuteText = "inside"       -- Geändert von outside
            , hand = "hollow"
            }
      }
    , Cmd.none
    )

-- --- UPDATE ---


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Stopwatch Logic
        StartStopwatch ->
            ( model, Time.now |> Task.perform StartAt )

        StartAt time ->
            ( { model | state = Running, startTime = Just time }, Cmd.none )

        PauseStopwatch ->
            let
                -- Die Zeit, die seit dem letzten Start vergangen ist
                currentSessionTime = model.currentTime
                
                -- Die absolute Gesamtzeit (vorherige Intervalle + aktuelles)
                totalTimeAtStop =
                    model.accumulatedTime + currentSessionTime

                -- Wir holen uns die Gesamtzeit der letzten aufgenommenen Runde
                lastLapTotal =
                    model.laps 
                        |> List.head 
                        |> Maybe.map .totalTime 
                        |> Maybe.withDefault 0

                -- Wir erstellen die finale Runde für diesen Stopp
                finalLap =
                    { id = List.length model.laps + 1
                    , lapTime = totalTimeAtStop - lastLapTotal
                    , totalTime = totalTimeAtStop
                    }

                updatedLaps =
                    finalLap :: model.laps
            in
            ( { model 
                | state = Paused
                , accumulatedTime = totalTimeAtStop
                , currentTime = 0
                , startTime = Nothing
                , laps = updatedLaps 
              }
            , Cmd.batch 
                [ Ports.setPageTitle "Paused - Stopwatch"
                , Ports.saveLaps (Decoders.encodeLapList updatedLaps)
                ]
            )

        ResumeStopwatch ->
            ( model, Time.now |> Task.perform StartAt )

        ResetStopwatch ->
            ( { model | state = Stopped, currentTime = 0, accumulatedTime = 0, startTime = Nothing, laps = [] }
            , Cmd.batch 
                [ Ports.saveLaps (Decoders.encodeLapList [])
                , Ports.setPageTitle "Stopwatch" -- Reset to default
                ]
            )

        TakeLap ->
            let
                totalTime =
                    model.accumulatedTime + model.currentTime

                lastLapTotal =
                    model.laps |> List.head |> Maybe.map .totalTime |> Maybe.withDefault 0

                newLap =
                    { id = List.length model.laps + 1
                    , lapTime = totalTime - lastLapTotal
                    , totalTime = totalTime
                    }

                updatedLaps =
                    newLap :: model.laps
            in
            ( { model | laps = updatedLaps }
            , Ports.saveLaps (Decoders.encodeLapList updatedLaps)
            )

        Tick time ->
            case model.startTime of
                Just start ->
                    let
                        diff =
                            toFloat (Time.posixToMillis time - Time.posixToMillis start)
                        
                        totalTime = 
                            model.accumulatedTime + diff
                    in
                    ( { model | currentTime = diff }
                    , Ports.setPageTitle (formatTitleTime totalTime) 
                    )

                Nothing ->
                    ( model, Cmd.none )

        -- UI State
        ToggleSidebar ->
            ( { model | sidebarOpen = not model.sidebarOpen }, Cmd.none )

        ToggleNightMode ->
            let
                newMode =
                    not model.nightMode
            in
            ( { model | nightMode = newMode }
            , Ports.saveConfig (Decoders.encodePersistentState { model | nightMode = newMode })
            )

        SetTimeFormat format ->
            ( { model | timeFormat = format }
            , Ports.saveConfig (Decoders.encodePersistentState { model | timeFormat = format })
            )

        AdjustFontSize delta ->
            ( { model | fontSizeId = clamp 0 3 (model.fontSizeId + delta) }, Cmd.none )

        SetPageTitle title ->
            ( model, Ports.setPageTitle title )

        -- Inbound from Ports (JS -> Elm)
        ReceiveConfig rawValue ->
            case Decode.decodeValue Decoders.decodeConfig rawValue of
                Ok config ->
                    ( { model
                        | nightMode = config.nightMode
                        , timeFormat = config.timeFormat
                        , fontSizeId = config.fontSizeId
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        CycleClockStyle category ->
            let
                config = model.clockConfig

                -- Helper to find the next item in a list (the "rotation" logic)
                cycle current options =
                    let
                        idx = List.indexedMap (\i v -> (i, v)) options
                            |> List.filter (\(_, v) -> v == current)
                            |> List.head
                            |> Maybe.map Tuple.first
                            |> Maybe.withDefault 0
                        nextIdx = remainderBy (List.length options) (idx + 1)
                    in
                    List.drop nextIdx options |> List.head |> Maybe.withDefault current
            in
            case category of
                "hour" -> ({ model | clockConfig = { config | hour = cycle config.hour [ "text", "text-quarters", "pill" ] } }, Cmd.none)
                "hour-text" -> ({ model | clockConfig = { config | hourText = cycle config.hourText [ "large", "small" ] } }, Cmd.none)
                "hour-display" -> ({ model | clockConfig = { config | hourDisplay = cycle config.hourDisplay [ "all", "quarters", "none" ] } }, Cmd.none)
                "minute" -> ({ model | clockConfig = { config | minute = cycle config.minute [ "line", "dot" ] } }, Cmd.none)
                "minute-display" -> ({ model | clockConfig = { config | minuteDisplay = cycle config.minuteDisplay [ "fine", "fine-2", "coarse", "major", "none" ] } }, Cmd.none)
                "minute-text" -> ({ model | clockConfig = { config | minuteText = cycle config.minuteText [ "inside", "outside", "none" ] } }, Cmd.none)
                "hand" -> ({ model | clockConfig = { config | hand = cycle config.hand [ "normal", "hollow" ] } }, Cmd.none)
                _ -> ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


-- --- SUBSCRIPTIONS ---


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        baseSubs =
            [ Ports.configReceiver ReceiveConfig ]

        activeSubs =
            if model.state == Running then
                [ Time.every 33 Tick ]

            else
                []
    in
    Sub.batch (baseSubs ++ activeSubs)


-- --- VIEW ---


view : Model -> Html Msg
view model =
    MainLayout.view model



-- Add this to the bottom of Main.elm or near your other helpers
formatTitleTime : Float -> String
formatTitleTime ms =
    let
        totalSeconds = floor (ms / 1000)
        minutes = remainderBy 60 (totalSeconds // 60)
        seconds = remainderBy 60 totalSeconds
        msec = floor (ms - (toFloat (floor ms // 1000) * 1000))
        
        pad n = String.padLeft 2 '0' (String.fromInt n)
    in
    pad minutes ++ ":" ++ pad seconds ++ "." ++ String.padLeft 2 '0' (String.fromInt (msec // 10))