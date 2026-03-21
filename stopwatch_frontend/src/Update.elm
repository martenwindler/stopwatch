module Update exposing (update)

import Decoders
import Json.Decode as Decode
import Ports
import Task
import Time
import Types exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        -- --- STOPWATCH CORE LOGIC ---
        StartStopwatch ->
            -- Wir holen uns die aktuelle Zeit vom System, um einen sauberen Startpunkt zu haben
            ( model, Time.now |> Task.perform StartAt )

        StartAt time ->
            ( { model | state = Running, startTime = Just time }, Cmd.none )

        PauseStopwatch ->
            -- Wir addieren die Zeit des aktuellen Laufs auf das "Konto" der akkumulierten Zeit
            let
                newAccumulated =
                    model.accumulatedTime + model.currentTime
            in
            ( { model
                | state = Paused
                , accumulatedTime = newAccumulated
                , currentTime = 0
                , startTime = Nothing
              }
            , Ports.setPageTitle "Pausiert - Stoppuhr"
            )

        ResumeStopwatch ->
            ( model, Time.now |> Task.perform StartAt )

        ResetStopwatch ->
            let
                newModel =
                    { model
                        | state = Stopped
                        , currentTime = 0
                        , accumulatedTime = 0
                        , startTime = Nothing
                        , laps = []
                    }
            in
            ( newModel, Ports.saveLaps (Decoders.encodeLapList []) )

        TakeLap ->
            let
                total =
                    model.accumulatedTime + model.currentTime

                lastLapTotal =
                    model.laps
                        |> List.head
                        |> Maybe.map .totalTime
                        |> Maybe.withDefault 0

                newLap =
                    { id = List.length model.laps + 1
                    , lapTime = total - lastLapTotal
                    , totalTime = total
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

                        totalStr =
                            formatTimeForTitle (model.accumulatedTime + diff)
                    in
                    ( { model | currentTime = diff }
                    , Ports.setPageTitle (totalStr ++ " - Stoppuhr")
                    )

                Nothing ->
                    ( model, Cmd.none )

        -- --- UI & SETTINGS ---
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

        -- --- INBOUND FROM JS ---
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


-- --- HELPERS ---

{-| Formatiert die Zeit grob für den Browser-Tab (00:00:00) -}
formatTimeForTitle : Float -> String
formatTimeForTitle ms =
    let
        totalSeconds =
            floor (ms / 1000)

        seconds =
            remainderBy 60 totalSeconds

        minutes =
            remainderBy 60 (totalSeconds // 60)

        hours =
            totalSeconds // 3600

        pad n =
            if n < 10 then
                "0" ++ String.fromInt n
            else
                String.fromInt n
    in
    if hours > 0 then
        pad hours ++ ":" ++ pad minutes ++ ":" ++ pad seconds
    else
        pad minutes ++ ":" ++ pad seconds