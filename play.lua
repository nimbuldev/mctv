
local waveurl = "https://github.com/nimbuldev/mctv/apis/wave.lua"
local wavepath = "/apis/wave.lua"
if not fs.exists(wavepath) then
	print("Downloading wave API...")
	local wave = http.get(waveurl)
	local wavefile = fs.open(wavepath, "w")
	wavefile.write(wave.readAll())
	wavefile.close()
	wave.close()
end

local wave = dofile("apis/wave.lua") -- loads wave

args = {...}
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

local function getFile(url)
	if (not fs.exists(fname)) then
		print("Downloading " .. url)
		local r = http.get(url, nil, true)
		-- If the response is redirect, follow it
		if (r.getResponseCode() == 301 or r.getResponseCode() == 302) then
			print("Redirected to " .. r.getResponseHeaders()["Location"])
			local loc = r.getResponseHeaders()["Location"]
			r.close()
			return getFile(loc)
		end
		if (r.getResponseCode() == 200) then
			print("Creating file " .. fname)
			local f = fs.open("/music/" .. fname, "wb")
			if f then
				print("Writing to file")
				f.write(r.readAll())
				f.close()
			else
				print("Error: Could not open file")
			end
		else
			print("Error: Could not download file")
		end
	else
		print("File already exists")
	end
end


local dir, speaker = findPer("speaker")
local wc


if #args == 0 then
	print("Usage: play <file or URL> <beat interval>")
	return
end

if #args == 2 then
	interval = tonumber(args[2])
end

local fname
if http.checkURL(args[1]) then
	fname = args[1]:match("^.+/(.+)$")
	fname = fname:gsub("%%20", "_")		
	fname = fname:match("(.+)%?") or fname
	getFile(args[1])
else
	fname = args[1]
	if not fs.exists("/music/" .. fname) then
		print("File not found")
		return
	end
end

if (speaker ~= nil) then
	wc = wave.createContext()
	wc:addOutput(dir)
	print("Playing " .. fname .. " at " .. interval  .. " interval")
	
	local t = wave.loadTrack("/music/" .. fname)
    local instance = wc:addInstance(t)
    while instance.playing do -- While the instance hasn't finished playing
        wc:update() -- Updates the context which in turn plays the notes
        os.sleep(interval) 
    end
end
