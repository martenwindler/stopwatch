module View.Organisms.StopWatchPanel exposing (view)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class, id)
import Types exposing (..)
import View.Atoms.Buttons as Buttons
import View.Molecules.StopWatchDisplay as Display


view : Model -> Html Msg
view model =
    let
        totalTime = model.accumulatedTime + model.currentTime
    in
    div [ class "panel panel-default", id "pnl-main" ]
        [ div [ class "panel-body relative-container" ]
            [ div [ class "text-center stopwatch-display-container", id "pnl-time" ]
                [ Display.view totalTime model.timeFormat ]

            , h1 [ id "lbl-title", class "colored main-title" ] [ text model.title ]

            , div [ id "pnl-set-timer", class "text-center" ]
                (viewControls model)
            ]
        ]


viewControls : Model -> List (Html Msg)
viewControls model =
    case model.state of
        Stopped ->
            [ -- Runde Button anzeigen, aber deaktivieren
              Buttons.actionDisabled "Runde" "btn-primary" True NoOp
            , Buttons.action "Start" "btn-alt3" StartStopwatch 
            ]

        Running ->
            [ Buttons.action "Runde" "btn-primary" TakeLap
            , Buttons.action "Stopp" "btn-danger" PauseStopwatch
            ]

        Paused ->
            [ Buttons.actionDisabled "Reset" "btn-alt2" (model.accumulatedTime == 0) ResetStopwatch
            , Buttons.action "Start" "btn-alt3" ResumeStopwatch
            ]