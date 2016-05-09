-- lg3_LOGGER.lua     V0.9


-- 2 functions:  writeLog(descr)    clearLog()
-- log entry kept with timestamp 

logDepth=30   -- if too high, you might see "webpage too big" warnings

function write_Log(descr, valu, tim)

    local f = file.open("@log.var", "r")
    local j
    if not f then -- oops not existing. Create new empty one.
        file.open("@log.var", "w") 
        for j=1, logDepth do file.writeline("") end
        file.close() 
        file.open("@log.var", "r")
    end
    local rec=""
    for j=1, logDepth-1 do 
        rec = rec .. file.readline()
    end
    file.close()
    file.open("@log.tmp", "w")  -- use temp file in case of error
    if not valu then valu = " " end
    file.writeline("@ "..tim .. " -- "..descr .. " " .. valu ) -- new top line
    file.write(rec)    -- and the old data less oldest line
    lowMemMark("lg2")
    rec=nil
    file.close()
    file.remove("@log.var")
    file.rename("@log.tmp", "@log.var")
    if verboseINIT then print(string.format("%s at %s",descr, tim)) end
end
FREEZE("write_Log")

function writeLog(descr, valu)    -- wrapper to hide the frozen operation
    local tm = getTime()
    FN("write_Log")(descr, valu, tm)
end

function clearLog()
    file.remove("@log.var") -- easy!
end


