# ESP8266_LG3
An 8266 datalogger platform with webserver, true time, event logging, virtual memory, oled, telnet.

Project LG3

An 8266 datalogger platform with webserver, true time, event logging, virtual memory, oled, telnet.


LG3 is a small suite of lua files that forms an IoT logger platform, operating via local Access Point.  (It's “LG3” simply because there were two earlier versions.) It works easily on the devkit 1.0 boards and the variant clones based on ESP-12, but there is little reason that ESP-01 should not support many of the features. On this standard datalogger platform, you then add your specific “project”.

This github version is a snapshot taken from an evolving class project. See http://www.blavery.com/iot/ 
The github files may or may not receive advancements in code/features from that project. However, if something is broken here, that will be fixed.


Environment:
esp-12 based board (although esp-01 should be usable)
NodeMCU lua. Lua 5.1.4 was used for testing, on SDK 1.5.1
ESPlorer, at least for setting up & testing


Lua binary:
Your lua bin build should support at least these modules:  Adc, file, gpio, I2C, net, node, pwm, RTC-time, SNTP, timer, U8g with font_6x10, wifi. At this time (Apr 2016) the dev build supports deregistering wifi events more flexibly than master build, and so is recommended.  (It runs 115200 baud native, too.)


“LG3” suite includes these features:
2 second startup delay, for “panic/crash” escape.
The esp-12 led flashes during the delay time.
Escape with “flash” or “user” button at end of delay time.
Login to first available of up to 5 preset AP stations. 
This suits using variously at “class” and at home and from phone hotspot.
Auto wifi reconnection if wifi fails.
Read true time from any selected SMTP timeserver, and preserving that at RTC. 
Settable default timezone, over-rideable. 
Plaintext time-date.
Auto sensing of a connected OLED 0.96” I2C (4 pin) display. 
A small suitable library of oled layout styles.
Background oled pixel-painting.
2 gpio options to suit esp-12 and esp-01
Suits 1 or 2 colour oled, but alignment uses 2 colour to effect.
A primitive virtual memory system for “freezing” selected functions to flash file, and recalling at required runtime moments. 
LG3 code tuned to leave plenty of heap space for your project functions.
Adequate 7 mSec function reload time.
Globals LWM and LWMfn can be used to examine “low water mark”, ie lowest detected heap space.
A “datalogger” function to log events.
Timestamp stored with every event.
Stored on flash file.
Configurable capacity.
A sel-contained webserver process for simple button-based web page. 
Multi-packet TCP sending.
Framework for handling responses (eg GPIO write) to each button. 
Simple button() function to generate that html easily.
Custom coded html kept to minimum. A html coding “wrapper” supplies most of web page content.
Includes option code for datalogger buttons and TNET fields
Options to have web page auto-refresh.
Javascript refresh
Easy support for event logger display and erase buttons at web page. 
One option turns web page data log functions active or not.
On completion of all LG3 logger platform setup, transfer to whatever custom “project” lua file is to be run.
Possibly your “project” code requirements are now quite minimal, as the LG3 platform has supplied a comprehensive base of functions.
Support for optional simple “telnet” function where browser can have a text input field, to be sent to the lua interpreter. See project7.lua.
Enter command in text box, hit <ENTER> to submit. 
See the interpreter response (if any) by RESULT button as the subsequent web operation. 


Your “project”:
Several sample “project” files supplied, run on LG3 platform:
1. The “ubiquitous” 2 gpio out simple control from web page
2. WebIO-esp – control over each gpio, ala the defunct WebIO-pi
3. Scheduled hourly (or whatever) logging of all GPIO data
4. Simple demo of all supplied oled display styles
5. HC04 sonar logging/control – not yet
6. PIR logging – not yet
7. TNET – a minimal “telnet” access 
8. Battery voltage (or LDR) level monitor – not yet
9. Capture/logging of multiple button/switch events – not yet

Your project file MUST supply functions action(_GET) and buildpage().
You also handle any GPIO or device setup, and the device monitoring and event logging your project entails.


Configuration Options:
In lg3_INIT.lua:
Aplist={"theSand","77T5%s","blackphone","77YYt56"}
1 to 5 AP login/password pairs, to be tried in turn
ignoreTimeFail = true
If true, then a SNTP failure is ignored, continue with date 01/01/1970!
local projectFile = "project7.lua"
Where you nominate what “project” file will be run
In lg3_LOGGER.lua:
logDepth=30
Set how many logger entries will be kept. Oldest is then discarded.
In lg3_TIME.lua:
timeZoneDefault=10
Set your default timezone. Time function call can override this.
In your project file, optional globals for use by webserver:
suppressLogger=true
Buttons for datalogger are included by default, enless suppressed.
pageRefresh=xx (a number)
If this exists, then web page will auto-refresh every xx milliseconds
paramRefresh=”/?log=1”     or similar
over-ride the default “/” querystring in the page refresh URL. (This example represents "show log data".)
TNET=true
Activate telnet controls on the web page.


Future directions:
Wifi as AP rather than as Station?
Regimes for modem-sleep and/or deepsleep?

