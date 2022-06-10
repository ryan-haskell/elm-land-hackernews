module Api.TopStories exposing (fetch)

import Http
import Json.Decode as Json


fetch : { onComplete : Result Http.Error (List Int) -> msg } -> Cmd msg
fetch options =
    Http.get
        { url = "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
        , expect = Http.expectJson options.onComplete decoder
        }


decoder : Json.Decoder (List Int)
decoder =
    Json.list Json.int
        |> Json.map (List.take 30)
