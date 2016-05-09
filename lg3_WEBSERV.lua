-- lg3_WEBSERV.lua    V0.9.1

-- your project MUST supply 2 functions action(_GET) and buildpage()
-- there are also 3 (global) options that can be set in your project, affecting operation of webserver:
-- 1. if suppressLogger = true then DON'T provide "logger" reporting buttons to each web page
--    It's still legal to "writelog" to logger, but only way to see entries is via ESPlorer, not really much use in real life.
-- 2. if pageRefresh=(number xx) then web page will auto-refresh every xx millisecs
-- 3. if paramRefresh = "/?log=1" or similar then THAT querystring is in the page refresh URL. This case represents "show log data".
--    Default is null querystring in URL (ending "/"), refreshing the page without any log data.


srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    -- this function gets called each time a TCP msg arrives from a browser:
    conn:on("receive",  rcv_cb)
    conn:on("sent", function(conn)
        webPage = string.sub(webPage,1461) -- 1460 was already sent last time
        if #webPage>0 then   -- still more to send?
            conn:send(string.sub(webPage,1,1460))
        else    
            conn:close() 
            oledLock=nil
            collectgarbage()
        end
    end)
end)
-- webserver now on and listening for any incoming request

webPage=""

-- the "project" file submitted only minimal html for page title & page buttons. Not yet full html page.
-- Now add header & footer html, and logger buttons and logger data display
function pageWrap()
    -- part of the rcv_cb function
    webPage = "<html><body>\n<h1>Logger LG3</h1>" .. webPage 
    if TNET then
        if not tnetstr then tnetstr = "" end
        -- This is TNET, a mini-telnet function: enter command at browser, gets passed to lua interpreter.
        -- Pretty much anything legal at ESPlorer command box is legal here also, eg "gpio.write(4,1)" 
        local tnet_cmd=_GET.tn
        if type(tnet_cmd) == "string" then 
            tnetstr = "TNET> "..tnet_cmd
            print(tnetstr) 
            node.input(tnet_cmd)
            node.output(function(str) 
               if string.sub(str,1,2)=="> " then node.output(nil)  -- the ">" ready prompt of interpreter
               elseif str:byte(1,1) ~= 10 then tnetstr = tnetstr  .."<br />".. str   -- try to skip blank lines
               end 
            end, 1) 
            -- result printed by interpreter is available NEXT time thru here, by pressing "SEE RESULT" button
        end
        -- Now add a TNET command box and a SEE RESULT button on browser
        webPage = webPage .. "TNET: Mini telnet to Lua Interpreter:<br />"
        .. "<form><input name=tn size=30> <button>See Result</button></form>"  -- minimalist "form" !!!
        .. "<p>" .. tnetstr .."</p>"
    
    end
    local rec
    if not suppressLogger then
        -- draw 2 buttons for show/reset
        webPage = webPage .. "<hr><h2>Log</h2><p>"  
                   .. button("log", "1", "Show") .. " " 
                   .. button("log", "reset", "Reset") .. "</p>\n";
        if(_GET.log == "1") then
             -- user clicked SHOW button. read and format the log file for display            
             webPage = webPage .. "<p>"
             if file.open("@log.var", "r") then
                for num=1, logDepth do
                    rec=file.readline()
                    if #rec > 10 then 
                        webPage = webPage ..rec .."<br />"
                    end
                end
                file.close()
             end
             rec=nil
             webPage = webPage .. "</p><hr>\n"
             log=nil
             collectgarbage()
        elseif(_GET.log == "reset") then
            clearLog()
            webPage = webPage .. "<p>Log Cleared</p><hr>\n"  
        end
    end        
            
    -- optional pageRefresh to be nil or a number (milliseconds for web page auto-refresh)
    if not paramRefresh then paramRefresh = "/" end
    if pageRefresh or init then -- insert some javascript to webpage for browser to auto-refresh web page
        webPage = webPage .. "<script>setTimeout(function(){location.replace('"..paramRefresh.."')}," 
        .. (pageRefresh and pageRefresh or 3000) .. ");</script>" 
    end
     
    webPage = webPage .. "\n</body></html>"
    if #webPage > 4380 then webPage="WebPage too big. Limit 4380. Was " .. #webPage print "Webpage too big" end
    --where did this limit come from? maybe it's a myth? The routine here should cope with any length.
    _GET=nil

end
FREEZE("pageWrap")


-- this is the "callback" function triggered by incoming request:
function rcv_cb(client,request)
    -- the 10 lines below are a bit of magic that extracts any parameters like "/?pin=OFF2" in the web page request
    -- don't worry just how they work!

    local function hex_to_char(x)
      return string.char(tonumber(x, 16))
    end

    if not string.match(request,"favicon") then
        --print(request)
        oledLock=true    
        -- this lock can stay true for several calls into conn:on("sent"
        -- we don't know state of heap during background net functions. Are we paranoid?
        -- To be safe we simply prevent oled being called by its TMR for this duration.
        local _, _, _, _, vars = string.find(request, "([A-Z]+)(.+)?(.+) HTTP");
        _GET = {}
        local k,v
        if (vars ~= nil)then
            vars = vars:gsub("+"," "):gsub("%%(%x%x)", hex_to_char)  -- urldecode - needed by TNET
            for k, v in string.gmatch(vars, "(%w+)=(.+)&*") do
                _GET[k] = v
            end
        end
        
        
        if action then -- it could happen that project.lua is not yet loaded (still initialising?)
            action(_GET)           -- _GET is an array of any "querystring" parameters in web request (we expect 1 at most!)
            buildpage()            -- result returns in global webPage (incomplete html page so far)
            init=nil
        else
            webPage = "Site initialising still"
            init=true
        end
        -- we want action() & buildpage() done before FN -- for heap reasons
        FN("pageWrap")()   -- ie what pageWrap() would have been without freezing mode
        client:send(string.sub(webPage,1,1460))  -- sent first 1460 bytes (or less) - esp & internet packet limitation
        -- next thing to happen is conn:on("sent"...  above. There may be more still to send: handled above
    end

end

-- following is a utility function to make a html button on a web page. colour is optional
function button(vbl, value, label, colour)
    return '<a href="?' .. vbl .. '=' .. 
    value .. '"><button' .. 
    ((colour~='' and colour~=nil) and ' style="background-color:'..colour ..'"' or '')
     .. '>' .. label .. '</button></a>'
end

lowMemMark("ws")

