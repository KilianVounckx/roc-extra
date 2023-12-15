interface ResultUtils
    exposes [
        okOrCrash,
        okOrCrashWithMessage,
    ]
    imports []

okOrCrashWithMessage : Result a err, (err -> Str) -> a
okOrCrashWithMessage = \result, msg ->
    when result is
        Ok x -> x
        Err err -> crash (msg err)

okOrCrash : Result a err -> a where err implements Inspect
okOrCrash = \result ->
    okOrCrashWithMessage result Inspect.toStr
