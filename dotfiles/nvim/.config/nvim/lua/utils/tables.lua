local tables = {}

-- Functions

-- Merge a list of array outputs into a single one.
--
-- Compute the list returned by callback for each element and return a single
-- array accumulating the content of each list.
--
-- @generic TIn, TOut
-- @param array TIn[] A list of elements
-- @param callback fun(item: TIn): TOut[] A function which returns a list of
--                                        elements given an input element from
--                                        the array
-- @return TOut[] A one-dimensional array
function tables.accumulate(array, callback)
    local all_results = {}

    for i = 1, #array do
        all_results = tables.merge(all_results, callback(array[i]))
    end

    return all_results
end

-- Return all the distinct values from the array.
-- @generic T
-- @param array T[] A list of elements
-- @return T[] A list of unique elements
function tables.distinct(array)
    results = {}
    seen = {}

    for _, item in ipairs(array) do
        if not seen[item] then
            seen[item] = true
            table.insert(results, item)
        end
    end

    return results
end

-- Return a view of the array with only the elements that match the predicate.
-- @generic T
-- @param array T[] A list of elements
-- @param callback fun(item: T): boolean A predicate that can be applied to all
--                                       the elements of the list
-- @param T[] A new list containing a copy of only the elements that 
function tables.filter(array, callback)
    local results = {}

    for _, item in ipairs(array) do
        if callback(item) then
            table.insert(results, item)
        end
    end

    return results
end

-- Apply a callback to all the elements of an array without returning anything.
-- @generic T
-- @param array T[] The array containing the elements
-- @param callback fun(item: T) A function to apply on each element
function tables.foreach(array, callback)
    for i = 1, #array do
        callback(array[i])
    end
end


-- Apply a callback to all the elements of an array and return the results.
-- @generic TIn, TOut
-- @param array TIn[] The array containing the elements
-- @param callback fun(item: TIn): TOut A function to apply on each element
-- @return TOut[] A new array containing the result of each element into callback.
function tables.map(array, callback)
    local results = {}

    for i = 1, #array do
        table.insert(results, callback(array[i]))
    end

    return results
end

-- Return a new list containing the sum of the lists on left and right.
-- @generic TL, TR
-- @param left TL[] A first list
-- @param right TR[] A second list
-- @return TL|TR[] A new list containing the items from both lists.
function tables.merge(left, right)
    local list = {}

    for i = 1, #left do
        table.insert(list, left[i])
    end

    for i = 1, #right do
        table.insert(list, right[i])
    end

    return list
end

-- Apply a list of callbacks to the same list successively.
-- @generic T
-- @param array T[] A list of elements
-- @param callbacks fun(item: any): any A list of callbacks
-- @return any The state of array after going through the last callback
function tables.pipeline(array, callbacks)
    local state = array

    for i = 1, #callbacks do
        state = callbacks[i](state)
    end

    return state
end


return tables
