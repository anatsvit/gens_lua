--Если хочешь видеть что вышло в результате инструкции, адрес должен быть следующей инструкции
--||||||||||||||||||||||||||||||||||
local M = {}
local bufferKeys = {};
local cycleCounters = {};

--Рисует число (hex)
local function dtext(number, x, y)
	font.draw_hexstr(string.format('%X', number), x, y);
end

local function writeToFile(text)
    file = io.open("word_adresses_list.txt", "a");
    file:write(text);
    io.close(file);
end

local function registerOnAddress(buffer, address, register)
    memory.registerexec (address, function () 
        addToBuffer(buffer, string.format("0x%X", memory.getregister(register)));
    end)
end

local function cycleHook(buffer, addressBeforeCycle, addressRegister, addrSizeTable, addressAfterCycle)
    cycleCounters[addressBeforeCycle] = 0;
    local startAddressRegisterValue = 0;
    --Адрес перед меткой: сброс счетчика размера, считывание начального значения регистра адреса
    memory.registerexec (addressBeforeCycle, function () 
        cycleCounters[addressBeforeCycle] = 0;
        startAddressRegisterValue = memory.getregister(addressRegister);
    end)
    
    local length = table.maxn(addrSizeTable);
    local sizeValues = {['b'] = 1, ['w'] = 2, ['l'] = 4};
    
    for addressKey, sizePostfixValue in pairs(addrSizeTable) do
       memory.registerexec (addressKey, function () 
            cycleCounters[addressBeforeCycle] = cycleCounters[addressBeforeCycle] + sizeValues[sizePostfixValue];
       end)
    end
    
    --Адрес после dbf: запоминание адреса и размера в буфер
    memory.registerexec (addressAfterCycle, function () 
        addToBuffer(buffer, string.format("0x%X", startAddressRegisterValue) .. ", " .. cycleCounters[addressBeforeCycle]);
    end)
    
    gui.register (function () 
        gui.text(20, 20, table.maxn(buffer), 'green', 'red');
        gui.text(20, 30, cycleCounters[addressBeforeCycle], '#0000FF', 'red');
    end)
    
    --Сброс в файл
    input.registerhotkey (1, function () 
        writeBufferToFile(string.format("%X", addressBeforeCycle) .. "_" .. addressRegister .. ".txt", buffer);
    end)
end

local function printTextOnAddress(address, text)
    memory.registerexec (address, function () 
        writeToFile(text);
    end)
end

local function printTextOnRead(address, size)
    memory.registerread (address, size, function(address, size) 
        writeToFile(string.format('%X', memory.getregister("pc")) .. "::" .. string.format('%X', address) .. "\n");
    end)
end

function addToBuffer(buffer, value)
    if bufferKeys[value] == nil then
        table.insert(buffer, value);
        bufferKeys[value] = 1;
    end    
end

function writeBufferToFile(filename, buffer)
    file = io.open(filename, "a");
    local length = table.maxn(buffer);
    
    for i = 1, length do
       file:write(buffer[i] .. "\n");
    end
    
    io.close(file);
end

M.printTextOnRead = printTextOnRead
M.printTextOnAddress = printTextOnAddress
M.registerOnAddress = registerOnAddress
M.writeToFile = writeToFile
M.addToBuffer = addToBuffer
M.writeBufferToFile = writeBufferToFile
M.cycleHook = cycleHook
 
return M