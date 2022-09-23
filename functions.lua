local function findPer(pName)
    if (peripheral.getName) then
        local p = peripheral.find(pName)
        local n

        if (p) then
            n = peripheral.getName(p)
        end
        return n, p
    else
        local d = { "top", "bottom", "right", "left", "front", "back" }
        for i = 1, #d do
            if (peripheral.getType(d[i]) == pName) then
                local p = peripheral.wrap(d[i])
                local n = d[i]
                return n, p
            end
        end
    end
end

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
