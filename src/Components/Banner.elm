module Components.Banner exposing (view)

import Color exposing (darkBlue, white)
import Element exposing (Element, centerX, el, fill, height, px, rgb255, text, width)
import Element.Background as Background
import Element.Font as Font


view : Element msg
view =
    Element.row
        [ width Element.fill
        , height <| px 50
        , Background.color darkBlue
        ]
        [ Element.row
            [ width (fill |> Element.maximum 720)
            , centerX
            ]
            [ el
                [ Font.color white
                , Font.size 24
                , centerX
                ]
                (text "Weather")
            ]
        ]
