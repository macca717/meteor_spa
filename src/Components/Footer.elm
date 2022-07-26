module Components.Footer exposing (view)

import Color exposing (darkBlue, white)
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Spa.Generated.Route as Route


links : List (Element msg)
links =
    [ Element.link []
        { url = Route.toString Route.Top, label = Element.text "Home" }
    , Element.link []
        { url = Route.toString Route.Maps__Rain, label = Element.text "Rain Maps" }
    , Element.link []
        { url = Route.toString Route.Maps__Iso, label = Element.text "Iso Maps" }
    ]


view : Element msg
view =
    Element.row
        [ Element.centerX
        , Element.alignBottom
        , Background.color darkBlue
        , Element.paddingXY 40 20
        , Element.width Element.fill
        ]
        [ Element.row
            [ Element.width (Element.fill |> Element.maximum 500)
            , Element.centerX
            , Element.spaceEvenly
            , Font.color white
            ]
            links
        ]
