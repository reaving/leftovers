-- Setup

require('luau')
packets = require('packets')
config = require('config')
res = require('resources')

_addon.name = 'Chatbutt'
_addon.author = 'Wunjo'
_addon.commands = {'Chatbutt'}
_addon.version = '1.0.0.1'

windower.register_event('chat message', function(message,sender,mode,gm)
    -- Source: Windower4\res\chat.lua
    -- mode: 3=tell, 4=party, 5=LS, 33=unity
    
    local lowermsg = string.lower(message)
    
    if mode ~= 4 then return end
    if string.lower(sender) ~= 'wunjo' then return end
    
    -- If party/Wunjo or LSchat then
    if lowermsg:startswith('!papers dj') or lowermsg:startswith('!papers fl') then
        log(lowermsg)
        
        params = ShowSplit(lowermsg..'   ', ' ')
        local chatLotType   = string.upper(params[2])
        local chatPaperName = string.upper(params[3])
        
        local allPapers = string.upper('Headshard,Torsoshard,Handshard,Legshard,Footshard,Voidhead,Voidtorso,Voidhand,Voidleg,Voidfoot')
        if chatPaperName == nil or chatPaperName == '' then
            chatAndWait('/p No shard type indicated.')
            return
        elseif string.find(allPapers..',',chatPaperName..',') == nil then
            chatAndWait('/p Shard type may have been misspelled.')
            return
        end
        
        -- Create an empty list/array.  We'll use this to keep a list of all the papers that we have in our bag.
        local tableItems = {}
        countItems(tableItems,"Inventory")
        
        local paperLists = {}
        CountPapers(tableItems,paperLists)
        
        -- This controls which lists are displayed and in what order.
        local paperNameList = ShowSplit(
                                    'Headshard,Torsoshard,Handshard,Legshard,Footshard,'..
                                    'Voidhead,Voidtorso,Voidhand,Voidleg,Voidfoot', ',')
        
        if chatLotType == 'DJ' then chatAndWait('/p +++ '..chatPaperName..' +++ declared jobs') end
        if chatLotType == 'FL' then chatAndWait('/p --- '..chatPaperName..' --- free lot') end
        for i,v in pairs(paperNameList) do
            local p = paperLists[v]
            if string.upper(v) == chatPaperName then
                if paperLists[v]['nextlist'] == 1 and paperLists[v]['count'] == 0 then
                    chatAndWait('/p Did not find any papers for that paper type.')
                end
                for k=1,4 do
                    if p[k] ~= '' then chatAndWait('/p '..p['abrv']..':'..p[k]) end
                end
            end
        end
        
    elseif lowermsg:startswith('!leftovers') then
        log(lowermsg)
        
        -- Create an empty list/array.  We'll use this to keep a list of all the papers that we have in our bag.
        local tableItems = {}
        countItems(tableItems,"Inventory")
        countItems(tableItems,"Safe")
        countItems(tableItems,"Case")
        countItems(tableItems,"Sack")
        
        local paperLists = {}
        CountPapers(tableItems,paperLists)
        
        -- This controls the order in which the lists appear in party chat.
        local paperNameList = ShowSplit(
                                    'Headshard,Torsoshard,Handshard,Legshard,Footshard,'..
                                    'Voidhead,Voidtorso,Voidhand,Voidleg,Voidfoot', ',')
        
        chatAndWait('/p >>>> List of LeftOver papers <<<<')
        
        chatAndWait('/p Please check this list for papers that you might need.')
        chatAndWait('/p Please wait until all the items are listed.')
        chatAndWait('/p Rule 1: You are not allowed to sell any of these papers.')
        chatAndWait('/p -- Lot on papers that you intend to use.')
        chatAndWait('/p Rule 2: If you need a paper, request it specifically.')
        chatAndWait('/p -- For example: Do NOT just say "WHM", say "torso:WHM"')
        chatAndWait('/p -- or "torso:WHM(2)" if you need two of them.')
        chatAndWait('/p Rule 3: All these papers are Free Lot.')
        chatAndWait('/p Rule 4: You may request papers even if you do not have')
        chatAndWait('/p -- those jobs fully leveled.')
        chatAndWait('/p Rule 5: No bag limit, request as many as you need.')
        
        for i,v in pairs(paperNameList) do
            local p = paperLists[v]
            
            if p['type'] == 'Shard' then
                chatAndWait('/p ---------- Shard Papers ----------')
                chatAndWait('/p You only need FIVE max to upgrade from +1 to +3')
                chatAndWait('/p --')
            elseif p['type'] == 'Void' then
                chatAndWait('/p ---------- Void Papers ----------')
                chatAndWait('/p You only need THREE max to upgrade from +2 to +3')
                chatAndWait('/p --')
            end
            
            for k=1,4 do
                if p[k] ~= '' then chatAndWait('/p '..p['abrv']..':'..p[k]) end
            end
        end
        
        chatAndWait('/p ---------- End of List ----------')
    
    end
    
end)

function chatAndWait(chatting)
    windower.chat.input:schedule(1,chatting)
    coroutine.sleep(2)
