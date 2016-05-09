-- webioesp    V0.9

-- project2.lua  class 6


-- 1. Compulsory ACTION() function (responding to web page buttons)
--=================================================================

function action(_GET)
    -- like "/?M=3" - toggle o pin's mode in/out
    D=_GET.M
    if (D) then 
        D = tonumber(D)
        mode[D] = 1-mode[D]   -- toggle preserved table to keep track of in/out modes (we can't read this back from gpio)
        gpio.mode(D, mode[D]) -- actual gpio set to match the table entry
        print("D"..D.." mode " .. ((mode[D]==0) and "IN" or "OUT") )
        oled("jnl", "D"..D.." mode " .. ((mode[D]==0) and "IN" or "OUT") )
    end
    
    -- like "/?W=3"   - toggle an output (only) pin hi/lo
    D=_GET.W
    if (D) then
        D = tonumber(D)
        if (mode[D]==1) then -- output pin?
            gpio.write(D, 1-gpio.read(D)) -- toggle output
            print("D"..D.." write " .. gpio.read(D))
            oled("jnl","D"..D.." write " .. gpio.read(D))
        end 
    end
    
end

-- 2. Compulsory BUILDPAGE() function (html content into new web page)
--====================================================================

suppressLogger = true
pageRefresh=15000

function buildpage()
        webPage = "<h2>WebIOesp</h2>"
        if flashsize<4096 then webPage = webPage .. "This seems to be an ESP-01 !" end
        for D=0,8 do   -- do all 9 gpio numbers D0-D8
            if not (D==i2c_sda or D==(i2c_sda+1)) then -- exc skip over D1 D2 or whatever i2c was found on
                -- for each gpio, make two clickable buttons one for mode one for output write
                webPage = webPage .. "<p>"..button("M", tostring(D), (mode[D]==0) and ".IN." or "Out",(mode[D]==0) and "lightgreen" or "pink") .. " &nbsp; " 
                .. button("W", tostring(D), "D"..tostring(D),(gpio.read(D)==0) and "" or "red") .." "..Descr[D+1].."</p>\n" 
            end
        end

end



-- 3. Any GPIO or other hardware setup?
-- ====================================

_,_,_,_,_,flashsize=node.info()    _=nil   -- 6th return value    discard first 5

Descr= {"","","","Pump1","Led","Door Sw","Pump2","","Horn"}

-- set all gpio as input. To real gpio system and to "ghost" table mode{} that is supposed to stay in step.

mode = {}
for D=0,8 do 
    if not (D== i2c_sda or D==(i2c_sda+1)) then gpio.mode(D,0) mode[D] = 0 end
end   -- D is D0 D1 - D8 etc marked on devkit brd
-- note we skip over d1 d2  because we used those for i2c oled

-- exc we decide to set D4 as output:    0=input 1=output   (just like 0=low   1=hi)
gpio.mode(4,1) mode[4] = 1

writeLog("Restart")  -- comment this OUT if restart event not needed in log


-- 4. The actual things that happen in YOUR project.
-- ================================================

