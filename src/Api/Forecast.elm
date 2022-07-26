module Api.Forecast exposing (Forecast, dayOfWeek, fromJSON, high, listOfForecastsDecoder, low, synopsis, word)

import Json.Decode as Decode


type Forecast
    = Forecast Data


type alias Data =
    { dayOfWeek : String
    , synopsis : String
    , word : String
    , high : Float
    , low : Float
    }


fromJSON : String -> Result Decode.Error (List Forecast)
fromJSON =
    Decode.decodeString listOfForecastsDecoder


forecastDecoder : Decode.Decoder Forecast
forecastDecoder =
    Decode.map Forecast dataDecoder


dataDecoder : Decode.Decoder Data
dataDecoder =
    Decode.map5 Data
        (Decode.field "dow" Decode.string)
        (Decode.field "forecast" Decode.string)
        (Decode.field "forecastWord" Decode.string)
        (Decode.field "max" Decode.float)
        (Decode.field "min" Decode.float)


listOfForecastsDecoder : Decode.Decoder (List Forecast)
listOfForecastsDecoder =
    Decode.field "forecasts" (Decode.list forecastDecoder)



-- Getters


dayOfWeek : Forecast -> String
dayOfWeek (Forecast data) =
    data.dayOfWeek


synopsis : Forecast -> String
synopsis (Forecast data) =
    data.synopsis


word : Forecast -> String
word (Forecast data) =
    data.word


high : Forecast -> Float
high (Forecast data) =
    data.high


low : Forecast -> Float
low (Forecast data) =
    data.low



-- Helpers
