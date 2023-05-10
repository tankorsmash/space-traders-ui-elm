module Ui exposing (..)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Time


column : List (Html.Attribute msg) -> List (Html msg) -> Html msg
column attrs =
    Html.div
        (attrs
            ++ [ Html.Attributes.style "display" "grid"
               , Html.Attributes.style "grid-template-columns" "1fr"
               ]
        )


width : { fill : Html.Attribute msg }
width =
    { fill = Html.Attributes.style "width" "100%"
    }


center : { justify : Html.Attribute msg, align : Html.Attribute msg }
center =
    { justify = Html.Attributes.style "justify-content" "center"
    , align = Html.Attributes.style "align-items" "center"
    }


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


viewLabelGroup : String -> List { label : String, value : String } -> Html msg
viewLabelGroup title children =
    Html.div
        [ Html.Attributes.style "display" "grid"
        , Html.Attributes.style "grid-template-columns" "1fr 1fr"
        ]
        (Html.h3 [] [ Html.text title ]
            :: List.concatMap viewLabeled children
        )


viewLabeled : { label : String, value : String } -> List (Html msg)
viewLabeled options =
    [ Html.span
        [ Html.Attributes.style "grid-column" "1"
        , Html.Attributes.style "font-weight" "bold"
        , Html.Attributes.style "padding" "0.5rem "
        , Html.Attributes.style "border" "1px solid black"
        , Html.Attributes.style "margin-bottom" "0.5rem"
        , Html.Attributes.style "border-top-left-radius" "0.25rem"
        , Html.Attributes.style "border-bottom-left-radius" "0.25rem"
        , Html.Attributes.style "background" "lightgray"
        , Html.Attributes.style "border-right" "none"
        ]
        [ Html.text options.label ]
    , Html.span
        [ Html.Attributes.style "grid-column" "2"
        , Html.Attributes.style "padding" "0.5rem"
        , Html.Attributes.style "border" "1px solid black"
        , Html.Attributes.style "margin-bottom" "0.5rem"
        , Html.Attributes.style "border-top-right-radius" "0.25rem"
        , Html.Attributes.style "border-bottom-right-radius" "0.25rem"
        , Html.Attributes.style "border-left" "none"
        ]
        [ Html.text options.value ]
    ]
