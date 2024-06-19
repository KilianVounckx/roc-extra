module [
    clamp,
]

## `clamp num { min, max }` returns `min` if `num` is smaller than `min` and
## `max` if `num` is greater than `max`. If `num` is in between `min` and
## `max`, `num` is returned.
##
## This function uses `expect` to check that `min` is smaller than or equal to
## `max`. This can be used in tests to check for proper usage.
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

expect
    clamp 0 { min: -1, max: 1 } == 0

expect
    clamp -2 { min: -1, max: 1 } == -1

expect
    clamp 2 { min: -1, max: 1 } == 1
