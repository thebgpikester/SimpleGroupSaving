# Simple Group Saving by Pikey May 2019

Usage of this script should credit the following contributors:

-Pikey

-Speed & Grimes for their work on Serialising tables

-FlightControl for MOOSE (Required)
 
INTENDED AUDIENCE

DCS Server Admins looking to do long term multi session play that will need a server reboot in between and they wish to keep the Ground 
Unit positions true from one reload to the next.
 
USAGE

Ensure LFS and IO are not santitised in missionScripting.lua. This enables writing of files. If you don't know what this does, don't attempt to use this script. 
Requires versions of MOOSE.lua supporting "SET:ForEachGroupAlive()". Should be good for 6 months or more from date of writing. MIST not required, but should work OK with it regardless. 
Edit 'SaveScheduleUnits' below, (line 34) to the number of seconds between saves. Low impact. 10 seconds is a fast schedule. 
Place Ground Groups wherever you want on the map as normal.Run this script at Mission start.The script will create a small file with the list of Groups and Units. 
At Mission Start it will check for a save file, if not there, create it fresh. If the table is there, it loads it and Spawns everything that was saved. The table is updated throughout mission play. 
The next time the mission is loaded it goes through all the Groups again and loads them from the save file.
 
LIMITATIONS

Only Ground Groups and Units are specified, play with the SET Filter at your own peril. Could be adjusted for just one Coalition or a FilterByName(). See line 107 and 168 for the SET.
See https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Set.html##(SET_GROUP)

Naval Groups not Saved. If Included, there may be issues with spawned objects and Client slots where Ships have slots for aircraft/helo. Possible if not a factor.

Statics are not included. See 'Simple Static Saving' for a solution.

Routes are not saved. (lines 148-153) if you wish to keep them, but they won't activate them on restart. It is impossible to query a group for it's current route, only for the original route it recieved from the Mission Editor. Therefore a DCS limitation.
