-- Downloads all nbs files from https://github.com/TheInfamousAlk/nbs and puts them in /music/

local nbsurl = "https://github.com/nimbuldev/mctv/tree/master/nbs"


local function getFile(url, fname)
	if (not fs.exists(fname)) then
		print("GETTING " .. url)
		local r = http.get(url, nil, true)
		-- If the response is redirect, follow it
        if r then
            if (r.getResponseCode() == 301 or r.getResponseCode() == 302) then
                print("Redirected to " .. r.getResponseHeaders()["Location"])
                local loc = r.getResponseHeaders()["Location"]
                r.close()
                return getFile(loc, fname)
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
                print("Error: status code " .. r.getResponseCode())
            end
        else 
            print("Error: got nil response")
        end
	else
		print("File already exists")
	end
end





local nbs = http.get(nbsurl)
local nbshtml = nbs.readAll()
nbs.close()

-- find all the links to nbs files
local nbsfiles = {}
for nbsfile in string.gmatch(nbshtml, 'href="(.-)"') do
    if string.sub(nbsfile, -4) == ".nbs" then
        -- Append ?raw=true
        nbsfile = nbsfile .. "?raw=true"
        -- if it's a relative link that includes TheInfamousAlk/nbs, remove it and make it absolute
        if string.sub(nbsfile, 1, 1) == "/" then
            nbsfile = "https://github.com" .. nbsfile
        end
        -- if it's a relative link that doesn't include TheInfamousAlk/nbs, add it
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
    getFile(nbsfile, name)
    os.sleep(0.25)
end