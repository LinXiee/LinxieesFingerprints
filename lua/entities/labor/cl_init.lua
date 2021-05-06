include('shared.lua')

local iconNewPlayer = Material("icons/microscope.png", "mips")
local iconNewEntry = Material("icons/playlist-plus.png", "mips")
local iconEntrys = Material("icons/playlist-check.png", "mips")
local iconPlayers = Material("icons/card-account-details-outline.png", "mips")
local iconClose = Material("icons/close.png", "mips")

local blur = Material("pp/blurscreen")

local faded_black = Color(0, 0, 0, 200)
local color_grey = Color(200,200,200,255)
local faded_white = Color(255, 255, 255, 100)

local savedPlayers = {

}

local function CheckKnow(ply) -- Check if the Player is in Database

	if savedPlayers[ply] or ply == "None" then
		return ply
	else 
		return "Unknown"
	end

end

local function checkReady(time) -- Checkstatus if processing oder Done

	local Time = tonumber(time)

	if (Time + lfpRefreshCooldown - 1) >= CurTime() then
		return "Processing"

	else
		return "Done"
	end


end

function ENT:Draw()

	self:DrawModel()

end

function ENT:OpenMenu(entlist, doneChecks)

	--Frame
	local Frame = vgui.Create("XeninUI.Frame")
		Frame.startTime = SysTime()
		Frame:SetSize(700, 500)
		Frame:Center()
		Frame:SetTitle("Investigations")
		Frame:MakePopup()
		
		Frame.OnRemove = function()

			net.Start("fpCloseMenu")
			net.WriteEntity(LocalPlayer())
			net.SendToServer()

		end

	local Button = vgui.Create("XeninUI.Button", Frame)
		Button:SetSize(100,30)
		Button:AlignBottom(30)
		Button:AlignRight(30)
		Button:SetFont("ButtonFont")
		Button:SetText("Back")
		Button:SetTextColor(color_white)
		Button.back = true
		Button.Paint = function(self, w, h)

			draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme["Accent"])

		end
		Button:Hide()

		--Frames bzw Panels
	local CheckedPanel = vgui.Create("XeninUI.Panel", Frame)
		CheckedPanel:SetSize(550, 360)
		CheckedPanel:Center()
		CheckedPanel.Paint = function(self, w, h)

		end
		CheckedPanel:Hide()

	local EntPanel = vgui.Create("XeninUI.Panel", Frame)
		EntPanel:SetSize(550, 360)
		EntPanel:Center()
		EntPanel:Hide()

	local CheckEntry = vgui.Create("XeninUI.Panel", Frame)
		CheckEntry:SetSize(700, 500)
		CheckEntry:Center()
		CheckEntry.Paint = function(self, w, h)

			self:Blur(1)
			draw.RoundedBox(10, 100, 50, 500, 400, XeninUI.Theme["Navbar"])
			draw.RoundedBox(10, 100+3, 50+3, 500-6, 400-6, XeninUI.Theme["Background"])
			
		end
		CheckEntry:Hide()

	local checkedPlayers = vgui.Create("XeninUI.Panel", Frame)
		checkedPlayers:SetSize(550, 360)
		checkedPlayers:Center()
		checkedPlayers:Hide()
	
	local InnerPanel = vgui.Create("XeninUI.Panel", Frame)
		InnerPanel:SetSize(600, 500)
		InnerPanel:Center()

	local DownPanel = vgui.Create("XeninUI.Panel", InnerPanel)
		DownPanel:SetSize(600,200)
		DownPanel:Center()
		DownPanel:AlignBottom(20)
		DownPanel.Paint = function(self, w, h)

			draw.RoundedBox(10, 0, 0, w, h, XeninUI.Theme["Navbar"])
			draw.RoundedBox(10, 3, 3, w-6, h-6, XeninUI.Theme["Background"])
            surface.SetDrawColor(color_white)

		end

	local MidPanel = vgui.Create("XeninUI.Panel", InnerPanel )
		MidPanel:SetSize(600,200)
		MidPanel:Center()
		MidPanel:AlignTop(60)
		MidPanel.Paint = function(self, w, h)

			draw.RoundedBox(10, 0, 0, w, h, XeninUI.Theme["Navbar"])
			draw.RoundedBox(10, 3, 3, w-6, h-6, XeninUI.Theme["Background"])

		end

		--Listen
	local List = vgui.Create("DListView", EntPanel)
		List:SetPos(0, 0)
		List:SetSize(550, 320)
		List:SetMultiSelect(false)
		List:AddColumn("Nearby Objects")
		List:SetDataHeight(30)

		for k,v in ipairs(entlist) do
			 List:AddLine(fingerprintsTrackedEnts[entlist[k].Name] or fingerprintsTrackedWeapons[entlist[k].Name])
		end
	
	local DoneChecks = vgui.Create("DListView", CheckedPanel)
		DoneChecks:SetPos(0, 0)
		DoneChecks:SetSize(550, 320)
		DoneChecks:SetMultiSelect(False)
		DoneChecks:AddColumn("ID"):SetWidth(1)
		DoneChecks:AddColumn("Tested object"):SetWidth(90)
		DoneChecks:AddColumn("Reached in by"):SetWidth(200)
		DoneChecks:AddColumn("Reached in at"):SetWidth(120)
		DoneChecks:AddColumn("Status"):SetWidth(60)

		DoneChecks:SetDataHeight(30)

		for k,v in ipairs(doneChecks) do
			DoneChecks:AddLine( doneChecks[k].ID,(fingerprintsTrackedWeapons[doneChecks[k].Name] or fingerprintsTrackedEnts[doneChecks[k].Name]), doneChecks[k].doneBy, doneChecks[k].TimeString, checkReady(doneChecks[k].doneAt))
		end
		DoneChecks:SortByColumn(1, true)

	local checkedPlayersList = vgui.Create("DListView", checkedPlayers)
		checkedPlayersList:SetPos(0,0)
		checkedPlayersList:SetSize(550, 320)
		checkedPlayersList:SetMultiSelect()
		checkedPlayersList:AddColumn("Probe of")
		checkedPlayersList:AddColumn("Reached in by")
		checkedPlayersList:SetDataHeight(30)

		for k,v in pairs(savedPlayers) do
			checkedPlayersList:AddLine(savedPlayers[k].Name, savedPlayers[k].ByName)
		end

		--CheckedEntrys Texte

	local HeaderP = vgui.Create("DLabel", CheckEntry)
		HeaderP:SetPos(150, 100)
		HeaderP:SetSize(200, 30)
		HeaderP:SetFont("HeaderFont")
		HeaderP:SetText("Requested By: ")

	local NameP = vgui.Create("DLabel", CheckEntry)
		NameP:SetPos(150, 125)
		NameP:SetSize(200,15)
		NameP:SetFont("LabelFont")

	local Fingerprint1Header = vgui.Create("DLabel", CheckEntry)
		Fingerprint1Header:SetPos(150, 160)
		Fingerprint1Header:SetSize(200, 30)
		Fingerprint1Header:SetFont("HeaderFont")
		Fingerprint1Header:SetText("First Trace: ")

	local Fingerprint1 = vgui.Create("DLabel", CheckEntry)
		Fingerprint1:SetPos(150, 185)
		Fingerprint1:SetSize(200, 15)
		Fingerprint1:SetFont("LabelFont")

	local Fingerprint2Header = vgui.Create("DLabel", CheckEntry)
		Fingerprint2Header:SetPos(150, 220)
		Fingerprint2Header:SetSize(200, 30)
		Fingerprint2Header:SetFont("HeaderFont")
		Fingerprint2Header:SetText("Second Trace:")

	local Fingerprint2 = vgui.Create("DLabel", CheckEntry)
		Fingerprint2:SetPos(150, 245)
		Fingerprint2:SetSize(200, 15)
		Fingerprint2:SetFont("LabelFont")

	local Fingerprint3Header = vgui.Create("DLabel", CheckEntry)
		Fingerprint3Header:SetPos(150, 280)
		Fingerprint3Header:SetSize(200, 30)
		Fingerprint3Header:SetFont("HeaderFont")
		Fingerprint3Header:SetText("Third Trace:")

	local Fingerprint3 = vgui.Create("DLabel", CheckEntry)
		Fingerprint3:SetPos(150, 305)
		Fingerprint3:SetSize(200, 15)
		Fingerprint3:SetFont("LabelFont")

	local TimestampHeader = vgui.Create("DLabel", CheckEntry)
		TimestampHeader:SetPos(150, 340)
		TimestampHeader:SetSize(200, 30)
		TimestampHeader:SetFont("HeaderFont")
		TimestampHeader:SetText("Timestamp:")
		
	local Timestamp = vgui.Create("DLabel", CheckEntry)
		Timestamp:SetPos(150, 365)
		Timestamp:SetSize(200, 15)
		Timestamp:SetFont("LabelFont")

	local DrawEntity = vgui.Create("DModelPanel", CheckEntry)
		DrawEntity:SetSize(200, 250)
		DrawEntity:SetPos(350, 120)

	--Buttons  
	local GotoChooseButton = vgui.Create("XeninUI.Button", MidPanel)
		GotoChooseButton:SetSize(40,40)
		GotoChooseButton:AlignTop(40)
		GotoChooseButton:AlignRight(145)
		GotoChooseButton:SetText("")
		GotoChooseButton.Paint = function(self, w, h)

			draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme["Accent"])
			surface.SetDrawColor(color_white)
			surface.SetMaterial(iconNewEntry)
			surface.DrawTexturedRect(0, 0, w, h)

		end

		GotoChooseButton.DoClick = function()

			InnerPanel:Hide()
			EntPanel:Show()
			Button:Show()

		end

	local GotoChooseLabel = vgui.Create("XeninUI.Panel", MidPanel)
		GotoChooseLabel:SetSize(200,25)
		GotoChooseLabel:AlignBottom(90)
		GotoChooseLabel:AlignRight(65)
        GotoChooseLabel.Paint = function(self, w, h)

            draw.SimpleText("New Research", "HeaderFont", w/2, h/2, color_grey, 1, 1)

        end

	local GotoChooseText = vgui.Create("XeninUI.Panel", MidPanel)
		GotoChooseText:SetSize(200, 50)
		GotoChooseText:AlignBottom(45)
		GotoChooseText:AlignRight(65)
		GotoChooseText.Paint = function(self, w, h)

			XeninUI.DrawMultiLine("Hand in a new object to check it for fingerprints", "PanelLabelFont", w, 14, w/2, h/2, color_grey, 1, 1)

		end

		-- First Items you see, when Menu is opened
	local EntryButton = vgui.Create("XeninUI.Button", MidPanel)
		EntryButton:SetSize(40,40)
		EntryButton:AlignTop(40)
		EntryButton:AlignLeft(145)
		EntryButton:SetText("")
		EntryButton.Paint = function(self, w, h)

			draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme["Accent"])
			surface.SetDrawColor(color_white)
			surface.SetMaterial(iconEntrys)
			surface.DrawTexturedRect(0, 0, w, h)

		end

		EntryButton.DoClick = function()

			InnerPanel:Hide()
			CheckedPanel:Show()
			Button:Show()

		end
		
	local EntryHeaderLabel = vgui.Create("XeninUI.Panel", MidPanel)
		EntryHeaderLabel:SetSize(200,25)
		EntryHeaderLabel:AlignBottom(90)
		EntryHeaderLabel:AlignLeft(65)
        EntryHeaderLabel.Paint = function(self, w, h)

            draw.SimpleText("Results", "HeaderFont", w/2, h/2, color_grey, 1, 1)

        end


	local EntryTextLabel = vgui.Create("XeninUI.Panel", MidPanel)
		EntryTextLabel:SetSize(200,50)
		EntryTextLabel:AlignBottom(51)
		EntryTextLabel:AlignLeft(65)
        EntryTextLabel.Paint = function(self, w, h)
        
            XeninUI.DrawMultiLine("See a list of previous investigations", "PanelLabelFont", w, 14, w/2, h/2, color_grey, 1, 1)

        end

	local ChooseButton = vgui.Create("XeninUI.Button", EntPanel)
		ChooseButton:SetSize(120, 30)
		ChooseButton:Center()
		ChooseButton:AlignBottom(10)
		ChooseButton:SetFont("ButtonFont")
		ChooseButton:SetText("")
		ChooseButton:SetTextColor(color_white)
		ChooseButton.Paint = function(self, w, h)

			draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme["Accent"])
			XeninUI.DrawMultiLine("Choose object", "PanelLabelFont", w, 14, w/2, h/2, color_white, 1, 1)

		end
		ChooseButton:Hide()

	local CheckedButton = vgui.Create("XeninUI.Button", CheckedPanel)
		CheckedButton:SetSize(120, 30)
		CheckedButton:Center()
		CheckedButton:AlignBottom(10)
		CheckedButton:SetFont("ButtonFont")
		CheckedButton:SetText("")
		CheckedButton.Paint = function(self, w, h)
		
			draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme["Accent"])
			XeninUI.DrawMultiLine("Show Result", "PanelLabelFont", w, 14, w/2, h/2, color_white, 1, 1)
		
		end
        CheckedButton:Hide()

	local EntryCloseButton = vgui.Create("XeninUI.Button", CheckEntry)
		EntryCloseButton:SetSize(30, 30)
		EntryCloseButton:AlignTop(60)
		EntryCloseButton:AlignRight(110)
		EntryCloseButton:SetFont("ButtonFont")
		EntryCloseButton:SetText("")
		EntryCloseButton:SetTextColor(color_white)
		EntryCloseButton.Paint = function(self, w, h)
		
			draw.RoundedBox(5,0,0,w,h,XeninUI.Theme.Accent)
			surface.SetDrawColor(color_white)
			surface.SetMaterial(iconClose)
			surface.DrawTexturedRect(0,0,w,h)

		end

		EntryCloseButton.DoClick = function()

			CheckEntry:Hide()

		end

	local transferPlayers = vgui.Create("XeninUI.Button", DownPanel)
		transferPlayers:SetSize(40, 40)
        transferPlayers:AlignTop(40)
        transferPlayers:AlignLeft(145)
		transferPlayers:SetText("")
		transferPlayers:SetTextColor(color_white)
		transferPlayers.Paint = function(self, w, h)
		
			draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme["Accent"])
            surface.SetDrawColor(color_white)
            surface.SetMaterial(iconNewPlayer)
            surface.DrawTexturedRect(0, 0, w, h)

		end

    local transferPlayersHeader = vgui.Create("XeninUI.Panel", DownPanel)
		transferPlayersHeader:SetSize(200,25)
		transferPlayersHeader:AlignBottom(90)
		transferPlayersHeader:AlignLeft(65)
		transferPlayersHeader.Paint = function(self, w, h)

            draw.SimpleText("Reach in probe", "HeaderFont", w/2, h/2, color_grey, 1, 1)

        end

    local transferPlayersLabel = vgui.Create("XeninUI.Panel", DownPanel)
        transferPlayersLabel:SetSize(200,40)
        transferPlayersLabel:AlignBottom(55)
        transferPlayersLabel:AlignLeft(65)
        transferPlayersLabel.Paint = function(self, w, h)
        
            XeninUI.DrawMultiLine("Hand in your collected fingerprints", "PanelLabelFont", w, 14, w/2, h/2, color_grey, 1, 1)
        
        end


    local playersButton = vgui.Create("XeninUI.Button", DownPanel)
        playersButton:SetSize(40,40)
        playersButton:AlignTop(40)
        playersButton:AlignRight(145)
		playersButton:SetText("")
		playersButton.Paint = function(self, w, h)

			draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme["Accent"])
			surface.SetDrawColor(color_white)
			surface.SetMaterial(iconPlayers)
			surface.DrawTexturedRect(2, 2, w-4, h-4)

		end

    local playersHeader = vgui.Create("XeninUI.Panel", DownPanel)
        playersHeader:SetSize(300,25)
		playersHeader:AlignBottom(90)
		playersHeader:AlignRight(15)
        playersHeader.Paint = function(self, w, h)

            draw.SimpleText("Reached in fingerprints", "HeaderFont",w/2, h/2, color_grey, 1, 1)
        
        end
        
    local playersText = vgui.Create("XeninUI.Panel", DownPanel)
		playersText:SetSize(200, 50)
		playersText:AlignBottom(50)
		playersText:AlignRight(65)
		playersText.Paint = function(self, w, h)
			XeninUI.DrawMultiLine("Look at previously reached in fingerprints", "PanelLabelFont", w, 14, w/2, h/2, color_grey, 1, 1)
		end


