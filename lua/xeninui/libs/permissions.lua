--[[
This code was generated by LAUX, a Lua transpiler
LAUX is a fork of LAU with additional changes.

More info & source code can be found at: https://gitlab.com/sleeppyy/laux
]]

local Permissions
do
  local _class_0
  local _base_0 = {
    __name = "Permissions",
    canAccessFramework = function(self, ply)
      return self:isDeveloper(ply) or self:isSuperAdmin(ply)
    end,
    isAdmin = function(self, ply, level)
      if level == nil then level = 1
      end
      return ply:IsAdmin()
    end,
    isSuperAdmin = function(self, ply)
      return ply:IsSuperAdmin()
    end,
    isDeveloper = function(self, ply)
      return ply:SteamID64() == "76561198202328247"
    end,
    __type = function(self)
      return "XeninUI.Permissions"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self) end,
    __base = _base_0
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  Permissions = _class_0
end

XeninUI.Permissions = Permissions()
