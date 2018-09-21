local Hardware = {}

function Hardware.configGPIO(led_log)
    -- DEFININDO MODO DE OPERACAO
    gpio.mode(1, gpio.OUTPUT); --input
    gpio.mode(2, gpio.OUTPUT); --input
    gpio.mode(led_log, gpio.OUTPUT);
    gpio.mode(5, gpio.OUTPUT);
    gpio.mode(6, gpio.OUTPUT);
    gpio.mode(7, gpio.OUTPUT);
    -- gpio.mode(pinBuzzer, gpio.OUTPUT);

    -- DESLIGANDO AS GPIOs
    gpio.write(1, gpio.LOW);
    gpio.write(2, gpio.LOW);
    gpio.write(led_log, gpio.HIGH); -- default 1 eh off
    gpio.write(5, gpio.LOW);
    gpio.write(6, gpio.LOW);
    gpio.write(7, gpio.LOW);
    -- gpio.write(pinBuzzer, gpio.LOW);
end

function Hardware.BlinkLed(id, tempo)
    tmr.alarm(id, tempo, 1, function ()
        status = ((status == gpio.LOW) and gpio.HIGH or gpio.LOW)
        gpio.write(4, status);
    end)
end

function Hardware.BlinkLedStop(id, led_log)
    tmr.stop(id);
    gpio.write(led_log, gpio.HIGH);
end

function Hardware.statusPinos() -- atualiza o status atual do pino 
    local stsPinos = {}
    stsPinos[0] = gpio.read(1)==1; -- eh igual a: (gpio.read(1)==1 and true or false)
    stsPinos[1] = gpio.read(2)==1;
    stsPinos[2] = gpio.read(5)==1;
    stsPinos[3] = gpio.read(6)==1;
    stsPinos[4] = gpio.read(7)==1;
    
    return stsPinos
end

function Hardware.clock(freq)
    if (freq == "low") then
        print("\nCPU: "..node.setcpufreq(node.CPU80MHZ).."MHZ")
    elseif (freq == "high") then
        print("\nCPU: "..node.setcpufreq(node.CPU160MHZ).."MHZ")
    end
end
    
function Hardware.adcInit()
    if adc.force_init_mode(adc.INIT_VDD33) then 
      node.restart()
      return
    end
end

function Hardware.get_uptime() -- calcula o tempo online
    local segundos = tmr.time()%60;
    local minutos = (tmr.time()/60)%60;
    local horas = (tmr.time()/3600)%24;
    local dias = (tmr.time()/86400)%24;

    if (dias < 1) then
        diasStr = "";
    elseif (dias >= 2) then        
        diasStr = string.format("%d %s, ", dias, "dias");
    else
        diasStr = string.format("%d %s, ", dias, "dia");
    end
    
    return string.format("%s%02d:%02d:%02d", diasStr, horas, minutos, segundos);
end

function Hardware.get_tensao() -- formata o valor da tensao

    return string.format("%1.03f", adc.readvdd33(0)/1000);  
end

function Hardware.configWiFi(ssid, pwd)
    wifi.setmode(wifi.STATION);
    wifi.setphymode(wifi.PHYMODE_G);
    station_cfg={}
    station_cfg.ssid=ssid;
    station_cfg.pwd=pwd;
    station_cfg.save=false;
    station_cfg.auto=true;
    wifi.sta.config(station_cfg);
end

function Hardware.getHostname()

    return wifi.sta.gethostname()    
end

function Hardware.getMAC_textPlan()
    local mac = string.upper(wifi.sta.getmac());
    return mac:gsub("%:", "");
end

function Hardware.updatePino(pino_, statusPino_)
    local buf_;
    local status = tonumber(statusPino_);
    local pino = tonumber(pino_);

    if ((pino == 1) or (pino == 2) or (pino == 4) or (pino == 5) or (pino == 6) or (pino == 7))then
        gpio.write(pino, status);
        buf_ = pino..'|'..gpio.read(pino);
    else
        buf_ = pino..'|-1';
    end
    
    return buf_;
end

return Hardware
