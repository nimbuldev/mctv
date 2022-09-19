local repo = "https://github.com/nimbuldev/mctv/raw/master"

local wavepath = "/apis/wave.lua"
local shufflepath = "/shuffle.lua"
local nbspath = "/nbs/"


local function getFile(url, fname)
	if (not fs.exists(fname)) then
		print("GETTING " .. url)
		local r = http.get(url, nil, true)
        if r then
            if (r.getResponseCode() == 301 or r.getResponseCode() == 302) then
                -- print("Redirected to " .. r.getResponseHeaders()["Location"])
                local loc = r.getResponseHeaders()["Location"]
                r.close()
                return getFile(loc, fname)
            end
            if (r.getResponseCode() == 200) then
                -- print("Creating file " .. fname)
                local f = fs.open(fname, "wb")
                if f then
                    f.write(r.readAll())
                    f.close()
                else
                    -- print("Error: Could not open file")
                end
            else
                -- print("Error: status code " .. r.getResponseCode())
            end
        else 
            -- print("Error: got nil response")
        end
	else
		print("File already exists")
	end
end

print("Downloading wave.lua")
getFile(repo .. wavepath, wavepath)

print("Downloading shuffle.lua")
getFile(repo..shufflepath, "shuffle.lua")

print("Downloading songs...")
os.sleep(0.5)
local nbs = http.get(repo..nbspath)
local nbshtml = nbs.readAll()
nbs.close()

local nbsfiles = {}
for nbsfile in string.gmatch(nbshtml, 'href="(.-)"') do
    if string.sub(nbsfile, -4) == ".nbs" then
        nbsfile = nbsfile .. "?raw=true"
        if string.sub(nbsfile, 1, 1) == "/" then
            nbsfile = "https://github.com" .. nbsfile
        end
        if string.sub(nbsfile, 1, 1) ~= "/" and string.sub(nbsfile, 1, 4) ~= "http" then
            nbsfile = nbsurl .. "/" .. nbsfile
        end
        table.insert(nbsfiles, nbsfile)
    end
end

local name
for i, nbsfile in ipairs(nbsfiles) do
    name = nbsfile:match("^.+/(.+)$")
    name = name:gsub("%%20", "_")		
    name = name:match("(.+)%?") or name
    getFile(nbsfile, "/music/"..name)
end
