module [
    clamp,
    digits,
    undigits,
]

import BoolUtils

## `clamp num { min, max }` returns `min` if `num` is smaller than `min` and
## `max` if `num` is greater than `max`. If `num` is in between `min` and
## `max`, `num` is returned.
##
## This function uses `expect` to check that `min` is smaller than or equal to
## `max`. This can be used in tests to check for proper usage.
##
## ## Tags
## * stdplz
clamp : Num a, { min : Num a, max : Num a } -> Num a
clamp = \num, { min, max } ->
    expect
        min <= max

    if num <= min then
        min
    else if num >= max then
        max
    else
        num

expect clamp 0 { min: -1, max: 1 } == 0
expect clamp -2 { min: -1, max: 1 } == -1
expect clamp 2 { min: -1, max: 1 } == 1

## `digits num base` splits `num` into its digit representation in `base`.
digits : Int a, Int a -> Result (List (Int a)) [InvalidBase, Negative]
digits = \num, base ->
    {} <- BoolUtils.guard (num < 0) (Err Negative)
    {} <- BoolUtils.guard (base < 2) (Err InvalidBase)
    helper = \x, acc ->
        if Num.abs x < base then
            List.reverse (List.append acc x)
        else
            helper (x // base) (List.append acc (x % base))
    Ok (helper num [])

expect digits 0 10 == Ok [0]
expect digits 123 10 == Ok [1, 2, 3]
expect digits 123 2 == Ok [1, 1, 1, 1, 0, 1, 1]
expect digits 123 1 == Err InvalidBase
expect digits -123 10 == Err Negative

undigits : List (Int a), Int a -> Result (Int a) [InvalidBase, Negative]
undigits = \digitList, base ->
    {} <- BoolUtils.guard (base < 2) (Err InvalidBase)
    digitList
    |> List.walkTry 0 \acc, digit ->
        {} <- BoolUtils.guard (digit < 0) (Err Negative)
        Ok (acc * base + digit)

expect undigits [] 10 == Ok 0
expect undigits [1, 2, 3] 10 == Ok 123
expect undigits [1, 1, 1, 1, 0, 1, 1] 2 == Ok 123
expect undigits [] 1 == Err InvalidBase
expect undigits [1, -1] 10 == Err Negative

