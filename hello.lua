local font = require("font")
local mylib = require("mylib")

addressBuffer = {};
--Кандидаты на дампинг
--248B26 ok
--2491E6 ok
--249234 ok
--24933E ok
--2493A4 ok
--249450 ok
--2499B2 propusk
--2499CC propusk
--2499FE ok
--249A20 propusk
--24C7CA ok
--24C7CE ok
--24C8C8 ok
--24C8FC propusk
--24CA8C propusk
--24F9D8 propusk
--24FA00 propusk
--250460 ok
--251A62 ok
--251AC8 ok

--[[
local currentAddress  = 0x24C;
local currentRegister = "a5";

input.registerhotkey (1, function () 
    mylib.writeBufferToFile(string.format("%X", currentAddress) .. "_" .. currentRegister .. ".txt", addressBuffer);
end)

mylib.registerOnAddress(addressBuffer, currentAddress, currentRegister);

gui.register (function () 
    gui.text(20, 20, table.maxn(addressBuffer), 'green', 'red');
end)
]]--

mylib.cycleHook(addressBuffer, 0x28E, 'a5', {[0x290] = 'b'}, 0x298)

