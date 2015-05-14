local md5 = require "md5"

local root = "D:/code/tttttfile/"

local file_list = {
	"doc/",
	"etc/",
	"src/",
	"test/",
}
local wfile = io.open(root.."/check.data","w")

for i=1,#file_list do
	--print("fciv.exe "..root..file_list[i].." -r -exc md5.xml -md5 -xml "..root..file_list[i].. "/md5.xml")
	os.execute("fciv.exe "..root..file_list[i].." -r -exc md5.xml -md5 -xml "..root..file_list[i].. "/md5.xml")
	local file = io.open(root..file_list[i].."/md5.xml","r")
	local str = file:read("*a")
	print(str,#str)
	local md5_as_hex   = md5.sumhexa(str)
	print(md5_as_hex)
	wfile:write(file_list[i].."/md5.xml\n")
	wfile:write(md5_as_hex.."\n")
end