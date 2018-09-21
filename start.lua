local Hardware = require "hardware";

Hardware.clock("high");
Hardware.configWiFi("dlink-7238", "urrlg57003");
Hardware.configGPIO();
Hardware.adcInit();

print("Aguardando IP...");
Hardware.BlinkLed(1, 500);

tmr.alarm(0, 5000, 1, function()
    ipAddr = wifi.sta.getip();
    if ipAddr ~= nil then
        tmr.stop(0);
        Hardware.BlinkLedStop(1);
        print("");
        print("IP: "..ipAddr);
        print("SSID: \""..wifi.sta.getconfig().."\"\n");
        --print("start.lua - mem alocada: "..Hardware.memoriaAloc());
        dofile("principal.lua");
    end
end)

--[[
    adc,file,gpio,http,mqtt,net,node,pwm,tmr,wifi
]]--
