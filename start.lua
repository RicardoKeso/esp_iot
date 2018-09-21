local Hardware = require "hardware";
local ledLog = 4;

Hardware.clock("high");
Hardware.configWiFi("dlink-7238", "urrlg57003");
Hardware.configGPIO(ledLog);
Hardware.adcInit();

print("Aguardando IP...");
Hardware.BlinkLed(1, 500, ledLog);
tmr.alarm(0, 5000, 1, function()
    ipAddr = wifi.sta.getip();
    if ipAddr ~= nil then
        tmr.stop(0);
        Hardware.BlinkLedStop(1, ledLog);
        print("");
        print("IP: "..ipAddr);
        print("SSID: \""..wifi.sta.getconfig().."\"\n");
        
        dofile("principal.lua");
    end
end)

--[[
    adc,file,gpio,http,mqtt,net,node,pwm,tmr,wifi
]]--
