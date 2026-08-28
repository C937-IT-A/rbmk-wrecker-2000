-- USER INPUTS
local redInputSide = require("sides").right -- side to take redstone input from
local autoScram = true -- should the program automatically SCRAM the reactor if meltdown conditions are detected?

--[[
Define RoR frequencies for rod controllers below as strings.
NOTE: Empty strings will no longer nullify input fields. Use 'nil' instead.
]]
local controlRodRegistry = {
    { "b26599b0", "RED" },
    { "37000bc7", "YELLOW" },
    { nil, "GREEN" },
    { nil, "BLUE" },
    { nil, "PURPLE" }
}

--[[
Define RoR frequencies for data reading below as strings.
NOTE: these values need to be mapped by a logic reciever somewhere up the line unless otherwise denoted
NOTE: there MUST be a torch transmitting on each active frequency, or the signal from the previous frequency will 'bleed' into the next
          if you wish to deactivate a frequency (prevent bleed), replace the string frequency value with 'nil' or 'false' to skip it.
          DO NOT remove dataRegistry or its indices! set negative truthy values as denoted above to deactivate data reading.
]]
local dataRegistry = {
    nil,        -- col heat
    nil,        -- fuel heat
    nil,        -- depletion
    nil,        -- xenon poison
    nil         -- turbine throughput; no mapping required (binary)
}

-- PROGRAM BODY

local cmp = require("component"); local serial; local fs; local comp = require("computer"); local active = true; local gpu =
    cmp.gpu; local ox, oy =
    gpu.getResolution(); local term; local RoR; local input; local rednet; local threading = require("thread"); gpu
    .setResolution(60, 40); local resX, resY = gpu.getResolution(); gpu.setBackground(0); gpu.fill(1, 1, resX, resY, ' '); gpu
    .setForeground(0xffffff);
gpu.set(1, 1, '╒')
gpu.set(resX, 1, '╕')
gpu.set(1, resY, '╘')
gpu.set(resX, resY, '╛')
os.sleep(.01)
gpu.fill(2, 1, resX - 2, 1, '═')
gpu.fill(2, resY, resX - 2, 1, '═')
gpu.fill(1, 2, 1, resY - 2, '│')
gpu.fill(resX, 2, 1, resY - 2, '│')
os.sleep(.15)

local hang = false
local icl = ""
local lty = 3
local function newCheck(name, toLoad)
    threading.create(function()
        local cy = lty
        gpu.set(3, lty, '☐ ' .. name)
        lty = lty + 1
        if lty > resY - 2 then lty = 3 end
        os.sleep(math.random() + .6)
        local s, e = pcall(toLoad)
        local of = gpu.getForeground()
        if s then
            gpu.setForeground(0x00ff00)
            gpu.set(3, cy, '☑')
            gpu.setForeground(of)
        else
            icl = icl .. name .. ", "
            hang = true
            gpu.setForeground(0xff0000)
            gpu.set(3, cy, '☒')
            gpu.setForeground(of)
            os.sleep(1)
            local cy0 = cy
            local m = ""
            for x = 3, resX - 4 do m = m .. gpu.get(x, cy0) end
            repeat
                local of0 = gpu.getForeground()
                gpu.setForeground(0xffffff)
                gpu.fill(3, cy0, resX - 4, 1, ' ')
                gpu.set(3, cy0, e)
                gpu.setForeground(of0)
                os.sleep(.8)
                of0 = gpu.getForeground()
                gpu.setForeground(0xff0000)
                gpu.fill(3, cy0, resX - 4, 1, ' ')
                gpu.set(3, cy0, m)
                gpu.setForeground(of0)
                os.sleep(.8)
            until not active --NOTE: relies on soft exit!
        end; of = nil
    end)
end

