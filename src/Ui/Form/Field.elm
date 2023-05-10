module Ui.Form.Field exposing (..)

import Form
import Form.FieldView
import Form.Validation
import Html exposing (Html)
import Html.Attributes


errorsView : Form.Context String input -> Form.Validation.Field String parsed kind -> Html msg
errorsView { submitAttempted, errors } field =
    if submitAttempted || Form.Validation.statusAtLeast Form.Validation.Blurred field then
        errors
            |> Form.errorsForField field
            |> List.head
            |> Maybe.map
                (\error ->
                    Html.span
                        [ Html.Attributes.style "color" "red"
                        , Html.Attributes.style "grid-column" "2"
                        ]
                        [ Html.text error ]
                )
            |> Maybe.withDefault (Html.text "")

    else
        Html.text ""


text : Form.Context String input -> String -> Form.Validation.Field String parsed Form.FieldView.Input -> List (Html msg)
text formState label field =
    [ Html.label
        [ Html.Attributes.style "grid-column" "1" ]
        [ Html.text label ]
    , Form.FieldView.input
        [ Html.Attributes.style "grid-column" "2" ]
        field
    , errorsView formState field
    ]


select :
    { toString : parsed -> String }
    -> Form.Context String input
    -> String
    -> Form.Validation.Field String parsed (Form.FieldView.Options parsed)
    -> List (Html msg)
select options formState label field =
    [ Html.label
        [ Html.Attributes.style "grid-column" "1" ]
        [ Html.text label ]
    , Form.FieldView.select
        [ Html.Attributes.style "grid-column" "2" ]
        (\item -> ( [], options.toString item ))
        field
    , errorsView formState field
    ]


submit : { label : String, disabled : Bool } -> List (Html msg)
submit { label, disabled } =
    [ Html.button
        [ Html.Attributes.style "grid-column" "2"
        , Html.Attributes.style "cursor" "pointer"
        , Html.Attributes.disabled disabled
        ]
        [ Html.text label ]
    ]
