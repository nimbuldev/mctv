local screenWidth, screenHeight = term.getSize()
local args = { ... }

-- Need to test other wave api versions
local wave = dofile("apis/wave.lua")
local files = {}
local context = {}
local instance = {}
local running = true
local timer = 0
local interval = 0.05
local currentSongIndex = 1

local function init()
    if #args ~= 0 then
        print("Does not take arguments, plays all songs in the music folder, press up/down to change the interval, left/right to change the song")
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
    currentSongIndex = math.random(1, #files)
end

local function draw()
    term.clear()
    term.setCursorPos(1, 1)
    local numElements = screenHeight - 8
    local bound = currentSongIndex - math.floor(numElements / 2)
    for i = 1, numElements do
        term.setCursorPos(1, i)
        if (i + bound == currentSongIndex) then
            term.setTextColor(colors.yellow)
        else
            term.setTextColor(colors.white)
        end
        if (i + bound < 1) then
            local name = files[i + bound + #files]
            name = name:gsub(".nbs", ""):gsub("_", " ")
            term.write(name)
        elseif (i + bound > #files) then
            local name = files[i + bound - #files]
            name = name:gsub(".nbs", ""):gsub("_", " ")
            term.write(name)
        else
            local name = files[i + bound]
            name = name:gsub(".nbs", ""):gsub("_", " ")
            term.write(name)
        end
    end
    term.setCursorPos(1, numElements + 1)
    term.setTextColor(colors.white)
    for i = 1, screenWidth do
        term.write("-")
    end
    print(" ")
    print("Interval: " .. interval)
    print("Currently Playing: " .. files[currentSongIndex])

    for i = 1, term.getSize() do
        term.write("-")
    end
    print("Press Q to quit, left/right to change interval, up/down to change song")
end

local function playSong(songIndex)
    if interval < 0.05 then
        interval = 0.05
    end
    if interval > 0.99 then
        interval = 0.99
    end
    draw()
    context:removeInstance(1)
    local fname = files[songIndex]
    local t = wave.loadTrack("/music/" .. fname)
    instance = context:addInstance(t)
end

local function handleKeypress(key)
    if (key == 208) then
        currentSongIndex = currentSongIndex + 1
        if (currentSongIndex > #files) then
            currentSongIndex = 1
        end
        playSong(currentSongIndex)
    elseif (key == 200) then
        currentSongIndex = currentSongIndex - 1
        if (currentSongIndex < 1) then
            currentSongIndex = #files
        end
        playSong(currentSongIndex)
    elseif (key == 205) then
        interval = interval + 0.01
        if (interval > 0.99) then
            interval = 0.99
        end
    elseif (key == 203) then
        interval = interval - 0.01
        if (interval < 0.05) then
            interval = 0.05
        end
    elseif (key == 16) then
        os.queueEvent("terminate")
    end
    draw()
end

local function nextSong()
    currentSongIndex = currentSongIndex + 1
    if (currentSongIndex > #files) then
        currentSongIndex = 1
    end
    playSong(currentSongIndex)
end

local function tick()
    local e = { os.pullEvent() }
    if e[1] == "timer" and e[2] == timer then
        timer = os.startTimer(interval)
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
    timer = os.startTimer(0.05)
    draw()
    while running do
        tick()
    end
end

local function main()
    init()
    playSong(currentSongIndex)
    run()
end

main()
