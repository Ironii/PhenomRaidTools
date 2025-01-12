local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local Difficulties = {
  difficultyStrings = {
    "Normal",
    "Heroic",
    "Mythic"
  }
}


-------------------------------------------------------------------------------
-- Public API

function PRT.AddDifficultyWidgets(container, options)
  local explanationLabel = PRT.Label(L["PhenomRaidTools will only load for the configured difficulties."])
  explanationLabel:SetRelativeWidth(1)

  local dungeonGroup = PRT.InlineGroup(L["Dungeon"])
  dungeonGroup:SetLayout("Flow")

  for _, difficulty in ipairs(Difficulties.difficultyStrings) do
    local widget = PRT.CheckBox(L[difficulty], nil, options["dungeon"][difficulty])
    widget:SetRelativeWidth(0.33)
    widget:SetCallback("OnValueChanged",
      function()
        options["dungeon"][difficulty] = widget:GetValue()
      end)
    dungeonGroup:AddChild(widget)
  end

  local raidGroup = PRT.InlineGroup(L["Raid"])
  raidGroup:SetLayout("Flow")

  for _, difficulty in ipairs(Difficulties.difficultyStrings) do
    local widget = PRT.CheckBox(L[difficulty], nil, options["raid"][difficulty])
    widget:SetRelativeWidth(0.33)
    widget:SetCallback("OnValueChanged",
      function()
        options["raid"][difficulty] = widget:GetValue()
      end)
    raidGroup:AddChild(widget)
  end

  container:AddChild(explanationLabel)
  container:AddChild(dungeonGroup)
  container:AddChild(raidGroup)
end
