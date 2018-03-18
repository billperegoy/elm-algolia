module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import Facets


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ headerView model
        , bodyView model
        ]


headerView : Model -> Html Msg
headerView model =
    div [ class "row" ]
        [ searchInputView
        ]


bodyView : Model -> Html Msg
bodyView model =
    div [ class "row" ]
        [ facetView model
        , resultsView model
        ]


checkBoxAny : String -> String -> List Facets.FacetType -> List Facets.FacetType -> Html Msg
checkBoxAny checkboxId labelText facets newFacets =
    div []
        [ label
            [ class ""
            , for checkboxId
            ]
            [ text labelText ]
        , input
            [ type_ "checkbox"
            , onCheck (UpdateFacet newFacets)
            , checked (containsAnyOf newFacets facets)
            , class ""
            , id checkboxId
            ]
            []
        ]


checkBoxAll : String -> String -> List Facets.FacetType -> List Facets.FacetType -> Html Msg
checkBoxAll checkboxId labelText facets newFacets =
    div []
        [ label
            [ class ""
            , for checkboxId
            ]
            [ text labelText ]
        , input
            [ type_ "checkbox"
            , onCheck (UpdateFacet newFacets)
            , checked (containsAllOf newFacets facets)
            , class ""
            , id checkboxId
            ]
            []
        ]


containsAnyOf : List a -> List a -> Bool
containsAnyOf matchers elements =
    List.foldl
        (\elem accum -> (List.member elem elements) || accum)
        False
        matchers


containsAllOf : List a -> List a -> Bool
containsAllOf matchers elements =
    List.foldl
        (\elem accum -> (List.member elem elements) && accum)
        True
        matchers


facetView : Model -> Html Msg
facetView model =
    div [ class "col-md-4" ]
        [ routesFacetView model
        , stopsStationsFacetView model
        , pagesAndDocumentsFacetView model
        , newsFacetView model
        , eventsFacetView model
        ]


routesFacetView : Model -> Html Msg
routesFacetView model =
    div []
        [ checkBoxAll "lines-and-routes-facet" "LInes and Routes" model.facetFilters Facets.allRouteFacets
        , checkBoxAny "subway-facet" "Subway" model.facetFilters Facets.subwayFacets
        , checkBoxAny "bus-facet" "Bus" model.facetFilters [ Facets.BusFacet ]
        , checkBoxAny "commuter-rail-facet" "Commuter Rail" model.facetFilters [ Facets.CommuterRailFacet ]
        , checkBoxAny "ferry-facet" "Ferry" model.facetFilters [ Facets.FerryFacet ]
        ]


stopsStationsFacetView : Model -> Html Msg
stopsStationsFacetView model =
    div []
        [ checkBoxAll "stations-and-stops-facet" "Stations and Stops" model.facetFilters [ Facets.StopFacet, Facets.StationFacet ]
        , checkBoxAny "stations-facet" "Stations" model.facetFilters [ Facets.StationFacet ]
        , checkBoxAny "stations-facet" "Stops" model.facetFilters [ Facets.StopFacet ]
        ]


pagesAndDocumentsFacetView : Model -> Html Msg
pagesAndDocumentsFacetView model =
    div []
        [ checkBoxAll "pages-and-documents-facet" "Pages and Documents" model.facetFilters Facets.pagesAndDocumentsFacets
        , checkBoxAny "pages-facet" "Pages" model.facetFilters Facets.pageFacets
        , checkBoxAny "documents-facet" "Documents" model.facetFilters Facets.documentFacets
        ]


newsFacetView : Model -> Html Msg
newsFacetView model =
    div []
        [ checkBoxAny "news-facet" "News" model.facetFilters [ Facets.NewsEntryFacet ] ]


eventsFacetView : Model -> Html Msg
eventsFacetView model =
    div []
        [ checkBoxAny "events-facet" "Events" model.facetFilters [ Facets.EventFacet ] ]


resultsView : Model -> Html Msg
resultsView model =
    div [ class "col-md-8" ]
        [ routesResultsView model.searchResults
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
