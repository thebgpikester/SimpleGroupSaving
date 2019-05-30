-- Simple Group Saving by Pikey May 2019 https://github.com/thebgpikester/SimpleGroupSaving/
-- Usage of this script should credit the following contributors:
 --Pikey, 
 --Speed & Grimes for their work on Serialising tables, included below,
 --FlightControl for MOOSE (Required)
 
 --INTENDED USAGE
 --DCS Server Admins looking to do long term multi session play that will need a server reboot in between and they wish to keep the Ground 
 --Unit positions true from one reload to the next.
 
 --USAGE
 --Ensure LFS and IO are not santitised in missionScripting.lua. This enables writing of files. If you don't know what this does, don't attempt to use this script.
 --Requires versions of MOOSE.lua supporting "SET:ForEachGroupAlive()". Should be good for 6 months or more from date of writing. 
 --MIST not required, but should work OK with it regardless.
 --Edit 'SaveScheduleUnits' below, (line 34) to the number of seconds between saves. Low impact. 10 seconds is a fast schedule.
 --Place Ground Groups wherever you want on the map as normal.
 --Run this script at Mission start
 --The script will create a small file with the list of Groups and Units.
 --At Mission Start it will check for a save file, if not there, create it fresh
 --If the table is there, it loads it and Spawns everything that was saved.
 --The table is updated throughout mission play
 --The next time the mission is loaded it goes through all the Groups again and loads them from the save file.
 
 --LIMITATIONS
 --Only Ground Groups and Units are specified, play with the SET Filter at your own peril. Could be adjusted for just one Coalition or a FilterByName().
 --See line 107 and 168 for the SET.
 --See https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Set.html##(SET_GROUP)
 --Naval Groups not Saved. If Included, there may be issues with spawned objects and Client slots where Ships have slots for aircraft/helo. Possible if not a factor
 --Statics are not included. See 'Simple Static Saving' for a solution
 --Routes are not saved. Uncomment lines 148-153 if you wish to keep them, but they won't activate them on restart. It is impossible to query a group for it's current
 --route, only for the original route it recieved from the Mission Editor. Therefore a DCS limitation.
 -----------------------------------
 --Configurable for user:
 SaveScheduleUnits=10 --how many seconds between each check of all the statics.
 -----------------------------------
 --Do not edit below here
 -----------------------------------
 local version = "1.0"
 
 function IntegratedbasicSerialize(s)
    if s == nil then
      return "\"\""
    else
      if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
        return tostring(s)
      elseif type(s) == 'string' then
        return string.format('%q', s)
      end
    end
  end
  
-- imported slmod.serializeWithCycles (Speed)
  function IntegratedserializeWithCycles(name, value, saved)
    local basicSerialize = function (o)
      if type(o) == "number" then
        return tostring(o)
      elseif type(o) == "boolean" then
        return tostring(o)
      else -- assume it is a string
        return IntegratedbasicSerialize(o)
      end
    end

    local t_str = {}
    saved = saved or {}       -- initial value
    if ((type(value) == 'string') or (type(value) == 'number') or (type(value) == 'table') or (type(value) == 'boolean')) then
      table.insert(t_str, name .. " = ")
      if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
        table.insert(t_str, basicSerialize(value) ..  "\n")
      else

        if saved[value] then    -- value already saved?
          table.insert(t_str, saved[value] .. "\n")
        else
          saved[value] = name   -- save name for next time
          table.insert(t_str, "{}\n")
          for k,v in pairs(value) do      -- save its fields
            local fieldname = string.format("%s[%s]", name, basicSerialize(k))
            table.insert(t_str, IntegratedserializeWithCycles(fieldname, v, saved))
          end
        end
      end
      return table.concat(t_str)
    else
      return ""
    end
  end

function file_exists(name) --check if the file already exists for writing
    if lfs.attributes(name) then
    return true
    else
    return false end 
end

function writemission(data, file)--Function for saving to file (commonly found)
  File = io.open(file, "w")
  File:write(data)
  File:close()
end

--SCRIPT START
env.info("Loaded Simple Group Saving, by Pikey, 2018, version " .. version)

if file_exists("SaveUnits.lua") then --Script has been run before, so we need to load the save
  env.info("Existing database, loading from File.")
  AllGroups = SET_GROUP:New():FilterCategories("ground"):FilterActive(true):FilterStart()
    AllGroups:ForEachGroup(function (grp)
      grp:Destroy()
    end)

  dofile("SaveUnits.lua")
  tempTable={}
  Spawn={}
