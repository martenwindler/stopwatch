module View.Organisms.Clock exposing (view)

import Html exposing (Html, div, text, b)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
import Types exposing (Model, Msg(..))

view : Model -> Html Msg
view model =
    let
        cfg = model.clockConfig
        totalMs = model.accumulatedTime + model.currentTime
        
        -- Zeit-Berechnungen für die Zeiger
        seconds = totalMs / 1000
        minutes = seconds / 60
        hours = minutes / 12

        rotate deg = "rotate(" ++ String.fromFloat (deg * 6) ++ "deg)"

        -- Hier werden die Klassen dynamisch basierend auf model.clockConfig gesetzt
        clockClasses =
            String.join " "
                [ "clock"
                , "hour-style-" ++ cfg.hour
                , "hour-text-style-" ++ cfg.hourText
                , "hour-display-style-" ++ cfg.hourDisplay
                , "minute-style-" ++ cfg.minute
                , "minute-display-style-" ++ cfg.minuteDisplay
                , "minute-text-style-" ++ cfg.minuteText
                , "hand-style-" ++ cfg.hand
                ]
    in
    div [ class "clock-container" ]
        [ -- Der befüllte Chooser
          div [ id "chooser" ] 
            [ viewChooserItem "hour" cfg.hour
            , viewChooserItem "hour-text" cfg.hourText
            , viewChooserItem "hour-display" cfg.hourDisplay
            , viewChooserItem "minute" cfg.minute
            , viewChooserItem "minute-display" cfg.minuteDisplay
            , viewChooserItem "minute-text" cfg.minuteText
            , viewChooserItem "hand" cfg.hand
            ]
        , div [ class "fill" ]
            [ div 
                [ id "utility-clock"
                , class clockClasses
                ]
                [ div [ class "centre" ]
                    [ -- Die dynamischen Markierungen
                      div [ class "dynamic" ] 
                        (List.concat 
                            [ List.map viewMinute (List.range 1 240 |> List.map (\n -> toFloat n / 4))
                            , List.map viewHour (List.range 1 12)
                            ]
                        )
                    , div [ class "expand round circle-1" ] []
                    
                    -- Zeiger
                    , div [ class "anchor hour", style "transform" (rotate hours) ]
                        [ div [ class "element thin-hand" ] []
                        , div [ class "element fat-hand" ] []
                        ]
                    , div [ class "anchor minute", style "transform" (rotate minutes) ]
                        [ div [ class "element thin-hand" ] []
                        , div [ class "element fat-hand minute-hand" ] []
                        ]
                    , div [ class "anchor second", style "transform" (rotate seconds) ]
                        [ div [ class "element second-hand second-hand-front" ] []
                        , div [ class "element second-hand second-hand-back" ] []
                        ]
                    
                    , div [ class "expand round circle-2" ] []
                    ]
                ]
            ]
        ]

-- Hilfsfunktion für die Chooser-Buttons
viewChooserItem : String -> String -> Html Msg
viewChooserItem label value =
    div 
        [ class "chooser-item"
        , onClick (CycleClockStyle label) 
        ] 
        [ text (label ++ "-style-"), b [] [ text value ] ]

-- Erzeugt die Minutenstriche
viewMinute : Float -> Html msg
viewMinute n =
    let
        isMajor = (remainderBy 5 (floor n)) == 0 && (n == toFloat (floor n))
        klass = if isMajor then "major" else "part"
        rot = "rotate(" ++ String.fromFloat (n * 6) ++ "deg)"
        revRot = "rotate(" ++ String.fromFloat (n * -6) ++ "deg)"
    in
    div [ class "anchor", style "transform" rot ]
        [ div [ class ("element minute-line " ++ klass) ] []
        , if isMajor then
            div [ class ("anchor minute-text " ++ klass), style "transform" revRot ]
                [ div [ class "expand content" ] [ text (String.padLeft 2 '0' (String.fromInt (floor n))) ] ]
          else
            text ""
        ]

-- Erzeugt die Stundenmarkierungen
viewHour : Int -> Html msg
viewHour n =
    let
        rot = "rotate(" ++ String.fromInt (n * 30) ++ "deg)"
        revRot = "rotate(" ++ String.fromInt (n * -30) ++ "deg)"
    in
    div [ class "anchor", style "transform" rot ]
        [ div [ class ("element hour-pill hour-item hour-" ++ String.fromInt n) ] []
        , div [ class ("anchor hour-text hour-item hour-" ++ String.fromInt n), style "transform" revRot ]
            [ div [ class "expand content" ] [ text (String.fromInt n) ] ]
        ]