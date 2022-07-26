module Pages.Top exposing (Model, Msg, Params, page)

import Api.Api exposing (CurrentWeather, currentWeather)
import Api.Forecast as Forecast exposing (Forecast)
import Color exposing (lightGrey)
import Components.Card exposing (card, errorCard)
import Components.Separator exposing (separator)
import Dict
import Element exposing (..)
import Element.Font as Font
import Errors exposing (httpErrorToString)
import RemoteData exposing (WebData)
import Shared
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)
import String
import Time exposing (Posix)



-- Constants


appVersion : String
appVersion =
    "1.01d"


type alias Params =
    ()



-- Model


type alias Model =
    { data : WebData CurrentWeather
    , device : Element.Device
    , timeZone : Time.Zone
    , appVersion : String
    }


type Msg
    = GotCurrentWeather (WebData CurrentWeather)
    | DataUpdate


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , save = save
        , load = load
        }


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( { model | device = shared.device, timeZone = shared.timeZone }
    , Cmd.none
    )


save : Model -> Shared.Model -> Shared.Model
save model shared =
    shared



-- INIT


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { data = RemoteData.Loading, device = shared.device, timeZone = shared.timeZone, appVersion = appVersion }
    , currentWeather
        { onResponse = GotCurrentWeather }
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotCurrentWeather response ->
            ( { model | data = response }, Cmd.none )

        DataUpdate ->
            ( model, currentWeather { onResponse = GotCurrentWeather } )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every (120 * 1000) (\_ -> DataUpdate)



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Weather"
    , body =
        case model.data of
            RemoteData.NotAsked ->
                [ el [] (text "Not Asked") ]

            RemoteData.Loading ->
                [ loadingView ]

            RemoteData.Success data ->
                [ column [ spacing 10, width fill ]
                    [ currentConditionsView data model.timeZone
                    , tomorrowsConditionsView data
                    , restOfWeekConditionsView data
                    , versionView model.appVersion data
                    ]
                ]

            RemoteData.Failure err ->
                [ errorCard <| httpErrorToString err ]
    }


loadingView : Element msg
loadingView =
    image [ centerX, centerY ] { src = "dist/img/tail-spin.svg", description = "Loading" }


currentConditionsView : CurrentWeather -> Time.Zone -> Element msg
currentConditionsView data zone =
    card <|
        [ column [ width fill, spacing 20 ]
            [ row [ width fill, Font.size 18 ]
                [ el [] (text <| "Current Conditions")
                , el [ alignRight, Font.size 14, Font.extraLight, Font.italic ] (text <| "Updated " ++ posixTimeToString data.time zone)
                ]
            , separator lightGrey
            , currentTempView data
            , separator lightGrey
            , column
                [ width fill, spacing 10 ]
                [ readingView { icon = "dist/img/weather-windy.svg", desc = "Wind", value = data.wind }
                , readingView { icon = "dist/img/gauge.svg", desc = "Pressure", value = data.pressureMBar ++ " mbar" }
                , readingView { icon = "dist/img/rainfall.svg", desc = "Rainfall", value = data.rainFall ++ " mm/h" }
                ]
            , separator lightGrey
            , todaysForecastView data
            ]
        ]


tomorrowsConditionsView : CurrentWeather -> Element msg
tomorrowsConditionsView data =
    let
        highTempStr =
            getTomorrowsForecast data.forecasts
                |> Maybe.map Forecast.high
                |> Maybe.map String.fromFloat
                |> Maybe.withDefault "--"

        lowTempStr =
            getTomorrowsForecast data.forecasts
                |> Maybe.map Forecast.low
                |> Maybe.map String.fromFloat
                |> Maybe.withDefault "--"

        forecast =
            getTomorrowsForecast data.forecasts
                |> Maybe.map Forecast.synopsis
                |> Maybe.withDefault "Failed to load forecast"

        forecastWord =
            getTomorrowsForecast data.forecasts
                |> Maybe.map Forecast.word
                |> Maybe.withDefault "Error"

        conditionsIconPath =
            getWeatherIconURL forecastWord
    in
    card <|
        [ column [ width fill, spacing 20 ]
            [ row []
                [ el [ Font.size 18 ] (text "Tomorrow") ]
            , separator lightGrey
            , row [ width fill, spacing 10 ]
                [ row [ spacing 5 ]
                    [ image [] { src = conditionsIconPath, description = forecastWord }
                    , el [ Font.size 16 ] (text forecastWord)
                    ]
                , row [ alignRight, Font.size 18, Font.light ]
                    [ thermostatImage [] { src = "dist/img/thermometer-hot.svg", description = "High Temperature" }
                    , el [] (text <| highTempStr ++ displayDegrees)
                    ]
                , row [ Font.size 18, Font.light ]
                    [ thermostatImage [] { src = "dist/img/thermometer-cold.svg", description = "Low Temperature" }
                    , el [] (text <| lowTempStr ++ displayDegrees)
                    ]
                ]
            , separator lightGrey
            , paragraph [ Font.light ] [ text forecast ]
            ]
        ]


readingView : { icon : String, desc : String, value : String } -> Element msg
readingView { icon, desc, value } =
    row
        [ width fill
        , spacing 10
        , Font.size 16
        ]
        [ image [] { src = icon, description = "wind" }
        , el [] (text desc)
        , el [ alignRight, Font.light ] (text value)
        ]


