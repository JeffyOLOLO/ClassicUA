local _, ClassicUA.db = ...
local db = ClassicUA.db

function CUA_entries:get_stats()
    local stats = {}
    for _, v in ipairs({ "quest_a", "quest_h", "quest_n", "book", "item", "spell", "npc", "object", "zone" }) do
        stats[v] = 0
        for _, _ in pairs(db[v]) do stats[v] = stats[v] + 1 end
    end
    return stats
end

function CUA_entries:prepare_zones()
    local z = db.zone

    -- known aliases
    z["Crossroads"] = z["The Crossroads"]
    z["Crusader's Outpost"] = z["Crusader Outpost"]
    z["Dabyrie's Farmstead"] = z["Dabyrie Farmstead"]
    z["Stormwind City"] = z["Stormwind"]
    z["Stranglethorn"] = z["Stranglethorn Vale"]

    -- known taxi points
    local known_taxi_points = {
        "Aerie Peak, The Hinterlands",
        "Astranaar, Ashenvale",
        "Auberdine, Darkshore",
        "Bloodvenom Post, Felwood",
        "Booty Bay, Stranglethorn",
        "Brackenwall Village, Dustwallow Marsh",
        "Camp Mojache, Feralas",
        "Camp Taurajo, The Barrens",
        "Cenarion Hold, Silithus",
        "Chillwind Camp, Western Plaguelands",
        "Crossroads, The Barrens",
        "Darkshire, Duskwood",
        "Everlook, Winterspring",
        "Feathermoon, Feralas",
        "Flame Crest, Burning Steppes",
        "Freewind Post, Thousand Needles",
        "Gadgetzan, Tanaris",
        "Grom'gol, Stranglethorn",
        "Hammerfall, Arathi",
        "Ironforge, Dun Morogh",
        "Kargath, Badlands",
        "Lakeshire, Redridge",
        "Light's Hope Chapel, Eastern Plaguelands",
        "Marshal's Refuge, Un'Goro Crater",
        "Menethil Harbor, Wetlands",
        "Moonglade",
        "Morgan's Vigil, Burning Steppes",
        "Nethergarde Keep, Blasted Lands",
        "Nijel's Point, Desolace",
        "Orgrimmar, Durotar",
        "Ratchet, The Barrens",
        "Refuge Pointe, Arathi",
        "Revantusk Village, The Hinterlands",
        "Rut'theran Village, Teldrassil",
        "Sentinel Hill, Westfall",
        "Shadowprey Village, Desolace",
        "Southshore, Hillsbrad",
        "Splintertree Post, Ashenvale",
        "Stonard, Swamp of Sorrows",
        "Stonetalon Peak, Stonetalon Mountains",
        "Stormwind, Elwynn",
        "Sun Rock Retreat, Stonetalon Mountains",
        "Talonbranch Glade, Felwood",
        "Talrendis Point, Azshara",
        "Tarren Mill, Hillsbrad",
        "Thalanaar, Feralas",
        "The Sepulcher, Silverpine Forest",
        "Thelsamar, Loch Modan",
        "Theramore, Dustwallow Marsh",
        "Thorium Point, Searing Gorge",
        "Thunder Bluff, Mulgore",
        "Undercity, Tirisfal",
        "Valormok, Azshara",
        "Zoram'gar Outpost, Ashenvale",
    }

    for _, v in ipairs(known_taxi_points) do
        local loc, zone = strsplit(",", v)
        if loc and zone then
            loc = strtrim(loc)
            zone = strtrim(zone)
            if z[loc] and z[zone] then
                z[v] = z[loc] .. ", " .. z[zone]
            else
                print("[!] ClassicUA: Failed to prepare taxi zone \"" .. v .. "\"")
            end
        end
    end
end

function CUA_entries:prepare_quests(is_alliance)
    -- init faction quests reference
    db.quest_f = is_alliance and db.quest_a or db.quest_h
    -- drop opposite faction quests
    db[ is_alliance and "quest_h" or "quest_a" ] = nil
end

