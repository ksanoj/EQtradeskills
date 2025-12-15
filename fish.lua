--[[
    Fish.lua
    Originally Written By: Yoda & DKAA
    v3.0 Re-written by wired420
    v3.5 De-bugged & updated by FelisMalum
    v4.0 Converted to Lua
    
    Usage:
        Have bait. Have a rod or rods (if breakable version) in your
        inventory or in primary hand. Be standing at water facing it.
        Run script. If rod breaks it will look for another one,
        highest fishing mod bonus first, in your inventory to equip.
        If there is a certain rod you WANT to use equip it before
        starting the script
    
    Commands:
        /fishcampon  - Will log out when you run out of bait or rods.
        /fishcampoff - Will stay logged in but end script when out of
                       bait or rods. (Default)
]]

local mq = require('mq')

print('\ag[FishBot]\ax v4.0 started.')

-- State variables
local campWhenDone = false
local running = true

-- Fishing pole list (ordered by priority/quality, best first)
local fishingPoles = {
    "Blessed Fishing Rod",
    "The Bone Rod",
    "Collapsible Fishing Pole",
    "Ancient Fishing Pole",
    "Brell's Fishin' Pole",
    "Uliorn's Fishing Pole",
    "KT's Magic Fishing Pole",
    "Hintol's Fishing Pole",
    "Grey Wood Fishing Pole",
    "Aglthin's Fishing Pole",
    "Kerran Fishing Pole",
    "Fishing Pole"
}

-- Items to destroy when caught
local trashItems = {
    "Tattered Cloth Sandal",
    "Rusty Dagger",
    "Fish Scales"
}

-- Utility function for delays
local function delay(ms)
    if not ms or ms <= 0 then return end
    local endTime = os.clock() * 1000 + ms
    while (os.clock() * 1000) < endTime do
        mq.doevents()
    end
end

-- Find item count in inventory
local function findItemCount(itemName)
    return mq.TLO.FindItemCount('=' .. itemName)() or 0
end

-- Check if item is trash
local function isTrashItem(itemName)
    for _, trash in ipairs(trashItems) do
        if itemName == trash then
            return true
        end
    end
    return false
end

-- Handle cursor items
local function handleCursor()
    if not mq.TLO.Cursor.ID() then return end
    
    delay(1000)
    
    local cursorName = mq.TLO.Cursor.Name()
    local cursorID = mq.TLO.Cursor.ID()
    
    if isTrashItem(cursorName) then
        print(string.format('\ar[FishBot]\ax Destroying: \ao%s', cursorName))
        mq.cmd('/destroy')
        -- Wait for item to be destroyed
        local startTime = os.clock() * 1000
        while mq.TLO.Cursor.ID() == cursorID and (os.clock() * 1000 - startTime) < 1000 do
            mq.doevents()
            delay(50)
        end
    else
        if cursorName ~= "Summoned: Ale" then
            print(string.format('\ag[FishBot]\ax Caught: \ao%s', cursorName))
        end
        mq.cmd('/autoinventory')
        -- Wait for item to be inventoried
        local startTime = os.clock() * 1000
        while mq.TLO.Cursor.ID() == cursorID and (os.clock() * 1000 - startTime) < 1000 do
            mq.doevents()
            delay(50)
        end
    end
end

