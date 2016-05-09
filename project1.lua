-- project1.lua   V0.9



--[[
 This logger suite "LG3" uses these init files:
    LG3_INIT.lua
    LG3_LOGGER.lua
    LG3_TIME.lua
    LG3_FREEZE.lua
    LG3_LOGIN.lua
    LG3_OLED.lua
    LG3_WEBSERV.lua

 When the "init" sequence is complete, it expects to hand over to your "project file(s)"  =  project.lua
 The two essential requirements in the project file are functions "action()" and "buildpage()"
 The webservr module expects to call to these (custom) functions whenever a user calls your device on web browser.
 Beyond those two functions, your project can then include whatever logging/reporting/control functions you wish.

--]]



-- 1. Compulsory ACTION() function (responding to web page buttons)
--=================================================================


-- action() and buildpage() are triggered when a web browser calls in (see webserv.lua)
-- customise to suit your project.

-- action any gpio jobs to be done
function action(_GET)
        -- let's action what came in as the page request:
        -- _GET is a table of whatever parameters (key:value) came from web browser (usually just 1 at a time)
        -- print (_GET.pin)
        if(_GET.pin == "ON1")then
            gpio.write(led1, gpio.HIGH);
        elseif(_GET.pin == "OFF1")then
            gpio.write(led1, gpio.LOW);
        elseif(_GET.pin == "ON2")then
            gpio.write(led2, gpio.HIGH);
            oled("jnl","LED2 ON  " .. string.sub(getTime(10),1,8))
        elseif(_GET.pin == "OFF2")then
            gpio.write(led2, gpio.LOW);
            oled("jnl","LED2 OFF " .. string.sub(getTime(10),1,8))  
        end
end

-- 2. Compulsory BUILDPAGE() function (html content into new web page)
--====================================================================


-- construct web page
-- webPage is a global string variable sent back to init_WEBSERV.lua
function buildpage()
        -- Build a customised string of html to be included in new web page:
        webPage = "<h2>Project 1</h2>"
        webPage = webPage.."<p>GPI016 " .. button("pin", "ON1", "HIGH") .. " " .. button("pin", "OFF1", "LOW") .. " red</p>\n";
        webPage = webPage.."<p>GPI002 " .. button("pin", "ON2", "HIGH") .. " " .. button("pin", "OFF2", "LOW") .. " blue</p>\n";
        -- And feedback: tell the web person what LED settings now are:
        if gpio.read(led1) == 0 then webPage = webPage .. "<p>RED  LED ON (pulled LOW)</p>\n" end
        if gpio.read(led2) == 0 then webPage = webPage .. "<p>BLUE LED ON (pulled LOW)</p>\n" end
        -- note webserv module will add <html>  </html> top&tail, plus the log buttons & logger display
end
-- note the "button()" function is a handy utility included in init_WEBSERV.lua


-- 3. Any GPIO or other hardware setup?
-- ====================================

-- set the GPIO pins being used
led1 = 0   -- D0 ie GPIO16 RED or BLUE LED on devkit board
led2 = 4   -- D4 ie GPIO2  BLUE LED on ESP12 part
-- set GPIO outputs
gpio.mode(led1, gpio.OUTPUT) 
gpio.write(led1,1)
gpio.mode(led2, gpio.OUTPUT) 
gpio.write(led2,1)

writeLog("Restart")  -- comment this OUT if restart event not needed in log


-- 4. The actual things that happen in YOUR project.
-- ================================================

local TMR=5

-- capture selected button press(es) and log the event:
function chkButn()  -- button gets checked every 0.15 seconds. Effective enough debounce?

    -- Button on G0 (D3) is the flash button
    btnState = gpio.read(3)
    if btnState == 0 and lastBtnState == 1 then
        writeLog("Button", "0")   
        oled("jnl","Button0  " .. string.sub(getTime(10),1,8))
    end
    lastBtnState = btnState

    -- button on gpio4 (D2) only on the Witty board
    btnState4 = gpio.read(2)
    if btnState4 == 0 and lastBtnState4 == 1 then
        writeLog("Button", "4")
    end
    lastBtnState4 = btnState4
end
lastBtnState = gpio.read(3)
lastBtnState4 = gpio.read(2)
tmr.alarm(TMR, 150, 1, chkButn)   -- this timer will tick away forever now, calling chkButn() every 150 mSec




-- from now on, the only events that cause any code to run are web page clicks coming in from browser, and ESP button presses that get logged
