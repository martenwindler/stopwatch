module View.Organisms.Sidebar exposing (view)

import Html exposing (Html, div, ul, li, a, span, i, text)
import Html.Attributes exposing (class, href)
import Types exposing (Model, Msg)


view : Model -> Html Msg
view model =
    div [ class "am-left-sidebar" ]
        [ div [ class "content" ]
            [ ul [ class "sidebar-elements" ]
                [ li [ class "active" ]
                    [ a [ href "#" ]
                        [ i [ class "icon ci-stopwatch" ] []
                        , span [] [ text "Stoppuhr" ]
                        ]
                    ]
                ]
            ]
        ]