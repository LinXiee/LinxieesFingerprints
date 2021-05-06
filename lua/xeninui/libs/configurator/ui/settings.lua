--[[
This code was generated by LAUX, a Lua transpiler
LAUX is a fork of LAU with additional changes.

More info & source code can be found at: https://gitlab.com/sleeppyy/laux
]]

local PANEL = {}

XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Title", 40)
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Navbar", 18)
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Setting", 18)
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Setting.Italic", 18, nil, {
italic = true
})
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Category", 22)
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Selectbox", 18)
XeninUI:CreateFont("Xenin.Configurator.Admin.Panel.Save", 16)

AccessorFunc(PANEL, "m_networkId", "NetworkId")

function PANEL:OnSearch() end

function PANEL:Init()
  self.Categories = {}
  self.Settings = {}

  self:DockPadding(16, 16, 16, 16)

  self:SetNetworkId("settings")

  self.Top = self:Add("Panel")
  self.Top:Dock(TOP)

  self.Title = self.Top:Add("DLabel")
  self.Title:Dock(LEFT)
  self.Title:DockMargin(0, -10, 0, 0)
  self.Title:SetFont("Xenin.Configurator.Admin.Panel.Title")

  self.Save = self.Top:Add("DButton")
  self.Save:Dock(RIGHT)
  self.Save:DockMargin(8, 0, 0, 0)
  self.Save:SetText("Save")
  self.Save.Color = XeninUI.Theme.GreenDark
  self.Save.TextColor = color_white
  self.Save:SetFont("Xenin.Configurator.Admin.Panel.Save")
  self.Save.Paint = function(pnl, w, h)
    pnl:SetTextColor(pnl.TextColor)

    XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.Color)
  end
  self.Save.DoClick = function(pnl)
    local id = self:GetNetworkId()
    local settings = {}
    for i, v in ipairs(self.Settings) do
      local id = v.Data.id
      local val = v.Input:GetSettingValue()

      self.ctr:set(id, val)
      settings[id] = val
    end

    XeninUI.Configurator.Network:sendSaveSettings(self.script, settings)
  end
  self.Save.SetState = function(pnl, state)
    pnl.State = state
    pnl:LerpColor("Color", ColorAlpha(XeninUI.Theme.GreenDark, state and 255 or 125))
    pnl:LerpColor("TextColor", ColorAlpha(color_white, state and 255 or 125))
  end
  self.Save:SetState(true)
  XeninUI:AddRippleClickEffect(self.Save, color_black)

  self.Search = self.Top:Add("XeninUI.TextEntry")
  self.Search:Dock(RIGHT)
  self.Search:DockMargin(0, 0, 0, 0)
  self.Search:SetPlaceholder("Search")
  self.Search:SetIcon(XeninUI.Materials.Search, true)
  self.Search.textentry:SetUpdateOnType(true)
  self.Search.textentry.OnValueChange = function(pnl, text)
    XeninUI:Debounce("Xenin.Configurator.Admin.Debounce", 0.2, function()
      if (!IsValid(self)) then return end

      self:OnSearch(text)
    end)
  end

  self.Navbar = self:Add("DPanel")
  self.Navbar:Dock(TOP)
  self.Navbar:DockMargin(0, 8, 0, 16)
  self.Navbar.Paint = function(pnl, w, h) end
  self.Navbar.Navbar = self.Navbar:Add("DPanel")
  self.Navbar.Navbar:Dock(FILL)
  self.Navbar.Navbar:DockMargin(0, 4, 0, 0)
  self.Navbar.Navbar.Paint = function() end
  self.Navbar.Navbar.PerformLayout = function(pnl, w, h)
    pnl.Line:SetTall(2)
    pnl.Line:SetPos(pnl.Line.x, h - 2)
  end
  self.Navbar.Navbar.SetActive = function(pnl, id)
    local active = pnl.Active
    pnl.Active = id

    local btn = pnl.Buttons[active]
    if IsValid(btn) then
      btn:LerpColor("TextColor", Color(145, 145, 145))
    end

    btn = pnl.Buttons[id]
    if (!IsValid(btn)) then return end

    local _, _, margin, _ = btn:GetDockMargin()
    local x = 0
    for i = 1, id - 1 do
      x = x + (pnl.Buttons[i]:GetWide() + margin)
    end

    if active then
      pnl.Line:LerpMoveX(x, 0.3)
      pnl.Line:LerpWidth(btn:GetWide(), 0.3)
      btn:LerpColor("TextColor", color_white)
      local cat = self:GetCategory(btn:GetText())
      if ispanel(cat) then
        self.Scroll:ScrollToChild(cat)
      end
    else
      pnl.Line.x = x
      pnl.Line:SetWide(btn:GetWide())
      btn.TextColor = color_white
    end
  end

  self.Navbar.Navbar.Line = self.Navbar.Navbar:Add("DPanel")
  self.Navbar.Navbar.Line:SetMouseInputEnabled(false)
  self.Navbar.Navbar.Line.x = 0
  self.Navbar.Navbar.Line.Paint = function(pnl, w, h)
    surface.SetDrawColor(XeninUI.Theme.Accent)
    surface.DrawRect(0, 0, w, h)
  end

  self.Navbar.Navbar.Buttons = {}
  self.Navbar.Navbar.AddButton = function(pnl, name)
    local btn = pnl:Add("DButton")
    btn:Dock(LEFT)
    btn:DockMargin(0, 0, 12, 0)
    btn:SetText(name)
    btn:SetFont("Xenin.Configurator.Admin.Panel.Navbar")
    btn:SizeToContentsX(0)
    btn:SizeToContentsY()
    btn.TextColor = Color(145, 145, 145)
    btn.Paint = function(pnl, w, h)
      pnl:SetTextColor(pnl.TextColor)
    end
    btn.OnCursorEntered = function(pnl)
      pnl:LerpColor("TextColor", color_white)
    end
    btn.OnCursorExited = function()
      if (pnl.Active == btn.Id) then return end

      btn:LerpColor("TextColor", Color(145, 145, 145))
    end
    btn.DoClick = function()
      pnl:SetActive(btn.Id)
    end

    local id = table.insert(pnl.Buttons, btn)
    pnl.Buttons[id].Id = id
  end

  self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
  self.Scroll:Dock(FILL)

  self.Body = self.Scroll:Add("Panel")
  self.Body.PerformLayout = function(pnl, w, h)
    pnl:SizeToChildren(false, true)
  end
