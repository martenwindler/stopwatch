module Example exposing (..)

import Expect
import Test exposing (..)
import Types exposing (RunningState(..))

suite : Test
suite =
    describe "Stopwatch Logic"
        [ test "Initial state should be Stopped" <|
            \_ ->
                let
                    initialState = Stopped
                in
                Expect.equal initialState Stopped
        ]