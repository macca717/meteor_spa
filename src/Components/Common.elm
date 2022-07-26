module Components.Common exposing (fixedRatioImage)

import Element exposing (Attribute, Element, fill, height, image, px, width)


fixedRatioImage : List (Attribute msg) -> { width : Float, ratio : Float, src : String, description : String } -> Element msg
fixedRatioImage attrs { width, ratio, src, description } =
    let
        updated =
            attrs ++ [ height <| px (floor <| width * ratio) ]
    in
    image
        updated
        { src = src, description = description }
