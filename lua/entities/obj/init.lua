AddCSLuaFile( "cl_init.lua" ) --
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/hunter/blocks/cube05x05x05.mdl" ) -- Standardmodel
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid(SOLID_VPHYSICS)   
	self:SetUseType(SIMPLE_USE) 

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end 

end

function ENT:Use(act, call)

	call:PickupObject(self)
	call:ChatPrint(self:GetClass())

	self:AddFingerPrint(call)

end
