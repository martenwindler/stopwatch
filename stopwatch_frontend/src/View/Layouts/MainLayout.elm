module View.Layouts.MainLayout exposing (view)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Types exposing (Model, Msg)
import View.Organisms.Navbar as Navbar
import View.Organisms.Sidebar as Sidebar
import View.Organisms.StopWatchPanel as StopWatchPanel
import View.Organisms.Table as Table


view : Model -> Html Msg
view model =
    div [ class "am-wrapper am-fixed-sidebar" ]
        [ Navbar.view model
        , Sidebar.view model
        , div [ class "am-content" ]
            [ div [ class "main-content" ]
                [ StopWatchPanel.view model
                , Table.view model.laps model.timeFormat
                ]
            ]
        ]