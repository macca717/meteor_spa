module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

-- import Components.Footer as Footer

import Browser.Events as Events
import Browser.Navigation exposing (Key)
import Element exposing (..)
import Json.Decode as Decode
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Task
import Time
import Url exposing (Url)



-- INIT


type alias Flags =
    { width : Int
    , height : Int
    }


type alias Model =
    { url : Url
    , key : Key
    , device : Device
    , timeZone : Time.Zone
    }


init : Decode.Value -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        decoded =
            Decode.decodeValue flagsDecoder flags
                |> Result.withDefault (Flags 800 600)
    in
    ( { url = url
      , key = key
      , device = classifyDevice { height = decoded.height, width = decoded.width }
      , timeZone = Time.utc
      }
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Resize Int Int
    | AdjustTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resize width height ->
            let
                updated =
                    classifyDevice { width = width, height = height }
            in
            ( { model | device = updated }, Cmd.none )

        AdjustTimeZone newZone ->
            ( { model | timeZone = newZone }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Events.onResize (\width height -> Resize width height) ]



-- VIEW


view :
    { page : Document msg, toMsg : Msg -> msg }
    -> Model
    -> Document msg
view { page, toMsg } model =
    { title = page.title
    , body =
        [ column
            [ paddingEach
                { top = 20
                , right = 10
                , bottom = 100
                , left = 10
                }
            , spacing 20
            , width (fill |> maximum 500)
            , height fill
            , centerX
            ]
            [ column [ height fill, width fill ] page.body
            ]
        ]
    }



-- DECODERS


flagsDecoder : Decode.Decoder Flags
flagsDecoder =
    Decode.map2 Flags
        (Decode.field "width" Decode.int)
        (Decode.field "height" Decode.int)
