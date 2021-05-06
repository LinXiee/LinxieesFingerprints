include( 'shared.lua' )

SWEP.PrintName        = "Handschuhe"
SWEP.Author           = ""
SWEP.Purpose          = ""
SWEP.Instructions     = ""

SWEP.Slot             = 2
SWEP.SlotPos          = 3

SWEP.DrawAmmo         = false
SWEP.DrawCrosshair    = true

SWEP.BounceWeaponIcon = false


function SWEP:SecondaryAttack() -- Giving the player the option to check if he has gloves on or not

    if (self.Cooldown or 0) >= CurTime() then return end
    self.Cooldown = CurTime() + 3

    if LocalPlayer().gloves then 

        chat.AddText(XeninUI.Theme.Purple, "[Fingerprints] ", color_white, "Deine Handschuhe sind angezogen")

    else 

        chat.AddText(XeninUI.Theme.Purple, "[Fingerprints] ", color_white, "Du trägst keine Handschuhe")

    end

end