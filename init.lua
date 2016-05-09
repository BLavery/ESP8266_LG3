-- init.lua

-- Starts by printing Abort? then waits 2 secs with blue led flashing.
-- If you press & hold GPIO0 button (the Flash button) AFTER 1st message, and DURING end of flashing led,
-- (ie press when blue light starts for 2 seconds) 
-- then init.lua aborts.
-- This may help you escape from any startup code with a PANIC error, which can otherwise cause endless crash/reset cycle.

print "Abort by button?" 
gpio.mode(4,gpio.OUTPUT)   -- the blue led on ESP12 submodule
gpio.mode(3,gpio.INPUT)  -- make sure D3 button is working, & not left as an output since just before reset
pwm.setup(4,12,950)   -- flash
pwm.start(4)                                                          --   stage #1
tmr.alarm(4, 2000, 0, function()   -- TIMER 4
    -- we arrive here after the 2 seconds past reset
    -- see https://bigdanzblog.wordpress.com/2015/04/24/esp8266-nodemcu-interrupting-init-lua-during-boot/
    pwm.stop(4)
    pwm.close(4)          -- stop flash
    if gpio.read(3) == 0 then
        print "Button: Aborted!"
        gpio.write(4,0)        -- turn on
        return  -- EXITS
    end
    gpio.write(4,1)        -- turn led off
    gpio.mode(4,0)         -- restore to regular input mode

    -- we didn't use button to abort, so go to next stage

    dofile("lg3_INIT.lua")   -- we initialise all the LG3 suite
end)