end

function PANEL:SetActive(id)
  self.Navbar.Navbar:SetActive(id)
end

function PANEL:AddButton(name)
  self.Navbar.Navbar:AddButton(name)
end

function PANEL:PerformLayout(w, h)
  self.Navbar:SetTall(32)
  self.Top:SetTall(32)
  self.Search:SetWide(200)

  if IsValid(self.Body) then
    self.Body:SetWide(math.min(650, w - 56))
    self.Body:SizeToContentsY()
    self.Body:Center()
    self.Body:SizeToChildren(false, true)
  end

  for i, v in ipairs(self.Settings) do
    v:SetTall(v.Height or 48)
  end
end

function PANEL:SetTitle(title)
  self.Title:SetText(title)
  self.Title:SizeToContents()
end

function PANEL:Paint(w, h)
  surface.SetDrawColor(180, 180, 180)
  surface.DrawLine(16, 56, w - 16, 56)
end

function PANEL:CreateCategory(name)
  local panel = self.Body:Add("DPanel")
  panel:Dock(TOP)
  panel:DockPadding(0, 36, 0, 40)
  panel.Name = name
  panel.Paint = function(pnl, w, h)

    draw.SimpleText(pnl.Name, "Xenin.Configurator.Admin.Panel.Category", 8, 32 / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end
  panel.PerformLayout = function(pnl, w, h)
    pnl:SizeToChildren(false, true)
  end

  return panel
end

function PANEL:GetCategory(cat)
  return self.Categories[cat]
end

function PANEL:SetSettings(tbl)
  self.settings = tbl

  for i, v in ipairs(tbl) do
    self:AddSetting(v)
  end
end

function PANEL:AddSetting(tbl)
  if (!self.Categories[tbl.category]) then
    local foundCat
    for i, v in pairs(self.Navbar.Navbar.Buttons) do
      if (v:GetText() != tbl.category) then continue end

      foundCat = true
      break
    end
    if (!foundCat) then
      self:AddButton(tbl.category)
    end
    self.Categories[tbl.category] = self:CreateCategory(tbl.category)
  end

  local input = XeninUI.Configurator:CreateInputPanel(tbl.type, self, tbl)
  if input.SetData then
    input:SetData(tbl.data)
  end
  if input.SetInput then
    input:SetInput(tbl.value)
  end

  local panel = self.Categories[tbl.category]:Add("DPanel")
  input:SetParent(panel)
  panel:Dock(TOP)
  panel.Data = tbl
  panel.Height = input.Height or 48
  panel:SetTall(input.Height or 48)
  panel.Input = input
  panel.Markup = markup.Parse("<font=Xenin.Configurator.Admin.Panel.Setting><color=145,145,145>" .. tostring(tbl.name) .. "</color></font>")
  panel.Paint = function(pnl, w, h)
    local x = 0
    if tbl.onPaint then x = x + tbl.onPaint(pnl, w, h)
    end
    surface.SetDrawColor(100, 100, 100)
    surface.DrawRect(0, h - 1, w, 1)

    pnl.Markup:Draw(x + 8, 48 / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end
  if tbl.func then
    tbl.func(input, panel)
  end
  if (tbl.onChange or tbl.data.onChange) then
    input.onChange = tbl.onChange or tbl.data.onChange
  end
  if tbl.data.postInit then
    tbl.data.postInit(input, panel)
  end
  panel.PerformLayout = function(pnl, w, h)
    local l, t, r, b = pnl.Input:GetDockMargin()
    pnl.Input:SetTall(h - t - b)
    pnl.Input:SetPos(w - l - pnl.Input:GetWide() - r, t)
  end

  table.insert(self.Settings, panel)
end

function PANEL:SetScript(script)
  self.script = script
  self.ctr = XeninUI.Configurator:FindControllerByScriptName(script)
end

function PANEL:SetData(data)
  self:SetTitle(data.name)
  if data.hideSearch then
    self.Search:SetVisible(false)
  end
  self:SetSettings(self.ctr:getSortedSettings())
  self:SetActive(1)
end

vgui.Register("Xenin.Configurator.Admin.Panel", PANEL, "XeninUI.Panel")
