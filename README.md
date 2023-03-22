# Simple Group Saving by Pikey May 2019 (updated March 2023)

Usage of this script should credit the following contributors, copy and paste it into your code and DO NOT DELETE else I will have your mission removed from wherever it is:

-Pikey
-Speed & Grimes for their work on Serialising tables
-FlightControl for MOOSE (Required)
-FunkyFranky for a quick solution on an error in a loop
-Moose contirbutors with radian fixes, ideas and requests
 
## WHAT IS THIS?

This script saves all ground unit positions and headings (air and ships and statics are ignored) in the game to a local save file. Everytime the mission is started the script checks for an existing save file and puts the units in their most recent place. This script can be used by DCS Server Admins looking to do long term multi session play that will need a server reboot in between.
 
## REQUIREMENTS

1. MOOSE.lua ( https://github.com/FlightControl-Master/MOOSE_INCLUDE/tree/master/Moose_Include_Static ) Run this file at Mission Start using a Trigger in your mission for ON MISSION START with no conditions and an action of DO FILE pointing to Moose.lua
2. The SGS.lua file in this repository. Run this file after the Moose.lua, preferably as a ONCE trigger with no conditions and a DO FILE action. 
3. Your target DCS installation must have access to run io and lfs to write the file. This is a step that is unavoidable for saving any file via a mission but it carries risk whcih I will explain as a footnote**

## LIMITATIONS

By default saves both coalitions, and only Ground groups and units. Can be adjusted for just one Coalition or a FilterByName() which means units that share the same string of letters in their name.
See https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Set.html##(SET_GROUP)

Air units are not Saved. The reason is that the DCS API (Simulator Scripting Engine) does not allow us to export any Tasks of a plane in memory, thus respawning a plane without the game memory will cause air units to just RTB instantly.

Naval Groups not Saved. The reason is that Naval units acting as airbases that hold a Client plane/helo slot cannot be spawned in a new place. Since ships don't go far, it's not always a problem. If you want to include non airbase type ships it would require sorting through ships by name and a specific setup.

Statics are not included. See 'Simple Static Saving' in my repo for a solution.

Routes are not saved. Routes and tasks for dynamically routed or dynamically tasked AI cannot be accessed, its in DCS memory and ED haven't given us tools for accessing it. Therefore a DCS limitation.

## Changes
-Updated March 2023 - moved saves to saved games and provided variable at top for customising save name
-Updated Dec 2022 - worked around a bug that caused every unit found in a group to return the first one's details. Not sure when that broke, possibly October 2022

## **MissionScripting.lua Sanitization.
People today are getting to blasé about doing this on their clients. Whilst on one hand writers are enabling things with this code that DCS should have written years ago, on the other hand we are having to open up security measures to do it. Since it makes no difference because people can Google how to do it without reading I am going to put a DISCLAIMER and clear warning here:

### DISCLAIMER
The lua modules of os, lfs and io enable the execution of any code from within the mission environment. This is a double edged sword. As a server, you only execute what you want, and therefore as long as this is your server and you understand not to download any mission file and run it without reading the code that executes, your risk is quite small, and smaller for having more brains and time to check. 
As a Client, and I mean someone who joins other servers this problem is much, much worse. If you join a server normally you do not execute the servers code, you just listen to its units moving around and messages and so on. However, in a certain set of circumstances you can run code from someone else on your machine. I've seen it exploited with my own eyes and it made the blood drain from my face. The most common method is to run a server track file, however that is not the only method.

THis script does not enable anything, you have to do that. You will not be able to blame ED for any loss or damage, even if you downloaded the file from their repository. That waiver is in your license agreement. To imagine they check all that code is an inexusable naivety anyway. You perform the actions below with the full knowledge of the Risk to your computer, data and liveliehood:

Comment out the lines in [DCS Installation]\Scripts\MissionScripting.lua using two minus -- 
![image](https://user-images.githubusercontent.com/22999891/226926947-3989c324-0ef7-4d05-9413-c87adf281da1.png)
