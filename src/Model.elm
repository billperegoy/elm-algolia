module Model exposing (..)

import Http


type alias Flags =
    { algoliaApiKey : String
    , algoliaApplicationId : String
    }


type alias Model =
    { algoliaApiKey : String
    , algoliaApplicationId : String
    , searchInput : String
    , searchResults : List SearchHit
    , errorText : String
    }


type alias MultiIndexSearchResponse =
    { results : List SearchResponse }


type alias SearchResponse =
    { hits : List SearchHit }


type SearchHit
    = StopHit StopSearchHit
    | RouteHit RouteSearchHit
    | DrupalHit DrupalSearchHit



-- Stop


type alias StopSearchHit =
    { url : String
    , stop : Stop
    }


type alias Stop =
    { id : String
    , name : String
    }



-- Route


type alias RouteSearchHit =
    { url : String
    , route : Route
    }


type alias Route =
    { id : String
    , name : String
    }



-- Drupal


type alias DrupalSearchHit =
    { contentTitle : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    { algoliaApiKey = flags.algoliaApiKey
    , algoliaApplicationId = flags.algoliaApplicationId
    , searchInput = ""
    , searchResults = []
    , errorText = ""
    }
        ! []


type Msg
    = UpdateSearchInput String
    | ProcessSearchResponse (Result Http.Error SearchResponse)
    | ProcessMultiIndexSearchResponse (Result Http.Error MultiIndexSearchResponse)