function CUA_entries:prepare_codes(name, race, class, is_male)
    -- print("preparing codes for: " .. name .. " / " .. race .. " / " .. class .. " / " .. (is_male and "male" or "famale"))
    local sex = is_male and 1 or 2
    local cases = { "н", "р", "д", "з", "о", "м", "к" }

    local codes = {
        ["{ім'я}"] = name,
        ["{Ім'я}"] = name,
        ["{ІМ'Я}"] = string.upper(name),
    }

    -- race

    for _, c in ipairs(cases) do
        local t = db.race[race][c][sex]
        codes["{раса:" .. c .. "}"] = t
        codes["{Раса:" .. c .. "}"] = capitalize(t)
        codes["{РАСА:" .. c .. "}"] = string.upper(t)
        if c == "н" then -- "н" is default grammatical case
            codes["{раса}"] = codes["{раса:н}"]
            codes["{Раса}"] = codes["{Раса:н}"]
            codes["{РАСА}"] = codes["{РАСА:н}"]
        end
    end

    -- class

    for _, c in ipairs(cases) do
        local t = db.class[class][c][sex]
        codes["{клас:" .. c .. "}"] = t
        codes["{Клас:" .. c .. "}"] = capitalize(t)
        codes["{КЛАС:" .. c .. "}"] = string.upper(t)
        if c == "н" then -- "н" is default grammatical case
            codes["{клас}"] = codes["{клас:н}"]
            codes["{Клас}"] = codes["{Клас:н}"]
            codes["{КЛАС}"] = codes["{КЛАС:н}"]
        end
    end

    -- sex

    -- only "стать" is needed, but we make possible to use any letter casing
    -- (even if it has nothing to do with the letter case of the result, as text gets shown as is)
    codes["{стать:(.-):(.-)}"] = function (a, b) return is_male and a or b end
    codes["{Стать:(.-):(.-)}"] = function (a, b) return is_male and a or b end
    codes["{СТАТЬ:(.-):(.-)}"] = function (a, b) return is_male and a or b end

    -- print_table(codes, "codes")
    db.codes = codes
end

local function make_text(text)
    if not text then
        return nil
    end

    for k, v in pairs(db.codes) do
        text = text:gsub(k, v)
    end

    return text
end

local function make_text_array(array)
    if array then
        local result = {}
        for i = 1, #array do
            result[i] = make_text(array[i])
        end
        return result
    else
        return nil
    end
end

function CUA_entries:get_entry(entry_type, entry_id)
    if entry_type and entry_id then
        entry_id = tonumber(entry_id)

        if entry_type == "quest" then
            local quest = nil

            if db.quest_f[entry_id] then
                quest = db.quest_f[entry_id]
            elseif db.quest_n[entry_id] then
                quest = db.quest_n[entry_id]
            end

            if quest then
                return make_text_array(quest)
            end
        end

        if entry_type == "book" then
            local book = db.book[entry_id]
            if book then
                return make_text_array(book)
            end
        end

        if db[entry_type] and db[entry_type][entry_id] then
            local entry = db[entry_type][entry_id]

            if entry.ref and (entry_type == "spell" or entry_type == "item") then
                local entry_ref = db[entry_type][entry.ref]
                if entry_ref then
                    -- todo: maybe add caching of the result table
                    return CUA_utils:copy_table(CUA_utils:copy_table({}, entry_ref), entry)
                else
                    return CUA_utils:copy_table({ entry_type .. "|cff999999#|r" .. entry_id .. "|cff999999=>|r" .. entry.ref }, entry)
                end
            end

            return entry
        end
    end

    return false
end

-- todo: add another loop to try different "'s", e.g. "XXX's" and "XXXs'" are considered to be equal
function CUA_entries:get_entry_text(entry_key)
    if entry_key then
        for i = 1, 2 do
            if i == 2 then
                -- if failed to find original entry_key, try one more time with/out starting "The "
                if entry_key:find("^The ") then
                    -- remove starting "The "
                    if #entry_key > 5 then
                        entry_key = entry_key:sub(5)
                    else
                        break
                    end
                else
                    -- add starting "The "
                    entry_key = "The " .. entry_key
                end
            end

            local object = db.object[entry_key]
            if object then
                return object
            end

            local zone = db.zone[entry_key]
            if zone then
                return zone
            end
        end
    end

    return false
end

function CUA_entries:make_entry_text(text, tooltip, tooltip_matches_to_skip)
    if not text then
        return nil
    end

    text = { strsplit("#", text) }
    if #text == 1 then
        return text[1]
    end

    if not tooltip_matches_to_skip then
        tooltip_matches_to_skip = 0
    end

    local values = {}

    for i = 2, #text do
        local p = esc(text[i]):gsub("{(%d+)}", function (a) return "(%d+)" end)
        local match_number = 0
        for j = 1, tooltip:NumLines() do
            local t = getglobal(tooltip:GetName() .. "TextLeft" .. j):GetText()
            local v = { t:match(p) }
            if #v > 0 then
                match_number = match_number + 1
                if match_number > tooltip_matches_to_skip then
                    for k = 1, #v do values[#values + 1] = v[k] end
                    break
                end
            end
        end
    end

    return text[1]:gsub("{(%d+)}", function (a) return values[tonumber(a)] end)
end

function CUA_entries:get_text(entry_key)
    if entry_key and db.text[entry_key] then
        return db.text[entry_key]
    else
        return entry_key
    end
end
