
-- Plays songs from the music folder, songs can be downloaded with play.lua

local wave = dofile("apis/wave.lua")
interval = 0.05
index = 1

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

    -- I would prefer if the song was skipped only when a certain key is pressed but...
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
    return key
end
 
local args = {...}
if #args ~= 0 then
    print("Does not take arguments, plays all songs in the music folder, press up/down to change the interval, left/right to change the song")
    return
end
 
 
local dir, speaker = findPer("speaker")
local wc
 
local files = fs.list("/music")


local function play()

    if (index < 1) then
        index = #files
    elseif (index > #files) then
        index = 1
    end

    term.clear()
    term.setCursorPos(1,1)
    
    for i=index - 4, index + 4 do
        if (i == index) then
            term.setTextColor(colors.yellow)
        else
            term.setTextColor(colors.white)
        end
        term.setCursorPos(1, i - index + 6)
        if (i < 1) then
            term.write(files[#files + i])
            print(" ")
        elseif (i > #files) then
            term.write(files[i - #files])
            print(" ")
        else
            term.write(files[i])
            print(" ")
        end
    end
    term.setCursorPos(1, 10)
    term.setTextColor(colors.white)
    for i=1, term.getSize() do
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
            wc:update()
            os.sleep(interval) 
        end
        index = index + 1
    end
end
 
while true do
    parallel.waitForAny(getKeypress, play)
end