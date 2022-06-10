module Utils.Time exposing
    ( format
    , fromSecondsToPosix
    , relativeFormat
    )

import DateFormat
import DateFormat.Relative
import Time


format : Time.Zone -> Time.Posix -> String
format zone posix =
    DateFormat.format
        [ DateFormat.monthNameFull
        , DateFormat.text " "
        , DateFormat.dayOfMonthSuffix
        , DateFormat.text ", "
        , DateFormat.yearNumber
        , DateFormat.text " at "
        , DateFormat.hourNumber
        , DateFormat.text ":"
        , DateFormat.minuteFixed
        , DateFormat.amPmLowercase
        ]
        zone
        posix


relativeFormat : Time.Posix -> Time.Posix -> String
relativeFormat now posix =
    DateFormat.Relative.relativeTime now posix


fromSecondsToPosix : Int -> Time.Posix
fromSecondsToPosix numberOfSeconds =
    Time.millisToPosix (numberOfSeconds * 1000)
