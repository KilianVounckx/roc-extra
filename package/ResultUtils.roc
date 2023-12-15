interface ResultUtils
    exposes [
        okOrCrash,
        okOrCrashWithMessage,
    ]
    imports []

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
    when result is
        Ok x -> x
        Err err -> crash (msg err)

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
