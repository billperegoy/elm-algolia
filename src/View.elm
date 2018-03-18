module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ searchInputView
        , routesResultsView model.searchResults
        , stopsResultsView model.searchResults
        , drupalResultsView model.searchResults
        , searchErrors model
        ]


searchInputView : Html Msg
searchInputView =
    input [ onInput UpdateSearchInput ] []


searchErrors : Model -> Html Msg
searchErrors model =
    p [] [ text model.errorText ]


stopsResultsView : List SearchHit -> Html Msg
stopsResultsView hits =
    div []
        [ h2 [] [ text "Stops" ]
        , div []
            (List.map
                (\hit ->
                    case hit of
                        StopHit h ->
                            div []
                                [ a [ href ("https://www.mbta.com/stops/" ++ h.stop.id) ]
                                    [ text h.stop.name ]
                                ]

                        _ ->
                            div [] []
                )
                hits
            )
        ]


routesResultsView : List SearchHit -> Html Msg
routesResultsView hits =
    div []
        [ h2 [] [ text "Routes" ]
        , div []
            (List.map
                (\hit ->
                    case hit of
                        RouteHit h ->
                            div []
                                [ a [ href ("https://www.mbta.com/schedules/" ++ h.route.id ++ "/line") ]
                                    [ text h.route.name ]
                                ]

                        _ ->
                            div [] []
                )
                hits
            )
        ]


drupalResultsView : List SearchHit -> Html Msg
drupalResultsView hits =
    div []
        [ h2 [] [ text "Content" ]
        , div []
            (List.map
                (\hit ->
                    case hit of
                        DrupalHit h ->
                            div []
                                [ a [ href ("#") ]
                                    [ text h.contentTitle ]
                                ]

                        _ ->
                            div [] []
                )
                hits
            )
        ]
