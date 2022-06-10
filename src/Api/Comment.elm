module Api.Comment exposing (Comment, DeletableComment(..), fetch)

import Http
import Json.Decode as Json
import Time
import Utils.Time


type DeletableComment
    = NotDeleted Comment
    | TotallyDeleted DeletedComment


type alias Comment =
    { id : Int
    , text : String
    , time : Time.Posix
    , author : String
    , commentIds : List Int
    }


type alias DeletedComment =
    { id : Int
    }


fetch :
    { id : String
    , onComplete : Result Http.Error DeletableComment -> msg
    }
    -> Cmd msg
fetch options =
    Http.get
        { url =
            "https://hacker-news.firebaseio.com/v0/item/{{id}}.json?print=pretty"
                |> String.replace "{{id}}" options.id
        , expect = Http.expectJson options.onComplete decoder
        }


decoder : Json.Decoder DeletableComment
decoder =
    Json.oneOf
        [ commentDecoder |> Json.map NotDeleted
        , deletedCommentDecoder |> Json.map TotallyDeleted
        ]


commentDecoder : Json.Decoder Comment
commentDecoder =
    Json.map5 Comment
        (Json.field "id" Json.int)
        (Json.field "text" Json.string)
        (Json.field "time" Json.int
            |> Json.map Utils.Time.fromSecondsToPosix
        )
        (Json.field "by" Json.string)
        (Json.oneOf
            [ Json.field "kids" (Json.list Json.int)
            , Json.succeed []
            ]
        )


deletedCommentDecoder : Json.Decoder DeletedComment
deletedCommentDecoder =
    Json.map DeletedComment
        (Json.field "id" Json.int)
