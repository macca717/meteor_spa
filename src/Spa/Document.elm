module Spa.Document exposing
    ( Document
    , map
    , toBrowserDocument
    )

import Browser
import Components.Banner as Banner
import Components.Footer as Footer
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font


type alias Document msg =
    { title : String
    , body : List (Element msg)
    }


map : (msg1 -> msg2) -> Document msg1 -> Document msg2
map fn doc =
    { title = doc.title
    , body = List.map (Element.map fn) doc.body
    }


toBrowserDocument : Document msg -> Browser.Document msg
toBrowserDocument doc =
    { title = doc.title
    , body =
        [ Element.layout
            [ width fill
            , height fill
            , Background.color <| rgb255 29 75 138
            , Font.size 16
            , Font.family
                [ Font.external
                    { name = "Roboto"
                    , url = "https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&display=swap"
                    }
                , Font.sansSerif
                ]
            , Element.inFront <| Footer.view
            , scrollbarY
            ]
            (column [ width fill, height fill ] <| Banner.view :: doc.body)
        ]
    }
