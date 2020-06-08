local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Core = {
    openFrames = {

    }
}


-------------------------------------------------------------------------------
-- Local Helper

local RegisterESCHandler = function(name, container)
	_G[name] = container.frame
    tinsert(UISpecialFrames, name)
end

Core.RegisterFrame = function(id, frame)
    Core.openFrames[id] = frame
end

Core.UnregisterFrame = function(id)
    Core.openFrames[id] = nil
end

Core.FrameExists = function(text)
    local frame = Core.openFrames[text]

    if frame then
        return true
    else
        return false
    end        
end

Core.CloseAllOpenFrames = function()
    for id, frame in pairs(Core.openFrames) do
        frame:Hide()
    end

    wipe(Core.openFrames)
end

Core.DisabledText = function(text, enabled)
    if enabled then
        return text
    else
        return PRT.ColoredString(text, PRT.db.profile.colors.disabled)
    end
end

Core.GeneratePercentageTree = function(percentage)
    local t = {
        value = percentage.name,
        text = Core.DisabledText(percentage.name, percentage.enabled)
    }
    
    return t
end

Core.GeneratePercentagesTree = function(percentages)
    local children = {}
    local t = {
    }

    if percentages then
        if getn(percentages) > 0 then
            PRT.SortTableByName(percentages)
            t.children = children
            for i, percentage in ipairs(percentages) do
                tinsert(children, Core.GeneratePercentageTree(percentage))
            end
        end
    end
    
    return t
end

Core.GeneratePowerPercentagesTree = function(percentages)
    local tree = Core.GeneratePercentagesTree(percentages)
    tree.value = "powerPercentages"
    tree.text = L["treePowerPercentage"]
    tree.icon = 132849

    return tree
end

Core.GenerateHealthPercentagesTree = function(percentages)
    local tree = Core.GeneratePercentagesTree(percentages)
    tree.value = "healthPercentages"
    tree.text = L["treeHealthPercentage"]
    tree.icon = 648207

    return tree
end

Core.GenerateRotationTree = function(rotation)
    local t = {
        value = rotation.name,
        text = Core.DisabledText(rotation.name, rotation.enabled)
    }

    if rotation.triggerCondition then
        if rotation.triggerCondition.spellIcon then
            t.icon = rotation.triggerCondition.spellIcon
        end
    end
    
    return t
end

Core.GenerateRotationsTree = function(rotations)
    local children = {}
    local t = {
        value = "rotations",
        text = L["treeRotation"], 
        icon = 450907
    }

    if rotations then
        if getn(rotations) > 0 then
            PRT.SortTableByName(rotations)
            t.children = children
            for i, rotation in ipairs(rotations) do
                tinsert(children, Core.GenerateRotationTree(rotation))
            end
        end
    end
    return t
end

Core.GenerateTimerTree = function(timer)
    local t = {
        value = timer.name,
        text = Core.DisabledText(timer.name, timer.enabled)
    }

    if timer.startCondition then
        if timer.startCondition.spellIcon then
            t.icon = timer.startCondition.spellIcon
        end
    end
    
    return t
end

Core.GenerateTimersTree = function(timers)
    local children = {}
    local t = {
        value = "timers",
        text = L["treeTimer"],
        icon = 237538,
    }

    if timers then
        if getn(timers) > 0 then
            PRT.SortTableByName(timers)
            t.children = children
            for i, timer in ipairs(timers) do
                tinsert(children, Core.GenerateTimerTree(timer))
            end
        end
    end
    
    return t
end

Core.GenerateEncounterTree = function(encounter)
    -- Ensure that encounter has all trigger tables!
    PRT.EnsureEncounterTrigger(encounter)
    
    local children = {}
    local t = {
        value = encounter.id,  
        text = Core.DisabledText(encounter.name, encounter.enabled),    
        children = {
            Core.GenerateTimersTree(encounter.Timers),
            Core.GenerateRotationsTree(encounter.Rotations),
            Core.GenerateHealthPercentagesTree(encounter.HealthPercentages),
            Core.GeneratePowerPercentagesTree(encounter.PowerPercentages)
        }
    }

    return t
end

Core.GenerateEncountersTree = function(encounters)
    local children = {}

    local t = {
        value  = "encounters",
        text = L["treeEncounters"],
        children = children
    }    
    PRT.SortTableByName(encounters)
    for i, encounter in ipairs(encounters) do
        tinsert(children, Core.GenerateEncounterTree(encounter))
    end

    return t
end

Core.GenerateOptionsTree = function()
    local t = {
        value = "options",
        text = L["treeOptions"]
    }
    return t
end

Core.GenerateTreeByProfile = function(profile)
    local t = {
        Core.GenerateOptionsTree(),        
    }

    if profile.senderMode then
        tinsert(t, Core.GenerateEncountersTree(profile.encounters))
    end

    return t
end

