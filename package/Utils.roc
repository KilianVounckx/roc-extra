module [
    loop,
]

## `loop init func` repeatedly applies `func` to init. Whenever the output has
## tag `Continue`, its payload is `func`'s next input. When the output first
## has tag `Break`, its payload is `loop`'s output.
##
## This function can be used to make a common pattern simpler. Often you
## need to do something until some condition is met, based on some
## intermediate state. This is different from functions like [List.walk],
## where the condition is always to be at the end of the list. For these
## kind of situations, you need a function which calls itself recursively.
## Sometimes this feels like overkill, so in these situations `loop` can help.
##
## This function can also be thought of as the functional equivalent of
## an imperative 'while' loop, whereas functions like [List.map] and [List.walk]
## are equivalent to imperative `for` loops.
##
## ## Examples
##
## Consider the following function to calculate the n'th Fibonacci number:
## ```
## fib : U32 -> U32
## fib = \n ->
##     helper : U32, U32, U32 -> U32
##     helper = \a, b, left ->
##         if left == 0 then
##             a
##         else
##             helper b (a + b) (left - 1)
##
##     helper 0 1 n
## ```
## This helper feels too much for such a simple function. With `loop` it
## becomes:
## ```
## fib : U32 -> U32
## fib = \n ->
##     Utils.loop (0, 1, n) \(a, b, left) ->
##         if left == 0 then
##             Break a
##         else
##             Continue (b, a + b, left - 1)
## ```
loop : state, (state -> [Continue state, Break output]) -> output
loop = \init, step ->
    when step init is
        Break output -> output
        Continue next -> loop next step

expect
    fib : U32 -> U32
    fib = \n ->
        loop (0, 1, n) \(a, b, left) ->
            if left == 0 then
                Break a
            else
                Continue (b, a + b, left - 1)

    f = fib 10
    f == 55
