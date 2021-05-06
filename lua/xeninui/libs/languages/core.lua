--[[
This code was generated by LAUX, a Lua transpiler
LAUX is a fork of LAU with additional changes.

More info & source code can be found at: https://gitlab.com/sleeppyy/laux
]]

XeninUI.LanguageAddons = XeninUI.LanguageAddons or {}

if (!file.IsDir("xenin/languages", "DATA")) then
  file.CreateDir("xenin/languages")
end

local LANG = {}
LANG.Languages = {}

AccessorFunc(LANG, "m_url", "URL")
AccessorFunc(LANG, "m_folder", "Folder")
AccessorFunc(LANG, "m_branch", "Branch")

function LANG:SetActiveLanguage(lang)
  self.activeLang = lang

  self.Languages[lang] = self.Languages[lang] or {
    phrases = {},
    cachedPhrases = {}
  }
end

function LANG:GetActiveLanguage(lang)
  return self.activeLang end

function LANG:SetID(id)
  self.ID = id

  if (!file.IsDir("xenin/languages/" .. id, "DATA")) then
    file.CreateDir("xenin/languages/" .. id)
  end
end

function LANG:GetID()
  return self.ID
end

function LANG:GetFilePath(lang)
  return "xenin/languages/" .. self:GetID() .. "/" .. lang .. ".json"
end

function LANG:Exists(lang)
  return file.Exists(self:GetFilePath(lang), "DATA")
end

function LANG:SetLocalLanguage(lang, tbl)
  local _tbl = {}
  _tbl.cachedPhrases = {}
  tbl = isstring(tbl) and util.JSONToTable(tbl) or tbl
  table.Merge(_tbl, tbl)

  self.Languages[lang] = _tbl
end

function LANG:Download(lang, overwrite)
  local p = XeninUI.Promises.new()
  if (self:GetLanguage(lang) and !overwrite) then
    local tbl = self:GetLanguage(lang)
    if tbl then
      return p:resolve(tbl)
    else
      local tbl = file.Read(self:GetFilePath(lang), "DATA")
      if tbl then
        return p:resolve(util.JSONToTable(tbl))
      end
    end


  end

  local branch = self:GetBranch() or "master"
  local url = self:GetURL() .. "/raw/" .. branch .. "/" .. self:GetFolder() .. "/" .. lang .. ".json"
  local function tryDownloadFromServer(err)
    if (CLIENT and !LocalPlayer()["__XeninLanguageRequest_" .. tostring(self:GetID()) .. "_" .. tostring(lang)]) then
      LocalPlayer()["__XeninLanguageRequest_" .. tostring(self:GetID()) .. "_" .. tostring(lang)] = true

      XeninUI.LanguagesNetwork:sendRequestLanguage(self:GetID(), lang)

      return p:reject(err or "Download failure, attempting to download from server>")
    end

    return p:reject(err or "Download failure, attempting to download from server>")
  end

  http.Fetch(url, function(body, size, headers, code)
    if (code != 200) then
      return tryDownloadFromServer()
    end
    if (size == 0) then
      return tryDownloadFromServer("GitLab is down??")
    end


    if (body:sub(1, 15) == "<!DOCTYPE html>") then
      return tryDownloadFromServer(lang .. " language not found")
    end
    local tbl = util.JSONToTable(body)
    if (!tbl) then
      return tryDownloadFromServer("Unable to decode JSON")
    end

    file.Write(self:GetFilePath(lang), body)

    local _tbl = {}
    _tbl.cachedPhrases = {}
    table.Merge(_tbl, tbl)
    self.Languages[lang] = _tbl

    p:resolve(tbl, body, headers)
  end, function(err)

    if (CLIENT and !LocalPlayer()["__XeninLanguageRequest_" .. tostring(self:GetID()) .. "_" .. tostring(lang)]) then
      LocalPlayer()["__XeninLanguageRequest_" .. tostring(self:GetID()) .. "_" .. tostring(lang)] = true

      XeninUI.LanguagesNetwork:sendRequestLanguage(self:GetID(), lang)

      return p:reject("Download failure, attempting to download from server>")
    end

    p:reject(err)
  end)

  return p
end

function LANG:GetLanguage(lang)
  return self.Languages[lang] or {
    phrases = {},
    cachedPhrases = {}
  }
end

function LANG:GetCachedPhrase(lang, phrase)
  local tbl = self:GetLanguage(lang)
  local str

  if (!tbl.cachedPhrases[phrase]) then
    local split = string.Explode(".", phrase)
    local outputPhrase = tbl.phrases
    for i, v in ipairs(split) do
      if (!outputPhrase[v]) then
        outputPhrase = nil

        break
      end

      outputPhrase = outputPhrase[v]
    end

    str = outputPhrase
    tbl.cachedPhrases[phrase] = outputPhrase
  else
    str = tbl.cachedPhrases[phrase]
  end

  return str
end

function LANG:GetPhrase(phrase, replacement)
  local activeLang = self:GetActiveLanguage()
  local str = self:GetCachedPhrase(activeLang, phrase)
  if (!str and activeLang != "english") then
    str = self:GetCachedPhrase("english", phrase)

    if (!str) then str = phrase end
  end

  if (replacement and str) then
    for i, v in pairs(replacement) do
      str = str:Replace(":" .. i .. ":", v)
    end
  end

  return str
end

function XeninUI:Language(id)
  if self.LanguageAddons[id] then
    return self.LanguageAddons[id]
  end

  local tbl = table.Copy(LANG)
  tbl:SetID(id)

  self.LanguageAddons[id] = tbl

  return tbl
end
