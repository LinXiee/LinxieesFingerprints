include( 'shared.lua' )

--[[

Commented Code is part of a planned feature.
Was too lazy to finish it. Also the Idea on how i want it to be is missing

]]---

local fingerprintIcon = Material("icons/fingerprint.png", "noclamp smooth")
local objectsIcon = Material("icons/archive-search-outline.png")


SWEP.Author = "LinXiee"
SWEP.PrintName = "Fingerabdruck Abholer"
SWEP.Instructions = "Links-Klick: Probe von Spieler nehmen \nRechts-Klick: Liste mit Proben anzeigen"
SWEP.Purpose = "Hiermit kannst du Fingerabdrücke von Spielern einholen"
SWEP.Category = "Fingerprint"
SWEP.HoldType = "normal"

SWEP.Slot             = 2
SWEP.SlotPos          = 8

SWEP.DrawAmmo         = false
SWEP.DrawCrosshair    = true

SWEP.WepSelectIcon    = surface.GetTextureID( "weapons/empty_hands" )
SWEP.BounceWeaponIcon = false


local function getNames(wpn) --Get the Names saved on the weapon

    local setNames = {
        [1] = "No Trace",
        [2] = "No Trace",
        [3] = "No Trace",
        [4] = "No trace",
    }

    local i = 1

    if wpn.Names then
       for k, v in pairs(wpn.Names) do            
            setNames[i] = wpn.Names[k]
            i = i + 1
        end    
    end

    return setNames

end

local function removeName(index, getedNames) --If clicked on a name, remove the name and push the other to top

    local toRemove = getedNames[index]

    self.Names[toRemove] = nil

    if table.IsEmpty(self.Names) then self.Names = nil end

    net.Start("fpExchangePlayersToServer")
    net.WriteEntity(self)
    net.WriteString(toRemove)
    net.SendToServer()

end

function SWEP:Initialize()

    self.menuOpen = false

end

function SWEP:SecondaryAttack()

    if self.menuOpen then return end
    self:OpenMenu()

end

function SWEP:PrimaryAttack()
end


function SWEP:OpenMenu()
    
    local getedNames = getNames(self)
    
    self.menuOpen = true

    local Frame = vgui.Create("XeninUI.Frame")
        Frame:SetSize(700,500)
        Frame:Center()
        Frame:SetTitle("Collected Hints")
        Frame:MakePopup()

    Frame.OnClose = function()

        self.menuOpen = false 

    end

    Frame.OnRemove = function()

        self.menuOpen = false

    end

  
    local playersPanel = vgui.Create("XeninUI.Panel", Frame)
        playersPanel:SetSize(600,400)
        playersPanel:Center()
        playersPanel.Paint = function(self, w , h)

            draw.SimpleText("Collected Hints", "HeaderFont", 0, 30, color_white,0,1)
            XeninUI.DrawMultiLine("Look at all fingerprints you currently collected", "LabelFont", w, 14, 0, 55, color_grey, 0, 1)

            draw.RoundedBox(10, 0, 90, w, 50, XeninUI.Theme.Navbar)
            draw.SimpleText(getedNames[1], "HeaderFont", w/2, 115, color_white, 1, 1)                     

            draw.RoundedBox(10, 0,155, w, 50, XeninUI.Theme.Navbar)
            draw.SimpleText(getedNames[2], "HeaderFont", w/2, 180, color_white, 1, 1)

            draw.RoundedBox(10, 0, 220, w, 50, XeninUI.Theme.Navbar)
            draw.SimpleText(getedNames[3], "HeaderFont", w/2, 245, color_white, 1, 1)

            draw.RoundedBox(10, 0,285, w, 50, XeninUI.Theme.Navbar)
            draw.SimpleText(getedNames[4], "HeaderFont", w/2, 310, color_white, 1, 1)

            XeninUI.DrawMultiLine("Click on a name to remove it from the list!", "PanelLabelFont", w, 14, w/2, h-30, color_grey, 1, 1)

        end


    local getBut1 = vgui.Create("XeninUI.Button", playersPanel)
        getBut1:SetSize(600,50)
        getBut1:Center()
        getBut1:AlignTop(90)
        getBut1:SetText("")
        getBut1.Paint = function(self, w, h) end
        getBut1.DoClick = function() 
            removeName(1, getedNames)
            Frame:Remove()
        end  
        if getedNames[1] == ("No Fingerprint" or nil) then getBut1:Hide() end
    
    local getBut2 = vgui.Create("XeninUI.Button", playersPanel)
            getBut2:SetSize(600, 50)
            getBut2:Center()
            getBut2:AlignTop(155)
            getBut2:SetText("")
            getBut2.Paint = function(self, w, h)  end
            getBut2.DoClick = function() removeName(2, getedNames) Frame:Remove() end
            if getedNames[2] == ("No Fingerprint" or nil) then getBut2:Hide() end
            
    local getBut3 = vgui.Create("XeninUI.Button", playersPanel)
            getBut3:SetSize(600, 50)
            getBut3:Center()
            getBut3:AlignTop(220)
            getBut3:SetText("")
            getBut3.Paint = function(self, w, h) end
            getBut3.DoClick = function() removeName(3, getedNames) Frame:Remove() end
        if getedNames[3] == ("No Fingerprint" or nil) then getBut3:Hide() end

    local getBut4 = vgui.Create("XeninUI.Button", playersPanel)
        getBut4:SetSize(600, 50)
        getBut4:Center()
        getBut4:AlignTop(285)
        getBut4:SetText("")
        getBut4.Paint = function(self, w, h)
        end
        getBut4.DoClick = function() removeName(4, getedNames) Frame:Remove() end
        if getedNames[4] == ("No Fingerprint" or nil) then getBut4:Hide() end
            

end

net.Receive("fpExchangePlayers", function() --exchanging players from server to client, only takes place at successfull leftklick

    self = net.ReadEntity()
    self.Names = net.ReadTable()
    plyName = net.ReadString()
    PrintTable(self.Names)

    chat.AddText(XeninUI.Theme.Purple,"[Fingerprints] ", color_white, "Fingerprint of ".. plyName .." collected") 

end)