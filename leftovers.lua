-- Setup

require('luau')
packets = require('packets')
config = require('config')
res = require('resources')

_addon.name = 'Leftovers'
_addon.author = 'Wunjo/Bahamut'
_addon.commands = {'Leftovers'}
_addon.version = '1.0.0.2'

-- Path needs to have the forward slash "/" between drive, folders, and sub-folders.
pathExportFile = "C:/Windower4/DynaPapersLeftover.csv"
pathExportText = "C:/Windower4/DynaPapersLeftover.txt"

-- To run this code, enter these commands into your console:
--      lua r leftovers
--      leftovers run
-- To unload this addon:
--      lua u leftovers
windower.register_event('addon command', function (...)
	local args = T{...}:map(string.lower)
	if args[1] == "run" then
        log("....Leftovers - START....")
		Main()
        log("....Leftovers - DONE....")
	end
end)

function Main()
    -- Output File Sample:
    -- Job, Head, Trso, Hand, Legs, Foot,VHead,VTrso,VHand,VLegs,VFoot
    -- WAR,     ,   10,    1,     ,     ,     ,   11,    2,    7,     
    -- MNK,    2,   12,     ,    2,    4,    1,   12,    2,    4,    3
    
    -- Jobs in sort order
    local jobOrder = ezSplit("WAR,MNK,WHM,BLM,RDM,THF,PLD,DRK,BST,BRD,RNG,SAM,NIN,DRG,SMN,BLU,COR,PUP,DNC,SCH,GEO,RUN",",")
    local partOrder = ezSplit("Headshard,Torsoshard,Handshard,Legshard,Footshard,Voidhead,Voidtorso,Voidhand,Voidleg,Voidfoot",",")
    
    -- Create a table listing all known dynamis papers.  Set them all to zero.
    local bagItems = {}
    -- Loop through each job (WAR, MNK, etc.)
    for _,job in ipairs(jobOrder) do
        -- Loop through each part (headshard, torsoshard, etc.)
        for _,part in ipairs(partOrder) do
            -- Re-create the item name, for example: "Headshard"..": ".."MNK"
            itemName = part..": "..job
            bagItems[itemName] = 0
        end
    end
    
    -- For each paper, count how many we have on this character.
    CountItemsInBags(bagItems)
    
    -- Open the export file for writing.
    local fout = assert(io.open(pathExportFile, "w"))
    -- Add the header row.
    fout:write('Job, Head, Trso, Hand, Legs, Foot,VHead,VTrso,VHand,VLegs,VFoot\n')
    
    -- Collect all information by job and by slot
    --
    -- Loop through each job (WAR, MNK, etc.)
    for _,job in ipairs(jobOrder) do
        -- Start each new row with the job abbreviation.
        text = job
        -- Loop through each part (headshard, torsoshard, etc.)
        for index,part in ipairs(partOrder) do
            -- Re-create the item name, for example: "Headshard"..": ".."MNK"
            itemName = part..": "..job
            -- Get the quantity for that item.  ex. bagItems["Headshard: MNK"]
            --      Yes, you saw that right, the item's name is the key to look up the quantity.
            itemCount = bagItems[itemName]
            -- Add a comma.
            text = text..","
            -- If we don't have any, then just put blanks, otherwise put the quantity.
            if itemCount == 0 then
                -- I put blanks instead of the number ZERO so the user can quickly determine
                --      if we had any of that particular paper available.
                -- If you want to put a ZERO there, then replace the last space with a "0".
                text = text.."     "
            else
                text = text..string.sub(string.format("      %d",itemCount),-5)
            end
        end
        fout:write(text..'\n')
    end
    
    -- Close the output file.
    fout:close()
    
    -- Open the export file for writing.
    local fout = assert(io.open(pathExportText, "w"))
    
    -- Collect all information by job and by slot
    --
    -- Loop through each job (WAR, MNK, etc.)
    for _,job in ipairs(jobOrder) do
        
        if job == 'WAR' or job == 'THF' or job == 'RNG' or job == 'BLU' or job == 'GEO' then
            -- Add the header row.
            fout:write('Job,Type, Head, Trso, Hand, Legs, Foot\n')
        end
        
        -- Start each new row with the job abbreviation.
        text = job..',Shrd'
        text = text..','..string.sub(string.format("      %d",bagItems["Headshard: "..job]),-5)
        text = text..','..string.sub(string.format("      %d",bagItems["Torsoshard: "..job]),-5)
        text = text..','..string.sub(string.format("      %d",bagItems["Handshard: "..job]),-5)
        text = text..','..string.sub(string.format("      %d",bagItems["Legshard: "..job]),-5)
        text = text..','..string.sub(string.format("      %d",bagItems["Footshard: "..job]),-5)
        fout:write(text..'\n')
        
        text = job..',Void'
        text = text..','..string.sub(string.format("      %d",bagItems["Voidhead: "..job]),-5)
        text = text..','..string.sub(string.format("      %d",bagItems["Voidtorso: "..job]),-5)
        text = text..','..string.sub(string.format("      %d",bagItems["Voidhand: "..job]),-5)
        text = text..','..string.sub(string.format("      %d",bagItems["Voidleg: "..job]),-5)
        text = text..','..string.sub(string.format("      %d",bagItems["Voidfoot: "..job]),-5)
        fout:write(text..'\n')
        
        fout:write('\n')
    end
    
    -- Close the output file.
    fout:close()
