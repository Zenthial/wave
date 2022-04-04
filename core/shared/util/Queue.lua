local Queue = {}

function Queue.new()
    return {first = 0, last = -1, size = 0}
end

function Queue.pushFront(list, value)
    local first = list.first - 1
    list.first = first
    list[first] = value
end
  
function Queue.push(list, value)
    local last = list.last + 1
    list.last = last
    list[last] = value
    list.size += 1
end
  
function Queue.pop(list)
    local first = list.first
    if first > list.last then error("list is empty") end
    local value = list[first]
    list[first] = nil        -- to allow garbage collection
    list.first = first + 1
    list.size -= 1
    return value
end
  
function Queue.popBack(list)
    local last = list.last
    if list.first > last then error("list is empty") end
    local value = list[last]
    list[last] = nil         -- to allow garbage collection
    list.last = last - 1
    return value
end

return Queue