module Api.Api exposing (CurrentWeather, IsoMap, RainMap, currentWeather, isoMaps, rainMaps)

import Api.Forecast as Forecast
import Api.Wind
import Http exposing (Header, header)
import Json.Decode as Decode
import RemoteData exposing (WebData)
import Time



-- TYPES


type alias RainMap =
    { url : String
    , validFromTime : String
    }


type alias IsoMap =
    { url : String
    , validFromTime : String
    }


type alias CurrentWeather =
    { version : String
    , time : Time.Posix
    , outsideTemp : String
    , pressureMBar : String
    , wind : String
    , rainFall : String
    , forecasts : List Forecast.Forecast
    }



-- Constants


defaultHeaders : List Header
defaultHeaders =
    [ header "Accept" "application/json" ]


apiDataUrl : String
apiDataUrl =
    "http://10.10.1.24/weather/api/v2/data/"


defaultTimeout : Maybe Float
defaultTimeout =
    Just 10000


rainMaps : { onResponse : WebData (List RainMap) -> msg } -> Cmd msg
rainMaps options =
    Http.request
        { method = "GET"
        , headers = defaultHeaders
        , url = apiDataUrl
        , body = Http.emptyBody
        , expect =
            Http.expectJson (RemoteData.fromResult >> options.onResponse) rainMapsDecoder
        , timeout = defaultTimeout
        , tracker = Nothing
        }


isoMaps : { onResponse : WebData (List IsoMap) -> msg } -> Cmd msg
isoMaps options =
    Http.request
        { method = "GET"
        , headers = defaultHeaders
        , url = apiDataUrl
        , body = Http.emptyBody
        , expect =
            Http.expectJson (RemoteData.fromResult >> options.onResponse) isoMapsDecoder
        , timeout = defaultTimeout
        , tracker = Nothing
        }


currentWeather : { onResponse : WebData CurrentWeather -> msg } -> Cmd msg
currentWeather options =
    Http.request
        { method = "GET"
        , headers = defaultHeaders
        , url = apiDataUrl
        , body = Http.emptyBody
        , expect =
            Http.expectJson (RemoteData.fromResult >> options.onResponse) currentWeatherDecoder
        , timeout = defaultTimeout
        , tracker = Nothing
        }



-- DECODERS


rainMapsDecoder : Decode.Decoder (List RainMap)
rainMapsDecoder =
    Decode.at [ "maps", "rain" ] (Decode.list rainMapDecoder)


rainMapDecoder : Decode.Decoder RainMap
rainMapDecoder =
    Decode.map2 RainMap
        (Decode.at [ "url" ] Decode.string)
        (Decode.at [ "validFrom" ] Decode.string)


isoMapsDecoder : Decode.Decoder (List IsoMap)
isoMapsDecoder =
    Decode.at [ "maps", "iso" ] (Decode.list isoMapDecoder)


isoMapDecoder : Decode.Decoder IsoMap
isoMapDecoder =
    Decode.map2 IsoMap
        (Decode.at [ "url" ] Decode.string)
        (Decode.at [ "validFromTime" ] Decode.string)


currentWeatherDecoder : Decode.Decoder CurrentWeather
currentWeatherDecoder =
    Decode.map7 CurrentWeather
        (Decode.at [ "version" ] Decode.string)
        timeDecoder
        (Decode.at [ "current", "outsideTemp" ] Decode.float
            |> Decode.andThen
                (\val ->
                    Decode.succeed <| String.fromFloat val
                )
        )
        (Decode.at [ "current", "pressureMBar" ] Decode.float
            |> Decode.andThen
                (\val ->
                    Decode.succeed <| String.fromFloat val
                )
        )
        (Api.Wind.windDecoder
            |> Decode.andThen
                (\wind ->
                    Decode.succeed <| Api.Wind.toString wind
                )
        )
        (Decode.at [ "current", "rainRate" ] Decode.float
            |> Decode.andThen
                (\val ->
                    Decode.succeed <| String.fromFloat val
                )
        )
        Forecast.listOfForecastsDecoder


timeDecoder : Decode.Decoder Time.Posix
timeDecoder =
    Decode.map Time.millisToPosix
        (Decode.field "time" Decode.int)
