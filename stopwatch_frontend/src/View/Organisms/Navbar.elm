module View.Organisms.Navbar exposing (view)

import Html exposing (Html, a, div, nav, span, text)
import Html.Attributes exposing (class, href, id)
import Types exposing (Model, Msg)


view : Model -> Html Msg
view model =
    nav [ class "navbar navbar-default navbar-fixed-top am-top-header" ]
        [ div [ class "container-fluid" ]
            [ div [ class "navbar-header" ]
                [ div [ class "page-title" ] [ span [] [ text "" ] ]
                , a [ class "navbar-brand", href "/" ] []
                ]
            ]
        ]