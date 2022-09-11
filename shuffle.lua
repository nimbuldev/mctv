
-- Randomly selects a song from the music folder and plays it, songs can be downloaded with
-- play.lua

local waveurl = "https://github.com/nimbuldev/mctv/raw/master/apis/wave.lua"
local wavepath = "/apis/wave.lua"
if not fs.exists(wavepath) then
	print("Downloading wave API...")
	local wave = http.get(waveurl)
	local wavefile = fs.open(wavepath, "w")
	wavefile.write(wave.readAll())
	wavefile.close()
	wave.close()
end

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
    print("Song skipped")
    return key
end
 
local args = {...}
if #args ~= 0 then
    print("Does not take arguments, continuously randomly selects a song from the music folder and plays it, press any key to skip")
    return
end
 
 
local dir, speaker = findPer("speaker")
local wc
 
local files = fs.list("/music")
 
local function play()

    local fname = files[math.random(#files)]
    print("Now Playing : " .. fname)
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
    end
end
 
while true do
    parallel.waitForAny(getKeypress, play)
end