module View.Organisms.Table exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, id, colspan)
import Types exposing (Lap, TimeFormat(..))


{-| Rendert die Rundentabelle. Die Struktur ist immer da, damit das CSS greift.
-}
view : List Lap -> TimeFormat -> Html msg
view laps format =
    div [ class "row", id "row-laps" ]
        [ div [ class "col-md-12 text-light" ]
            [ div [ class "panel panel-default", id "pnl-laps" ]
                [ div [ class "colored panel-body text-center text-ellipsis" ]
                    [ table [ id "tbl-laps", class "center table-laps" ]
                        [ thead []
                            [ tr []
                                [ th [ class "text-center" ] [ text "Round" ]
                                , th [ class "text-center" ] [ text "Time" ]
                                , th [ class "text-center" ] [ text "Total time-lapse" ]
                                ]
                            ]
                        , tbody [] 
                            (if List.isEmpty laps then
                                [ tr [] [ td [ colspan 3, class "text-muted", id "no-laps-hint" ] [ text "No time-laps recorded" ] ] ]
                             else
                                List.map (viewLapRow format) laps
                            )
                        ]
                    ]
                ]
            ]
        ]


viewLapRow : TimeFormat -> Lap -> Html msg
viewLapRow format lap =
    tr [ class "digit" ]
        [ td [] [ text (String.fromInt lap.id) ]
        , td [] [ text (formatTime lap.lapTime format) ]
        , td [] [ text (formatTime lap.totalTime format) ]
        ]


-- --- HELPERS ---

formatTime : Float -> TimeFormat -> String
formatTime ms format =
    let
        totalSeconds = floor (ms / 1000)
        minutes = remainderBy 60 (totalSeconds // 60)
        seconds = remainderBy 60 totalSeconds
        hours = totalSeconds // 3600
        msec = floor (ms - (toFloat (floor ms // 1000) * 1000))
        pad n = if n < 10 then "0" ++ String.fromInt n else String.fromInt n

        baseStr =
            if hours > 0 then
                pad hours ++ ":" ++ pad minutes ++ ":" ++ pad seconds
            else
                pad minutes ++ ":" ++ pad seconds
    in
    case format of
        FormatThreeDecimals -> baseStr ++ "." ++ (String.fromInt msec |> String.padLeft 3 '0')
        FormatTwoDecimals -> baseStr ++ "." ++ (String.fromInt (msec // 10) |> String.padLeft 2 '0')
        FormatOneDecimal -> baseStr ++ "." ++ String.fromInt (msec // 100)
        FormatNoDecimals -> baseStr