module Ui.System.Waypoint exposing (view)

import Html exposing (Html)
import Html.Attributes
import SpaceTrader.Point.Waypoint
import SpaceTrader.Ship
import SpaceTrader.System.Waypoint
import Ui
import Ui.Button
import Ui.Waypoint.Type


view :
    { myShips : List SpaceTrader.Ship.Ship
    , onCreateSurveyClicked : { waypointId : SpaceTrader.Point.Waypoint.Waypoint, shipId : String } -> msg
    }
    -> SpaceTrader.System.Waypoint.Waypoint
    -> Html msg
view opts waypoint =
    -- { symbol : String
    -- , type_ : SpaceTrader.Waypoint.Type.Type
    -- , x : Int
    -- , y : Int
    -- }
    Html.div
        [ Ui.grid
        , Html.Attributes.style "grid-template-columns" "12rem 1fr"
        ]
        [ waypoint.symbol
            |> SpaceTrader.Point.Waypoint.toShortLabel
            |> Html.text
        , Html.text ": "
        , Html.text <| Ui.Waypoint.Type.view waypoint.type_
        , Ui.Button.default [ Html.Attributes.style "width" "fit-content" ]
            { label = Html.text "Create survey"
            , onClick =
                let
                    shipsHere =
                        opts.myShips
                            |> List.filterMap
                                (\ship ->
                                    if ship.nav.waypoint == waypoint.symbol then
                                        Just ship

                                    else
                                        Nothing
                                )
                in
                case shipsHere of
                    [] ->
                        Nothing

                    ship :: _ ->
                        case ship.cooldown of
                            Nothing ->
                                opts.onCreateSurveyClicked
                                    { shipId = ship.id
                                    , waypointId = waypoint.symbol
                                    }
                                    |> Just

                            Just _ ->
                                Nothing
            }
        ]
