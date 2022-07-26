module Example exposing (..)

-- import Fuzz exposing (Fuzzer, int, list, string)

import Expect
import Test exposing (..)


suite : Test
suite =
    test "Example Test"
        (\_ -> Expect.equal 2 2)
