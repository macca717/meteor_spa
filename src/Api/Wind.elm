module Api.Wind exposing (Data, Wind, directionCardinal, directionDegrees, new, speedInKnots, toString, windDecoder)

import Json.Decode as Decode


type alias Data =
    { speedKnots : Float
    , directionDegrees : Float
    , directionStr : String
    }


type alias CardinalDir =
    String


type alias Degrees =
    Float


type Wind
    = Wind Data


new : Data -> Wind
new data =
    Wind data



-- Getters


speedInKnots : Wind -> Float
speedInKnots (Wind data) =
    data.speedKnots


directionCardinal : Wind -> String
directionCardinal (Wind data) =
    data.directionStr


directionDegrees : Wind -> Float
directionDegrees (Wind data) =
    data.directionDegrees


toString : Wind -> String
toString (Wind data) =
    String.fromFloat data.speedKnots
        ++ " kts "
        ++ data.directionStr



-- Decoders


windDecoder : Decode.Decoder Wind
windDecoder =
    Decode.map new windDataDecoder


windDataDecoder : Decode.Decoder Data
windDataDecoder =
    Decode.map3 Data
        (Decode.at [ "current", "wind", "speedKts" ] Decode.float)
        (Decode.oneOf
            [ Decode.at [ "current", "wind", "directionDegrees" ] Decode.float
            , Decode.succeed 0.0
            ]
        )
        (Decode.at [ "current", "wind", "cardinalStr" ] Decode.string)
