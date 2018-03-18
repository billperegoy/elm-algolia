module Facets exposing (..)


type FacetType
    = LightRailFacet
    | HeavyRailFacet
    | CommuterRailFacet
    | BusFacet
    | FerryFacet
    | StopFacet
    | StationFacet
    | BusLineFacet
    | OrangeLineFacet
    | GreenLineFacet
    | RedLineFacet
    | BlueLineFacet
    | CommuterRailLineFacet
    | MattapanTrolleyLineFacet
    | FerryLineFacet
    | PageFacet
    | LandingPageFacet
    | SearchResultFacet
    | PersonFacet
    | ProjectFacet
    | ProjectUpdateFacet
    | NewsEntryFacet
    | EventFacet


subwayFacets : List FacetType
subwayFacets =
    [ LightRailFacet, HeavyRailFacet ]


allRouteFacets : List FacetType
allRouteFacets =
    [ LightRailFacet, HeavyRailFacet, CommuterRailFacet, BusFacet, FerryFacet ]


pageFacets : List FacetType
pageFacets =
    [ PageFacet, LandingPageFacet ]


documentFacets : List FacetType
documentFacets =
    [ PersonFacet, ProjectFacet, ProjectUpdateFacet ]


pagesAndDocumentsFacets : List FacetType
pagesAndDocumentsFacets =
    List.append pageFacets documentFacets


facetMap : FacetType -> String
facetMap facet =
    case facet of
        LightRailFacet ->
            "\"route.type:0\""

        HeavyRailFacet ->
            "\"route.type:1\""

        CommuterRailFacet ->
            "\"route.type:2\""

        BusFacet ->
            "\"route.type:3\""

        FerryFacet ->
            "\"route.type:4\""

        StopFacet ->
            "\"stop.station?:false\""

        StationFacet ->
            "\"stop.station?:true\""

        BusLineFacet ->
            "\"routes.icon:bus\""

        OrangeLineFacet ->
            "\"routes.icon:orange_line\""

        RedLineFacet ->
            "\"routes.icon:red_line\""

        BlueLineFacet ->
            "\"routes.icon:blue_line\""

        GreenLineFacet ->
            "\"routes.icon:green_line\""

        CommuterRailLineFacet ->
            "\"routes.icon:commuter_rail\""

        MattapanTrolleyLineFacet ->
            "\"routes.icon:mattapan_trolley\""

        FerryLineFacet ->
            "\"routes.icon:ferry\""

        NewsEntryFacet ->
            "\"_content_type:news_entry\""

        EventFacet ->
            "\"_content_type:event\""

        PageFacet ->
            "\"_content_type:page\""

        LandingPageFacet ->
            "\"_content_type:landing_page\""

        SearchResultFacet ->
            "\"_content_type:search_result\""

        PersonFacet ->
            "\"_content_type:person\""

        ProjectFacet ->
            "\"_content_type:project\""

        ProjectUpdateFacet ->
            "\"_content_type:project_update\""


searchString : List FacetType -> String
searchString facets =
    "[[" ++ (List.map facetMap facets |> String.join (",")) ++ "]]"
