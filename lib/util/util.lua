local util = {}

function util.split(str, sep, stop_at_first)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(str, pattern, function(c) fields[#fields+1] = c end)
    if stop_at_first and #fields > 1 then
        local s = fields[1]..sep
        fields = {fields[1], str:sub(s:len()+1,str:len())}
    end
    return fields
end

return util
