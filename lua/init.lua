-- Begin WiFi configuration

local wifiConfig = {}

-- wifi.STATION         -- station: join a WiFi network
-- wifi.SOFTAP          -- access point: create a WiFi network
-- wifi.wifi.STATIONAP  -- both station and access point
wifiConfig.mode = wifi.STATIONAP  -- both station and access point

wifiConfig.accessPointConfig = {}
wifiConfig.accessPointConfig.ssid = "ESP-"..node.chipid()   -- Name of the SSID you want to create
wifiConfig.accessPointConfig.pwd = "ESP-"..node.chipid()    -- WiFi password - at least 8 characters

wifiConfig.accessPointIpConfig = {}
wifiConfig.accessPointIpConfig.ip = "192.168.111.1"
wifiConfig.accessPointIpConfig.netmask = "255.255.255.0"
wifiConfig.accessPointIpConfig.gateway = "192.168.111.1"

wifiConfig.stationPointConfig = {}
-- wifiConfig.stationPointConfig.ssid = "liaohome"        -- Name of the WiFi network you want to join
-- wifiConfig.stationPointConfig.pwd =  "liaoliao"        -- Password for the WiFi network
-- wifiConfig.stationPointConfig.ssid = "SEI2"        
-- wifiConfig.stationPointConfig.pwd =  "23689646"   
wifiConfig.stationPointConfig.ssid = "pliao's iPhone"        
wifiConfig.stationPointConfig.pwd =  "0975891896" 

-- Tell the chip to connect to the access point

wifi.setmode(wifiConfig.mode)
print('set (mode='..wifi.getmode()..')')

if (wifiConfig.mode == wifi.SOFTAP) or (wifiConfig.mode == wifi.STATIONAP) then
    print('AP MAC: ',wifi.ap.getmac())
    wifi.ap.config(wifiConfig.accessPointConfig)
    wifi.ap.setip(wifiConfig.accessPointIpConfig)
end
if (wifiConfig.mode == wifi.STATION) or (wifiConfig.mode == wifi.STATIONAP) then
    print('Client MAC: ',wifi.sta.getmac())
    wifi.sta.config(wifiConfig.stationPointConfig.ssid, wifiConfig.stationPointConfig.pwd, 1)
end

print('chip: ',node.chipid())
print('heap: ',node.heap())

wifiConfig = nil
collectgarbage()

-- End WiFi configuration

-- Connect to the WiFi access point.
-- Once the device is connected, you may start the HTTP server.

if (wifi.getmode() == wifi.STATION) or (wifi.getmode() == wifi.STATIONAP) then
    local joinCounter = 0
    local joinMaxAttempts = 5
    tmr.alarm(0, 3000, 1, function()
       local ip = wifi.sta.getip()
       if ip == nil and joinCounter < joinMaxAttempts then
          print('Connecting to WiFi Access Point ...')
          joinCounter = joinCounter +1
       else
          if joinCounter == joinMaxAttempts then
             print('Failed to connect to WiFi Access Point.')
          else
             print('IP: ',ip)
          end
          tmr.stop(0)
          joinCounter = nil
          joinMaxAttempts = nil
          collectgarbage()
       end
    end)
end

-- End Wifi connection

-- Include aREST module
local rest = require "aREST"

-- Set module ID & name
rest.set_id("1")
rest.set_name("esp8266")

-- Create server
srv=net.createServer(net.TCP) 
print("Server started")

-- Start server
srv:listen(80,function(conn)
  conn:on("receive",function(conn,request)

    -- Handle requests
    rest.handle(conn, request)
  
  end)

  conn:on("sent",function(conn) conn:close() end)
end)
