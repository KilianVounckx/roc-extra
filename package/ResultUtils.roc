module [
    okOrCrash,
    okOrCrashWithMessage,
    withLazyDefault,
]

## `okOrCrash err` takes a result and returns its `Ok` value.
## If the result contains an `Err` value, crashes with its Inspect string.
##
## If you want more control over the crash message, see [okOrCrashWithMessage]
okOrCrash : Result a err -> a where err implements Inspect
okOrCrash = \result ->
    okOrCrashWithMessage result Inspect.toStr

expect
    result : Result U32 []
    result = Ok 42
    okOrCrash result == 42
expect
    result : Result {} [NeverUsed]
    result = Ok {}
    okOrCrash result == {}
expect
    result : Result Str [SomeError]
    result = Ok "hi"
    okOrCrash result == "hi"

## `okOrCrashWithMessage result msg` takes a result and returns its `Ok` value.
## If the result contains an `Err`, calls `msg` on its payload and crashes with
## the resulting string as a message
okOrCrashWithMessage : Result a err, (err -> Str) -> a
okOrCrashWithMessage = \result, msg ->
    withLazyDefault result (\err -> crash (msg err))

expect
    result : Result U32 []
    result = Ok 42
    okOrCrashWithMessage result (\_ -> "crashed") == 42

expect
    result : Result {} [NeverUsed]
    result = Ok {}

    msg : [NeverUsed] -> Str
    msg = \err ->
        when err is
            NeverUsed -> "never used"

    okOrCrashWithMessage result msg == {}

expect
    result : Result Str [SomeError]
    result = Ok "hi"
    okOrCrashWithMessage result Inspect.toStr == "hi"

## `withLazyDefault result err` takes a result and returns its `Ok` value.
## If the result contains an `Err`, calls `fun` on its payload and returns
## its output.
withLazyDefault : Result a err, (err -> a) -> a
withLazyDefault = \result, fun ->
    when result is
        Ok x -> x
        Err err -> fun err

expect
    result : Result U32 []
    result = Ok 42
    withLazyDefault result (\_ -> 50) == 42

expect
    result : Result U32 [NeverUsed]
    result = Err NeverUsed
    withLazyDefault result (\_ -> 50) == 50

expect
    result : Result U32 [This, That]
    result = Err This
    (
        withLazyDefault
            result
            (\err ->
                when err is
                    This -> 50
                    That -> 60
            )
    )
    == 50
