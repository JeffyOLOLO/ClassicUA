
local tooltip_entry_type = false
local tooltip_entry_id = false

-- content_index: default is 2 (description)
function CUA_tooltips:add_entry_to_tooltip(tooltip, entry_type, entry_id, content_index)
    if tooltip_entry_type then
        return
    end

    local entry = get_entry(entry_type, entry_id)

    if not entry then -- todo: check if debug info should be shown
        entry = { entry_type .. "|cff999999#|r" .. entry_id }
    end

    if entry then
        tooltip:AddLine(" ")
        tooltip:AddLine("|TInterface\\AddOns\\ClassicUA\\assets\\ua:0|t " .. capitalize(entry[1]), 1, 1, 1)

        local content = make_entry_text(entry[content_index or 2], tooltip)
        if content then
            tooltip:AddLine(capitalize(content), 1, 1, 1, true)
        end

        if tooltip:IsShown() then
            tooltip:Show()
        end
    end

    tooltip_entry_type = entry_type
    tooltip_entry_id = entry_id
end

--rem
function CUA_tooltips:add_talent_entry_to_tooltip(tooltip, tab_index, talent_index, rank, max_rank)
    local talent = addonTable.talent_tree[tab_index] and addonTable.talent_tree[tab_index][talent_index] or false
    if not talent then -- this can never be true (as we have full Classic talent tree)
        return
    end

    local rank_to_show = math.max(rank, 1)
    local next_rank_to_show = math.min(rank + 1, max_rank)

    if not talent[rank_to_show] or not talent[next_rank_to_show] then -- this can never be true (otherwise, bug in talent_tree)
        return
    end

    local entry = get_entry("spell", talent[rank_to_show])
    if not entry then
        entry = { "spell|cff999999#|r" .. talent[rank_to_show] }
    end

    tooltip:AddLine(" ")
    tooltip:AddLine("|TInterface\\AddOns\\ClassicUA\\assets\\ua:0|t " .. entry[1], 1, 1, 1)

    if entry[2] then
        tooltip:AddLine(make_entry_text(entry[2], tooltip), 1, 1, 1, true)
    end

    if rank_to_show ~= next_rank_to_show then
        local next_rank_desc = "spell|cff999999#|r" .. talent[next_rank_to_show]

        local entry = get_entry("spell", talent[next_rank_to_show])
        if entry and entry[2] then
            next_rank_desc = make_entry_text(entry[2], tooltip, 1)
        end

        tooltip:AddLine(" ")
        tooltip:AddLine(get_text("Next rank") .. ":", 1, 1, 1)
        tooltip:AddLine(next_rank_desc, 1, 1, 1, true)
    end

    if tooltip:IsShown() then
        tooltip:Show()
    end

    tooltip_entry_type = "spell"
    tooltip_entry_id = talent[rank_to_show]
end

function CUA_tooltips:tooltip_set_item(self)
    local _, link = self:GetItem()
    if link then
        local _, _, id = link:find("Hitem:(%d+):")
        if id then
            add_entry_to_tooltip(self, "item", id)
        end
    end
end

function CUA_tooltips:tooltip_set_spell(self)
    local _, id = self:GetSpell()
    if id then
        add_entry_to_tooltip(self, "spell", id)
    end
end

function CUA_tooltips:tooltip_set_unit(self)
    local _, unit = self:GetUnit()
    if unit then
        local guid = UnitGUID(unit)
        local _, _, _, _, _, id, _ = strsplit("-", guid)
        if id then
            add_entry_to_tooltip(self, "npc", id)
        end
    end
end

function CUA_tooltips:tooltip_cleared(self)
    tooltip_entry_type = false
    tooltip_entry_id = false
end

for _, tt in pairs { GameTooltip, ItemRefTooltip } do
    tt:HookScript("OnTooltipSetItem", tooltip_set_item)
    tt:HookScript("OnTooltipSetSpell", tooltip_set_spell)
    tt:HookScript("OnTooltipSetUnit", tooltip_set_unit)
    tt:HookScript("OnTooltipCleared", tooltip_cleared)
end

--rem
hooksecurefunc(GameTooltip, "SetTalent", function (self, tab_index, talent_index)
    local rank, max_rank, is_active = select(5, GetTalentInfo(tab_index, talent_index))
    if not is_active then -- skip active talent (they get shown as spell)
        -- print("talent", tab_index, talent_index, "rank", rank, max_rank)
        add_talent_entry_to_tooltip(self, tab_index, talent_index, rank, max_rank)
    end
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function (self, unit, index, filter)
    local id = select(10, UnitAura(unit, index, filter))
    if id then
        add_entry_to_tooltip(self, "spell", id, 3)
    end
end)

hooksecurefunc(GameTooltip, "SetUnitBuff", function (self, unit, index)
    local id = select(10, UnitAura(unit, index, "HELPFUL"))
    if id then
        add_entry_to_tooltip(self, "spell", id, 3)
    end
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function (self, unit, index)
    local id = select(10, UnitAura(unit, index, "HARMFUL"))
    if id then
        add_entry_to_tooltip(self, "spell", id, 3)
    end
end)

GameTooltip:HookScript("OnUpdate", function (self)
    local name, unit = self:GetUnit()
    if name == nil and unit == nil and not tooltip_entry_type then
        local text = GameTooltipTextLeft1:GetText()
        if text ~= tooltip_entry_id then
            local entry = get_entry_text(text)
            if entry then
                if self:NumLines() > 1 then self:AddLine(" ") end
                self:AddLine("|TInterface\\AddOns\\ClassicUA\\assets\\ua:0|t " .. capitalize(entry), 1, 1, 1)

                if self:IsShown() then
                    self:Show()
                end
            end

            tooltip_entry_type = "text"
            tooltip_entry_id = text
        end
    end
end)
