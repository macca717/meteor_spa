module Pages.Maps.Rain exposing (Model, Msg, Params, page)

import Api.Api exposing (RainMap, rainMaps)
import Browser.Dom
import Browser.Events
import Color exposing (lightGrey)
import Components.Card exposing (card, errorCard)
import Components.Common exposing (fixedRatioImage)
import Components.Separator exposing (separator)
import Element exposing (Element, centerX, centerY, column, el, fill, height, htmlAttribute, image, px, spacing, text, width)
import Element.Font as Font
import Errors exposing (httpErrorToString)
import Html.Attributes
import RemoteData exposing (WebData)
import Shared
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)
import Task


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
    ( { model | device = shared.device }
    , Cmd.none
    )


save : Model -> Shared.Model -> Shared.Model
save model shared =
    shared



-- INIT


type alias Params =
    ()


type alias Model =
    { data : WebData (List RainMap)
    , device : Element.Device
    , imageSize : ImageDimensions
    }


type alias ImageDimensions =
    { width : Float
    , height : Float
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { data = RemoteData.Loading
      , device = shared.device
      , imageSize = { width = 0, height = 0 }
      }
    , Cmd.batch
        [ rainMaps { onResponse = GotRainMapData }
        , Task.attempt GotImageElement (Browser.Dom.getElement "rain-img-1")
        ]
    )



-- UPDATE


type Msg
    = GotRainMapData (WebData (List RainMap))
    | GotImageElement (Result Browser.Dom.Error Browser.Dom.Element)
    | Resize


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotRainMapData response ->
            ( { model | data = response }, Cmd.none )

        GotImageElement result ->
            case result of
                Ok el ->
                    ( { model | imageSize = { width = el.element.width, height = el.element.height } }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        Resize ->
            ( model, Task.attempt GotImageElement (Browser.Dom.getElement "rain-img-1") )


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize (\_ _ -> Resize)



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Maps.Rain"
    , body =
        case model.data of
            RemoteData.NotAsked ->
                [ el [] (text "Not Asked") ]

            RemoteData.Loading ->
                [ loadImageTemplateView model.imageSize ]

            RemoteData.Success data ->
                [ loadedMapsView model.imageSize data ]

            RemoteData.Failure err ->
                [ errorCard <| httpErrorToString err ]
    }


loadImageTemplateView : ImageDimensions -> Element msg
loadImageTemplateView imageSize =
    card <|
        [ column [ width fill, spacing 20 ] <|
            el [ Font.size 18 ] (text "Rain Maps")
                :: List.indexedMap
                    (\i _ ->
                        column [ width fill, spacing 20 ]
                            [ separator lightGrey
                            , el [ Font.light ] (text "")
                            , fixedRatioImage
                                [ centerX, centerY, width fill, htmlAttribute <| Html.Attributes.id <| "rain-img-" ++ String.fromInt i ]
                                { src = "/dist/img/tail-spin.svg", description = "Rain map", width = imageSize.width, ratio = 0.772 }
                            ]
                    )
                    (List.range 1 9)
        ]


loadedMapsView : ImageDimensions -> List RainMap -> Element msg
loadedMapsView imageSize maps =
    card <|
        [ column [ width fill, spacing 20 ] <|
            el [ Font.size 18 ] (text "Rain Maps")
                :: List.indexedMap
                    (\i map ->
                        column [ width fill, spacing 20 ]
                            [ separator lightGrey
                            , el [ Font.light ] (text map.validFromTime)
                            , fixedRatioImage
                                [ centerX, width fill, htmlAttribute <| Html.Attributes.id <| "rain-img-" ++ String.fromInt i ]
                                { src = map.url, description = "Rain map", width = imageSize.width, ratio = 0.772 }
                            ]
                    )
                    maps
        ]
