local Hardware = require "hardware";
local Web = require "web";

local ipAddr = wifi.sta.getip();
local macTextPlan = string.upper(wifi.sta.getmac()):gsub("%:", "");

local espId = macTextPlan;

local led_log = 4;
local serverName = "192.168.0.133";
local portaServerMQTT = 1883;
local portaServerHTTP = 8080;
local portaLocalHTTP = 80;
local tls = 0;
local qos = 1;
local retain = 1;
local keepAlive = 60;
local topicPub = "/status";
local topicSub = "/action";

local mqttP1 = espId.."/p01";
local mqttP2 = espId.."/p02";
local mqttP5 = espId.."/p05";
local mqttP6 = espId.."/p06";
local mqttP7 = espId.."/p07";

local m = mqtt.Client(espId, keepAlive);
local srv = net.createServer(net.TCP);

local localEsp = "sala"

-- ***************************************************************************************************************

function Receiver(client, request)
    gpio.write(led_log, gpio.LOW);
    collectgarbage()
    --
    local response = {};
    local _GET = {};

    local function send(localSocket_)
        if #response > 0 then
            localSocket_:send(table.remove(response, 1));
        else
            localSocket_:close();
            response = nil;
        end
    end

    local function Enviar()
        client:on("sent", send);
        send(client);
        collectgarbage();
    end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    if (string.find(request, "favicon.ico") ~= nil) then
        response[1] = "HTTP/1.1 404"; -- 404 not found
    else        
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        
        if (vars ~= nil) then -- captura as variaveis GET 
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v;
            end

            if ((_GET.func == "2") and (_GET.sta == macTextPlan)) then
                if ((_GET.pino ~= nil) and (_GET.statusPino ~= nil)) then
                    Hardware.updatePino(_GET.pino, _GET.statusPino);
                    m:publish(espId.."/p0".._GET.pino..topicPub, _GET.statusPino, qos, retain);
                end
                response[2] = Web.menuStandAlone(Hardware.statusPinos(), _GET, macTextPlan);                    
                response[1] = Web.status(Hardware, ipAddr, macTextPlan, localEsp);
            elseif ((_GET.func == "3") and (_GET.rst == macTextPlan))  then
                response[1] = Web.reset(ipAddr, macTextPlan);
            elseif ((_GET.func == "4") and (_GET.up == macTextPlan))  then
                Web.update_arquivo(serverName, portaServerHTTP, "principal.lua");
                response[1] = Web.reset(ipAddr, macTextPlan);
            end
        else
            response[1] = Web.reset(ipAddr, macTextPlan);
        end
    end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Enviar();
    --
    gpio.write(led_log, gpio.HIGH);
end

srv:listen(portaLocalHTTP, function(conn) conn:on("receive", Receiver) end)

-- ***************************************************************************************************************

function StartMqtt(m)
    collectgarbage()

    m:on("message", 
        function(client, topic, data)    
            gpio.write(led_log, gpio.LOW);  
            --
            if (topic == mqttP1..topicSub) then
                gpio.write(1, ((data == "0") and gpio.LOW or gpio.HIGH));
                client:publish(mqttP1..topicPub, gpio.read(1), qos, retain);
            elseif (topic == mqttP2..topicSub) then
                gpio.write(2, ((data == "0") and gpio.LOW or gpio.HIGH));
                client:publish(mqttP2..topicPub, gpio.read(2), qos, retain);
            elseif (topic == mqttP5..topicSub) then
                gpio.write(5, ((data == "0") and gpio.LOW or gpio.HIGH));
                client:publish(mqttP5..topicPub, gpio.read(5), qos, retain);
            elseif (topic == mqttP6..topicSub) then
                    gpio.write(6, ((data == "0") and gpio.LOW or gpio.HIGH));
                    client:publish(mqttP6..topicPub, gpio.read(6), qos, retain);
            elseif (topic == mqttP7..topicSub) then
                gpio.write(7, ((data == "0") and gpio.LOW or gpio.HIGH));
                client:publish(mqttP7..topicPub, gpio.read(7), qos, retain);
            end
            --        
            gpio.write(led_log, gpio.HIGH);
        end
    );

    local function Conectar(logFlag)
        m:close();
        m:connect(serverName, portaServerMQTT, tls, 
            function(client)
                print("MQTT - conectado "..serverName..":"..portaServerMQTT.."\n")
                Hardware.BlinkLedStop(1);

                m:subscribe(
                {
                    [mqttP1.."/action"]=qos,
                    [mqttP2.."/action"]=qos,
                    [mqttP5.."/action"]=qos,
                    [mqttP6.."/action"]=qos,
                    [mqttP7.."/action"]=qos
                })
                --function(conn) print("MQTT - subscribe") end)                
            end,            
            function(client, motivoId)
                if (logFlag) then
                    
                    if (motivoId == -5) then
                        print("servico("..serverName..") nao encontrado.\n");
                    elseif (motivoId == -2) then
                        print("servico("..serverName..") travado.\n");
                    else        
                        print("motivo falha: " .. motivoId);
                    end

                    logflag = false
                    Hardware.BlinkLed(1, 250)
                end
                tmr.alarm(2, 5000, tmr.ALARM_SINGLE, function() Conectar(logflag) end)
            end);
    end

    m:on("offline", function(client) print ("Offline") Conectar(true) end)

    Conectar(true);
end

StartMqtt(m);

-- ***************************************************************************************************************

collectgarbage()
