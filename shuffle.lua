-- Todo: Make responsive to screen height

local args = {...}
local wave = dofile("apis/wave.lua")
interval = 0.05

local function findPer(pName)
    if (peripheral.getName) then
        local p = peripheral.find(pName)
        local n
 
        if (p) then
            n = peripheral.getName(p)
        end
        return n, p
    else
        local d = {"top", "bottom", "right", "left", "front", "back"}
        for i=1, #d do
            if (peripheral.getType(d[i]) == pName) then
                local p = peripheral.wrap(d[i])
                local n = d[i]
                return n, p
            end
        end
    end
end
 
local function getKeypress()
    local event, key = os.pullEvent("key")
    term.clear()
    if (key == 208) then
        index = index + 1
    elseif (key == 200) then
        index = index - 1
    elseif (key == 205) then
        interval = interval + 0.01
    elseif (key == 203) then
        interval = interval - 0.01
    elseif (key == 16) then
        os.queueEvent("terminate")
    end
    if interval < 0.05 then
        interval = 0.05
    end
    if interval > 0.99 then
        interval = 0.99
    end
    return key
end

if #args ~= 0 then
    print("Does not take arguments, plays all songs in the music folder, press up/down to change the interval, left/right to change the song")
    return
end
 
local dir, speaker = findPer("speaker")
local wc
local files = fs.list("/music")

index = math.random(1, #files)



local function play()
    if (index < 1) then
        index = #files
    elseif (index > #files) then
        index = 1
    end
    term.clear()
    term.setCursorPos(1,1)
    
    
    local w, h = term.getSize()
    local numElements = h - 6
    local mid = math.floor(boundsize / 2)
    for i=1, numElements do
        if (i == index) then
            term.setTextColor(colors.yellow)
        else
            term.setTextColor(colors.white)
        end
        term.setCursorPos(1, i)
        term.write(files[i])
    end
    term.setCursorPos(1, numElements + 1)
    term.setTextColor(colors.white)
    for i=1, w do
        term.write("-")
    end
    print(" ")
    print("Interval: " .. interval)
    print("Currently Playing: " .. files[index])
    
    for i=1, term.getSize() do
        term.write("-")
    end
    print("Press Q to quit, left/right to change interval, up/down to change song")      
    local fname = files[index]
    os.sleep(1)
    if (speaker ~= nil) then
        wc = wave.createContext()
        wc:addOutput(dir)
        local t = wave.loadTrack("/music/" .. fname)
        local instance = wc:addInstance(t)
        while (instance.playing) do
            os.sleep(interval) 
        end
        index = index + 1
    end
end
 
while true do
    parallel.waitForAny(getKeypress, play)
end