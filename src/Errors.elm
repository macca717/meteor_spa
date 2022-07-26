module Errors exposing (httpErrorToString)

import Http


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        Http.BadBody msg ->
            msg

        Http.Timeout ->
            "The request timed out. The weather server is not responding, please retry in a few minutes"

        Http.NetworkError ->
            "There was a network error, please check your connection and reload."

        Http.BadStatus code ->
            "The server returned a bad status " ++ String.fromInt code

        Http.BadUrl msg ->
            msg
