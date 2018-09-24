local Web = {}

function Web.update_arquivo(server, porta, caminho, nomeArquivo) -- atualiza o init.lua 
    server = "http://"..server..":"..porta.."/"
    arquivo = nomeArquivo
    versaoFile = "versao.txt"
    versao = '1'
    caminhoCompleto = server..caminho..arquivo

    if file.open(versaoFile, "r") then
        versao = file.readline();
        file.close()
        versao = versao + 1;
    end
        
    http.request(caminhoCompleto, "GET", "", "", function(code, data)
        if (code > 0) then
            file.rename(arquivo, "v"..versao.."."..arquivo)
            fd = file.open(arquivo, "a+")
            if fd then
                fd:write(data)
                fd:close()
            end
        else        
          print("HTTP request (file) failed - "..server)
        end
    end)

    dest = file.open(versaoFile, "w")
        if dest then
            dest:write(versao..' ')
        end
    dest:close();
    print("Arquivo "..arquivo.." atualizado")
    --node.restart()
end

function Web.reset(ipAddr, macTextPlan)
    local titulo = 'vazio'
    local delay = 1
    local buf_;

    buf_ = "<!DOCTYPE html><html><head>"
    buf_ = buf_.."<meta http-equiv=\"refresh\" content=\""..delay..";url=http://"..ipAddr.."/?func=2&sta="..macTextPlan.."\">"
    buf_ = buf_.."</head><body>"
    buf_ = buf_.."Reiniciando em <span id=\"countdowntimer\">"..delay.."</span> segundos"
    buf_ = buf_.."<script type=\"text/javascript\">"
    buf_ = buf_.."    var timeleft = "..delay..";"
    buf_ = buf_.."    var downloadTimer = setInterval(function(){"
    buf_ = buf_.."    timeleft--;"
    buf_ = buf_.."    document.getElementById(\"countdowntimer\").textContent = timeleft;"
    buf_ = buf_.."    if(timeleft <= 0)"
    buf_ = buf_.."        clearInterval(downloadTimer);"
    buf_ = buf_.."    },1000);"
    buf_ = buf_.."</script>"
    buf_ = buf_.."</body></html>"

    return buf_;
end

function Web.menuStandAlone(stsPinos_, paramGET_, macTextPlan_)

    local buf_ ;
    buf_ = "<table style=\"border: 1px solid black;\"><tr>";
    buf_ = buf_.."<td>(pD1)GPIO5 <a href=\"?func=2\&pino=1\&statusPino="..(stsPinos_[0] and "0" or "1").."\&sta="..macTextPlan_.."\"><button><b>"..(stsPinos_[0] and "ON" or "OFF").."</b></button></a></td>";
    buf_ = buf_.."<td>(pD2)GPIO4 <a href=\"?func=2\&pino=2\&statusPino="..(stsPinos_[1] and "0" or "1").."\&sta="..macTextPlan_.."\"><button><b>"..(stsPinos_[1] and "ON" or "OFF").."</b></button></a></td>";
    buf_ = buf_.."</tr><tr>";
    buf_ = buf_.."<td>(pD5)GPIO14 <a href=\"?func=2\&pino=5\&statusPino="..(stsPinos_[2] and "0" or "1").."\&sta="..macTextPlan_.."\"><button><b>"..(stsPinos_[2] and "ON" or "OFF").."</b></button></a></td>";
    buf_ = buf_.."<td>(pD6)GPIO12 <a href=\"?func=2\&pino=6\&statusPino="..(stsPinos_[3] and "0" or "1").."\&sta="..macTextPlan_.."\"><button><b>"..(stsPinos_[3] and "ON" or "OFF").."</b></button></a></td>";
    buf_ = buf_.."</tr><tr>"
    buf_ = buf_.."<td>(pD7)GPIO13 <a href=\"?func=2\&pino=7\&statusPino="..(stsPinos_[4] and "0" or "1").."\&sta="..macTextPlan_.."\"><button><b>"..(stsPinos_[4] and "ON" or "OFF").."</b></button></a></td>";
    buf_ = buf_.."<td></td></tr><tr>";
    buf_ = buf_.."<td><a href=\"?func=4&up="..macTextPlan_.."\"><button><b>UPDATE</b></button></a></td>";
    buf_ = buf_.."<td><a href=\"?func=3&rst="..macTextPlan_.."\"><button><b>RESTART</b></button></a></td>";
    buf_ = buf_.."</tr></table>";
    
    return buf_
end

function Web.status(hardware_, ipAddr_, macTextPlan_, hostname_)
    local tensao = string.format("%1.03f", adc.readvdd33(0)/1000);
    local stsPinos_ = hardware_.statusPinos()
    local buf_;
    local total_allocated, estimated_used = node.egc.meminfo();
    
    buf_ = "<pre>up time: "..hardware_.get_uptime();
    buf_ = buf_.."\nip: "..ipAddr_;
    buf_ = buf_.."\nmac: "..macTextPlan_;
    buf_ = buf_.."\ntensao: "..tensao.."V";
    buf_ = buf_.."\nlocal: "..hostname_;
    buf_ = buf_.."\nmem alocada: "..string.format("%1.01f", (total_allocated/32768)*100).."%"; --32KiB = 32768, 32KB = 32000
    buf_ = buf_.."\n";
    buf_ = buf_.."\npino 1: " .. (stsPinos_[0] and "on" or "off");
    buf_ = buf_.."\tpino 2: " .. (stsPinos_[1] and "on" or "off");
    buf_ = buf_.."\npino 5: " .. (stsPinos_[2] and "on" or "off");
    buf_ = buf_.."\npino 6: " .. (stsPinos_[3] and "on" or "off");
    buf_ = buf_.."\tpino 7: " .. (stsPinos_[4] and "on" or "off") .. "</pre>";

    return buf_
end

return Web