currentTempView : CurrentWeather -> Element msg
currentTempView data =
    let
        highTempStr =
            getTodaysForecast data.forecasts
                |> Maybe.map Forecast.high
                |> Maybe.map String.fromFloat
                |> Maybe.withDefault "--"

        lowTempStr =
            getTodaysForecast data.forecasts
                |> Maybe.map Forecast.low
                |> Maybe.map String.fromFloat
                |> Maybe.withDefault "--"
    in
    row
        [ width fill
        ]
        [ column [ spacing 10 ]
            [ el [ Font.size 16 ] (text "Actual Temperature")
            , el [ Font.size 24, Font.extraLight ] (text <| data.outsideTemp ++ displayDegrees)
            ]
        , column [ width fill, Font.light ]
            [ row [ width fill, spacing 5 ]
                [ thermostatImage [ alignRight ] { src = "dist/img/thermometer-hot.svg", description = "High Temperature" }
                , el [ alignRight, Font.alignRight, Font.size 18, width (fill |> minimum 40) ] (text <| highTempStr ++ displayDegrees)
                ]
            , row [ width fill, spacing 5 ]
                [ thermostatImage [ alignRight ] { src = "dist/img/thermometer-cold.svg", description = "Low Temperature" }
                , el [ alignRight, Font.alignRight, Font.size 18, width (fill |> minimum 40) ] (text <| lowTempStr ++ displayDegrees)
                ]
            ]
        ]


todaysForecastView : CurrentWeather -> Element msg
todaysForecastView data =
    let
        forecast =
            getTodaysForecast data.forecasts
                |> Maybe.map Forecast.synopsis
                |> Maybe.withDefault "Failed to load forecast"
    in
    row [ Font.light ]
        [ paragraph [] [ text forecast ]
        ]


restOfWeekConditionsView : CurrentWeather -> Element msg
restOfWeekConditionsView data =
    let
        forecastweek =
            List.drop 2 data.forecasts
                |> List.take 6
    in
    wrappedRow [ spacing 10 ]
        (List.map
            weekDayView
            forecastweek
        )


weekDayView : Forecast -> Element msg
weekDayView forecast =
    card <|
        [ column
            [ width (fill |> minimum 100)
            , height (fill |> minimum 100)
            , centerX
            , spacing 10
            ]
            [ el [ centerX ] (text <| Forecast.dayOfWeek forecast)
            , separator lightGrey
            , row [ width fill, centerY, Font.light, Font.size 18 ]
                [ image [ width fill ] { src = getWeatherIconURL <| Forecast.word forecast, description = "" }
                , column [ width fill ]
                    [ row [ width fill ]
                        [ thermostatImage [] { src = "dist/img/thermometer-hot.svg", description = "High Temperature" }
                        , el [ alignRight ] (text <| (String.fromFloat <| Forecast.high forecast) ++ displayDegrees)
                        ]
                    , row [ width fill ]
                        [ thermostatImage [] { src = "dist/img/thermometer-cold.svg", description = "Low Temperature" }
                        , el [ alignRight ] (text <| (String.fromFloat <| Forecast.low forecast) ++ displayDegrees)
                        ]
                    ]
                ]
            ]
        ]


versionView : String -> CurrentWeather -> Element msg
versionView app data =
    el [ centerX, Font.size 12, Font.italic, Font.color lightGrey, Font.extraLight ] (text <| "App " ++ app ++ "; API " ++ data.version)



-- HELPERS


displayDegrees : String
displayDegrees =
    String.fromChar (Char.fromCode 0xB0)
        ++ "C"


getTodaysForecast : List Forecast -> Maybe Forecast
getTodaysForecast forecasts =
    List.head forecasts


getTomorrowsForecast : List Forecast -> Maybe Forecast
getTomorrowsForecast forecasts =
    List.take 2 forecasts
        |> List.reverse
        |> List.head


getWeatherIconURL : String -> String
getWeatherIconURL desc =
    let
        weatherDict =
            Dict.fromList
                [ ( "Fine", "dist/img/weather-sunny.svg" )
                , ( "Cloudy", "dist/img/weather-cloudy.svg" )
                , ( "Drizzle", "dist/img/weather-rainy.svg" )
                , ( "Few showers", "dist/img/weather-rainy.svg" )
                , ( "Partly cloudy", "dist/img/weather-partly-cloudy.svg" )
                , ( "Rain", "dist/img/weather-pouring.svg" )
                , ( "Wind rain", "dist/img/weather-rainy.svg" )
                , ( "Showers", "dist/img/weather-rainy.svg" )
                ]
    in
    Dict.get desc weatherDict
        |> Maybe.withDefault "dist/img/error-icon.svg"


thermostatImage : List (Attribute msg) -> { src : String, description : String } -> Element msg
thermostatImage attrs { src, description } =
    image
        (alpha 0.7
            :: attrs
        )
        { src = src, description = description }


posixTimeToString : Posix -> Time.Zone -> String
posixTimeToString time zone =
    let
        hourStr =
            String.fromInt <| Time.toHour zone time

        minutes =
            Time.toMinute zone time

        minutesStr =
            if minutes < 10 then
                "0" ++ String.fromInt minutes

            else
                String.fromInt minutes
    in
    hourStr ++ ":" ++ minutesStr
