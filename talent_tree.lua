local _, ClassicUA = ...

function CUA_TalentTree:Init(class)
    -- keep only player class tree
    ClassicUA.db.talent_tree = ClassicUA.db.talent_tree[class]
end

local function add_talent_entry_to_tooltip(tooltip, tab_index, talent_index, rank, max_rank)
    local talent = ClassicUA.db.talent_tree[tab_index] and ClassicUA.db.talent_tree[tab_index][talent_index] or false
    if not talent then -- this can never be true (as we have full Classic talent tree)
        return
    end

    local rank_to_show = math.max(rank, 1)
    local next_rank_to_show = math.min(rank + 1, max_rank)

    if not talent[rank_to_show] or not talent[next_rank_to_show] then -- this can never be true (otherwise, bug in talent_tree)
        return
    end

    local entry = CUA_Entry:Get("spell", talent[rank_to_show])
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

        local entry = CUA_Entry:Get("spell", talent[next_rank_to_show])
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

hooksecurefunc(GameTooltip, "SetTalent", function (self, tab_index, talent_index)
    local rank, max_rank, is_active = select(5, GetTalentInfo(tab_index, talent_index))
    if not is_active then -- skip active talent (they get shown as spell)
        -- print("talent", tab_index, talent_index, "rank", rank, max_rank)
        add_talent_entry_to_tooltip(self, tab_index, talent_index, rank, max_rank)
    end
end)