Core.OnGroupSelected = function(container, key, profile)
    container:ReleaseChildren()
    
    local mainKey, encounterID, triggerType, triggerName = strsplit("\001", key)
    
    -- options selected
    if mainKey == "options" then        
        PRT.AddOptionWidgets(container, profile)

    -- encounters selected
    elseif mainKey == "encounters" and not triggerType and not triggerName and not encounterID then
        PRT.AddEncountersWidgets(container, profile)

    -- single encounter selected
    elseif encounterID and not triggerType and not triggerName then
        PRT.AddEncounterOptions(container, profile, encounterID)

    -- encounter trigger type selected
    elseif triggerType and not triggerName then
        if triggerType == "timers" then
            PRT.AddTimerOptionsWidgets(container, profile, encounterID)
        elseif triggerType == "rotations" then
            PRT.AddRotationOptions(container, profile, encounterID)
        elseif triggerType == "healthPercentages" then
            PRT.AddHealthPercentageOptions(container, profile, encounterID)
        elseif triggerType == "powerPercentages" then
            PRT.AddPowerPercentageOptions(container, profile, encounterID)
        end
    
    -- single timer selected
    elseif triggerType == "timers" and triggerName then
        PRT.AddTimerWidget(container, profile, tonumber(encounterID), triggerName)

    -- single rotaion selected
    elseif triggerType == "rotations" and triggerName then
        PRT.AddRotationWidget(container, profile, tonumber(encounterID), triggerName)

    -- single healthPercentages selected        
    elseif triggerType == "healthPercentages" and triggerName then
        PRT.AddHealthPercentageWidget(container, profile, tonumber(encounterID), triggerName)

    -- single powerPercentages selected        
    elseif triggerType == "powerPercentages" and triggerName then
        PRT.AddPowerPercentageWidget(container, profile, tonumber(encounterID), triggerName)
    end

    container:DoLayout()
    PRT.mainWindowContent:RefreshTree()
end

Core.ReselectCurrentValue = function()
    if PRT.mainWindowContent.selectedValue then
        PRT.mainWindowContent:SelectByValue(PRT.mainWindowContent.selectedValue)
    end
end

Core.ReselectExchangeLast = function(last)   
    if PRT.mainWindowContent.selectedValue then
        local xs = { strsplit("\001", PRT.mainWindowContent.selectedValue) }        
        tremove(xs, #xs)
        tinsert(xs, last)
        local selectValue = strjoin("\001", unpack(xs))
        PRT.mainWindowContent:SelectByValue(selectValue)
        PRT.mainWindowContent.selectedValue = selectValue
    end
end

Core.UpdateTree = function()
    PRT.mainWindowContent:SetTree(Core.GenerateTreeByProfile(PRT.db.profile))
end

Core.CreateMainWindowContent = function(profile)
    -- Create a sroll frame for the tree group content
    local treeContentScrollFrame = PRT.ScrollFrame()
    
    -- Generate tree group for the main menue structure
    local tree = Core.GenerateTreeByProfile(profile)
    local treeGroup = PRT.TreeGroup(tree)
    PRT.mainWindowContent = treeGroup 
    treeGroup:SetCallback("OnGroupSelected", 
        function(widget, event, key) 
            treeGroup.selectedValue = key
            Core.OnGroupSelected(treeContentScrollFrame, key, profile) 
        end)	    
        
    -- Expand encounters by default
    local treeGroupStatus = { groups = {} }
    treeGroup:SetStatusTable(treeGroupStatus)
    treeGroupStatus.groups["encounters"] = true    
    treeGroup:SelectByValue("options")
    treeGroup:RefreshTree()
         
    PRT.mainWindowContent.scrollFrame = treeContentScrollFrame

    treeGroup:AddChild(treeContentScrollFrame)

	return treeGroup
end

-------------------------------------------------------------------------------
-- Public API

PRT.CreateMainWindow = function(profile)
    local mainWindow = PRT.Window("mainWindowTitle")
    local mainWindowContent = Core.CreateMainWindowContent(profile)

	mainWindow:SetCallback("OnClose",
		function(widget) 
            PRT.Release(widget)
            PRT.ReceiverOverlay.Hide()
            PRT.SenderOverlay.Hide()
            Core.CloseAllOpenFrames()
        end)
        
    mainWindow:SetWidth(950)
    mainWindow:SetHeight(600)
    mainWindow.frame:SetMinResize(400, 400)
    RegisterESCHandler("mainWindow", mainWindow)

    -- Initialize sender and receiver frames
    PRT.ReceiverOverlay.Show()
    PRT.SenderOverlay.Show()    
    PRT.SenderOverlay.ShowPlaceholder(profile.overlay.sender)
    PRT.ReceiverOverlay.ShowPlaceholder(profile.overlay.receiver)

    mainWindow:AddChild(mainWindowContent)
    
    -- We hold the frame reference for some hacky rerendering usages :(
    PRT.mainWindow = mainWindow
    PRT.mainWindowContent = mainWindowContent
end	

-- Make functions publicly available
PRT.Core = Core