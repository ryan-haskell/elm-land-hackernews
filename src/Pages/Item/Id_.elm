module Pages.Item.Id_ exposing (Model, Msg, page)

import Api.Comment exposing (Comment, DeletableComment(..))
import Api.Item exposing (Item)
import Components.LoadableSection
import Components.LoadingSpinner
import ElmLand.Layout
import ElmLand.Page exposing (Page)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Encode
import Markdown
import Task
import Time
import Utils.Time
import View exposing (View)


layout : ElmLand.Layout.Layout
layout =
    ElmLand.Layout.Navbar


page : { id : String } -> Page Model Msg
page params =
    ElmLand.Page.element
        { init = init params.id
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { item : Maybe Item
    , comments : List Comment
    , zone : Time.Zone
    }


init : String -> ( Model, Cmd Msg )
init id =
    ( { item = Nothing
      , zone = Time.utc
      , comments = []
      }
    , Cmd.batch
        [ Api.Item.fetch
            { id = id
            , onComplete = ApiFetchedItem
            }
        , Time.here
            |> Task.perform ElmSentTimeZone
        ]
    )



-- UPDATE


type Msg
    = ApiFetchedItem (Result Http.Error Item)
    | ApiFetchedComment (Result Http.Error DeletableComment)
    | ElmSentTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ElmSentTimeZone zone ->
            ( { model | zone = zone }
            , Cmd.none
            )

        ApiFetchedItem result ->
            case result of
                Ok item ->
                    ( { model | item = Just item }
                    , Cmd.batch (List.map fetchComment item.commentIds)
                    )

                Err reason ->
                    ( model
                    , Cmd.none
                    )

        ApiFetchedComment result ->
            case result of
                Ok (Api.Comment.NotDeleted comment) ->
                    ( { model | comments = model.comments ++ [ comment ] }
                    , Cmd.none
                    )

                Ok (Api.Comment.TotallyDeleted { id }) ->
                    ( { model
                        | item =
                            model.item
                                |> Maybe.map (removeCommentWithId id)
                      }
                    , Cmd.none
                    )

                Err reason ->
                    ( model
                    , Cmd.none
                    )


removeCommentWithId : Int -> Item -> Item
removeCommentWithId id item =
    { item
        | commentIds =
            List.filter (\commentId -> commentId /= id) item.commentIds
    }


fetchComment : Int -> Cmd Msg
fetchComment commentId =
    Api.Comment.fetch
        { id = String.fromInt commentId
        , onComplete = ApiFetchedComment
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


maxTitleLength =
    20


view : Model -> View Msg
view model =
    case model.item of
        Nothing ->
            { title = "HackerNews"
            , body = [ Components.LoadingSpinner.view ]
            }

        Just item ->
            { title =
                if String.length item.title > maxTitleLength then
                    String.left maxTitleLength item.title ++ "... | HackerNews"

                else
                    item.title ++ " | HackerNews"
            , body = [ viewItem model item ]
            }


viewItem : Model -> Item -> Html Msg
viewItem model item =
    div [ class "column gap-32 pad-y-64" ]
        [ div [ class "column gap-8 pad-y-32" ]
            [ h1 [ class "font-title" ] [ text item.title ]
            , div [ class "font-subtitle row gap-8" ]
                [ p [] [ text (String.fromInt item.points ++ " points") ]
                , p [] [ text "by" ]
                , p [] [ text ("@" ++ item.author) ]
                , p [] [ text "|" ]
                , p [] [ text (Utils.Time.format model.zone item.time) ]
                ]
            ]
        , div [ class "column gap-32" ]
            (Components.LoadableSection.view
                { ids = item.commentIds
                , items = model.comments
                , viewItem = viewComment model
                }
            )
        ]


viewComment : Model -> Comment -> Html Msg
viewComment model comment =
    div [ class "comment column gap-8" ]
        [ div [ class "row gap-16 center-y" ]
            [ h3 [ class "font-medium" ] [ text ("@" ++ comment.author) ]
            , p [ class "font-small" ]
                [ text (Utils.Time.format model.zone comment.time)
                ]
            ]
        , node "raw-html"
            [ class "markdown font-small"
            , property "rawHtml" (Json.Encode.string comment.text)
            ]
            []
        ]
