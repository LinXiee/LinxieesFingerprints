--[[
This code was generated by LAUX, a Lua transpiler
LAUX is a fork of LAU with additional changes.

More info & source code can be found at: https://gitlab.com/sleeppyy/laux
]]

do
  local _class_0
  local _base_0 = {
    __name = "XeninUI.ORM.ORM",
    tableWrapper = function(self)
      return function(...)
        return XeninUI.ORM.Table(self.connection, ...)
      end
    end,
    createMigrationTable = function(self, callback)
      if callback == nil then callback = function() end
      end
      return XeninUI.ORM.Table(self.connection, "xenin_framework_migrations", function(tbl)
        tbl:string("id"):length(255):primary()
        tbl:date("last_updated"):nullable()
        tbl:integer("times_updated"):default(0)
      end, callback)
    end,
    getConnection = function(self)
      return self.connection
    end,
    handleMigration = function(self, file, tablePath)
      local conn = self.connection
      local split = string.Explode("_", file)
      local date = split[1]
      table.remove(split, 1)
      local tableName = table.concat(split, "_")
      tableName = tableName:sub(1, #tableName - 4)

      local x = self:orm("xenin_framework_migrations"):select():where("last_updated", ">", date):where("id", "=", tableName):run():next(function(result)
        if (!result) then
          include(tablePath .. file)(self:tableWrapper())

          self:orm("xenin_framework_migrations"):debugName("XD"):upsert({
            last_updated = date,
            id = tableName,
            times_updated = Builder.upsertDifference({
              insert = Builder.raw(0),
              update = Builder.raw("times_updated + 1")
            })
          }):run()

        end
      end, function(err)
        Error(err)
      end)

    end,
    orm = function(self, tableName, returnId)
      return self.b(tableName, self.connection, returnId)
    end,
    __type = function(self)
      return "XeninUI.ORM.ORM"end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, tablePath, connection)
      if connection == nil then connection = XeninDB
      end
      self.connection = connection
      self:createMigrationTable(function()
        local files = file.Find(tostring(tablePath) .. "*.lua", "LUA")
        for i, file in ipairs(files) do
          self:handleMigration(file, tablePath)
        end
      end, function(err)
        Error(err)
      end)

      self.b = XeninUI.ORM.Builder

      return self
    end,
    __base = _base_0
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  XeninUI.ORM.ORM = _class_0
end