--RUN THROUGH THE KEYS IN THE TABLE (GROUPS)
  for k,v in pairs (SaveUnits) do
    units={}
--RUN THROUGH THE UNITS IN EACH GROUP
      for i= 1, #(SaveUnits[k]["units"]) do 
  
tempTable =

  { 
   ["type"]=SaveUnits[k]["units"][i]["type"],
   ["transportable"]= {["randomTransportable"] = false,}, 
   --["unitId"]=9000,used to generate ID's here but no longer doing that since DCS seems to handle it
   ["skill"]=SaveUnits[k]["units"][i]["skill"],
   ["y"]=SaveUnits[k]["units"][i]["y"] ,
   ["x"]=SaveUnits[k]["units"][i]["x"] ,
   ["name"]=SaveUnits[k]["units"][i]["name"],
   ["heading"]=SaveUnits[k]["units"][i]["heading"],
   ["playerCanDrive"]=true,  --hardcoded but easily changed.  
  }

      table.insert(units,tempTable)
    end --end unit for loop


groupData = 

  {
    ["visible"] = true,
    --["lateActivation"] = false,
    ["tasks"] = {}, -- end of ["tasks"]
    ["uncontrollable"] = false,
    ["task"] = "Ground Nothing",
    --["taskSelected"] = true,
    --["route"] = 
    --{ 
    --["spans"] = {},
    --["points"]= {}
    -- },-- end of ["spans"] 
    --["groupId"] = 9000 + _count,
    ["hidden"] = false,
    ["units"] = units,
    ["y"] = SaveUnits[k]["y"],
    ["x"] = SaveUnits[k]["x"],
    ["name"] = SaveUnits[k]["name"],
    --["start_time"] = 0,
  } 

  coalition.addGroup(SaveUnits[k]["CountryID"], SaveUnits[k]["CategoryID"], groupData)
  groupData = {}
  end --end Group for loop

else --Save File does not exist we start a fresh table, no spawns needed
  SaveUnits={}
  AllGroups = SET_GROUP:New():FilterCategories("ground"):FilterActive(true):FilterStart()
end

--THE SAVING SCHEDULE
SCHEDULER:New( nil, function()
  AllGroups:ForEachGroupAlive(function (grp)
  local DCSgroup = Group.getByName(grp:GetName() )
  local size = DCSgroup:getSize()

_unittable={}

for i = 1, size do

local tmpTable =

  {   
    ["type"]=grp:GetUnit(i):GetTypeName(),
    ["transportable"]=true,
    ["unitID"]=grp:GetUnit(i):GetID(),
    ["skill"]="Average",
    ["y"]=grp:GetUnit(i):GetVec2().y,
    ["x"]=grp:GetUnit(i):GetVec2().x,
    ["name"]=grp:GetUnit(i):GetName(),
    ["playerCanDrive"]=true,
    ["heading"]=grp:GetUnit(i):GetHeading(),
  }

table.insert(_unittable,tmpTable) --add units to a temporary table
end

SaveUnits[grp:GetName()] =
{
   ["CountryID"]=grp:GetCountry(),
   ["SpawnCoalitionID"]=grp:GetCountry(),
   ["tasks"]={}, --grp:GetTaskMission(), --wrong gives the whole thing
   ["CategoryID"]=grp:GetCategory(),
   ["task"]="Ground Nothing",
   ["route"]={}, -- grp:GetTaskRoute(),
   ["groupId"]=grp:GetID(),
   --["SpawnCategoryID"]=grp:GetCategory(),
   ["units"]= _unittable,
   ["y"]=grp:GetVec2().y, 
   ["x"]=grp:GetVec2().x,
   ["name"]=grp:GetName(),
   ["start_time"]=0,
   ["CoalitionID"]=grp:GetCoalition(),
   ["SpawnCountryID"]=grp:GetCoalition(),
}

end)

newMissionStr = IntegratedserializeWithCycles("SaveUnits",SaveUnits) --save the Table as a serialised type with key SaveUnits
writemission(newMissionStr, "SaveUnits.lua")--write the file from the above to SaveUnits.lua
SaveUnits={}--clear the table for a new write.
--env.info("Data saved.")
end, {}, 1, SaveScheduleUnits)