newCheck("GPU API", function() end)
os.sleep(math.random() * .3 + .1)
newCheck("COMPONENT API", function() end)
os.sleep(math.random() * .3 + .1)
newCheck("THREADING API", function() end)
os.sleep(math.random() * .3 + .1)
newCheck("COMPUTER API", function() end)
os.sleep(math.random() * .3 + .1)
newCheck("TERMINAL API", function() term = require("term") end)
os.sleep(math.random() * .3 + .1)
newCheck("REDSTONE API", function() rednet = cmp.redstone end)
os.sleep(math.random() * .3 + .1)
newCheck("SERIALIZATION API", function() serial = require("serialization") end)
os.sleep(math.random() * .3 + .1)
newCheck("FILESYSTEM API", function() fs = require("filesystem") end)
os.sleep(math.random() * .3 + .1)
newCheck("TORCH ADDRESS INDEX",
    function()
        local fh = io.open("/rbmk/torches.add", "r"); RoR = cmp.proxy(fh:read("*l")); input = cmp.proxy(fh:read("*l")); if fh then
            fh:close()
        end
    end)
os.sleep(math.random() * .3 + .1)

os.sleep(3.5)
if hang then
    comp.beep(1800, .35)
    os.sleep(.15)
    comp.beep(1800, .35)
    gpu.setForeground(0xffffff)
    gpu.set(resX / 2 - 10, 1, "PRESS ANY KEY TO EXIT")
    local _ = require("event").pull("key_down") -- wait until user presses any key
    active = false
    term.clear()
    error("Error loading required components: " .. icl:sub(1, #icl - 2))
end

term.clear()
local lrh = {
    { 0, "RED" },
    { 0, "YELLOW" },
    { 0, "GREEN" },
    { 0, "BLUE" },
    { 0, "PURPLE" }
}

local function setRods(color, level) end

local function textInput(button)
    gpu.setForeground(0)
    local ob = gpu.getBackground()
    gpu.setBackground(button[3])
    gpu.set(button[1], button[2], "000")
    gpu.setBackground(ob)
    local etrd = ""
    local color = button[7]
    repeat
        term.setCursor(0, 1)
        local _, _, char = require("event").pull("key_down")
        if char == 13 then
            setRods(color, tonumber(etrd) or 0); if not tonumber(etrd) then
                ob = gpu.getBackground()
                gpu.setBackground(button[3])
                gpu.set(button[1], button[2], "000")
                gpu.setBackground(ob)
            end
            break
        end
        if #etrd > 0 and char == 8 then
            etrd = etrd:sub(1, #etrd - 1);ob = gpu.getBackground();gpu.setBackground(button[3]);gpu.set(button[1], button[2], "   "); gpu.set(button[1], button[2],string.rep('0', 3 - #etrd) .. etrd);gpu.setBackground(ob)
        end
        char = string.char(char)
        if tonumber(char) and #etrd < 3 then
            etrd = etrd .. char
            if tonumber(etrd) > 100 then etrd = "100" end
            ob = gpu.getBackground()
            gpu.setBackground(button[3])
            gpu.set(button[1], button[2], string.rep('0', 3 - #etrd) .. etrd)
            comp.beep(tonumber(etrd) * 10 + 100, .1)
            gpu.setBackground(ob)
        elseif #etrd >= 3 then
            comp.beep(2000, .075)
        end
    until not active
    comp.beep(1100, .05)
end
local buttonRegistry = {}
local function popButtons()
    local of = gpu.getForeground(); local ob = gpu.getBackground()
    for _, v in pairs(buttonRegistry) do
        gpu.setBackground(v[3])
        gpu.setForeground(v[4])
        gpu.set(v[1], v[2], v[5])
    end
    gpu.setForeground(of); gpu.setBackground(ob)
end
local function loadPreset(btn) end
local pln
local function checkPresets()
    lty = 5
    if fs.exists("/rbmk/presets.rbmk") then
        local ln = 0
        for _ in io.lines("/rbmk/presets.rbmk") do ln = ln + 1 end; pln = ln
        gpu.setBackground(0xc3c3c3)
        gpu.fill(21, 3, 15, ln + 3, ' ')
        gpu.set(25, 3, "PRESETS")
        table.insert(buttonRegistry,
            { 26, 4, 0xff0000, 0, "DELETE", function()
                fs.remove("/rbmk/presets.rbmk"); gpu.setBackground(0xaaaaff); gpu.fill(21, 3, 15, pln + 3, ' '); pln = 0
            end, nil })
        for i, v in pairs(buttonRegistry) do if v[6] == loadPreset then table.remove(buttonRegistry, i) end end
        for line in io.lines("/rbmk/presets.rbmk") do
            gpu.setBackground(0xd2d2d2)
            gpu.setForeground(0)
            gpu.fill(21, lty, 10, 1, ' ')
            local data = serial.unserialize(line)
            if data then
                gpu.set(21, lty, data[1])
                table.insert(buttonRegistry, { 32, lty, 0x00ff00, 0, "LOAD", loadPreset, data[2] })
                gpu.set(21, lty, data[1])
                lty = lty + 1
            end
        end
    end
end
local function saveAsPreset(_)
    local etrd = ""
    comp.beep(500, .05)
    repeat
        local _, _, char = require("event").pull("key_down")
        if char == 13 then break end
        if char == 8 then
            etrd = etrd:sub(1, #etrd - 1); comp.beep(650, .05)
        end
        if #etrd > 9 then
            comp.beep(1750, .05)
        else
            if string.char(char) then
                etrd = etrd .. string.char(char)
                comp.beep(750, .1)
            end
        end
    until not active
    local fh = io.open("/rbmk/presets.rbmk", "a")
    if fh then
        local nt = {}
        for _, v in pairs(lrh) do table.insert(nt, v[1]) end
        fh:write(serial.serialize({ etrd, nt }) .. '\n')
        fh:close()
        comp.beep(1000, .05)
    else
        comp.beep(1500, .05)
    end
    os.sleep(.1)
    checkPresets()
    popButtons()
end

local function scram() setRods("RED", 0); setRods("YELLOW", 0); setRods("GREEN", 0); setRods("BLUE", 0); setRods("PURPLE", 0); comp.beep(1800, .75); comp.beep(2000, 1) end

local graphID=0
local gHist={}

buttonRegistry = {
    --[[
    {X_pos,Y_pos,backColor,foreColor,"text",function}
    ]]
    { resX - 5, 1,  0x3c3c3c, 0xffffff, "SAVE",  saveAsPreset,nil },
    { resX,     1,  0xff0000, 0,        "X",     function() active = false end,nil },
    { 2,        4,  0xd2d2d2, 0,        "---",   textInput,"RED" },
    { 2,        6,  0xd2d2d2, 0,        "---",   textInput,"YELLOW" },
    { 2,        8,  0xd2d2d2, 0,        "---",   textInput,"GREEN" },
    { 2,        10, 0xd2d2d2, 0,        "---",   textInput,"BLUE" },
    { 2,        12, 0xd2d2d2, 0,        "---",   textInput,"PURPLE" },
    {5, resY-13, 0x00ff00, 0, "GRAPH", function() graphID=1;gHist={} end, "GRAPH_1"},
    {15, resY-13, 0x00ff00, 0, "GRAPH", function() graphID=2;gHist={} end, "GRAPH_2"},
    {27, resY-13, 0x00ff00, 0, "GRAPH", function() graphID=3;gHist={} end, "GRAPH_3"},
    {39, resY-13, 0x00ff00, 0, "GRAPH", function() graphID=4;gHist={} end, "GRAPH_4"},
    { resX - 11, 1, 0xff7000, 0,        "SCRAM",scram,nil }
}
function loadPreset(btn)
    for i, v in pairs(btn[7]) do
        setRods(controlRodRegistry[i][2], v)
        local ob = gpu.getBackground(); local of = gpu.getForeground()
        gpu.setBackground(0xd2d2d2); gpu.setForeground(0)
        for _, x in pairs(buttonRegistry) do
            if x[6] == textInput and x[7] == controlRodRegistry[i][2] then
                gpu.set(x[1] + 13, x[2], string.rep('0', 3 - #tostring(v)) .. tostring(v))
                break
            end
        end
        gpu.setBackground(ob); gpu.setForeground(of)
    end
end

for i, v in pairs(buttonRegistry) do
    for _, x in pairs(controlRodRegistry) do
        if x[2] == v[7] and not x[1] then
            v[6] = function() comp.beep(1500, .05) end; v[5] = "D/C";v[3]=0xffff00
        end
    end
    for i2,x in pairs(dataRegistry) do
        if not x and v[7]=="GRAPH_"..tostring(i2) then
            table.remove(buttonRegistry,i)
        end
    end
end
function setRods(color, level)
    RoR.setCustomMap(true)
    for _, v in pairs(controlRodRegistry) do
        if v[1] and v[2] == color then
            RoR.setChannel(v[1])
            RoR.setCustomMapValues({ "setrods!" .. tostring(level), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil })
            os.sleep()
            RoR.setPolling(true)
            local rhr
            for _, x in pairs(lrh) do
                if x[2] == color then
                    rhr = x; break
                end
            end
            local btn
            for _, x in pairs(buttonRegistry) do
                if x[7] == color then
                    btn = x; break
                end
            end
            threading.create(function()
                local lh = rhr[1]
                local ttm = math.abs(lh - level) * .18
                rhr[1] = level
                local ob = gpu.getBackground()
                local of = gpu.getForeground()
                gpu.setBackground(0xff0000)
                gpu.setForeground(0x909000)
                gpu.set(13, btn[2], '░')
                gpu.setBackground(ob); gpu.setForeground(of)
                os.sleep(ttm / 3)
                if not active then error() end
                ob = gpu.getBackground()
                of = gpu.getForeground()
                gpu.setBackground(0xff0000)
                gpu.setForeground(0xffff00)
                gpu.set(13, btn[2], '▒')
                gpu.setBackground(ob); gpu.setForeground(of)
                os.sleep(ttm / 3)
                if not active then error() end
                ob = gpu.getBackground()
                of = gpu.getForeground()
                gpu.setBackground(0xffff00)
                gpu.setForeground(0x90ff50)
                gpu.set(13, btn[2], '▓')
                gpu.setBackground(ob); gpu.setForeground(of)
                os.sleep(ttm / 3)
                if not active then error() end
                ob = gpu.getBackground()
                gpu.setBackground(0x00ff00)
                gpu.set(13, btn[2], ' ')
                gpu.setBackground(ob)
            end)
            os.sleep(.05)
            RoR.setPolling(false)
            break
        end
    end
end

gpu.setBackground(0xaaaaff)
gpu.fill(1, 1, resX, resY, ' ')
gpu.setBackground(0xffffff)
gpu.fill(1, 1, resX, 2, ' ')
gpu.setForeground(0)
gpu.set(1, 1, "RBMK WRECKER 2000")
gpu.setBackground(0xc3c3c3); gpu.fill(1, 3, 19, 11, ' '); gpu.fill(37,3,resX-36,18,' '); gpu.set(2, 3, "SET  COLOR P LPV"); gpu.set(40,3,"GRAPH")
gpu.setBackground(0); gpu.fill(38,4,resX-38,15,' ');
checkPresets(); os.sleep(.05)
gpu.setBackground(0xa5a5a5)
gpu.setForeground(0xff0000); gpu.set(buttonRegistry[3][1] + 4, buttonRegistry[3][2], "   RED")
gpu.setForeground(0xffff00); gpu.set(buttonRegistry[4][1] + 4, buttonRegistry[4][2], "YELLOW")
gpu.setForeground(0x00ff00); gpu.set(buttonRegistry[5][1] + 4, buttonRegistry[5][2], " GREEN")
gpu.setForeground(0x0000ff); gpu.set(buttonRegistry[6][1] + 4, buttonRegistry[6][2], "  BLUE")
gpu.setForeground(0xff00ff); gpu.set(buttonRegistry[7][1] + 4, buttonRegistry[7][2], "PURPLE")
gpu.setBackground(0xd2d2d2); gpu.setForeground(0)
gpu.set(buttonRegistry[3][1] + 13, buttonRegistry[3][2], "---"); gpu.set(buttonRegistry[4][1] + 13, buttonRegistry[4][2],
    "---"); gpu.set(buttonRegistry[5][1] + 13, buttonRegistry[5][2], "---"); gpu.set(buttonRegistry[6][1] + 13,
    buttonRegistry[6][2], "---"); gpu.set(buttonRegistry[7][1] + 13, buttonRegistry[7][2], "---")

local function graph(n)
    table.insert(gHist,n)
    if #gHist>resX-38 then table.remove(gHist,1) end
    local ob = gpu.getBackground()
    gpu.setBackground(0); gpu.fill(38,4,resX-38,16,' ');
    gpu.setBackground(0xffffff)
    for i,v in pairs(gHist) do
        gpu.set(i+37,19-v,' ')
    end
    gpu.setBackground(ob)
end

local inpFunctions = {}

local lh = 0
function inpFunctions.updateColHeat()
    if not dataRegistry[1] then
        local of = gpu.getForeground(); local ob = gpu.getBackground()
        gpu.setForeground(0)
        gpu.setBackground(0xaaaaaa)
        gpu.set(5, resY - 15, "COL HT.")
        gpu.setBackground(0xffff00)
        gpu.set(5, resY - 14, "D/C")
        for y = resY - 15, resY - 1 do
            if y % 2 == 0 then
                gpu.setBackground(0xff0000)
            else
                gpu.setBackground(0x800000)
            end
            gpu.set(3, y, '║')
        end
        gpu.setForeground(of); gpu.setBackground(ob)
    return end
    input.setChannel(dataRegistry[1]); input.setPolling(true); input.setCustomMap(false)
    os.sleep(.1)
    local of = gpu.getForeground(); local ob = gpu.getBackground()
    gpu.setForeground(0)
    gpu.setBackground(0xaaaaaa)
    gpu.set(5, resY - 15, "COL HT.")
    gpu.setBackground(0x00ff00)
    gpu.set(5, resY - 14, "CONN.")
    for y = resY - 15, resY - 1 do
        if y % 2 == 0 then
            gpu.setBackground(0x5a5a5a)
        else
            gpu.setBackground(0x969696)
        end
        gpu.set(3, y, '║')
    end
    lh = rednet.getInput(redInputSide)
    for h = 1, lh do
        gpu.setBackground((0xff0000/15*h)+(0xffff00/h)) -- NOTE: Test me!
        gpu.set(3, resY - h, ' ')
    end
    gpu.setForeground(of); gpu.setBackground(ob)
    if graphID==1 then graph(lh) end
end

local lfh = 0
function inpFunctions.updateFuelHeat()
    if not dataRegistry[2] then
        local of = gpu.getForeground(); local ob = gpu.getBackground()
        gpu.setForeground(0)
        gpu.setBackground(0xaaaaaa)
        gpu.set(15, resY - 15, "FUEL HEAT")
        gpu.setBackground(0xffff00)
        gpu.set(15, resY - 14, "D/C")
        for y = resY - 15, resY - 1 do
            if y % 2 == 0 then
                gpu.setBackground(0xff0000)
            else
                gpu.setBackground(0x800000)
            end
            gpu.set(13, y, '║')
        end
        gpu.setForeground(of); gpu.setBackground(ob)
    return end
    input.setChannel(dataRegistry[2]); input.setPolling(true); input.setCustomMap(false)
    os.sleep(.1)
    local of = gpu.getForeground(); local ob = gpu.getBackground()
    gpu.setForeground(0)
    gpu.setBackground(0xaaaaaa)
    gpu.set(15, resY - 15, "FUEL HEAT")
    gpu.setBackground(0x00ff00)
    gpu.set(15, resY - 14, "CONN.")
    for y = resY - 15, resY - 1 do
        if y % 2 == 0 then
            gpu.setBackground(0x009000)
        else
            gpu.setBackground(0x006000)
        end
        gpu.set(13, y, '║')
    end
    lfh=rednet.getInput(redInputSide)
    for h = 1, lfh do
        gpu.set(13, resY - h, ' ')
        gpu.setBackground((0xff0000/15*h)+(0xffff00/h)) -- NOTE: Test me!
    end
    gpu.setForeground(of); gpu.setBackground(ob)
    if graphID==2 then graph(lfh) end
end

local ld = 0
function inpFunctions.updateDepletion()
    if not dataRegistry[3] then
        local of = gpu.getForeground(); local ob = gpu.getBackground()
        gpu.setForeground(0)
        gpu.setBackground(0xaaaaaa)
        gpu.set(27, resY - 15, "FUEL DPL.")
        gpu.setBackground(0xffff00)
        gpu.set(27, resY - 14, "D/C")
        for y = resY - 15, resY - 1 do
            if y % 2 == 0 then
                gpu.setBackground(0xff0000)
            else
                gpu.setBackground(0x800000)
            end
            gpu.set(25, y, '║')
        end
        gpu.setForeground(of); gpu.setBackground(ob)
    return end
    input.setChannel(dataRegistry[3]); input.setPolling(true); input.setCustomMap(false)
    os.sleep(.1)
    local of = gpu.getForeground(); local ob = gpu.getBackground()
    gpu.setForeground(0)
    gpu.setBackground(0xaaaaaa)
    gpu.set(27, resY - 15, "FUEL DPL.")
    gpu.setBackground(0x00ff00)
    gpu.set(27, resY - 14, "CONN.")
    for y = resY - 15, resY - 1 do
        if y % 2 == 0 then
            gpu.setBackground(0x009000)
        else
            gpu.setBackground(0x006000)
        end
        gpu.set(25, y, '║')
    end
    ld = rednet.getInput(redInputSide)
    for h = 1, ld do
        gpu.setBackground((0xaaaaaa/15*h)+(0x404040/h)) -- NOTE: Test me!
        gpu.set(25, resY - h, ' ')
    end
    gpu.setForeground(of); gpu.setBackground(ob)
    if graphID==3 then graph(ld) end
end

function inpFunctions.updateXenon()
    if not dataRegistry[4] then
        local of = gpu.getForeground(); local ob = gpu.getBackground()
        gpu.setForeground(0)
        gpu.setBackground(0xaaaaaa)
        gpu.set(39, resY - 15, "Xe PSN")
        gpu.setBackground(0xffff00)
        gpu.set(39, resY - 14, "D/C")
        for y = resY - 15, resY - 1 do
            if y % 2 == 0 then
                gpu.setBackground(0xff0000)
            else
                gpu.setBackground(0x800000)
            end
            gpu.set(37, y, '║')
        end
        gpu.setForeground(of); gpu.setBackground(ob)
    return end
    input.setChannel(dataRegistry[4]); input.setPolling(true); input.setCustomMap(false)
    os.sleep(.1)
    local of = gpu.getForeground(); local ob = gpu.getBackground()
    gpu.setForeground(0)
    gpu.setBackground(0xaaaaaa)
    gpu.set(39, resY - 15, "Xe PSN")
    gpu.setBackground(0x00ff00)
    gpu.set(39, resY - 14, "CONN.")
    for y = resY - 15, resY - 1 do
        if y % 2 == 0 then
            gpu.setBackground(0x5a5a5a)
        else
            gpu.setBackground(0x969696)
        end
        gpu.set(37, y, '║')
    end
    local lx = rednet.getInput(redInputSide)
    for h = 1, lx do
        gpu.setBackground((0x300030/15*h)+(0xaa00aa/h)) -- NOTE: Test me!
        gpu.set(37, resY - h, ' ')
    end
    gpu.setForeground(of); gpu.setBackground(ob)
    if graphID==4 then graph(lx) end
end

function inpFunctions.updateTurbine()
    local of = gpu.getForeground(); local ob = gpu.getBackground()
    if not dataRegistry[5] then
        gpu.setBackground(0xffff00); gpu.setForeground(0)
        gpu.set(resX - 4, resY - 1, "D/C")
        gpu.setForeground(of); gpu.setBackground(ob)
    return end
    input.setChannel(dataRegistry[5]); input.setPolling(true); input.setCustomMap(false)
    os.sleep(.1)
    if rednet.getInput(redInputSide) == 0 then
        gpu.setBackground(0); gpu.setForeground(0xffffff)
    else
        gpu.setBackground(0x00ff00); gpu.setForeground(0)
    end
    gpu.set(resX - 4, resY - 1, "TRB")
    gpu.setForeground(of); gpu.setBackground(ob)
end

function inpFunctions.fullDepletion()
    if not dataRegistry[3] then
        local of = gpu.getForeground(); local ob = gpu.getBackground()
        gpu.setBackground(0xffff00);gpu.setForeground(0)
        gpu.set(resX - 9, resY - 1, "D/C")
        gpu.setForeground(of); gpu.setBackground(ob)
    return end
    input.setChannel(dataRegistry[3]); input.setPolling(true); input.setCustomMap(false)
    os.sleep(.1)
    if ld == 15 then
        threading.create(function()
            local of
            local ob
            repeat
                os.sleep(.2)
                of = gpu.getForeground(); ob = gpu.getBackground()
                gpu.setBackground(0xff0000); gpu.setForeground(0); gpu.set(resX - 9, resY - 1, "DEP")
                gpu.setForeground(of); gpu.setBackground(ob)
                os.sleep(.2)
                of = gpu.getForeground(); ob = gpu.getBackground()
                gpu.setBackground(0); gpu.setForeground(0xffffff); gpu.set(resX - 9, resY - 1, "DEP")
                gpu.setForeground(of); gpu.setBackground(ob)
            until ld < 15
            of = gpu.getForeground(); ob = gpu.getBackground()
            gpu.setBackground(0); gpu.setForeground(0xffffff); gpu.set(resX - 9, resY - 1, "DEP")
            gpu.setForeground(of); gpu.setBackground(ob)
        end)
    else
        local of = gpu.getForeground(); local ob = gpu.getBackground()
        gpu.setBackground(0); gpu.setForeground(0xffffff); gpu.set(resX - 9, resY - 1, "DEP")
        gpu.setForeground(of); gpu.setBackground(ob)
    end
end

local oht = false
function inpFunctions.overheat()
    if not dataRegistry[1] and not dataRegistry[2] then
        local of = gpu.getForeground(); local ob = gpu.getBackground()
        gpu.setBackground(0xffff00); gpu.setForeground(0); gpu.set(resX - 9, resY - 3, "DISCONN.")
        gpu.setForeground(of); gpu.setBackground(ob)
    return end
    os.sleep(.1)
    if lh == 15 or lfh == 15 then
        if not oht then
            local of = gpu.getForeground(); local ob = gpu.getBackground()
            gpu.setBackground(0xff0000); gpu.setForeground(0); gpu.set(resX - 9, resY - 3, "OVERHEAT")
            gpu.setForeground(of); gpu.setBackground(ob)
            if autoScram then scram() end;oht = true
            threading.create(function()
                local of
                local ob
                repeat
                    comp.beep(2000, .05)
                    os.sleep(.1)
                    of = gpu.getForeground(); ob = gpu.getBackground()
                    gpu.setBackground(0xff0000); gpu.setForeground(0); gpu.set(resX - 9, resY - 3, "OVERHEAT")
                    gpu.setForeground(of); gpu.setBackground(ob)
                    comp.beep(1900, .05)
                    os.sleep(.1)
                    of = gpu.getForeground(); ob = gpu.getBackground()
                    gpu.setBackground(0); gpu.setForeground(0xffffff); gpu.set(resX - 9, resY - 3, "OVERHEAT")
                    gpu.setForeground(of); gpu.setBackground(ob)
                until lh < 15 and lfh < 15
                of = gpu.getForeground(); ob = gpu.getBackground()
                gpu.setBackground(0); gpu.setForeground(0xff0000); gpu.set(resX - 9, resY - 3, "RESOLVED")
                gpu.setForeground(of); gpu.setBackground(ob)
                oht = false
            end)
        end
    else
        local of = gpu.getForeground(); local ob = gpu.getBackground()
        gpu.setBackground(0); gpu.setForeground(0xffffff); gpu.set(resX - 9, resY - 3, "NOMINAL ")
        gpu.setForeground(of); gpu.setBackground(ob)
    end
end

gpu.setBackground(0xc3c3c3)
gpu.fill(2, resY - 17, resX - 2, 18, ' ')
threading.create(function()
    repeat
        for _, v in pairs(inpFunctions) do
            if not active then break end
            os.sleep(.05)
            v()
        end
    until not active
end)

popButtons()

repeat
    local _, _, x, y = require("event").pull("touch")
    for _, v in pairs(buttonRegistry) do
        if #v[5] > 1 then
            local xMatch = false
            for i = v[1], #v[5] + v[1] do
                if x == i then
                    xMatch = true; break
                end
            end
            if xMatch and v[2] == y then
                v[6](v)
                comp.beep(1250, .05)
                break
            end
        else
            if v[1] == x and v[2] == y then
                v[6](v)
                comp.beep(1250, .05)
                break
            end
        end
    end
until not active

active = false
os.sleep(1)
gpu.setBackground(0)
gpu.setForeground(0xffffff)
term.clear()
gpu.setResolution(ox, oy)
