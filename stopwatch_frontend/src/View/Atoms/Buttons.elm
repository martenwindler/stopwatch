module View.Atoms.Buttons exposing (action, actionDisabled)

import Html exposing (Html, button, text)
import Html.Attributes exposing (class, disabled, type_)
import Html.Events exposing (onClick)
import Types exposing (Msg)


{-| Standard Action-Button mit dynamischer Farbe -}
action : String -> String -> Msg -> Html Msg
action label extraClass msg =
    button
        [ type_ "button"
        , class ("btn btn-space btn-classic " ++ extraClass)
        , onClick msg
        ]
        [ text label ]


{-| Button mit integrierter Logik für den Deaktivierungs-Status.
Nützlich für den Reset-Button, wenn die Zeit noch auf 0 ist.
-}
actionDisabled : String -> String -> Bool -> Msg -> Html Msg
actionDisabled label extraClass isDisabled msg =
    button
        [ type_ "button"
        , class ("btn btn-space btn-classic " ++ extraClass)
        , disabled isDisabled
        , if isDisabled then
            class "disabled"
          else
            onClick msg
        ]
        [ text label ]