-- Equip fishing pole from inventory
local function equipFishingPole()
    -- Check if Fisherman's Companion exists and summon a pole if needed
    if mq.TLO.FindItem('Fisherman\'s Companion').ID() and not mq.TLO.FindItem('Brell\'s Fishin\' Pole').ID() then
        print('\ay[FishBot]\ax You have a Fisherman\'s Companion but haven\'t summoned a rod yet.')
        print('\ay[FishBot]\ax Let\'s fix that!')
        mq.cmd('/useitem "Fisherman\'s Companion"')
        delay(2000)
        -- Wait for casting to finish
        local maxWait = 11000
        local startTime = os.clock() * 1000
        while mq.TLO.Me.Casting.ID() and (os.clock() * 1000 - startTime) < maxWait do
            mq.doevents()
            delay(50)
        end
        mq.cmd('/autoinventory')
        delay(1000)
        -- Wait for cursor to clear
        maxWait = 10000
        startTime = os.clock() * 1000
        while mq.TLO.Cursor.ID() and (os.clock() * 1000 - startTime) < maxWait do
            mq.doevents()
            delay(50)
        end
    end
    
    -- Find best available fishing pole
    local poleName = nil
    for _, pole in ipairs(fishingPoles) do
        if mq.TLO.FindItem('=' .. pole).ID() then
            poleName = pole
            break
        end
    end
    
    if poleName then
        -- Pick up the pole
        mq.cmdf('/itemnotify "%s" leftmouseup', poleName)
        delay(1000)
        
        if mq.TLO.Cursor.ID() then
            print(string.format('\ag[FishBot]\ax Equipping \ar[\aw%s\ar]\ao in \atmainhand\ao.', poleName))
            mq.cmd('/itemnotify mainhand leftmouseup')
            delay(1000)
            mq.cmd('/autoinventory')
            delay(1000)
            -- Wait for cursor to clear
            local maxWait = 10000
            local startTime = os.clock() * 1000
            while mq.TLO.Cursor.ID() and (os.clock() * 1000 - startTime) < maxWait do
                mq.doevents()
                delay(50)
            end
        end
    else
        -- No fishing pole found
        if campWhenDone then
            print('\ar[FishBot]\ax You broke or lost your last fishing pole and you have requested I camp.')
            mq.cmd('/camp desktop')
        else
            print('\ar[FishBot]\ax You broke or lost your last fishing pole. Ending.')
        end
        running = false
    end
end

-- Handle broken pole event
local function onBrokenPole(line)
    equipFishingPole()
end

-- Handle no bait event
local function onNoBait(line)
    if campWhenDone then
        print('\ar[FishBot]\ax Fish will only bite if you have bait and you have requested I camp.')
        mq.cmd('/camp desktop')
    else
        print('\ar[FishBot]\ax Fish will only bite if you have bait. Ending.')
    end
    running = false
end

-- Handle no water event
local function onNoWater(line)
    if campWhenDone then
        print('\ar[FishBot]\ax You are not near water and have requested I camp.')
        mq.cmd('/camp desktop')
    else
        print('\ar[FishBot]\ax You are not near water. Ending.')
    end
    running = false
end

-- Handle leaving event
local function onLeaving(line)
    print('\ay[FishBot]\ax You wandered off, ending script.')
    running = false
end

-- Register events
mq.event('BrokenPole1', '#*#You need to put your fishing pole in your primary hand.#*#', onBrokenPole)
mq.event('BrokenPole2', '#*#You can\'t fish without a fishing pole, go buy one.#*#', onBrokenPole)
mq.event('NoBait', '#*#You can\'t fish without fishing bait, go buy some.#*#', onNoBait)
mq.event('NoWater', '#*#Trying to catch land sharks perhaps?#*#', onNoWater)
mq.event('Leaving', '#*#You stop fishing and go on your way.#*#', onLeaving)

-- Bind commands
mq.bind('/fishcampon', function()
    campWhenDone = true
    print('\ag[FishBot]\ax Will now camp when out of bait or fishing rods.')
end)

mq.bind('/fishcampoff', function()
    campWhenDone = false
    print('\ag[FishBot]\ax Will no longer camp when out of bait or fishing rods.')
end)

-- Main fishing loop
while running do
    mq.doevents()
    
    -- Handle items on cursor
    if mq.TLO.Cursor.ID() then
        handleCursor()
    else
        -- Check if fishing ability is ready
        if mq.TLO.Me.AbilityReady('Fishing')() then
            -- Wait a bit to make sure cursor is clear
            delay(2000)
            
            if not mq.TLO.Cursor.ID() then
                mq.cmd('/doability Fishing')
                -- Wait for fishing to complete (ability goes on cooldown)
                local maxWait = 10000
                local startTime = os.clock() * 1000
                while mq.TLO.Me.AbilityReady('Fishing')() and (os.clock() * 1000 - startTime) < maxWait do
                    mq.doevents()
                    delay(50)
                end
            end
        end
    end
    
    delay(50)
end

print('\ag[FishBot]\ax Script ended.')
