module RemoteData exposing
    ( RemoteData(..)
    , fromResult
    , toMaybe
    )


type RemoteData a
    = Loading
    | Failure String
    | Loaded a


fromResult : Result String a -> RemoteData a
fromResult result =
    case result of
        Ok a ->
            Loaded a

        Err e ->
            Failure e


toMaybe : RemoteData a -> Maybe a
toMaybe remoteData =
    case remoteData of
        Loaded a ->
            Just a

        _ ->
            Nothing
