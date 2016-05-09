-- telnet
-- class7
-- needs at least V0.9.1 of lg3_WEBSERV.lua

TNET=true    -- that's it!  tnet is now activated.


function action(_GET)
    -- nothing
end

function buildpage()
    webPage = "<h2>Project 7 - TNET</h2>"
    -- nothing more
end



-- Two interesting functions you could use from TNET - but of course can use the usual oled() syntax
function oledJnl(str)
    oled("jnl", str) 
    print "ok"
end
function oledYell(str1, str2)
    oled("yell", {str1 or "", str2 or ""})  
    print "ok"
end


writeLog("Restart") 
