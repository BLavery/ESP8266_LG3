--[[
lg3_INIT.lua   V0.9.1
recomended used with binary file nodemcu-dev-2016-04-10-flt.bin


 This logger suite "LG3" uses these init files
    lg3_INIT.lua
    lg3_LOGGER.lua
    lg3_FREEZE.lua
    lg3_TIME.lua
    lg3_LOGIN.lua
    lg3_OLED.lua
    lg3_WEBSERV.lua

 When the "init" sequence is complete, it expects to hand over to a "project file(s)"  =  project.lua 
     (actually, you can nominate your project file name as an option a few lines under here.)


GENERAL-PURPOSE STARTUP SCRIPT.
(Put your real project starting in "projectX.lua"   --    after this wifi login, logger, time,  etc is correctly finished.)

#1. Checks if OLED display exists.
#2. Then starts the wifi log-in to your AP. WAIT for wifi to connect.
#3. When (and only if) it succeeds, call back to "wifiLoginOK" and do what that says.
    (But if login eventually fails, say "give up" and not continue.)
#4. We've logged in, so it continues. Starts the "TIME" job. This sets RealTime Clock to then keep true date/time for us.
#5. When that's done, starts the LOGGER service, then the WEBSERVER.
#6. Finally jump to "projectX.lua" for getting on with our real job. 

]]--

verboseINIT = false
-- if verboseINIT set true, extra diagnostic messages will be printed.

APlist={"theBeach","theBestSpot","blackrat","brian123","BriansHotspot","","club3","c6774663"}
-- APlist = table of one or more SSID/PW pairs for access points you use
-- eg APlist={"blackrat","brian123"}   or APlist={"blackrat","brian123","theBeach","theBestSpot"}
-- the login process will try them in sequence

ignoreTimeFail = true
-- if true, then a SNTP fetch-time failure will be ignored, and date will be defaulted to 01/01/1970!
-- otherwise the default (false or nil) is that a time-fetch failure will STOP all further operation.

local projectFile = "project7.lua"

---------------------------------------------------------------------------


-- The Low water Mark is a development diagnostic to see (very approx) the lowest/worst memory available
-- LowMemMark() checks are strategicly planted in the code where memory might be low
-- if heap memory ever gets fully exhausted, there will be an "out of memory" crash/reboot.
-- If you ever see a "Mem LWM" warning at terminal, you can conclude things are getting marginal
function lowMemMark(x)
    collectgarbage() 
    local m = node.heap()
    if LWM > m then LWM = m LWMfn=x if m<10000 then print ("Mem LWM", m, x) end end
end

-- These 2 "callbacks" are triggered by result of "lg3_login.lua"
function wifiLoginOK()                  -- stage #3 
   oled("jnl","Fetch Time?")  
   dofile("lg3_TIME.lua")   -- Fetch internet time, and then at success, TIME_OK() gets called      stage #4
end

function wifiLoginFail()   -- OPTIONAL handling of case where wifilogin fails
   oled("jnl","Login fail")
   print "Login Fail"
end


-- this callback gets triggered when timer system correctly gets internet time to set the RTC
-- (or we have set the option to IGNORE a time-fetch failure)
function TIME_OK()
    if verboseINIT then print("Logged in at "..getTime(10)) end
    dofile("lg3_LOGGER.lua")         -- stage #5
    dofile("lg3_WEBSERV.lua")
    wifiLoginOK = nil    -- final cleanup of finished objects
    wifiLoginFail=nil
    verboseINIT=nil
    ignoreTimeFail=nil
    TIME_OK=nil
    oled("msgbox",{"LG3 Ready",wifi.sta.getip(),"AP= "..SSID,string.sub(getTime(10),1,14) })
    tmr.alarm(3,1,0,  function() 
        collectgarbage()
        dofile(projectFile)            -- launch project           -- stage #6 
        --print ("IP " .. wifi.sta.getip())
        if rtctime.get() > 10000 then print ("Time is ".. getTime(10)) end 
        print ("Project running on LG3")
        SSID=nil
        FREEZE=nil
    end ) 
end

-- here is where the first actions occur:
LWM = 100000 -- a global that can be interrogated in ESPlorer  We need to start with a high value

wifi.sta.disconnect()  -- we will start wifi login afresh

dofile("lg3_FREEZE.lua")
dofile("lg3_OLED.lua")   -- Is oled present?  stage #1
dofile("lg3_LOGIN.lua")   --  wifi login to available AP ...   Stage #2

-- if login succeeds, next thing to happen is wifiLoginOK() gets triggered

