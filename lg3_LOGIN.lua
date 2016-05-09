-- lg3_LOGIN.lua   V0.9.1

lowMemMark("lgin")
--register wifi progress callbacks

wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function()
    print("WRONG PASSWORD")
    configAP()  -- another attempt to log to an AP
end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function()
    print("AP NOT FOUND")
    configAP()  -- another attempt to log to an AP
end)

wifi.sta.eventMonReg(wifi.STA_CONNECTING, function(previous_State)
    if(previous_State==wifi.STA_GOTIP) then 
        print("Wifi lost, Retrying...")
    end
end)

function wifiRestart()
    print("Wifi restored " .. wifi.sta.getip())    
end

wifi.sta.eventMonReg(wifi.STA_GOTIP, function()
    -- this is the original GOT_IP callback.
    tmr.unregister(4)   -- terminate/release the timer 4 - we don't need it
    local _, _, devver = node.info()
    if devver==1 then   -- these unreg syntax need DEV branch?  If MASTER branch, don't try - doesnt work?
        wifi.sta.eventMonReg(wifi.STA_WRONGPWD,nil)
        wifi.sta.eventMonReg(wifi.STA_APNOTFOUND,nil)
        wifi.sta.eventMonReg(wifi.STA_GOTIP, wifiRestart) -- now a substitute GOT_IP callback for wifi REconnects
    else
        wifi.sta.eventMonStop()  -- master branch way of coping  
    end
    print("GOT IP  " .. wifi.sta.getip())
    configAP=nil
    APlist=nil
    if (wifiLoginOK) then wifiLoginOK()  end   -- we need a "let's continue on" function of this name to have been set up
end)


wifi.setmode(wifi.STATION)


function configAP()
    if #APlist>1 then   
        wifi.sta.config(APlist[1],APlist[2])  -- ... and request the login
        print ("login AP? " .. APlist[1])
        oled("jnl","Login " .. APlist[1] .. "?")
        SSID=APlist[1]  -- preserve current AP name for later. PROJECT gets an option to know it
        table.remove(APlist,1)   -- otherwise chop off first 2 fields to set up next attempt if needed
        table.remove(APlist,1)
    end

end

tmr.alarm(4,60000,0,function()   -- 60 sec timer (timer 4) in case we totally fail
    -- if timer hasn't been terminated earlier, and we got to here, we failed
    wifi.sta.eventMonStop()     -- throw away the wifi progress callbacks
    if (wifiLoginFail) then  -- has the optional loginfail function been even supplied?
         wifiLoginFail()
    else
        print "Wifi Login Fail"
    end
end)

wifi.sta.eventMonStart(150)
configAP()  -- first attempt to log to an AP
