local Hardware = require "hardware";

print("\nCPU: "..node.setcpufreq(node.CPU160MHZ).."MHZ");

wifi.setmode(wifi.STATION);
wifi.setphymode(wifi.PHYMODE_G);
station_cfg={}
station_cfg.ssid="dlink-7238";
station_cfg.pwd="urrlg57003";
station_cfg.save=false;
station_cfg.auto=true;
wifi.sta.config(station_cfg);

--Hardware.configGPIO();
gpio.mode(1, gpio.OUTPUT); --input
gpio.mode(2, gpio.OUTPUT); --input
gpio.mode(4, gpio.OUTPUT); -- led_log
gpio.mode(5, gpio.OUTPUT);
gpio.mode(6, gpio.OUTPUT);
gpio.mode(7, gpio.OUTPUT);
gpio.write(1, gpio.LOW);
gpio.write(2, gpio.LOW);
gpio.write(4, gpio.HIGH); -- default 1 eh off
gpio.write(5, gpio.LOW);
gpio.write(6, gpio.LOW);
gpio.write(7, gpio.LOW);

--Hardware.adcInit();
if adc.force_init_mode(adc.INIT_VDD33) then 
    node.restart()
    return
end

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
        dofile("principal.lua");
    end
end)

collectgarbage()
--[[
    adc,file,gpio,http,mqtt,net,node,pwm,tmr,wifi
]]--
