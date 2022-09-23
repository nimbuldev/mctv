local screenWidth, screenHeight = term.getSize()
local args = {...}

-- Need to test other wave api versions
local wave = dofile("apis/wave.lua") 
local files = {}
local context = {}
local instance = {}
Running = true
Timer = 0
Interval = 0.05

local function init()
    if #args ~= 0 then
        print("Does not take arguments, plays all songs in the music folder, press up/down to change the Interval, left/right to change the song")
        os.queueEvent("terminate")
        return
    end
    local outputs = wave.scanOutputs()
    if #outputs == 0 then
        error("no outputs found")
    end

    context = wave.createContext()
    context:addOutputs(outputs)
    files = fs.list("/music")
    CurrentSongIndex = math.random(1, #files)
end

local function draw()
    term.clear()
    term.setCursorPos(1,1)
    local numElements = screenHeight - 8
    local bound = CurrentSongIndex - math.floor(numElements / 2)
    for i=1, numElements do
        term.setCursorPos(1, i)
        if (i + bound == CurrentSongIndex) then
            term.setTextColor(colors.yellow)
        else
            term.setTextColor(colors.white)
        end
        if (i + bound < 1) then
            term.write(files[i + bound + #files])
        elseif (i + bound > #files) then
            term.write(files[i + bound - #files])
        else
            term.write(files[i + bound])
        end

    end
    term.setCursorPos(1, numElements + 1)
    term.setTextColor(colors.white)
    for i=1, screenWidth do
        term.write("-")
    end
    print(" ")
    print("Interval: " .. Interval)
    print("Currently Playing: " .. files[CurrentSongIndex])
    
    for i=1, term.getSize() do
        term.write("-")
    end
    print("Press Q to quit, left/right to change Interval, up/down to change song")      
end

local function playSong(songIndex)
    
    if Interval < 0.05 then
        Interval = 0.05
    end
    if Interval > 0.99 then
        Interval = 0.99
    end
    draw()
    context:removeInstance(1)
    local fname = files[songIndex]
    local t = wave.loadTrack("/music/" .. fname)
    instance = context:addInstance(t)
end



local function handleKeypress(key)
    
    if (key == 208) then
        CurrentSongIndex = CurrentSongIndex + 1
        if (CurrentSongIndex > #files) then
            CurrentSongIndex = 1
        end
        playSong(CurrentSongIndex)
    elseif (key == 200) then
        CurrentSongIndex = CurrentSongIndex - 1
        if (CurrentSongIndex < 1) then
            CurrentSongIndex = #files
        end
        playSong(CurrentSongIndex)
    elseif (key == 205) then
        Interval = Interval + 0.01
    elseif (key == 203) then
        Interval = Interval - 0.01
    elseif (key == 16) then
        os.queueEvent("terminate")
    end
    draw()
end


local function nextSong()
    CurrentSongIndex = CurrentSongIndex + 1
end

local function tick()
    local e = {os.pullEvent()}
    if e[1] == "timer" and e[2] == Timer then
			Timer = os.startTimer(Interval)
			local prevtick = instance.tick
			context:update()
			if prevtick > 1 and instance.tick == 1 then
				nextSong()
			end
		elseif e[1] == "term_resize" then
			screenWidth, screenHeight = term.getSize()
		elseif e[1] == "key" then
			handleKeypress(e[2])
		end
end


local function run()
    Timer = os.startTimer(0.05)
    draw()
    while Running do
        tick()
    end
end

local function main()
    init()
    playSong(CurrentSongIndex)
    run()
end

main()