-- this is a micro http server that takes care about allowing simple access on local data
-- don't worry it only binds to localhost
-- requires copas, lfs and gd libraries (Lua for windows has it all, otherwise, lua rocks and gcc is your friend.

require "lfs"
require "copas"
require "gd"

root = lfs.currentdir().."/build"

local defaultanswer = ([[
HTTP/1.1 %d %s
Content-Length: %d
Connection: close
Content-Type: %s

]]):gsub("\n","\r\n")
mimes = {
	css = 'text/css; charset=utf-8',
	png = 'image/png',
	jpg = 'image/jpeg',
	swf = 'application/x-shockwave-flash',
	html = 'text/html; charset=utf-8',
	xml = 'text/xml; charset=utf-8',
	js = 'text/javascript; charset=utf-8'
}
local gen = assert(loadfile("press.lua"))
local function httpd (skt)
	local function read (len) if len == 0 then return end return copas.receive(skt,len or "*l") end
	local function write(stuff) copas.send(skt,stuff) end
	-- read headers
	local header = {}
	local content_length = 0
	repeat
		local line = read()
		if line == "shutdown" then os.exit(0) end
		header[#header+1] = line
		--print(line)
		if not line then return end
		content_length = tonumber(line:lower():match "^content%-length:%s*(%d+)" or content_length)
	until not line or line == ""
	local post = read(content_length)

	if #header <2 then return skt:close() end
	local method,path,ver = header[1]:match "^(%S+)%s+(.*)%s+HTTP/([%d%.]+)$"
	local path,q = path:match "^([^?]*)?*(.*)$"

	if not method or (method ~= "POST" and method ~= "GET") then return skt:close() end
	if path:match "%.%." or #path>64 then return skt:close() end

	--if path == "/" then
		if lfs.attributes(root..path.."/index.html") then
			path = path.."/index.html"
		else
			--path = "/index.lua"
		end
	--end

	if path:match "%.html" then 
		gen "clean" 
	end
	path = root..path

	if not lfs.attributes(path) then
		local content = "The requested file '"..path.."' could not be found."
		write(defaultanswer:format(404,"File not found",#content,"text/html",content))
		return skt:close()
	end
	local status = 200
	local contenttype = "text/html; charset=utf-8"
	local content = "text/html\ndefaultanswer..."
	if path:match "%.lua$" then
		local f = assert(loadfile(path))
		local qpar = {}
		local function deurl(str)
			return str:gsub("%+"," "):gsub("%%(..)", function(p)
				return string.char(tonumber(p,16))
			end)
		end
		for key,param in q:gmatch "([^&]+)=([^&]+)" do
			qpar[deurl(key)] = deurl(param)
		end

		local out = {}
		local env = setmetatable({
			setcontenttype = function (t)
				contenttype = t
			end,
			setstatus = function(t) status = t end;
			path = path;
			q = q;
			get = qpar;
			post = post or "";
			method = method;
			send = function(x) out[#out+1] = x end;
		},{__index = _G})

		function env.include(f)
			local fn = assert(loadfile(f))
			setfenv(fn,env)
			return fn()
		end

		function env.print(...)
			for i=1,select('#',...) do out[#out+1] = tostring(select(i,...)) end
			out[#out+1] = "\n"
			return env.print
		end
		setfenv(f,env)
		local co = coroutine.create(f)
		repeat
			local ok,err = coroutine.resume(co,path,q,method)
			if not ok then
				status = 500
				contenttype = "text/plain"
				out = {"Server error: ",err,"\n",debug.traceback(co,err)}
				break
			end
		until coroutine.status(co) == "dead"

		content = table.concat(out)
	else
		local ext = path:match "%.([^./]*)$"
		contenttype = ext and mimes[ext] or "text/plain; charset=utf-8"
		local fp = assert(io.open(path,"rb"))
		content = fp:read "*a"
		fp:close()
	end

	write(defaultanswer:format(status,"OK",#content,contenttype)..content)
	--print(#(defaultanswer:format(status,"OK",#content,contenttype)..content),#content)
	skt:close()
end

print "Starting server on localhost:19293"
local sk = socket.connect("*",19293)
if sk then copas.send(sk,"shutdown\n") end

copas.addserver(assert(socket.bind("*",19293)),httpd)


function tick()
	copas.step(1);
end

while true do tick() end
