module Decoders exposing (..)

import Json.Decode as Decode exposing (Decoder, field, float, int, list, string, bool)
import Json.Encode as Encode
import Types exposing (..)

-- --- DECODER (JSON -> ELM) ---

{-| Decodiert eine einzelne Runde.
-}
decodeLap : Decoder Lap
decodeLap =
    Decode.map3 Lap
        (field "id" int)
        (field "lapTime" float)
        (field "totalTime" float)

{-| Decodiert die Konfiguration, falls diese aus dem LocalStorage kommt.
-}
decodeConfig : Decoder { nightMode : Bool, timeFormat : TimeFormat, fontSizeId : Int }
decodeConfig =
    Decode.map3 (\n f s -> { nightMode = n, timeFormat = f, fontSizeId = s })
        (field "nightMode" bool)
        (field "timeFormat" decodeTimeFormat)
        (field "fontSizeId" int)

decodeTimeFormat : Decoder TimeFormat
decodeTimeFormat =
    string |> Decode.andThen (\val ->
        case val of
            "FormatThreeDecimals" -> Decode.succeed FormatThreeDecimals
            "FormatTwoDecimals" -> Decode.succeed FormatTwoDecimals
            "FormatOneDecimal" -> Decode.succeed FormatOneDecimal
            "FormatNoDecimals" -> Decode.succeed FormatNoDecimals
            _ -> Decode.succeed FormatTwoDecimals
    )


-- --- ENCODER (ELM -> JSON) ---

{-| Wandelt eine Runde in JSON um.
-}
encodeLap : Lap -> Encode.Value
encodeLap lap =
    Encode.object
        [ ( "id", Encode.int lap.id )
        , ( "lapTime", Encode.float lap.lapTime )
        , ( "totalTime", Encode.float lap.totalTime )
        ]

{-| Hilfs-Encoder für die gesamte Rundenliste.
-}
encodeLapList : List Lap -> Encode.Value
encodeLapList laps =
    Encode.list encodeLap laps

{-| Wandelt das Zeitformat in einen String für JS um.
-}
encodeTimeFormat : TimeFormat -> Encode.Value
encodeTimeFormat format =
    case format of
        FormatThreeDecimals -> Encode.string "FormatThreeDecimals"
        FormatTwoDecimals -> Encode.string "FormatTwoDecimals"
        FormatOneDecimal -> Encode.string "FormatOneDecimal"
        FormatNoDecimals -> Encode.string "FormatNoDecimals"

{-| Encodiert den gesamten State für das Persistieren via Ports.
-}
encodePersistentState : Model -> Encode.Value
encodePersistentState model =
    Encode.object
        [ ( "nightMode", Encode.bool model.nightMode )
        , ( "timeFormat", encodeTimeFormat model.timeFormat )
        , ( "fontSizeId", Encode.int model.fontSizeId )
        , ( "laps", encodeLapList model.laps )
        , ( "accumulatedTime", Encode.float model.accumulatedTime )
        ]