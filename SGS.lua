-- Simple Group Saving by Pikey May 2019, updated March 2023 https://github.com/thebgpikester/SimpleGroupSaving/
-- 1.3 - Added custom file path March 21st
-- 1.2 -  GetUnit(x) was only returning GetUnit(1) - rewitten for GetUnits() December 2022
-- Protected namespace used as there can be variable name collisions
-- MOOSE and IO checks

-- Usage of this script should credit the following contributors:
 --Pikey, 
 --Speed & Grimes for their work on Serialising tables, included below,
 --FlightControl for MOOSE (Required)
 --Ghostrider+Moose community for fixing Radians instead of degrees
 
 --INTENDED USAGE
 --DCS Server Admins looking to do long term multi session play that will need a server reboot in between and they wish to keep the Ground 
 --Unit positions true from one reload to the next.
 --Something simpler than DSMC (the best tool for persistence) but captures unit headings
 
 --USAGE
 --Ensure LFS and IO are not santitised in missionScripting.lua. This enables writing of files. If you don't know what this does, don't attempt to use this script.
 --MIST not required, some reports of issues with concurrent running in certain orders/usages
 --Edit 'SaveScheduleUnits' below, (line 34) to the number of seconds between saves. Low impact. 10 seconds is a fast schedule.
 --Place Ground Groups wherever you want on the map as normal.
 --Run this script at Mission start
 --The script will create a small file with the list of Groups and Units.
 --At Mission Start it will check for a save file, if not there, create it fresh
 --If the table is there, it loads it and Spawns everything that was saved.
 --The table is updated throughout mission play
 --The next time the mission is loaded it goes through all the Groups again and loads them from the save file.
 --You can use this to place groups for any mission, it spawns whatever is in the file!
 
 --LIMITATIONS
 --Only Ground Groups and Units are specified, play with the SET Filter at your own peril. Could be adjusted for just one Coalition or a FilterByName().
 --See line 107 and 168 for the SET.
 --See https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Set.html##(SET_GROUP)
 --Naval Groups not Saved. If Included, there may be issues with spawned objects and Client slots where Ships have slots for aircraft/helo. Possible if not a factor
 --Statics are not included. See 'Simple Static Saving' for a solution
 --Routes are not saved. Uncomment lines 148-153 if you wish to keep them, but they won't activate them on restart. It is impossible to query a group for it's current
 --route, only for the original route it recieved from the Mission Editor. Therefore a DCS limitation.
 SGS={} --DO NOT TOUCH
 -----------------------------------
 --Configurable for user:
 SGS.filepath = lfs.writedir().."SaveUnits.lua" -- editing this changes the save file directory\filename from the default "Saved\Games\DCS\SaveUnits.lua"
 local SaveScheduleUnits = 10 --how many seconds between each check of all the units.
 -----------------------------------
 --Do not edit below here
 -----------------------------------
 local version = "1.3 - March 2023"
 

 
 if SET_GROUP then --MOOSE check
 
 if io then --sanitization check
 
 function SGS.IntegratedbasicSerialize(s)
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
  function SGS.IntegratedserializeWithCycles(name, value, saved)
    local basicSerialize = function (o)
      if type(o) == "number" then
        return tostring(o)
      elseif type(o) == "boolean" then
        return tostring(o)
      else -- assume it is a string
        return SGS.IntegratedbasicSerialize(o)
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
            table.insert(t_str, SGS.IntegratedserializeWithCycles(fieldname, v, saved))
          end
        end
      end
      return table.concat(t_str)
    else
      return ""
    end
  end

function SGS.file_exists(name) --check if the file already exists for writing
    if lfs.attributes(name) then
    return true
    else
    return false end 
end

function SGS.writemission(data, file)
  SGS.File = io.open(file, "w")
  SGS.File:write(data)
  SGS.File:close()
end

--SCRIPT START
env.info("Loaded Simple Group Saving, by Pikey, 2018, version " .. version)

if SGS.file_exists(SGS.filepath) then --Script has been run before, so we need to load the save
  env.info("Existing database, loading from File.")
  SGS.AllGroups = SET_GROUP:New():FilterCategories("ground"):FilterActive(true):FilterStart()
    SGS.AllGroups:ForEachGroup(function (grp)
      grp:Destroy()
    end)
  --NOTE the removal of all groups is required to put them back in the right place, therefore consider your script order very carefully, with this higher up.
  dofile(SGS.filepath)
  SGS.tempTable={}
  SGS.Spawn={}
