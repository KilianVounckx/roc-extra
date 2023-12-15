interface ListUtils
    exposes [
        mapAdjacent,
    ]
    imports []

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
