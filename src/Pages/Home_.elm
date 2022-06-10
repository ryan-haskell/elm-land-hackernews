module Pages.Home_ exposing (Model, Msg, page)

import Api.Item exposing (Item)
import Api.TopStories
import Components.Listing
import Components.LoadableSection
import Components.LoadingSpinner
import ElmLand.Layout
import ElmLand.Page exposing (Page)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import List.Extra
import Task
import Time
import View exposing (View)


page : Page Model Msg
page =
    ElmLand.Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { itemIds : List Int
    , items : List Item
    , now : Time.Posix
    , zone : Time.Zone
    }


init : ( Model, Cmd Msg )
init =
    ( { itemIds = []
      , items = []
      , now = Time.millisToPosix 0
      , zone = Time.utc
      }
    , Cmd.batch
        [ Api.TopStories.fetch
            { onComplete = ApiFetchedTopStoryIds
            }
        , Time.now
            |> Task.perform ElmSentCurrentTime
        , Time.here
            |> Task.perform ElmSentTimeZone
        ]
    )



-- UPDATE


type Msg
    = ElmSentCurrentTime Time.Posix
    | ElmSentTimeZone Time.Zone
    | ApiFetchedTopStoryIds (Result Http.Error (List Int))
    | ApiFetchedItem (Result Http.Error Item)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ElmSentCurrentTime now ->
            ( { model | now = now }
            , Cmd.none
            )

        ElmSentTimeZone zone ->
            ( { model | zone = zone }
            , Cmd.none
            )

        ApiFetchedTopStoryIds result ->
            case result of
                Ok itemIds ->
                    ( { model | itemIds = itemIds }
                    , itemIds
                        |> List.map sendItemFetchCmd
                        |> Cmd.batch
                    )

                Err reason ->
                    ( model
                    , Cmd.none
                    )

        ApiFetchedItem result ->
            case result of
                Ok item ->
                    ( { model | items = model.items ++ [ item ] }
                    , Cmd.none
                    )

                Err reason ->
                    ( model
                    , Cmd.none
                    )


sendItemFetchCmd : Int -> Cmd Msg
sendItemFetchCmd itemId =
    Api.Item.fetch
        { id = String.fromInt itemId
        , onComplete = ApiFetchedItem
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


layout : ElmLand.Layout.Layout
layout =
    ElmLand.Layout.Navbar


view : Model -> View Msg
view model =
    { title = "HackerNews | Elm Land"
    , body =
        [ div [ class "column gap-8" ]
            (Components.LoadableSection.view
                { ids = model.itemIds
                , items = model.items
                , viewItem = Components.Listing.view model.zone
                }
            )
        ]
    }
