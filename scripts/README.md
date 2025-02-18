# ClassicUA Generator Scripts

The following files are generated from Crowdin via set of scripts:
- book.lua
- npc.lua
- quests_a.lua
- quests_h.lua
- quests_n.lua
- zones.lua

All other files are edited manually, e.g. via pull requests.

## The Steps

1. Download all files from Crowdin:
    - Export terms in TBX format -> ClassicUA.tbx
    - Export quests via "Build & Download" -> ClassicUA.zip

2. Update Terms app:
    - Update file /docs/terms/ClassicUA.tbx
    - Update the date in /docs/terms/index.html
    - Commit "Update terms"

3. Generate quests, zones and npcs:
    - Clean up folder "translation_from_crowdin"
    - Copy ClassicUA.tbx and "uk" folder from ClassicUA.zip
    - Run: py gen_addon_quests_source_from_crowdin.py > translation_from_crowdin/quests_stats.txt
    - Run: py gen_addon_books_source_from_crowdin.py > translation_from_crowdin/books_stats.txt
    - Run: py gen_addon_zones_source_from_crowdin.py > translation_from_crowdin/zones_stats.txt
    - Run: py gen_addon_npcs_source_from_crowdin.py > translation_from_crowdin/npc_stats.txt

4. Update quests, zones and npcs in addon files:
    - Copy "translation_from_crowdin\entries" into "ClassicUA\entries"
    - Commit "Update zones translation" if zone.lua updated
    - Commit "Add translation for XXX NPCs" if npc2.lua updated
    - Commit "Add translation for XXX quests" if any quest_*.lua updated

5. Update and release new version
    - Commit "Bump version to X.X" with updated TOC files
    - Create new version archive "ClassicUA-vX.X.zip"
    - Upload the archive to CurseForge and wait until approved
