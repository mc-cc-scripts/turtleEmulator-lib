local pretty = {
    pretty_print = function (t)
        for k, v in pairs(t) do
            print(k, v)
        end
    end
}
return pretty