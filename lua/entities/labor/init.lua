util.AddNetworkString("fpOpenMenu")
util.AddNetworkString("fpGetInSphere")
util.AddNetworkString("fpSelectedEntity")
util.AddNetworkString("fpTransferPlayers")
util.AddNetworkString("fpSavedPlayers")
util.AddNetworkString("fpCloseMenu")
util.AddNetworkString("fpRefreshChecks")
AddCSLuaFile( "cl_init.lua" ) --
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local nearbyEnts = {}

local knownPlayers = { 
}

local doneChecks = {

}

local rf = RecipientFilter()

local function RefreshTable()

	timer.Simple(lfpRefreshCooldown, function() -- When cooldown ends, send the refreshed List to all players that opened the menu
	
		net.Start("fpRefreshChecks")
		net.WriteTable(doneChecks)
		net.Send(rf)
	end)

end

local function addKnownPlayer(guy, transferedPlayers, ply)
		
		if knownPlayers[transferedPlayers] then return end
		knownPlayers[transferedPlayers] = {Name = transferedPlayers, ByName = ply:GetName()}

end

function ENT:Initialize()

	self:SetModel("models/gman.mdl")
    self:SetSolid(SOLID_BBOX)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_IDLE)
    self:SetHullType(HULL_HUMAN)
    self:SetUseType(SIMPLE_USE)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE)
    self:CapabilitiesAdd(CAP_TURN_HEAD)
    self:DropToFloor()

	self.nearbyEnts = {}
end

function ENT:Use(act, call)

	rf:AddPlayer(call) -- If someone openes the Menu, add him to a recipientfilter (used for refresh)

	local earbyEnts = {}

	for k,v in ipairs(ents.FindInSphere(self:GetPos(),100)) do --Get every Entity that is tracked and in range

		if fingerprintsTrackedEnts[v:GetClass()] then
			earbyEnts[#earbyEnts + 1] = {Name = v:GetClass(), Fingerprints = v.FingerprintsPlayers, ent = v}
			PrintMessage(HUD_PRINTCONSOLE, v:GetModel())
		elseif v:GetClass() == "spawned_weapon" and v:GetWeaponClass() then
			earbyEnts[#earbyEnts + 1] = {Name = v:GetWeaponClass(), Fingerprints = v.FingerprintsPlayers, ent = v}
		end

	end

	self.nearbyEnts = earbyEnts

	net.Start("fpOpenMenu") --Send opened Menu for player
	net.WriteEntity(self)
	net.WriteTable(earbyEnts)
	net.WriteTable(doneChecks)
	net.WriteTable(knownPlayers)
	net.Send(call)

end

function ENT:GetKnownPlayers() -- ???
	return self.knownPlayers
end

net.Receive("fpGetInSphere", function()

	local choosenEnt = net.ReadTable()

	PrintMessage(HUD_PRINTCONSOLE,choosenEnt:GetClass())

end)

net.Receive("fpSelectedEntity", function() -- When User selects and entity, add it to the list of checked entitys

	local guy = net.ReadEntity()
	local index = net.ReadUInt(4)

	if not guy.nearbyEnts[index].ent:IsValid() then return end

	local doneby = net.ReadString()
	local Timestamp = os.time()
	local TimeString = os.date( "%H:%M:%S - %d/%m/%Y" , Timestamp )
	local doneAt = CurTime()

	local Model = guy.nearbyEnts[index].ent:GetModel()
	local selectedEnt = guy.nearbyEnts[index]

	guy.nearbyEnts[index].ent:Remove()

	doneChecks[#doneChecks + 1] = selectedEnt
	doneChecks[#doneChecks].ID = #doneChecks
	doneChecks[#doneChecks].doneBy = doneby
	doneChecks[#doneChecks].Model = Model
	doneChecks[#doneChecks].TimeString = TimeString
	doneChecks[#doneChecks].doneAt = doneAt

	RefreshTable()

end)

net.Receive("fpTransferPlayers", function()

	--Transferplayers from weapon "Fingerprintsgetter"
	local guy = net.ReadEntity()
	local ply = net.ReadEntity()
	local weapon = ply:GetWeapon("fingerprintsgetter")

	if !weapon:IsValid() then return end

	local weaponTable = weapon.PlayersKnown

	for k,v in pairs(weaponTable) do --Add the Players saved serversided on this weapon
		addKnownPlayer(guy, k, ply)
	end

	weapon.PlayersKnown = {} -- clear known players on the weapon

end)

net.Receive("fpCloseMenu", function() --When User removes Frame on Clientside, remove him from recipientfilter

	local ply = net.ReadEntity()
	rf:RemovePlayer(ply)

end)