--RUN THROUGH THE KEYS IN THE TABLE (GROUPS)
  for k,v in pairs (SGS.SaveUnits) do
    SGS.units={}
--RUN THROUGH THE UNITS IN EACH GROUP
      for i= 1, #(SGS.SaveUnits[k]["units"]) do 
  
SGS.tempTable =

  { 
   ["type"]=SGS.SaveUnits[k]["units"][i]["type"],
   ["transportable"]= {["randomTransportable"] = false,}, 
   --["unitId"]=9000,used to generate ID's here but no longer doing that since DCS seems to handle it
   ["skill"]=SGS.SaveUnits[k]["units"][i]["skill"],
   ["y"]=SGS.SaveUnits[k]["units"][i]["y"] ,
   ["x"]=SGS.SaveUnits[k]["units"][i]["x"] ,
   ["name"]=SGS.SaveUnits[k]["units"][i]["name"],
   ["heading"]=SGS.SaveUnits[k]["units"][i]["heading"],
   ["playerCanDrive"]=true,  --hardcoded but easily changed.  
   
  }

      table.insert(SGS.units,SGS.tempTable)
    end --end unit for loop


SGS.groupData = 

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
    ["units"] = SGS.units,
    ["y"] = SGS.SaveUnits[k]["y"],
    ["x"] = SGS.SaveUnits[k]["x"],
    ["name"] = SGS.SaveUnits[k]["name"],
    --["start_time"] = 0,
  } 

  coalition.addGroup(SGS.SaveUnits[k]["CountryID"], SGS.SaveUnits[k]["CategoryID"], SGS.groupData)
  SGS.groupData = {}
  end --end Group for loop

else --Save File does not exist we start a fresh table, no spawns needed
  SGS.SaveUnits={}
  SGS.AllGroups = SET_GROUP:New():FilterCategories("ground"):FilterActive(true):FilterStart()
end

--THE SAVING SCHEDULE
SCHEDULER:New( nil, function()
  SGS.AllGroups:ForEachGroupAlive(function (grp)
    local list = grp:GetUnits()

SGS._unittable={}

for i=1,#list do

local tmpTable =

  {   
    ["type"]=list[i]:GetTypeName(),
    ["livery_id"]=list[i]:GetTemplate()["livery_id"], --added Dec 2022
    ["transportable"]=true,
    ["unitID"]=list[i]:GetID(),
    ["skill"]="Average",
    ["y"]=list[i]:GetVec2().y,
    ["x"]=list[i]:GetVec2().x,
    ["name"]=list[i]:GetName(),
    ["playerCanDrive"]=true,
    ["heading"]=math.rad(list[i]:GetHeading()), --fixed 24/03/2020
   
  }

table.insert(SGS._unittable,tmpTable) --add units to a temporary table
end

SGS.SaveUnits[grp:GetName()] =
{
   ["CountryID"]=grp:GetCountry(),
   ["SpawnCoalitionID"]=grp:GetCountry(),
   ["tasks"]={}, 
   ["CategoryID"]=grp:GetCategory(),
   ["task"]="Ground Nothing",
   ["route"]={}, 
   ["groupId"]=grp:GetID(),
   ["units"]= SGS._unittable,
   ["y"]=grp:GetVec2().y, 
   ["x"]=grp:GetVec2().x,
   ["name"]=grp:GetName(),
   ["start_time"]=0,
   ["CoalitionID"]=grp:GetCoalition(),
   ["SpawnCountryID"]=grp:GetCoalition(),
}

end)

SGS.newMissionStr = SGS.IntegratedserializeWithCycles("SGS.SaveUnits",SGS.SaveUnits) --save the Table as a serialised type with key SaveUnits
SGS.writemission(SGS.newMissionStr, SGS.filepath)--write the file from the above to SaveUnits.lua
SGS.SaveUnits={}--clear the table for a new write.
--env.info("Data saved.")
end, {}, 1, SaveScheduleUnits)

else env.error("Lua io is sanitized. Read the requirements. Writing to the file system is required!")
end
else env.error("MOOSE not loaded! MOOSE must be loaded before running this.")
end
