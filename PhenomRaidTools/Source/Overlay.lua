local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local Overlay = {}
local headerColor = "FFFFF569"
local subHeaderColor = "FFFF7D0A"
local textColor = "FFFFFFFF"
local padding = 15


-------------------------------------------------------------------------------
-- Local Helper


-------------------------------------------------------------------------------
-- Public API

Overlay.SavePosition = function(widget, options)
    local left, top = widget:GetLeft(), widget:GetTop()

    options.top = UIParent:GetHeight() - top
    options.left = left
end

Overlay.UpdateSize = function(container)
    local headerWidth = container.header:GetStringWidth()
    local width = container.text:GetStringWidth()
    container:SetWidth(math.max(width, headerWidth) + (2 * padding))

    local headerHeight = container.header:GetStringHeight()
    local height = container.text:GetStringHeight()
    container:SetHeight(height + headerHeight + (2 * padding))
end

Overlay.UpdateFont = function(container, fontSize)
    container.text:SetFont(GameFontHighlightSmall:GetFont(), fontSize, "OUTLINE")
    container.header:SetFont(GameFontHighlightSmall:GetFont(), fontSize, "OUTLINE")
end

Overlay.UpdateBackdrop = function(container, r, g, b, a)
    container:SetBackdropColor(r, g, b, a);
end

Overlay.AddHeading = function(s, text)
    return s.."|c"..headerColor..text.."|r"
end

Overlay.AddSubHeading = function(s, text)
    return s.."|c"..subHeaderColor..text.."|r\n"
end

Overlay.AddText = function(s, text)
    return s.."|c"..textColor..text.."|r\n"
end

Overlay.SetMoveable = function(widget, v)
    widget:EnableMouse(v)
    widget:SetMovable(v)
end

Overlay.CreateOverlay = function(options, withBackdrop)
    PRT.Debug("Creating overlay")
    local overlayFrame = CreateFrame("Frame", nil, UIParent)
    overlayFrame:EnableMouse(true)
    overlayFrame:SetMovable(true)
    overlayFrame:SetClampedToScreen(true)
    overlayFrame:RegisterForDrag("LeftButton")
    overlayFrame:SetScript("OnDragStart", overlayFrame.StartMoving)
    overlayFrame:SetScript("OnDragStop", 
        function(widget) 
            Overlay.SavePosition(widget, options) 
            overlayFrame:StopMovingOrSizing() 
        end)

    if withBackdrop then
        overlayFrame:SetBackdrop(
            {
                bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                edgeFile = nil, 
                tile = true, tileSize = 16, edgeSize = 16, 
                insets = { 
                    left = 4, 
                    right = 4, 
                    top = 4, 
                    bottom = 4 
            }});

        overlayFrame:SetBackdropColor((options.backdropColor.r or 0), (options.backdropColor.g or 0), (options.backdropColor.b or 0), (options.backdropColor.a or 0));
    end

    overlayFrame:SetFrameStrata("MEDIUM")
    overlayFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", options.left, -options.top)

    overlayFrame.text = overlayFrame:CreateFontString(nil, "ARTWORK") 
    overlayFrame.text:SetJustifyH("CENTER")
    overlayFrame.text:SetFont(GameFontHighlightSmall:GetFont(), options.fontSize, "OUTLINE")
    overlayFrame.text:SetPoint("TOPLEFT", padding, 2 * -padding)
    overlayFrame.text:SetText("")

    overlayFrame.header = overlayFrame:CreateFontString(nil, "ARTWORK") 
    overlayFrame.header:SetJustifyH("CENTER")
    overlayFrame.header:SetFont(GameFontHighlightSmall:GetFont(), options.fontSize, "OUTLINE")
    overlayFrame.header:SetPoint("TOPLEFT", padding, -padding)
    overlayFrame.header:SetText("")

    return overlayFrame
end

Overlay.ClearText = function(widget)
    if widget then
        PRT.Debug("Clearing overlay text")
        widget.text:SetText("")
    end
end

Overlay.Hide = function(widget)
    if widget then    
        PRT.Debug("Hide overlay")        
		Overlay.ClearText(widget)
        widget:Hide()
    end
end

Overlay.Show = function(widget)
    if widget then        
        PRT.Debug("Show overlay")        
        Overlay.ClearText(widget)
        widget:Show()
    end
end

PRT.Overlay = Overlay