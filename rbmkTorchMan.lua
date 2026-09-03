require("term").clear()
print("Connect first RoR torch (transmitter)")
local transmitterAdd
repeat
    local _,add,ct=require("event").pull("component_added")
    if ct=="radio_torch" then transmitterAdd=add end
until transmitterAdd
print("Connected!")
print("\nConnect second RoR torch (reciever)")
local recieverAdd
repeat
    local _,add,ct=require("event").pull("component_added")
    if ct=="radio_torch" then recieverAdd=add end
until recieverAdd
print("Connected!")
print("\nWriting...")
local fh = io.open("/rbmk/torches.add","w")
fh:write(transmitterAdd.."\n"..recieverAdd)
fh:close()
print("Done!")
if require("filesystem").exists("/rbmk/rbmk.lua") then print("\nDetected RBMK control program is already installed. Run? (Y/N)\n > ");
    if string.lower(io.read("*l"))=='y' then os.execute("/rbmk/rbmk.lua") else require("term").clear() end
end
