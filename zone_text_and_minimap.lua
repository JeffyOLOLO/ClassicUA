local zone_text_lookup = {
    -- { FontString object, lookup function }
    { ZoneTextString, get_entry_text },
    { SubZoneTextString, get_entry_text },
    { MinimapZoneText, get_entry_text },
    { PVPInfoTextString, get_text },
    { PVPArenaTextString, get_text },
}

local function update_zone_text()
    local text, found
    for _, lookup in ipairs(zone_text_lookup) do
        text = lookup[1]:GetText()
        if text then
            local found = lookup[2](text)
            if found then
                lookup[1]:SetText(capitalize(found))
            end
        end
    end
end

local function prepare_zone_text()
    for _, lookup in ipairs(zone_text_lookup) do
        local _, size, style = lookup[1]:GetFont()
        lookup[1]:SetFont("Interface\\AddOns\\ClassicUA\\assets\\FRIZQT_UA.ttf", size, style)
    end
    update_zone_text()
end
