module [
    guard,
    lazyGuard,
]

## `guard condition return otherwise` is a convenience function to mimic
## early returns. It is designed to be used with backpassing syntax.
## Note that the `return` value is always evaluated. If it is expensive to
## compute, try [lazyGuard].
##
## ## Tags
## * stdplz
guard : Bool, a, ({} -> a) -> a
guard = \condition, return, otherwise ->
    if condition then
        return
    else
        otherwise {}

expect
    result =
        {} <- guard Bool.true 42
        50
    result == 42

expect
    result =
        {} <- guard Bool.false 42
        50
    result == 50

## `guard condition return otherwise` is a convenience function to mimic
## early returns. It is designed to be used with backpassing syntax.
##
## ## Tags
## * stdplz
lazyGuard : Bool, ({} -> a), ({} -> a) -> a
lazyGuard = \condition, return, otherwise ->
    if condition then
        return {}
    else
        otherwise {}

expect
    result =
        {} <- lazyGuard Bool.true \{} -> 42
        50
    result == 42

expect
    result =
        {} <- lazyGuard Bool.false \{} -> 42
        50
    result == 50