end

-- Source: http://lua-users.org/wiki/SplitJoin
-- Compatibility: Lua-5.0
--ShowSplit(",a,b,c,", ',')
----> { [1] = "", [2] = "a", [3] = "b", [4] = "c", [5] = "" }
function ShowSplit(str, delim, maxNb)
   -- Eliminate bad cases...
   if string.find(str, delim) == nil then
      return { str }
   end
   if maxNb == nil or maxNb < 1 then
      maxNb = 10    -- No limit
   end
   local result = {}
   local pat = "(.-)" .. delim .. "()"
   local nb = 0
   local lastPos
   for part, pos in string.gfind(str, pat) do
      nb = nb + 1
      result[nb] = part
      lastPos = pos
      if nb == maxNb then
         break
      end
   end
   -- Handle the last field
   if nb ~= maxNb then
      result[nb + 1] = string.sub(str, lastPos)
   end
   return result
end

function countItems(tableItems,bagName)
    -- https://forums.windower.net/index.php@sharelink=download%3BaHR0cDovL2ZvcnVtcy53aW5kb3dlci5uZXQvaW5kZXgucGhwPy90b3BpYy85MDQtcXVpY2stbHVhLXF1ZXN0aW9uL3BhZ2UtMg,,%3BUXVpY2sgbHVhIHF1ZXN0aW9uLi4u.html
    -- .get_items returns a list/array of items that are stored on the current character's specified bag.
    local items = windower.ffxi.get_items(bagName)
    -- Loop through the "items" list.
    for k,v in ipairs(items) do
        -- Note: "v" stands for the item's characteristics.  This includes the Item ID, Count, and other 
        --       information that the FFXI client stores in memory about this item.
        
        -- If the Item ID corresponds to a shard/void paper, then ...
        if v.id >= 9544 and v.id <= 9763 then
            -- Get the name of the item.
            nameItem = res.items[v.id].name
            -- If the 'element' is already on the list, then ...
            -- (for example: more than one stack)
            if tableItems[nameItem] then
                -- Add to the counter.  For example: the first stack has 12, the second stack has 8, total is 20.
                tableItems[nameItem]['count'] = tableItems[nameItem]['count'] + v.count
            else
                -- This shard/void paper is not on the list, add it.
                tableItems[nameItem] = {}
                -- Set up the 'count' characteristic for this paper.
                tableItems[nameItem]['count'] = v.count
            end
        end
    end
end

function addElements(paperLists,itemInfo)
    local item = ShowSplit(itemInfo..'//', '/')
    local itemName = item[1]
    
    paperLists[itemName] = {}
    paperLists[itemName]['name'] = item[1]
    paperLists[itemName]['nextlist'] = 1
    paperLists[itemName]['joblimit'] = 6        -- number of jobs displayed per chat line
    paperLists[itemName]['abrv'] = item[2]
    paperLists[itemName]['type'] = item[3]
    paperLists[itemName]['count'] = 0
    paperLists[itemName][1] = ''
    paperLists[itemName][2] = ''
    paperLists[itemName][3] = ''
    paperLists[itemName][4] = ''
    paperLists[itemName][5] = ''
    paperLists[itemName][6] = ''
    
end

function CountPapers(tableItems,paperLists)
    
    -- Create the paperLists list/array.
    local paperNames = ShowSplit(
                                'Headshard/Head/Shard,Torsoshard/Trso,Handshard/Hand,Legshard/Leg,Footshard/Foot,'..
                                'Voidhead/VHead/Void,Voidtorso/VTrso,Voidhand/VHand,Voidleg/VLeg,Voidfoot/VFoot', ',')
    -- Each 'element' of the list represents a different type of paper.
    -- Why do this?  We're going to report in chat for each type of shard/void on its own chat line.
    for i,v in pairs(paperNames) do
        addElements(paperLists,v)
    end
    
    -- We now have the list of papers in our bag "tableItems".
    -- Loop through that list and put together some text that we can drop into the chat.
    for i,v in pairs(tableItems) do
        -- Split this text into parts by separating using ": "
        local paperParts = ShowSplit(i, ': ')
        -- paperType = The part before the ": " for example: Footshard
        -- paperJob  = The part after the ": "  for example: THF
        local paperType = paperParts[1]
        local paperJob  = paperParts[2]
        
        if paperLists[paperType] then 
            
            if paperLists[paperType]['count'] == paperLists[paperType]['joblimit'] then
                paperLists[paperType]['nextlist'] = paperLists[paperType]['nextlist'] + 1
                paperLists[paperType]['count'] = 0
            end
            
            local nextList = paperLists[paperType]['nextlist']
            local thisList = paperLists[paperType][nextList]
            
            if thisList ~= '' then thisList = thisList..',' end
            thisList = thisList..paperJob
            if v.count > 1 then thisList = thisList..'('..v.count..')' end
            
            paperLists[paperType][nextList] = thisList
            paperLists[paperType]['count'] = paperLists[paperType]['count'] + 1
        end
    end
end
