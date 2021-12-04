print(string.format("[LOAF HOUSING WIPE]: Make sure to back up your database before using this resource.\nCommands:\n  * housing_wipe [what to wipe]"))

function Wipe(key, value, cb)
    MySQL.Async.fetchAll("SELECT `identifier`, `housedata` FROM `loaf_housing`", {}, function(result)
        if not result or #result <= 0 then return end

        for _, data in pairs(result) do
            local identifier = data.identifier
            local data = data.housedata
            if type(data) == "string" and json.decode(data) then
                data = json.decode(data)
                for houseid, housedata in pairs(data) do
                    for _, furnitureData in pairs(housedata.furniture) do
                        if furnitureData.storage and furnitureData.storage[key] then
                            furnitureData.storage[key] = value
                        end
                    end
                end

                MySQL.Sync.execute("UPDATE `loaf_housing` SET `housedata`=@housedata WHERE `identifier`=@identifier", {
                    ["@housedata"] = json.encode(data),
                    ["@identifier"] = identifier
                })
            end
        end

        if cb then cb() end
    end)
end

function WipeWeapons()
    print(string.format("\n^1Removing^0 all ^6weapons^0..."))
    Wipe("weapons", {}, function()
        print("^2Done^0 wiping all ^6weapons^0")
    end)
end

function WipeItems()
    print(string.format("\n^1Removing^0 all ^5items^0..."))
    Wipe("items", {}, function()
        print("^2Done^0 wiping all ^5items^0")
    end)
end

function WipeCash()
    print(string.format("\n^1Removing^0 all ^2cash^0..."))
    Wipe("cash", 0, function()
        print("^2Done^0 wiping all ^2cash^0")
    end)
end

function WipeBlack()
    print(string.format("\n^1Removing^0 all ^1black money^0..."))
    Wipe("black_money", 0, function()
        print("^2Done^0 wiping all ^1black money^0")
    end)
end

local wipeMethods = {
    ["weapons"] = WipeWeapons,
    ["items"] = WipeItems,
    ["cash"] = WipeCash,
    ["black"] = WipeBlack
}
RegisterCommand("housing_wipe", function(src, args)
    if src ~= 0 then return print("^1This command can only be run via the console.") end
    local toWipe = args[1]
    if not toWipe then return print("You must enter what to wipe.\nUsage: housing_wipe [What to wipe]") end
    if not wipeMethods[toWipe] then
        print("Invalid wipe method \""..toWipe.."\"")
        print("Valid options:")
        for method, _ in pairs(wipeMethods) do
            print(string.rep(" ", 2) .. "* " .. method)
        end
        return
    end
    wipeMethods[toWipe]()
end, true)