-- lg3_TIME.lua    V0.9
timeZoneDefault=10

function get_Time(tz, secs)

    -- returns 2 if a given year is a leap year, else returns 1
    local function isleapyear(y)
       if ((y%4)==0) or (((y%100)==0) and ((y%400)==0)) then
          return 2
       else
          return 1
       end
    end

    -- returns 366 if a given year is a leap year else returns 365
    local function daysperyear(y)
       if isleapyear(y)==2 then
          return 366
       else
          return 365
       end
    end

    if tz == nil then tz = timeZoneDefault end
    if secs == nil then secs=rtctime.get() end
    secs = secs +(tz*3600)   -- timezone adj
    local monthtable = {{31,28,31,30,31,30,31,31,30,31,30,31},{31,29,31,30,31,30,31,31,30,31,30,31}} -- days in each month
    local d=secs/86400
    local y=1970
    local m=1
    while (d>=daysperyear(y)) do d=d-daysperyear(y) y=y+1 end   -- subtract the number of seconds in a year
    while (d>=monthtable[isleapyear(y)][m]) do d=d-monthtable[isleapyear(y)][m] m=m+1 end -- subtract the number of days in a month
    secs=secs-1104494400-1104494400 -- convert from NTP to Unix (01/01/1900 to 01/01/1970)
    local hr=(secs%86400)/3600   -- hours
    local mn=(secs%3600)/60      -- minutes
    local sc=secs%60             -- seconds
    local mo=m                   -- month
    local dy=d+1                 -- day
    local yr=y                   -- year
    --return math.floor(hr),math.floor(mn),sc,math.floor(dy),mo,yr
    return string.format("%02d:%02d:%02d %02d/%02d/%04d",math.floor(hr),math.floor(mn),sc,math.floor(dy),mo,yr)
end
FREEZE("get_Time")



local SNTP_HOST = '150.101.217.196'
-- so where did that timeserver IP come from?  Google for "public sntp servers".   Eg  http://support.ntp.org/bin/view/Servers
-- I picked an "OpenAccess" one, Melbourne/Geelong, IP listed here:  http://support.ntp.org/bin/view/Servers/PublicTimeServer001121
-- In principle, any public "sntp server" should work.

-- The Real Time Clock is a crystal-controlled counter in the 8266's CPU, designed to keep track of elapsed microseconds.
-- By default it starts from zero each reboot, but if recalibrated against unix "epoch" microseconds (ie uSec since 1/1/1970 !!)
-- then the incrementing RTC count can be used to calculate real time thereafter.

-- So our code reads an sntp server & sets our rtc hardware
-- Later it can read rtc and format the count value as an accurate timedatestring


-- resident function:
-- returns the time as string of hour, minute, second, day, month and year
-- from the ESP8266 RTC seconds count (corrected to local time by tz, your timezone)
function getTime(tz, secs)   -- wrapper to hide the frozen operation
    -- secs parameter is optional.
    -- If not supplied (the default), secs is read from the rtc hardware (ie giving RTC "time just now")
    -- if secs IS supplied, then that raw secs number is calculated into the hr mn sec dy mn yr components

    -- if NO parameters are supplied, RTC is read and default timezone is used

    return FN("get_Time")(tz,secs)



end -- function getTime



-- init code:
if verboseINIT then print("\ncontacting NTP server...") end
sntp.sync(SNTP_HOST,

  -- following is the SUCCESS callback of sync
  function(sec,usec,server)   -- importantly, the rtc gets implicitly set
    if verboseINIT then print('Sync from SNTP timeserver', sec, '(and RTC set)') end
    if (sec > 1000000000) or ignoreTimeFail then
        if (TIME_OK) then TIME_OK()  end
    else
       if verboseINIT then print("Unable to get time and date from the NTP server.") end
    end
  end,

  function() -- this is the FAIL callback of sync
      print('Time setting failed!')
      oled("jnl","Time Fail")
      if ignoreTimeFail then
          if (TIME_OK) then TIME_OK()  end
      end
  end
  )


