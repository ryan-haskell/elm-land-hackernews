module Api.Item exposing (Item, fetch)

import Http
import Json.Decode as Json
import Time
import Utils.Time


type alias Item =
    { id : Int
    , title : String
    , time : Time.Posix
    , url : Maybe String
    , author : String
    , points : Int
    , commentIds : List Int
    }


fetch : { id : String, onComplete : Result Http.Error Item -> msg } -> Cmd msg
fetch options =
    Http.get
        { url =
            "https://hacker-news.firebaseio.com/v0/item/{{id}}.json?print=pretty"
                |> String.replace "{{id}}" options.id
        , expect = Http.expectJson options.onComplete decoder
        }


decoder : Json.Decoder Item
decoder =
    Json.map7 Item
        (Json.field "id" Json.int)
        (Json.field "title" Json.string)
        (Json.field "time" Json.int
            |> Json.map Utils.Time.fromSecondsToPosix
        )
        (Json.maybe (Json.field "url" Json.string))
        (Json.field "by" Json.string)
        (Json.field "score" Json.int)
        (Json.oneOf
            [ Json.field "kids" (Json.list Json.int)
            , Json.succeed []
            ]
        )
