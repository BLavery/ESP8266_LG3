--  lg3_FREEZE.lua   V0.9.1

local l = file.list()
local k,v
for k,v in pairs(l) do
  if string.sub(k,1,2)=="~~" then file.remove(k) end  -- delete all prev frozen function files
end

--[[
Note selected "functions" are frozen (ie stored as file on flash memory) --  and the original in-memory copy is deleted to save heap space.
Just after the function is originally declared,  see how there is a    FREEZE("myfunction") to place it out on flash file.
Those frozen functions can be brought back from flash file for the moments they are needed - "thawed" - (and deleted again.)
For example     FN("myfunction")(a,b)   becomes equivalent to the original (unfrozen) call     myfunction(a,b)
Function myfunction is "thawed" for just long enough to be called as needed.  There is a thaw time penalty of about 7 mSec to read the file.
--]]

function FREEZE(v)  -- freeze a function
        loadstring("fn = " .. v)()
		if type(fn) == "function" then
			file.open(string.format("~~%s.fn", v), "w+")
			file.write(string.dump(fn))
			file.close()
			loadstring(v.."=nil")()
		end
        fn=nil

end


function FN(v)  -- thaw & run a function (actually, just return restored function - and then need to execute it with ()  )

    -- returns frozen function
    loadstring("_fn=assert(loadfile('".. string.format("~~%s.fn", v) .. "'))")()
    lowMemMark("FN " .. v)    
    local fn = _fn   -- _fn global (loadstring needs),   fn local.
    _fn=nil  -- some juggling to ensure function gets fully de referenced
    collectgarbage()
    return fn
end
