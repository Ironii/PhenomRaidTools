local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local AceGUI = LibStub("AceGUI-3.0")
local Media = LibStub("LibSharedMedia-3.0")

local AceHelper = {
	widgetDefaultWidth = 250,
	LSMLists = {
		font = Media:HashTable("font"),
		sound = Media:HashTable("sound")
	}
}

-------------------------------------------------------------------------------
-- Local Helper

AceHelper.AddTooltip = function(widget, tooltip)
	if tooltip and widget then
		widget:SetCallback("OnEnter", function(widget) 
			GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			if type(tooltip) == "table" then
				for i, entry in ipairs(tooltip) do
					GameTooltip:AddLine(entry)	
				end
			else
				GameTooltip:AddLine(tooltip)	
			end
			GameTooltip:Show()
		end)

		widget:SetCallback("OnLeave", 
		function(widget) 
			GameTooltip:FadeOut() 
		end)
	end	
end

AceHelper.AddNewTab = function(widget, t, item)
    if not t then
        t = {}
    end
	tinsert(t, item)
	widget:SetTabs(PRT.TableToTabs(t, true))
	widget:DoLayout()
   widget:SelectTab(getn(t))
    
	PRT.Core.UpdateScrollFrame()
end

AceHelper.RemoveTab = function(widget, t, item)
	tremove(t, item)
	widget:SetTabs(PRT.TableToTabs(t, true))
	widget:DoLayout()
	widget:SelectTab(1)

	if getn(t) == 0 then
		widget:ReleaseChildren()
   end
    
	PRT.Core.UpdateScrollFrame()
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddSpellTooltip = function(widget, spellID)
	if spellID then
		widget:SetCallback("OnEnter", 
			function()
				GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
				GameTooltip:SetHyperlink("spell:"..spellID)			
				GameTooltip:Show()
			end)

		widget:SetCallback("OnLeave", 
			function()
				GameTooltip:Hide()
			end)
	end
	return widget
end

PRT.SelectFirstTab = function(container, t)		
	container:SelectTab(nil)
    if t then
		if getn(t) > 0 then
			container:SelectTab(1)
		end
	end
end

PRT.TableToTabs = function(t, withNewTab, newTabText)
	local tabs = {}
	
	if t then
        for i, v in ipairs(t) do
            if v.name then
                tinsert(tabs, {value = i, text = v.name})
            else
                tinsert(tabs, {value = i, text = i})
            end
		end
    end
    
    if withNewTab then
		tinsert(tabs, {value = "new", text = (newTabText or "+")})
	end
 
	return tabs
end

PRT.TabGroupSelected = function(widget, t, key, itemFunction, emptyItemFunction, deleteButton, deleteTextID)
	widget:ReleaseChildren()

	if key == "new" then
		local emptyItem = emptyItemFunction() or {}

		AceHelper.AddNewTab(widget, t, emptyItem)
    else	
		local item = nil
			        
        if t then
            item = t[key]
		  end
		
		itemFunction(item, widget, key, t) 

		if deleteButton then
			local deleteButtonText = L[deleteTextID]
			local deleteButton = AceGUI:Create("Button")
			deleteButton:SetText(deleteButtonText)
			deleteButton:SetCallback("OnClick", 
				function() 
					local text = L["deleteTabEntryConfirmationText"]
					PRT.ConfirmationDialog(text, 
						function()
							AceHelper.RemoveTab(widget, t, key)	
						end)            
			end)
		
			widget:AddChild(deleteButton)
		end
	end
	
	PRT.Core.UpdateScrollFrame()
end

PRT.ReSelectTab = function(container)
	container:SelectTab(container.localstatus.selected)
end

PRT.Release = function(widget)
	widget:ReleaseChildren()
	widget:Release()
end


-------------------------------------------------------------------------------
-- Container

PRT.TabGroup = function(textID, tabs)
	local text = L[textID]
	local container = AceGUI:Create("TabGroup")
	
	container:SetTitle(text)
	container:SetTabs(tabs)
	container:SetLayout("List")
	container:SetFullWidth(true)
	container:SetFullHeight(true)
	container:SetAutoAdjustHeight(true)
 
	return container
end

PRT.InlineGroup = function(textID)
	local text = L[textID]
	local container = AceGUI:Create("InlineGroup")    
	
	container:SetFullWidth(true)
	container:SetLayout("List")
	container:SetTitle(text)

   return container
end

-- TODO: Actually make this transparent even when using elvui
PRT.TransparentGroup = function()
	local text = L[textID]
	local container = AceGUI:Create("SimpleGroup")    
	container.frame:SetBackdrop(nil)

	container:SetFullWidth(true)
	container:SetLayout("List")

   return container
end

PRT.SimpleGroup = function()
	local container = AceGUI:Create("SimpleGroup")    
	
	container:SetFullWidth(true)
	container:SetLayout("List")

   return container
end

PRT.ScrollFrame = function()
	local container = AceGUI:Create("ScrollFrame")    
	
	container:SetLayout("List")	
	container:SetFullHeight(true)
	container:SetAutoAdjustHeight(true)

   return container
end

PRT.Frame = function(titleID)
	local titleText = L[titleID]
	local container = AceGUI:Create("Frame")    
	
	container:SetLayout("List")	
	container:SetFullHeight(true)
	container:SetAutoAdjustHeight(true)
	container:SetTitle(titleText)

   return container
