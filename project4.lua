-- project 4    V0.9.1
-- demo of oled modes
suppressLogger = true

function action()
end

function buildpage()
        webPage = "<h2>Project 4 - Oled demo only</h2>"
        if not disp then 
            webPage = webPage .. "NO OLED DISPLAY FOUND" 
        end
end

pass = 0
function demo() 
    pass = pass+1
    if pass == 1 then oled("yell", {"Line1", "line2"}) end
    if pass == 2 then oled("yell", {"Time", string.sub(getTime(), 1, 8)}) end
    if pass == 3 then oled("msgbox", {"heading", "Line1", "line2", "line3"}) end
    if pass == 4 then oled("yell", {"STOP", "WRONG WAY"}) end
    if pass == 5 then oled("bar",{"Temp",7}) end 
    if pass == 6 then oled("bar",{"Temp",50}) end 
    if pass == 7 then oled("bar",{"Temp",93}) end 
    if pass == 8 then oled("msgbox",{"WARNING !","Strange Access Pt?", "IP Address ",wifi.sta.getip() or "No IP"}) end
    if pass == 9 then oled("msgbox",{"HELLO","Today is", string.sub(getTime(), 10,14),"Get to work"}) end
    if pass == 10 then oled("jnl","new entry 1") end
    if pass == 11 then oled("jnl","another entry 2") end
    if pass == 12 then oled("jnl","new entry 3") end
    if pass == 13 then oled("jnl","fresh entry 4") end
    if pass == 14 then oled("jnl","new entry 5") end
    if pass == 15 then oled("jnl") pass = 0 end

end

--oled("blank")

tmr.alarm(5, 5000, 1, demo)  
