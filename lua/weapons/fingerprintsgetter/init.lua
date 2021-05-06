util.AddNetworkString("fpExchangePlayers")
util.AddNetworkString("fpEchangePlayersToServer")
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

SWEP.Weight         = 0
SWEP.AutoSwitchTo   = false
SWEP.AutoSwitchFrom = false

function SWEP:GetCapabilities() 
	return 0
end

function SWEP:CanSecondaryAttack()
	return false 
end

function SWEP:Initialize()
    
    self:SetHoldType(self.HoldType)
    self.PlayersKnown = {
    }

	--self.objectsKnown = {
	--	{}
	--}

end

function SWEP:PrimaryAttack()

    local ply = self:GetOwner()

    if ply:IsPlayer() then

        ply:LagCompensation( true )

        local lookingAt = ply:GetEyeTrace().Entity

        ply:LagCompensation( false )

            if lookingAt:IsPlayer() and ply:GetPos():DistToSqr(lookingAt:GetPos()) < 50^2 then
                if (self.cooldown or 0) > CurTime() then return end
                    self.cooldown = CurTime() + 1

					if self.PlayersKnown and (#self.PlayersKnown <= 4) then
						if self.PlayersKnown[lookingAt:GetName()] == lookingAt:GetName() then 
							
							return end
							self.PlayersKnown[lookingAt:GetName()] = lookingAt:GetName() 
							net.Start("fpExchangePlayers")
							net.WriteEntity(self)
							net.WriteTable(self.PlayersKnown)
							net.WriteString(lookingAt:GetName())
							net.Send(ply)
                	end


           	end
    end

end

function SWEP:SecondaryAttack()

end

function SWEP:GetKnownPlayer()

    return self.PlayersKnown

end

net.Receive("fpExchangePlayersToServer", function()

    local wpn = net.ReadEntity()
    local toRemove = net.ReadString()

    wpn.PlayersKnown[toRemove] = nil

end)