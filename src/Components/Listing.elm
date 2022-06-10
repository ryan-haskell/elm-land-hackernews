module Components.Listing exposing (view)

import Api.Item exposing (Item)
import Html exposing (..)
import Html.Attributes exposing (..)
import Time
import Utils.Time


view : Time.Zone -> Item -> Html msg
view zone item =
    let
        viewTitle : Html msg
        viewTitle =
            case item.url of
                Just url ->
                    a
                        [ class "link font-medium"
                        , target "_blank"
                        , rel "noopener noreferrer"
                        , href url
                        ]
                        [ text item.title ]

                Nothing ->
                    span [ class "font-medium" ] [ text item.title ]
    in
    div [ class "listing column gap-4" ]
        [ viewTitle
        , div [ class "row gap-4 font-small" ]
            (List.concat
                [ [ p [] [ text (String.fromInt item.points ++ " points") ]
                  , p [] [ text "by" ]
                  , p [] [ text ("@" ++ item.author) ]
                  , p [] [ text "|" ]
                  , p [] [ text (Utils.Time.format zone item.time) ]
                  ]
                , if List.isEmpty item.commentIds then
                    []

                  else
                    [ p [] [ text "|" ]
                    , a
                        [ class "link"
                        , href ("/item/" ++ String.fromInt item.id)
                        ]
                        [ text "View comments" ]
                    ]
                ]
            )
        ]
