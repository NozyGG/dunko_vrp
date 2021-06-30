local cfg = module("cfg/teleporters")
local teleporter_menus = {}
local DoorStatus = {}

for k,v in pairs(cfg.teleporters_types) do
  local teleporter_menu = {name="Teleporter",css={top="75px",header_color="rgba(255,0,0,0.75)"}}
  teleporter_menus[k] = teleporter_menu

  local teleporter_choice = function(player,choice)
    local user_id = vRP.getUserId(player)
    local data = vRP.getUserDataTable(user_id)
    if user_id ~= nil then
      vRP.closeMenu(player)
      if DoorStatus[user_id] == nil then
        DoorStatus[user_id] = true
        for k,v in pairs(cfg.teleporters) do
          local gtype, x,y,z, x2,y2,z2 = table.unpack(v)
          vRPclient.teleport(player, {x2,y2,z2})
          vRP.closeMenu(player)
          break
          vRP.openMenu(player,teleporter_menu)
        end
      else
        DoorStatus[user_id] = nil
        for k,v in pairs(cfg.teleporters) do
          local gtype, x,y,z, x2,y2,z2 = table.unpack(v)
          vRPclient.teleport(player, {x,y,z})
          vRP.closeMenu(player)
          break
          vRP.openMenu(player,teleporter_menu)
        end
      end
    end
  end
  
  teleporter_menu[k] = {teleporter_choice,k.." Door"}
end

local function build_client_teleporters(source)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    for k,v in pairs(cfg.teleporters) do
      local gtype, x,y,z, x2,y2,z2 = table.unpack(v)
      local group = cfg.teleporters_types[gtype]
      local menu = teleporter_menus[gtype]
      if group and menu then
        local gcfg = group._config or {}

        local function teleporter_ENTER()
			    local user_id = vRP.getUserId(source)
			    if user_id ~= nil and vRP.hasGroup(user_id,gcfg.group or "user") then -- Can be added in the config file a special permission if only that group wants to have acces to it
			    	vRP.openMenu(source,menu)
			    end
        end

        local function teleporter_EXIT()
			    local user_id = vRP.getUserId(source)
			    if user_id ~= nil and vRP.hasGroup(user_id,gcfg.group or "user") then -- Can be added in the config file a special permission if only that group wants to have acces to it
			    	vRP.openMenu(source,menu)
			    end
        end

        local function teleporter_leave()
          vRP.closeMenu(source)
        end

        if gcfg.blipid ~= nil and gcfg.blipcolor ~= nil then -- If blipid and blipcolor is added in the _config = {} in config file, then adds blip
          vRPclient.addBlip(source,{x,y,z,gcfg.blipid,gcfg.blipcolor,gtype})
        end
        vRPclient.addMarker(source, {x,y,z - 1, 0.7, 0.7, 0.5, 255, 154, 24, 125, 150})
        --vRPclient.addMarkerNames(source,{x,y,z, "~b~~n~~w~Enterance: "..tostring(gtype), 1, 1.0}) -- If dunko vrp pack has a draw text function, please change it here
        vRP.setArea(source,"vRP:TeleporterEnterance"..k,x,y,z,1,1.5,teleporter_ENTER,teleporter_leave)

        if gcfg.blipid ~= nil and gcfg.blipcolor ~= nil then -- If blipid and blipcolor is added in the _config = {} in config file, then adds blip
          vRPclient.addBlip(source,{x2,y2,z2,gcfg.blipid,gcfg.blipcolor,gtype})
        end
        vRPclient.addMarker(source, {x2,y2,z2 - 1, 0.7, 0.7, 0.5, 255, 154, 24, 125, 150})
        --vRPclient.addMarkerNames(source,{x2,y2,z2, "~b~~n~~w~Exit: "..tostring(gtype), 1, 1.0}) -- If dunko vrp pack has a draw text function, please change it here
        vRP.setArea(source,"vRP:TeleporterExit"..k,x2,y2,z2,1,1.5,teleporter_EXIT,teleporter_leave)
      end
    end
  end
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    build_client_teleporters(source)
  end
end)

AddEventHandler("vRP:playerLeave", function(user_id, source)
	if(DoorStatus[user_id] ~= nil)then
		DoorStatus[user_id] = nil
	end
end)
