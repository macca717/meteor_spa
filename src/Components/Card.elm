module Components.Card exposing (card, errorCard)

import Color exposing (lightGrey, white)
import Components.Separator exposing (separator)
import Element exposing (Element, column, el, fill, padding, paragraph, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


card : List (Element msg) -> Element msg
card items =
    column
        [ Background.color white
        , width fill
        , padding 20
        , Border.rounded 3
        ]
        items


errorCard : String -> Element msg
errorCard err =
    card <|
        [ column [ spacing 20, width fill ]
            [ el [ Font.size 18 ] (text "Error")
            , separator lightGrey
            , paragraph [ Font.light ] [ text err ]
            ]
        ]