end

function CountItemsInBags(bagItems)
    -- This get the list of all bags.
    bags = res.bags
    -- "res.bags" refers to <windower directory>\res\bags.lua
    -- The key, "k", in the for-loop is the left side of the first equals sign
    -- For example: k = 0, v is the list of characteristics, all that stuff in the "{}".
    -- For example: k = 0, v is all that stuff in the "{}".
    -- You can get the id by referring to v['id'], get the English name using v['en'], etc.
    -- [0] = {id=0,en="Inventory",access="Everywhere",command="inventory",equippable=true},
    -- [1] = {id=1,en="Safe",access="Mog House",command="bank"},
    -- [2] = {id=2,en="Storage",access="Mog House",command="storage"},
    
    -- Loop through all the bags.
    for k, v in pairs(bags) do
        -- print(k, v['id'], v['en'], v['command'])
        -- https://github.com/Windower/Lua/wiki/FFXI-Functions#windowerffxiget_bag_infobag
        -- "get_bag_info" returns a set of three items {count,enabled,max}
        -- We're interested in the enabled just in case the mule that stores
        -- these items doesn't have a bag enabled.
        bag = windower.ffxi.get_bag_info(v['id'])
        -- Only check the bag if it is enabled on the current character.
        if bag['enabled'] then
            -- print('Searching this bag: '..v['en'])
            -- Use the bag ID to get the contents of this bag.
            bagContents = windower.ffxi.get_items(v['id'])
            -- This routine counts the papers contained in this bag (bagContents)
            -- and adds them to the papers list (bagItems).
            CountItemsInBag(bagItems,bagContents)
        end
    end
end

function CountItemsInBag(bagItems,bagContents)
    -- Wiki Page: https://github.com/Windower/Lua/wiki/FFXI-Functions#windowerffxiget_itemsbag-index
    -- Structure:
    --      count: int,
    --      status: int,
    --      id: int,
    --      slot: int,
    --      bazaar: int,
    --      extdata: string,    
    
    -- Loop through the "items" list that we collected in the bagContents list.
    -- The key, "k", in the for-loop is the item IDs contained in "bagContents".
    -- The value set, "v", represents the set of the item's structure.
    -- In this case, v = {count,status,id,slot,bazaar,extdata}
    -- You can get the count of that item by using v['count']
    
    -- Loop through all the items in "bagContents".
    for k, v in ipairs(bagContents) do
        -- If the Item ID corresponds to a shard/void paper, then ...
        if v['id'] >= 9544 and v['id'] <= 9763 then
            -- Note that "name" is not in "bagContents".
            -- We can get the item name from "res.items".
            -- "res.items" Source: <windower directory>\res\items.lua
            -- Just supply the ID and get the name.
            nameItem = res.items[v['id']].name
            -- print(nameItem)
            -- If we don't have that item listed in the bagItems array, then add it.
            if bagItems[nameItem] == nil then
                bagItems[nameItem] = 0
            end
            -- Get the item count for this item in the current bag.
            -- Add it to the "bagItems" record for that item.
            bagItems[nameItem] = bagItems[nameItem] + v['count']
        end
    end
end

-- ------------------------------------                 ------------------------------------
-- ------------------------------------ HELPER ROUTINES ------------------------------------
-- ------------------------------------                 ------------------------------------

-- https://www.tutorialspoint.com/how-to-split-a-string-in-lua-programming
-- 
-- ans = mysplit("hey bro whats up?")
-- for _, v in ipairs(ans) do print(v) end
-- ans = mysplit("x,y,z,m,n",",")
-- for _, v in ipairs(ans) do print(v) end
-- 
-- FYI: The "_" in the "_, v" is the numerical index.
--      It starts at ONE.
--
function ezSplit(inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t={}
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
   end
   return t
end
