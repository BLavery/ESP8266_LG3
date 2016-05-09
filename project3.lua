-- hourly log all inputs
-- class6 project 3   V0.9



-- 1. Compulsory ACTION() function (responding to web page buttons)
--=================================================================


-- action() and buildpage() are triggered when a web browser calls in (see webserv.lua)
-- customise to suit your project.

-- action any gpio jobs to be done arising from browser buttons
function action(_GET)
        -- let's action what came in as the page request:
        -- _GET is a table of whatever parameters (key:value) came from web browser (usually just 1 at a time)
        -- print (_GET.pin)
        if(_GET.pin == "ON1")then
            gpio.write(led, gpio.HIGH);
        elseif(_GET.pin == "OFF1")then
            gpio.write(led, gpio.LOW);
        end

end

-- 2. Compulsory BUILDPAGE() function (html content into new web page)
--====================================================================


-- construct web page
-- webPage is a global string variable sent back to lg3_WEBSERV.lua

pageRefresh=40000

function buildpage()
        -- Build a customised string of html to be included in new web page:
        chkGpios()
        webPage = "<h2>Inputs Logger Project 3</h2>"
        local state = (gpio.read(led) == 0) and " ON" or " OFF"
        webPage = webPage.."<p>GPI002 (D4) " .. button("pin", "ON1", "HIGH") .. " " .. button("pin", "OFF1", "LOW") .. state .. "</p>\n";
        webPage = webPage .. "<p>GPIO States: " .. gpiostates .. " &nbsp; " ..
            button("r", "", "Refresh") .. "</p>\n"
end


-- 3. Any GPIO or other hardware setup?
-- ====================================

-- set the GPIO pins being used
led = 4   -- D4 ie GPIO2  BLUE LED on ESP12 part
gpio.write(led,0)   -- led on - just a sign to user that all is running.
-- this led is also still controllable (at browser)

-- all else left as inputs (default)


-- 4. The actual things that happen in YOUR project.
-- ================================================


gpiostates=""


function chkGpios() 
    gpiostates = "" 
    for D=0, 8 do
        if (D==i2c_sda or D==(i2c_sda+1)) then -- the 2 i2c pins just get a dot
            gpiostates = gpiostates .. "."
        else
            gpiostates = gpiostates .. ((gpio.read(D)==1) and "-" or tostring(D))
        end
    end

end
tmr.alarm(4, 1000, 1, chkGpios)   -- this timer will tick away forever now, keeping "gpiostates" string updated each second




-- a 5-second time displays on oled screen
tmr.alarm(0, 5000, 1, function()
    tt = getTime()
    oled("yell", {string.sub(tt,1,8), gpiostates} )

end)

-- an hourly timer for browser-based logger
tmr.alarm(3, 3600000, 1, function()
    writeLog(gpiostates)
end)


chkGpios()  
writeLog(gpiostates, " [restart]")  -- one entry immediately

-- from now on, the only events that cause any code to run are web page clicks coming in from browser, and timers