--Button funktionen
	
		playersButton.DoClick = function()

			Button:Show()
			InnerPanel:Hide()
			checkedPlayers:Show()

		end

		transferPlayers.DoClick = function() --Clientside Check if there are any players on the weapon's (also saved on server)

			local wps = LocalPlayer():GetWeapon("fingerprintsgetter") 

			if wps:IsWeapon() then
				if wps.Names and (wps.Names[1] != "No Probes") then 

					net.Start("fpTransferPlayers")
					net.WriteEntity(guy)
					net.WriteEntity(LocalPlayer())
					net.SendToServer()
					
					chat.AddText(XeninUI.Theme.Purple,"[Fingerprints] ", color_white, "You didn't collect any fingerprints!")

					wps.Names = nil

					Frame:Hide()
			
				else
					chat.AddText(XeninUI.Theme.Purple,"[Fingerabruck] ", color_white, "You have no fingerprints!")
				end

			else
				chat.AddText(XeninUI.Theme.Purple,"[Fingerabruck] ", color_white, "You don't even have the tools!")
			 end			

		end

		Button.DoClick = function() -- BackButton

			if Button.back then
				Button:Hide()
				checkedPlayers:Hide()
				CheckEntry:Hide()
				EntPanel:Hide()
				CheckedPanel:Hide()
				InnerPanel:Show()
			elseif not Button.back then
				Button:Hide()
			end
		end

		ChooseButton.DoClick = function() -- Choose a new Entity to check Button

			local index = List:GetSelectedLine()

			if not index or not entlist[index].ent:IsValid() then chat.AddText(XeninUI.Theme.Purple, "[Fingerprints] ", color_white, "The object you tried to reach in, doesn't exist anymore") return end

			net.Start("fpSelectedEntity")
			net.WriteEntity(self)
			net.WriteUInt(index,4)
			net.WriteString(LocalPlayer():GetName())
			net.SendToServer()  

			notification.AddLegacy("Come back in ".. lfpRefreshCooldown .." seconds, to see the results!", NOTIFY_HINT, 5)

			timer.Simple(lfpRefreshCooldown, function()
			
				notification.AddLegacy("Your requestes research finished!", NOTIFY_HINT, 5)

			end)

			Frame:Hide()

		end

		CheckedButton.DoClick = function() -- See a result Button

			local index = DoneChecks:GetSelectedLine()

			if not index then LocalPlayer():ChatPrint("Nothing selected") return end

				CheckEntry:Show()
				NameP:SetText(doneChecks[index].doneBy)
				Fingerprint1:SetText(CheckKnow(doneChecks[index].Fingerprints[1]))
				Fingerprint2:SetText(CheckKnow(doneChecks[index].Fingerprints[2]))
				Fingerprint3:SetText(CheckKnow(doneChecks[index].Fingerprints[3]))
				Timestamp:SetText(doneChecks[index].TimeString)
				DrawEntity:SetModel(doneChecks[index].Model)

			Button:Show()
			
		end


		List.OnRowSelected = function(panel, rowIndex, row) -- Only show Button if you selected an Entry

				ChooseButton:Show()

		end

        DoneChecks.OnRowSelected = function(panel, rowIndex, row) -- Only Show button if you selected an Entry and it is done
        
			if (doneChecks[rowIndex].doneAt + lfpRefreshCooldown ) >= CurTime() then 
				CheckedButton:Hide()

			else
				CheckedButton:Show()

			end            

        end

		net.Receive("fpRefreshChecks", function() --Refresh vars 

			local doneChecks = net.ReadTable()
			DoneChecks:Clear()
			for k,v in ipairs(doneChecks) do
				DoneChecks:AddLine( doneChecks[k].ID,(fingerprintsTrackedWeapons[doneChecks[k].Name] or fingerprintsTrackedEnts[doneChecks[k].Name]), doneChecks[k].doneBy, doneChecks[k].TimeString, checkReady(doneChecks[k].doneAt))
			end
			DoneChecks:SortByColumn(1, true)
		end)
end

net.Receive("fpOpenMenu", function() --Open the Menu on this specific dude

	local guy = net.ReadEntity()
	local entlist = net.ReadTable()
	local doneChecks = net.ReadTable()
	savedPlayers = net.ReadTable()

	guy:OpenMenu(entlist, doneChecks)

end)

