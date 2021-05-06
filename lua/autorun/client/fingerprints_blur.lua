-- Für HUD
 
local blur = Material("pp/blurscreen")
local scrw, scrh = ScrW(), ScrH()
function DrawBlurRect(x, y, w, h, amount)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(blur)
 
    for i = 1, 3 do
        blur:SetFloat("$blur", (i / 3) * (amount or 3))
        blur:Recompute()
 
        render.UpdateScreenEffectTexture()
 
        render.SetScissorRect(x, y, x + w, y + h, true)
            surface.DrawTexturedRect(0, 0, scrw, scrh)
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end
 
 
-- Für Panels in Paint Funktion (self:Blur())
 
local PanelMeta = FindMetaTable("Panel")
 
local surface_SetDrawColor, surface_DrawRect, surface_SetMaterial = surface.SetDrawColor, surface.DrawRect, surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect
local render_UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
 
local ScrW, ScrH = ScrW, ScrH
 
local registry = debug.getregistry()
local IMaterialTable = registry.IMaterial
local PanelTable = registry.Panel
 
local SetFloat = IMaterialTable.SetFloat
local Recompute = IMaterialTable.Recompute
 
local LocalToScreen = PanelTable.LocalToScreen
 
local blur = Material("pp/blurscreen")
function PanelMeta:Blur(amount)
    local x, y = LocalToScreen(self, 0, 0)
    local scrW, scrH = ScrW(), ScrH()
    surface_SetDrawColor(color_white)
    surface_SetMaterial(blur)
    for i = 1, 6 do
        SetFloat(blur, '$blur', (i / 6) * (amount or 3))
        Recompute(blur)
        render_UpdateScreenEffectTexture()
        surface_DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end
end