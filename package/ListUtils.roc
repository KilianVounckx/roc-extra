module [
    minMax,
    mapAdjacent,
    build,
    compare,
]

import Utils

## `minMax list` returns a record containing both the minimum and maximum of a list
##
## ## Tags
## * stdplz
minMax : List (Num a) -> Result { min : Num a, max : Num a } [ListWasEmpty]
minMax = \list ->
    when list is
        [] -> Err ListWasEmpty
        [first, .. as rest] ->
            rest
            |> List.walk { min: first, max: first } \acc, x ->
                if x < acc.min then
                    { acc & min: x }
                else if x > acc.max then
                    { acc & max: x }
                else
                    acc
            |> Ok

## `mapAdjacent list func` takes any two adjacent pairs in `list`, applies
## `func` to them, and stores the results in a new list.
##
## The resulting list's length is always one smaller than the input list's
## length. Only if the input list is empty, the result is still empty.
##
## ## Examples
## ```
## expect ListUtils.mapAdjacent [1, 2, 3, 4, 5] Num.add == [3, 5, 7, 9]
## ```
## ```
## expect ListUtils.mapAdjacent [1] Num.add == []
## ```
## ```
## expect ListUtils.mapAdjacent [] Num.add == []
## ```
mapAdjacent : List a, (a, a -> b) -> List b
mapAdjacent = \list, func ->
    List.map2 list (List.dropFirst list 1) func

expect mapAdjacent [1, 2, 3, 4, 5] Num.add == [3, 5, 7, 9]
expect mapAdjacent [1] Num.add == []
expect mapAdjacent [] Num.add == []

## `build init step` builds a list based on some updating state. The state
## starts at `init`. `step` updates the state. If it has tag `Continue`, it
## will update the state and append the output to the list. If it has tag
## `Break`, the list will be returned.
##
## ## Examples
## ```
## fibs : U32 -> List U32
## fibs = \n ->
##     ListUtils.build (0, 1, n) \(a, b, left) ->
##         if left == 0 then
##             Break
##         else
##             Continue { state: (b, a + b, left - 1), value: a }
## ```
build : state, (state -> [Continue { state : state, value : value }, Break]) -> List value
build = \init, step ->
    Utils.loop ([], init) \(acc, state) ->
        when step state is
            Continue { state: next, value } -> Continue (List.append acc value, next)
            Break -> Break acc

expect
    fibs : U32 -> List U32
    fibs = \n ->
        ListUtils.build (0, 1, n) \(a, b, left) ->
            if left == 0 then
                Break
            else
                Continue { state: (b, a + b, left - 1), value: a }

    fibs 10 == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

## `compare fun` takes a comparison function for some type, and returns a
## lexicographical comparison function for a list containing that type.
## The resulting function can be used in [List.sortWith].
##
## ## Tags
## * stdplz
compare : (a, a -> [LT, EQ, GT]) -> (List a, List a -> [LT, EQ, GT])
compare = \fun ->
    \list1, list2 ->
        List.map2 list1 list2 \x1, x2 -> (x1, x2)
        |> List.walkUntil EQ \_, (x1, x2) ->
            when fun x1 x2 is
                LT -> Break LT
                GT -> Break GT
                EQ -> Continue EQ

expect
    fun = compare Num.compare
    unsorted = [[3, 2, 3], [3, 3], [4, 3], [2, 5], [2, 4], [1, 2]]
    expected = [[1, 2], [2, 4], [2, 5], [3, 2, 3], [3, 3], [4, 3]]
    got = List.sortWith unsorted fun
    got == expected
