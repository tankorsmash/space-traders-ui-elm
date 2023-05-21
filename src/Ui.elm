module Ui exposing (..)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode
import List.NonEmpty
import Route exposing (Route)
import Time


column : List (Html.Attribute msg) -> List (Html msg) -> Html msg
column attrs =
    Html.div
        (attrs
            ++ [ Html.Attributes.style "display" "grid"
               , Html.Attributes.style "align-items" "start"
               ]
        )


row : List (Html.Attribute msg) -> List (Html msg) -> Html msg
row attrs =
    Html.div
        (attrs
            ++ [ Html.Attributes.style "display" "grid"
               , Html.Attributes.style "grid-auto-flow" "column"
               ]
        )


grid : Html.Attribute msg
grid =
    Html.Attributes.style "display" "grid"



-- width : { fill : Html.Attribute msg }
-- width =
--     { fill = Html.Attributes.style "width" "100%"
--     }


justify : { center : Html.Attribute msg, start : Html.Attribute msg, end : Html.Attribute msg }
justify =
    { center = Html.Attributes.style "justify-self" "center"
    , start = Html.Attributes.style "justify-self" "start"
    , end = Html.Attributes.style "justify-self" "end"
    }


align : { center : Html.Attribute msg, start : Html.Attribute msg, end : Html.Attribute msg }
align =
    { center = Html.Attributes.style "align-self" "center"
    , start = Html.Attributes.style "align-self" "start"
    , end = Html.Attributes.style "align-self" "end"
    }


gap : Float -> Html.Attribute msg
gap f =
    Html.Attributes.style "gap" (String.fromFloat f ++ "rem")


dateTime : Time.Zone -> Time.Posix -> String
dateTime timeZone time =
    let
        year =
            time
                |> Time.toYear timeZone
                |> String.fromInt

        month =
            time
                |> Time.toMonth timeZone
                |> monthToString

        day =
            time
                |> Time.toDay timeZone
                |> String.fromInt

        hour =
            time
                |> Time.toHour timeZone
                |> String.fromInt

        minute =
            time
                |> Time.toMinute timeZone
                |> String.fromInt
                |> String.padLeft 2 '0'

        second =
            time
                |> Time.toSecond timeZone
                |> String.fromInt
                |> String.padLeft 2 '0'
    in
    year ++ " " ++ month ++ " " ++ day ++ " @ " ++ hour ++ ":" ++ minute ++ ":" ++ second


monthToString : Time.Month -> String
monthToString month =
    case month of
        Time.Jan ->
            "January"

        Time.Feb ->
            "February"

        Time.Mar ->
            "March"

        Time.Apr ->
            "April"

        Time.May ->
            "May"

        Time.Jun ->
            "June"

        Time.Jul ->
            "July"

        Time.Aug ->
            "August"

        Time.Sep ->
            "September"

        Time.Oct ->
            "October"

        Time.Nov ->
            "November"

        Time.Dec ->
            "December"


viewLabelGroup : Html msg -> List { label : String, value : Html msg } -> Html msg
viewLabelGroup title children =
    Html.div
        [ Html.Attributes.style "display" "grid"
        , Html.Attributes.style "grid-template-columns" "1fr 1fr"
        ]
        (Html.h3 [ Html.Attributes.style "column" "1 / 3" ] [ title ]
            :: List.concatMap viewLabeled children
        )


viewLabeled : { label : String, value : Html msg } -> List (Html msg)
viewLabeled options =
    [ Html.span
        [ Html.Attributes.style "grid-column" "1"
        , Html.Attributes.style "font-weight" "bold"
        , Html.Attributes.style "padding" "0.5rem "
        , Html.Attributes.style "border-width" "1px "
        , Html.Attributes.style "margin-bottom" "0.5rem"
        , Html.Attributes.style "border-top-left-radius" "0.25rem"
        , Html.Attributes.style "border-bottom-left-radius" "0.25rem"
        , Html.Attributes.style "background" "var(--primary-color)"
        , Html.Attributes.style "color" "var(--secondary-color)"
        , Html.Attributes.style "border-right" "none"
        ]
        [ Html.text options.label ]
    , Html.span
        [ Html.Attributes.style "grid-column" "2"
        , Html.Attributes.style "padding" "0.5rem"
        , Html.Attributes.style "border" "1px solid"
        , Html.Attributes.style "margin-bottom" "0.5rem"
        , Html.Attributes.style "border-top-right-radius" "0.25rem"
        , Html.Attributes.style "border-bottom-right-radius" "0.25rem"
        , Html.Attributes.style "border-left" "none"
        ]
        [ options.value ]
    ]


header :
    { one : List (Html.Attribute msg) -> List (Html msg) -> Html msg
    , two : List (Html.Attribute msg) -> List (Html msg) -> Html msg
    , three : List (Html.Attribute msg) -> List (Html msg) -> Html msg
    , four : List (Html.Attribute msg) -> List (Html msg) -> Html msg
    }
header =
    { one = \attr -> Html.h1 ([ Html.Attributes.style "margin" "0" ] ++ attr)
    , two = \attr -> Html.h2 ([ Html.Attributes.style "margin" "0" ] ++ attr)
    , three = \attr -> Html.h3 ([ Html.Attributes.style "margin" "0" ] ++ attr)
    , four = \attr -> Html.h4 ([ Html.Attributes.style "margin" "0" ] ++ attr)
    }


progress : List (Html.Attribute msg) -> { max : Float, current : Float } -> Html msg
progress attr opt =
    Html.div
        [ Html.Attributes.style "width" "100%"
        , Html.Attributes.style "height" "1.5rem"
        , Html.Attributes.style "border" "0.125rem solid"
        ]
        [ Html.div
            [ Html.Attributes.style "width" (String.fromFloat (opt.current / opt.max * 100) ++ "%")
            , Html.Attributes.style "height" "100%"
            , Html.Attributes.style "background-color" "var(--blue-dark)"
            ]
            []
        ]


link : List (Html.Attribute msg) -> { label : Html msg, route : Route } -> Html msg
link attr opts =
    Html.a
        ([ Html.Attributes.href (Route.toUrlString opts.route)
         , Html.Attributes.style "color" "var(--blue-light)"
         ]
            ++ attr
        )
        [ opts.label ]
