module View.Molecules.StopWatchDisplay exposing (view)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, id, style)
import Types exposing (TimeFormat(..))


view : Float -> TimeFormat -> Html msg
view ms format =
    let
        totalSeconds =
            floor (ms / 1000)

        minutes =
            remainderBy 60 (totalSeconds // 60)

        seconds =
            remainderBy 60 totalSeconds

        hours =
            totalSeconds // 3600

        msec =
            floor (ms - (toFloat (floor ms // 1000) * 1000))

        timeStr =
            if hours > 0 then
                pad hours ++ ":" ++ pad minutes ++ ":" ++ pad seconds

            else
                pad minutes ++ ":" ++ pad seconds

        msecStr =
            formatMsec msec format
    in
    div [ id "pnl-time", class "text-center stopwatch-display-container" ]
        [ span [ id "lbl-time", class "colored digit text-nowrap font-digit main-time" ]
            [ text timeStr ]
        , if format == FormatNoDecimals then
            text ""

          else
            span [ id "lbl-msec", class "colored digit text-nowrap font-digit msec-time" ]
                [ text ("." ++ msecStr) ]
        ]


-- HELPERS


pad : Int -> String
pad n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n


formatMsec : Int -> TimeFormat -> String
formatMsec msec format =
    case format of
        FormatThreeDecimals ->
            String.fromInt msec |> String.padLeft 3 '0'

        FormatTwoDecimals ->
            String.fromInt (msec // 10) |> String.padLeft 2 '0'

        FormatOneDecimal ->
            String.fromInt (msec // 100)

        FormatNoDecimals ->
            ""