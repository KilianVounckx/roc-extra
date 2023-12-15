interface StrUtils
    exposes [
        hexEncode,
        hexDecode,
    ]
    imports [
        ResultUtils,
    ]

## `hexEncode bytes` returns the hex encoding of `bytes`.
##
## ## Examples
## ```
## expect hexEncode [0xde, 0xad, 0xbe, 0xaf] == "deadbeaf"
## expect hexEncode [] == ""
## ```
hexEncode : List U8 -> Str
hexEncode = \bytes ->
    bytes
    |> List.joinMap byteToHex
    |> Str.fromUtf8
    |> ResultUtils.okOrCrash

expect hexEncode [0xde, 0xad, 0xbe, 0xaf] == "deadbeaf"
expect hexEncode [] == ""

byteToHex : U8 -> List U8
byteToHex = \c ->
    [c // 16, c % 16]
    |> List.map \p ->
        if p < 10 then
            p + '0'
        else
            p - 10 + 'a'

## `hexDecode hex` returns the decoding of `hex` which is hex encoded.
##
## If `hex` is not properly encoded, `hexDecode` will return `Err InvalidHex`
##
## ## Examples
## ```
## expect hexEncode [0xde, 0xad, 0xbe, 0xaf] == "deadbeaf"
## expect hexEncode [] == ""
## ```
hexDecode : Str -> Result (List U8) [InvalidHex]
hexDecode = \hex ->
    hex
    |> Str.toUtf8
    |> List.chunksOf 2
    |> List.mapTry hexToByte

expect hexDecode "deadbeaf" == Ok [0xde, 0xad, 0xbe, 0xaf]
expect hexDecode "" == Ok []
expect hexDecode "Hello, World" == Err InvalidHex

hexToByte : List U8 -> Result U8 [InvalidHex]
hexToByte = \hex ->
    when hex is
        [p1, p2] ->
            p1
            |> hexPartToU8
            |> Result.try \c1 ->
                p2
                |> hexPartToU8
                |> Result.map \c2 ->
                    c1 * 16 + c2

        _ -> crash "unreachable hexToByte"

hexPartToU8 : U8 -> Result U8 [InvalidHex]
hexPartToU8 = \p ->
    if '0' <= p && p <= '9' then
        Ok (p - '0')
    else if 'a' <= p && p <= 'f' then
        Ok (p - 'a' + 10)
    else if 'A' <= p && p <= 'F' then
        Ok (p - 'A' + 10)
    else
        Err InvalidHex