end

PRT.TreeGroup = function(tree)
	local container = AceGUI:Create("TreeGroup")    
	
	container:SetLayout("Fill")
   container:SetTree(tree)

   return container
end

PRT.Window = function(titleID)
	local titleText = L[titleID]
	local container = AceGUI:Create("Window") 
	container.frame:SetFrameStrata("HIGH")   
	
	container:SetTitle(titleText)
	container:SetLayout("Fill")

   return container
end


-------------------------------------------------------------------------------
-- Widgets

PRT.Button = function(textID, addTooltip)
	local text = L[textID]

	local widget = AceGUI:Create("Button")

	if addTooltip then 		
		local tooltip = L[textID.."Tooltip"]
		AceHelper.AddTooltip(widget, tooltip)
	end

	widget:SetText(text)

	return widget
end

PRT.Heading = function(textID)
	local text = L[textID]

	local widget = AceGUI:Create("Heading")

	widget:SetText(text)
	widget:SetFullWidth(true)

	return widget
end
 
PRT.Label = function(textID, fontSize)
	local text = L[textID]

	local widget = AceGUI:Create("Label")

	widget:SetText(text)
	widget:SetFont(GameFontHighlightSmall:GetFont(), (fontSize or 12), "OUTLINE")
	widget:SetWidth(500)

	return widget
end

PRT.EditBox = function(textID, value, addTooltip)
	local text = L[textID]

	local widget = AceGUI:Create("EditBox")
	
	if addTooltip then 
		local tooltip = L[textID.."Tooltip"]
		AceHelper.AddTooltip(widget, tooltip)
	end

	widget:SetLabel(text)
	widget:SetText(value)
	widget:SetWidth(AceHelper.widgetDefaultWidth)
 
	return widget
end

PRT.MultiLineEditBox = function(textID, value, addTooltip)
	local text = L[textID]
	local widget = AceGUI:Create("MultiLineEditBox")
	
	if addTooltip then 
		local tooltip = L[textID.."Tooltip"]
		AceHelper.AddTooltip(widget, tooltip)
	end

	widget:SetLabel(text)
	if value then
		widget:SetText(value)
	end
 
	return widget
end

PRT.ColorPicker = function(textID, value)
	local text = L[textID]

	local widget = AceGUI:Create("ColorPicker")

	widget:SetLabel(text)
	widget:SetColor((value.r or 0), (value.g or 0), (value.b or 0), (value.a or 0))	
	widget:SetHasAlpha(false)
	--widget:SetRelativeWidth(1)
	widget:SetWidth(AceHelper.widgetDefaultWidth)

	return widget
end

PRT.Dropdown = function(textID, values, value, withEmpty, orderByKey)	
	local text = L[textID]

	local dropdownItems = {}
	if withEmpty then
		dropdownItems[999] = ""
	end

	for i,v in ipairs(values) do
		if type(v) == "string" then
			dropdownItems[v] = v
		else			
			dropdownItems[v.id] = v.name
		end
	end

	local widget = AceGUI:Create("Dropdown")	
	
	if orderByKey then
		local order = {}

		for i,v in ipairs(values) do
			local value
			if type(v) == "string" then
				value = v
			else			
				value = v.id
			end
			tinsert(order, value)
		end
		widget:SetList(dropdownItems, order)
	else
		widget:SetList(dropdownItems)
	end

	widget:SetLabel(text)	
	widget:SetText(dropdownItems[value])
	widget:SetWidth(AceHelper.widgetDefaultWidth)
	
	for i,v in ipairs(values) do
		if v.disabled then
			local id
			if type(v) == "string" then
				id = v
			else			
				id = v.id
			end
			widget:SetItemDisabled(id, true)
		end
	end

	return widget
end

PRT.CheckBox = function(textID, value, addTooltip)	
	local text = L[textID]	

	local widget = AceGUI:Create("CheckBox")

	if addTooltip then 
		local tooltip = L[textID.."Tooltip"]
		AceHelper.AddTooltip(widget, tooltip)
	end

	widget:SetLabel(text)
	widget:SetValue(value)
	widget:SetWidth(AceHelper.widgetDefaultWidth)

	return widget
end

PRT.Icon = function(value, spellID)	
	local widget = AceGUI:Create("Icon")
	widget:SetImage(value, 0.1, 0.9, 0.1, 0.9)
	PRT.AddSpellTooltip(widget, spellID)
 
	return widget
end

PRT.Slider = function(textID, value)
	local text = L[textID]
	local widget = AceGUI:Create("Slider")    
	
	widget:SetSliderValues(0, 60, 1)
	widget:SetLabel(text)
	if value then
		widget:SetValue(value)
	end
	widget:SetWidth(AceHelper.widgetDefaultWidth)

    return widget
end

PRT.SoundSelect = function(textID, value)
	local text = L[textID]

	local widget = AceGUI:Create("LSM30_Sound")
	widget:SetList(AceGUIWidgetLSMlists.sound)
	widget:SetLabel(text)	
	widget:SetText(value)

	return widget 
end

PRT.FontSelect = function(textID, value)
	local text = L[textID]

	local widget = AceGUI:Create("LSM30_Font")
	widget:SetList(AceGUIWidgetLSMlists.font)
	widget:SetLabel(text)	
	widget:SetText(value)

	return widget 
end