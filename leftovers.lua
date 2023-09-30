-- Setup

require('luau')
packets = require('packets')
config = require('config')
res = require('resources')

_addon.name = 'Leftovers'
_addon.author = 'Wunjo/Bahamut'
_addon.commands = {'Leftovers'}
_addon.version = '1.0.0.1'

-- List of bags to search when searching for papers.
listBagsToSearch = "inventory,safe,safe2,case,sack"
-- Path needs to have the forward slash "/" between drive, folders, and sub-folders.
pathExportFile = "C:/Windower4Kira/DynaPapersLeftover.csv"

windower.register_event('chat message', function(message,sender,mode,gm)
    local lowermsg = string.lower(message)
    
    if string.lower(sender) ~= 'wunjo' then return end
    if lowermsg:startswith('!leftovers') then
        log(lowermsg)
        
        -- Output File Sample:
        -- Job, Head, Trso, Hand, Legs, Foot,VHead,VTrso,VHand,VLegs,VFoot
        -- WAR,     ,   10,    1,     ,     ,     ,   11,    2,    7,     
        -- MNK,    2,   12,     ,    2,    4,    1,   12,    2,    4,    3
        
        -- Jobs in sort order
        local jobOrder = ezSplit("WAR,MNK,WHM,BLM,RDM,THF,PLD,DRK,BST,BRD,RNG,SAM,NIN,DRG,SMN,BLU,COR,PUP,DNC,SCH,GEO,RUN",",")
        local partOrder = ezSplit("Headshard,Torsoshard,Handshard,Legshard,Footshard,Voidhead,Voidtorso,Voidhand,Voidleg,Voidfoot",",")
        -- Testing
        -- local jobOrder = ezSplit("WAR,MNK",",")
        -- local partOrder = ezSplit("HeadShard,Torsoshard,Handshard,Legshard,Footshard,Voidhead,Voidtorso,Voidhand,Voidleg,Voidfoot",",")
        
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
        CountItemsInBags(bagItems,listBagsToSearch)
        
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
        log("done: check output")
    end
    
end)

function CountItemsInBags(bagItems,listBags)
    local bagNames = {}
    bagNames = ezSplit(listBags,",")
    
    -- Loop through the list of bags
    for _,bagName in ipairs(bagNames) do
        -- The .get_items() method returns a list/array of items that are stored on the current 
        --      character's specified bag.
        bagContents = windower.ffxi.get_items(bagName)
        -- Count those items
        CountItemsInBag(bagItems,bagContents)
    end
end

function CountItemsInBag(bagItems,bagContents)
    -- Loop through the "items" list
    for _,v in ipairs(bagContents) do
        -- <windower directory>\res\items.lua
        -- 
        -- Note: "v" stands for the item's characteristics array.  This array contains information
        --      like Item ID, Count, and other information that the FFXI client stores in memory 
        --      about this item.  It does not store the item's name.  We have to get that from the 
        --      resources/items array (res.items[#]).
        
        -- If the Item ID corresponds to a shard/void paper, then ...
        if v.id >= 9544 and v.id <= 9763 then
            nameItem = res.items[v.id].name
            -- If we don't have that item listed in the bagItems array, then add it.
            if bagItems[nameItem] == nil then
                bagItems[nameItem] = 0
            end
            bagItems[nameItem] = bagItems[nameItem] + v.count
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
