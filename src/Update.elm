module Update exposing (update)

import Json.Decode.Pipeline
import Json.Decode
import Json.Encode
import Http
import Model exposing (..)
import Facets


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSearchInput text ->
            { model | searchInput = text } ! [ performMultiIndexSearch model text model.facetFilters ]

        ProcessMultiIndexSearchResponse (Ok response) ->
            let
                results =
                    List.foldl
                        (\elem accum -> List.append accum elem.hits)
                        []
                        response.results
            in
                { model
                    | searchResults = results
                    , errorText = ""
                }
                    ! []

        ProcessMultiIndexSearchResponse (Err error) ->
            { model
                | searchResults = []
                , errorText = toString error
            }
                ! []

        UpdateFacet facets value ->
            let
                newFacetFilters =
                    case value of
                        True ->
                            addFacetFilters facets model.facetFilters

                        False ->
                            removeFacetFilters facets model.facetFilters
            in
                { model | facetFilters = newFacetFilters } ! [ performMultiIndexSearch model model.searchInput newFacetFilters ]


addFacetFilters : List Facets.FacetType -> List Facets.FacetType -> List Facets.FacetType
addFacetFilters newFacets facets =
    List.append facets newFacets


removeFacetFilters : List Facets.FacetType -> List Facets.FacetType -> List Facets.FacetType
removeFacetFilters facetsToRemove facets =
    List.foldl (\elem accum -> removeOneFacet elem accum) facets facetsToRemove


removeOneFacet : Facets.FacetType -> List Facets.FacetType -> List Facets.FacetType
removeOneFacet facet facets =
    List.filter (\elem -> elem /= facet) facets


stopDecoder : Json.Decode.Decoder Stop
stopDecoder =
    Json.Decode.Pipeline.decode Stop
        |> Json.Decode.Pipeline.required "id" Json.Decode.string
        |> Json.Decode.Pipeline.required "name" Json.Decode.string


stopSearchHitDecoder : Json.Decode.Decoder SearchHit
stopSearchHitDecoder =
    Json.Decode.Pipeline.decode StopSearchHit
        |> Json.Decode.Pipeline.required "url" Json.Decode.string
        |> Json.Decode.Pipeline.required "stop" stopDecoder
        |> Json.Decode.map StopHit


routeDecoder : Json.Decode.Decoder Route
routeDecoder =
    Json.Decode.Pipeline.decode Route
        |> Json.Decode.Pipeline.required "id" Json.Decode.string
        |> Json.Decode.Pipeline.required "name" Json.Decode.string


routeSearchHitDecoder : Json.Decode.Decoder SearchHit
routeSearchHitDecoder =
    Json.Decode.Pipeline.decode RouteSearchHit
        |> Json.Decode.Pipeline.required "url" Json.Decode.string
        |> Json.Decode.Pipeline.required "route" stopDecoder
        |> Json.Decode.map RouteHit


drupalSearchHitDecoder : Json.Decode.Decoder SearchHit
drupalSearchHitDecoder =
    Json.Decode.Pipeline.decode DrupalSearchHit
        |> Json.Decode.Pipeline.required "content_title" Json.Decode.string
        |> Json.Decode.map DrupalHit


multiIndexSearchResponseDecoder : Json.Decode.Decoder MultiIndexSearchResponse
multiIndexSearchResponseDecoder =
    Json.Decode.Pipeline.decode MultiIndexSearchResponse
        |> Json.Decode.Pipeline.required "results" searchResponseListDecoder


searchResponseDecoder : Json.Decode.Decoder SearchResponse
searchResponseDecoder =
    Json.Decode.Pipeline.decode SearchResponse
        |> Json.Decode.Pipeline.required "hits" searchHitListDecoder


searchHitListDecoder : Json.Decode.Decoder (List SearchHit)
searchHitListDecoder =
    [ stopSearchHitDecoder, routeSearchHitDecoder, drupalSearchHitDecoder ]
        |> Json.Decode.oneOf
        |> Json.Decode.list


searchResponseListDecoder : Json.Decode.Decoder (List SearchResponse)
searchResponseListDecoder =
    Json.Decode.list searchResponseDecoder



-- Single Index Search


queryUrl : String -> String -> String
queryUrl algoliaAppId indexName =
    "https://"
        ++ algoliaAppId
        ++ "-dsn.algolia.net/1/indexes/"
        ++ indexName
        ++ "/query"


searchBody : String -> Json.Encode.Value
searchBody searchString =
    let
        queryString =
            "query=" ++ searchString
    in
        Json.Encode.object
            [ ( "params", Json.Encode.string queryString ) ]



-- Multi Index Search


multiIndexQueryUrl : String -> String -> String
multiIndexQueryUrl algoliaAppId indexName =
    "https://"
        ++ algoliaAppId
        ++ "-dsn.algolia.net/1/indexes/"
        ++ "*"
        ++ "/queries"


indexObject : String -> String -> Json.Encode.Value
indexObject queryString indexName =
    Json.Encode.object
        [ ( "indexName", Json.Encode.string indexName )
        , ( "params", Json.Encode.string queryString )
        ]


multiIndexSearchBody : Model -> String -> List Facets.FacetType -> Json.Encode.Value
multiIndexSearchBody model searchString filters =
    let
        facets =
            "[*]"

        facetFilters =
            filters
                |> Facets.searchString

        facetString =
            "facets=" ++ facets ++ "&facetFilters=" ++ facetFilters

        queryString =
            "query=" ++ searchString ++ "&" ++ facetString

        indexObjects =
            [ "routes", "stops", "drupal" ]
                |> List.map (indexObject queryString)
    in
        Json.Encode.object
            [ ( "requests"
              , Json.Encode.list indexObjects
              )
            ]


performMultiIndexSearch : Model -> String -> List Facets.FacetType -> Cmd Msg
performMultiIndexSearch model searchString facets =
    let
        url =
            multiIndexQueryUrl model.algoliaApplicationId "stops"

        body =
            Http.jsonBody (multiIndexSearchBody model searchString facets)

        headers =
            [ Http.header "X-Algolia-API-Key" model.algoliaApiKey
            , Http.header "X-Algolia-Application-Id" model.algoliaApplicationId
            ]

        httpRequest =
            Http.request
                { method = "POST"
                , headers = headers
                , url = url
                , body = body
                , expect = Http.expectJson multiIndexSearchResponseDecoder
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send ProcessMultiIndexSearchResponse httpRequest
