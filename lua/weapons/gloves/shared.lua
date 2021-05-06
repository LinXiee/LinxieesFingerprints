
SWEP.Author = "LinXiee"
SWEP.PrintName = "Handschuhe"
SWEP.Instructions = "Test"
SWEP.Category = "Fingerprint"

SWEP.AutoSwitchTo = false 
SWEP.AutoSwitchFrom = false

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.ViewModelFlip = false 
SWEP.UseHands = false
SWEP.WorldModel = ""
SWEP.SetHoldType = "normal"

SWEP.Spawnable = true 

SWEP.Primary.Automatic		=  false
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Sound = Sound("")

SWEP.Secondary.Automatic	=  false
SWEP.Secondary.Ammo			=  "none"

function SWEP:Initialize()

    self:SetHoldType("normal")
    self.cooldown = 0
    self:GetOwner().gloves = false

end

function SWEP:PrimaryAttack() -- Just setting ply.gloves to false or true

    if self.cooldown > CurTime() then return end
    self.cooldown = CurTime() + 5

    if self:GetOwner():IsPlayer() then
        if self:GetOwner().gloves then
            self:GetOwner().gloves = false
            if SERVER then
                 self:GetOwner():Say("Ich habe mir Handschuhe ausgezogen!")
            end

        elseif not self:GetOwner().gloves then
            self:GetOwner().gloves = true
            if SERVER then
            self:GetOwner():Say("Ich habe meine Handschuhe angezogen")
            end
        end
    end

end

function SWEP:SecondaryAttack()

    return

end