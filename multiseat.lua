--[[

Multiseat - additional seats in GTA vehicles

@package PYLife.pl-core2
@copyright 2013-2014 AFX <afx@pylife.pl>
@author Wielebny <wielebny@bestplay.pl>

]]--


local multiSeatModels={
  [407]={ -- firetruck
    seats={ 
            {0.7,1.6,0},
            {0.35,1.6,0},
            {-0.35,1.6,0},
            {-0.7,1.6,0},
          }
    }
}

local function getFreeMultiSeat(veh)
  local available_seats={}

  for i,v in ipairs(multiSeatModels[getElementModel(veh)].seats) do
    available_seats[i]=true
  end
--  { [1]=true, [2]=true, [3]=true, [4]=true}

  for i,v in ipairs(getAttachedElements(veh)) do
    if getElementType(v)=="vehicle" then
      local seat=getElementData(v,"multiseat")
      if seat then available_seats[seat]=nil end
    end
  end

  -- return first element
  for i,v in pairs(available_seats) do return i  end
  return nil
end


addEventHandler("onVehicleEnter", root, function(plr, seat)
  if seat==0 then return end
  local vm=getElementModel(source)
  if not multiSeatModels[vm] then return end

  -- Let's find a free place
  local seat=getFreeMultiSeat(source)
  if not seat then
    -- no empty space, let the player seat in front passenger seat
    return
  end
--  outputDebugString("multiseat: " .. seat)

  removePedFromVehicle(plr)
  local veh=createVehicle(441, 0,0,-100)
  setElementCollisionsEnabled(veh, false)  
  attachElements(veh,source, unpack(multiSeatModels[vm].seats[seat])) -- 0.7,1.6,0)
  warpPedIntoVehicle(plr,veh,0)
  setTimer(warpPedIntoVehicle, 500, 1, plr, veh, 0)
  setElementAlpha(veh, 0)
  setCameraTarget(plr, source)
  setVehicleEngineState(veh,false)
  setVehicleLocked(veh, true)
  setElementData(veh,"multiseat", seat, false)
end, true, "low")


addEventHandler("onVehicleStartExit", resourceRoot, function(plr, seat)
  if seat~=0 then return end
  if getElementModel(source)~=441 then return end
  local firetruck=getElementAttachedTo(source)
  if firetruck then
      detachElements(source, firetruck)
      attachElements(source,firetruck, -0.7,1.6,0) -- przesuwamy na lewa strone aby wysiedli od strony kierowcy
--      cancelEvent()
  end
  setTimer(destroyElement, 500, 1, source)
  
end, true, "low")
