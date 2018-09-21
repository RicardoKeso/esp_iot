local Hardware = require "hardware";
local Const = require "constantes";

Hardware.clock("high");
Hardware.configWiFi(Const.ssid(), Const.pssid());
Hardware.configGPIO(Const.ledLog());
Hardware.adcInit();

print("Aguardando IP...");
Hardware.BlinkLed(1, 500, Const.ledLog());
tmr.alarm(0, 5000, 1, function()
    ipAddr = wifi.sta.getip();
    if ipAddr ~= nil then
        tmr.stop(0);
        Hardware.BlinkLedStop(1, Const.ledLog());
        print("");
        print("IP: "..ipAddr);
        print("SSID: \""..wifi.sta.getconfig().."\"\n");
        
        dofile("principal.lua");
    end
end)

--[[
    adc,file,gpio,http,mqtt,net,node,pwm,tmr,wifi
]]--
