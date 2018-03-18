module Update exposing (update)

import Json.Decode.Pipeline
import Json.Decode
import Json.Encode
import Http
import Model exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSearchInput text ->
            { model | searchInput = text } ! [ performMultiIndexSearch model text ]

        ProcessSearchResponse (Ok response) ->
            { model
                | searchResults = response.hits
                , errorText = ""
            }
                ! []

        ProcessSearchResponse (Err error) ->
            { model
                | searchResults = []
            }
                ! []

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
        |> Json.Decode.map (\elem -> StopHit elem)


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
        |> Json.Decode.map (\elem -> RouteHit elem)


drupalSearchHitDecoder : Json.Decode.Decoder SearchHit
drupalSearchHitDecoder =
    Json.Decode.Pipeline.decode DrupalSearchHit
        |> Json.Decode.Pipeline.required "content_title" Json.Decode.string
        |> Json.Decode.map (\elem -> DrupalHit elem)


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


performSearch : Model -> String -> Cmd Msg
performSearch model searchString =
    let
        url =
            queryUrl model.algoliaApiKey "stops"

        body =
            Http.jsonBody (searchBody searchString)

        headers =
            [ Http.header "X-Algolia-API-Key" model.algoliaApiKey
            , Http.header "X-Algolia-Application-Id" model.algoliaApiKey
            ]

        httpRequest =
            Http.request
                { method = "POST"
                , headers = headers
                , url = url
                , body = body
                , expect = Http.expectJson searchResponseDecoder
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send ProcessSearchResponse httpRequest



-- Multi Index Search


multiIndexQueryUrl : String -> String -> String
multiIndexQueryUrl algoliaAppId indexName =
    "https://"
        ++ algoliaAppId
        ++ "-dsn.algolia.net/1/indexes/"
        ++ "*"
        ++ "/queries"


multiIndexSearchBody : String -> Json.Encode.Value
multiIndexSearchBody searchString =
    let
        queryString =
            "query=" ++ searchString

        index1 =
            Json.Encode.object
                [ ( "indexName", Json.Encode.string "routes" )
                , ( "params", Json.Encode.string queryString )
                ]

        index2 =
            Json.Encode.object
                [ ( "indexName", Json.Encode.string "stops" )
                , ( "params", Json.Encode.string queryString )
                ]

        index3 =
            Json.Encode.object
                [ ( "indexName", Json.Encode.string "drupal" )
                , ( "params", Json.Encode.string queryString )
                ]
    in
        Json.Encode.object
            [ ( "requests", Json.Encode.list [ index1, index2, index3 ] ) ]


performMultiIndexSearch : Model -> String -> Cmd Msg
performMultiIndexSearch model searchString =
    let
        url =
            multiIndexQueryUrl model.algoliaApplicationId "stops"

        body =
            Http.jsonBody (multiIndexSearchBody searchString)

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
