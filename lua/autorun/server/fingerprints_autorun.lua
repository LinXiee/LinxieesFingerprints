
local EntList = {

}

meta = FindMetaTable("Entity")

function meta:AddFingerPrint(ply)

    if self:IsPlayer() then return end

    local plyName = ply:GetName()

    if self.FingerprintsPlayers[1] == plyName or ply.gloves then return end

    self.FingerprintsPlayers[3] = self.FingerprintsPlayers[2]
    self.FingerprintsPlayers[2] = self.FingerprintsPlayers[1]
    self.FingerprintsPlayers[1] = plyName

end -- Metatable Function for new Fingerprint

hook.Add("OnEntityCreated", "AddVars", function (ent) -- Giving Entitys no Fingerprints on Spawn

    if (!ent:IsValid() or !fingerprintsTrackedEnts[ ent:GetClass() ] ) then return end

    EntList[#EntList+1] = ent

    if ent.FingerprintsPlayers then
        
    else
        ent.FingerprintsPlayers = {
            "None",
            "None",
            "None",
        }
    end  

    if ent:GetOwner():IsPlayer() then --When some function add's an owner, get this owner for the first fingerprint
        ent.FingerprintsPlayers[1] = ent:GetOwner():GetName()
    end

end)


hook.Add("PlayerSpawn", "AddVarGlove", function(ply, transition) -- On Playerspawn set no gloves

    ply.gloves = false

end)

hook.Add("GravGunOnPickedUp", "AddGravPickUp", function(ply, ent) --When using and Entity with Gravgun, add Fingerprint

    if !ent:IsValid() then return end
    
    local class = ent:GetClass()
    if fingerprintsTrackedEnts[class] then
        
        ent:AddFingerPrint(ply)

    elseif class == "spawned_weapon" then
        local wepclass = ent:GetWeaponClass()
        if fingerprintsTrackedWeapons[wepclass] then
            
            ent:AddFingerPrint(ply)

        end

    end
    

end)

    
hook.Add("onDarkRPWeaponDropped", "fingerprintsonDrop", function(ply, ent, wep) --Assign Fingerprints on weapondrop

    if !IsValid(wep) then return end
    local class = wep:GetClass()

    if fingerprintsTrackedWeapons[class] then
        
        local tb = wep:GetTable()
        if tb.FingerprintsPlayers then -- If the Weapon in hand has fingerprints then assign these for the new created ent
            ent.FingerprintsPlayers = tb.FingerprintsPlayers 
        else -- If there are no fingerprints on the original weapon, add some
            
            ent.FingerprintsPlayers =  {
                "None",
                "None",
                "None",
            }

        end

        if not ply.gloves then 
            ent:AddFingerPrint(ply)
        end

    end
end)

hook.Add("PlayerPickupDarkRPWeapon", "fingerprintsOnPickup", function(ply, ent, wep) --On Pickup Weapon, take old fingerprints and add plyFingerprints
    -- Kuss und Gruß geht raus an mcNuggets
	if !IsValid(wep) then return end
	local class = wep:GetClass()
    if fingerprintsTrackedWeapons[class] then
 
		local tb = ent:GetTable()
		if tb.FingerprintsPlayers then
 
			local fingerprints = tb.FingerprintsPlayers
			timer.Simple(0, function()
				if !IsValid(ply) then return end
 
				local new_weapon = ply:GetWeapon(class)
				if new_weapon:IsValid() then
					new_weapon.FingerprintsPlayers = fingerprints
				end
 
			end)
 
		end
 
		if not ply.gloves then
 
			timer.Simple(0, function()
				if !IsValid(ply) then return end
 
				local new_weapon = ply:GetWeapon(class)
				if new_weapon:IsValid() then
					new_weapon:AddFingerPrint(ply)
    			end
 
			end)
 
		end
 
	end
end)