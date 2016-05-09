-- lg3_OLED.lua    V0.9.1    TMR 6


-- setup I2c and connect display  OLED I2C 4-pin 0.96 OLED display
-- Lua BIN file must include u8g module and font "font_6x10".  Connect to GPIOs either D1,D2 or D3,D4


        -- 5 possible display functions.

        -- oled("jnl", ...)   oled("blank")   oled("yell", ...)  oled("bar", ...)   oled("msgbox", ...)


function oleddraw(job,param,pas)

        -- several STYLES or JOBS (formatting) available

 
    disp:setFont(u8g.font_6x10)
    disp:setFontRefHeightExtendedText()
    disp:setDefaultForegroundColor()
    disp:setFontPosTop()
    
    if job=="yell" then
         -- param={2 msg lines} as table
         -- USE: oled("yell", {"STOP", "WRONG WAY"})
         disp:setScale2x2()
         disp:drawStr(2, 0, string.rep(" ", (10-string.len(param[1]))/2)..param[1])
         disp:drawStr(2, 20, string.rep(" ", (10-string.len(param[2]))/2)..param[2])
         disp:undoScale()
    elseif job=="bar" then
         -- param={heading, percent} as table
         -- USE: oled("bar",{"Temp",17})
         disp:setScale2x2()
         disp:drawStr(5, 0, string.rep(" ", (10-string.len(param[1]))/2)..param[1])
         disp:undoScale()

         disp:drawRFrame(0, 30, 128, 9, 1)
         disp:drawBox(0, 30, 128*param[2]/100, 9)
         disp:drawStr(60, 45, param[2])
    elseif job=="msgbox" then
         -- param={heading, +3 msg lines} as TABLE
         -- USE: oled("msgbox",{"WARNING !","", "IP Address ",wifi.sta.getip()})
         disp:setScale2x2()
         disp:drawStr(5, 0, string.rep(" ", (9-string.len(param[1]))/2)..param[1])
         disp:undoScale()

         disp:drawRFrame(0, 18, 128, 46, 9)

         disp:drawStr(5, 23, string.rep(" ", (20-string.len(param[2]))/2)..param[2])
         disp:drawStr(5, 36, string.rep(" ", (20-string.len(param[3]))/2)..param[3])
         disp:drawStr(5, 49, string.rep(" ", (20-string.len(param[4]))/2)..param[4])
    elseif job=="jnl" then
         -- param=new journal line as string
         -- USE: oled("jnl","new entry")
         -- if new string parameter is actually == nil, clear the journal (it still prints to oled)
         if pas ==1 then
            table.remove(Jnl,1)
            table.insert(Jnl,param)
         end
         if param == nil then Jnl = {"","","",""} end
         disp:drawRFrame(0, 0, 128, 64, 4)
         disp:drawStr(5, 5, Jnl[1])
         disp:drawStr(5, 20, Jnl[2])
         disp:drawStr(5, 33, Jnl[3])
         disp:drawStr(5, 46, Jnl[4])
    end
    
    if disp:nextPage() ~= false then     -- 29 msec
        -- each segment: not finished yet
        tmr.alarm(6, 5, 0, oled)   -- timer 6  - schedule again for another pass
    else
        -- oled output has just all finished
        jobb=nil
        param=nil


    end
    oledLock = nil
    lowMemMark("ol1")


end

FREEZE("oleddraw")

-- -------------------------------------------------

opass = 0
Jnl={"","JOURNAL","",""}  -- global/persistent


function oled(style, parm)

--print(node.heap())
    lowMemMark("ol0")

    if not disp then return end  -- will simply fail silently if display is not installed
    if style ~= nil then    -- this is a fresh oled command from user
        opass = 0
        lokpass=0
        jobb = style
        param = parm
        disp:firstPage() -- 900 usec
        tmr.alarm(6, 5, 0, oled) -- actual output will be done another time
        return
        -- note that all "real" calls to here from project or elsewhere (ie style + data parameters supplied)
        -- will not call on the (thawed) oleddraw function. This keeps heap usage down at this time.
    end
    -- beyond here, no other thawed functions should be in memory, because we arrived by timer.
    collectgarbage()
    if oledLock and (lokpass<20) then  -- webserver is busy. oled locked.  But if lok looks stuck, override it
        lokpass=lokpass+1
        tmr.alarm(6, 20, 0, oled) -- locked: defer until another time
    else
        opass = opass+1
        FN("oleddraw")(jobb,param,opass)   -- 17 - 33 msec, dep on style
        -- ie  same as    oleddraw(jobb,param,opass)    if it were not frozen
    end
end




-- oled(style, ...) is called by user to start new screen output.
-- oled(nil) is then automatically called about 7 times, to "paint" the pixels in segments
-- each individual segment call is abt 55 mSec, and complete repaint is abt 450 mSec
-- a new user call before one full repaint is complete, simply starts again with new content.

-- Are u8g oled driver and our needed font installed:
i2c_sda=98   -- V0.9.1 
if u8g.font_6x10 then
    local addrs = 0x3c  -- oled 96 ssd1306
    i2c.setup(0, 1, 2, i2c.SLOW)  -- try 1:  sda D1 scl D2  - recommended for devkit 1.0
    i2c.start(0)
    local c=i2c.address(0, addrs ,i2c.TRANSMITTER)
    i2c.stop(0)
    i2c_sda = 1
    if not c then
        i2c.setup(0, 3, 4, i2c.SLOW)   -- 2nd try sda D3(gpio0) scl D4(gpio2) - eg suits esp01
        i2c.start(0)
        c=i2c.address(0, addrs ,i2c.TRANSMITTER)
        i2c.stop(0)
        i2c_sda=3
    end
    if c then 
        disp = u8g.ssd1306_128x64_i2c(addrs) -- oled display was found. init it.
        print "OLED display found"
    else 
        i2c_sda=99 
    end  

    -- the object "disp" is created if oled display is discovered.
    -- existence of disp can be used to test if oled was installed.
    -- also, i2c_sda = 1 or 3 or 99 (no i2c) depending on pins where oled was found
end


