local Hardware = {}

function Hardware.BlinkLed(id, tempo)
    tmr.alarm(id, tempo, 1, function ()
        status = ((status == gpio.LOW) and gpio.HIGH or gpio.LOW)
        gpio.write(4, status);
    end)
end

function Hardware.BlinkLedStop(id)
    tmr.stop(id);
    gpio.write(4, gpio.HIGH);
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
