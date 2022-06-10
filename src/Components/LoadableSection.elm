module Components.LoadableSection exposing (view)

import Api.Item exposing (Item)
import Components.LoadingSpinner
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Extra


view :
    { items : List { item | id : Int }
    , ids : List Int
    , viewItem : { item | id : Int } -> Html msg
    }
    -> List (Html msg)
view options =
    if
        List.isEmpty options.items
            || List.length options.ids
            /= List.length options.items
    then
        [ Components.LoadingSpinner.view ]

    else
        options.items
            |> List.sortWith (sortByIds options.ids)
            |> List.map options.viewItem


sortByIds : List Int -> { item | id : Int } -> { item | id : Int } -> Order
sortByIds itemIds item1 item2 =
    let
        maybeIndexOfItem1 : Maybe Int
        maybeIndexOfItem1 =
            List.Extra.elemIndex item1.id itemIds

        maybeIndexOfItem2 : Maybe Int
        maybeIndexOfItem2 =
            List.Extra.elemIndex item2.id itemIds
    in
    case ( maybeIndexOfItem1, maybeIndexOfItem2 ) of
        ( Just index1, Just index2 ) ->
            compare index1 index2

        _ ->
            EQ
