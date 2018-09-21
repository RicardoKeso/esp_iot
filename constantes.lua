local Const = {}

local ledLog = 4;
local ssid = "-";
local pssid = "-";
local hostname = (string.upper(wifi.sta.getmac())):gsub("%:", "");
local idMqtt = hostname;
local alias = "sala";

local server = "192.168.0.133";
local portaMQTT = 1883;
local portaHTTP = 8080
local tls = 0;
local qos = 1;
local retain = 1;
local keepAlive = 60;
local portaLocalHTML = 80;
local topicPub = "/status";
local topicSub = "/action";

wifi.sta.sethostname(hostname);
--------------------------------------------------------------------------
function Const.ledLog() return ledLog end
function Const.ssid() return ssid end
function Const.pssid() return pssid end
function Const.hostname() return wifi.sta.gethostname() end
function Const.idMqtt() return idMqtt end
function Const.server() return server end
function Const.alias() return alias end

function Const.portaMQTT() return portaMQTT end
function Const.portaHTTP() return portaHTTP end
function Const.tls() return tls end
function Const.qos() return qos end
function Const.retain() return retain end
function Const.keepAlive() return keepAlive end
function Const.portaLocalHTML() return portaLocalHTML end
function Const.topicPub() return topicPub end
function Const.topicSub() return topicSub end

function Const.textPlan_MAC()
    local mac = string.upper(wifi.sta.getmac());
    return mac:gsub("%:", "");
end

--------------------------------------------------------------------------
return Const
