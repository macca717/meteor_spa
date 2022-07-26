module Components.Separator exposing (separator)

import Element exposing (Color, Element, el, fill, none, width)
import Element.Border as Border


separator : Color -> Element msg
separator color =
    el
        [ width fill
        , Border.widthEach { bottom = 0, left = 0, right = 0, top = 1 }
        , Border.solid
        , Border.color color
        ]
        none
