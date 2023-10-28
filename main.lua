----Welcome to the "main.lua" file! Here is where all the magic happens, everything from functions to callbacks are dOne_Character.
--Startup
local mod = RegisterMod("Evan & Wolliam Afton Character Mod", 1)
local game = Game()
local rng = RNG()

mod.Items = {
    puppetMask = Isaac.GetItemIdByName("Puppet Mask"),
	goldfreddyMask = Isaac.GetItemIdByName("Golden Freddy Mask"),
	springtrapMask = Isaac.GetItemIdByName("Springtrap Mask"),
	batteryFlashlight = Isaac.GetItemIdByName("Battery-Powered Flashlight"),
	foxyHook = Isaac.GetItemIdByName("Severed Hook"),
}

mod.ChildForms = nil

--Stat Functions
local function toTears(fireDelay) --thanks oat for the cool functions for calculating firerate!
	return 30 / (fireDelay + 1)
end
local function fromTears(tears)
	return math.max((30 / tears) - 1, -0.99)
end

--Character Functions
---@param name string
---@param isTainted boolean
---@return table
local function addCharacter(name, isTainted) -- This is the function used to determine the stats of your character, you can simply leave it as you will use it later!
	local character = { -- these stats are added to Isaac's base stats.
		NAME = name,
		ID = Isaac.GetPlayerTypeByName(name, isTainted), -- string, boolean
	}
	return character
end
mod.EvanAfton_Character = addCharacter("Evan Afton", false)
mod.WilliamAfton_Character = addCharacter("William Afton", true)

function mod:evalCache(player, cacheFlag) -- this function applies all the stats the character gains/loses on a new run.
	local function addStats(name, speed, tears, damage, range, shotspeed, luck, tearcolor, flying, tearflag) -- This is the function used to determine the stats of your character, you can simply leave it as you will use it later!
		if player:GetPlayerType(name) then
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed + speed
			end
			if cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = math.max(1.0, fromTears(toTears(player.MaxFireDelay) + tears))
			end
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + damage
			end
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.TearRange = player.TearRange + range * 40
			end
			if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
				player.ShotSpeed = player.ShotSpeed + shotspeed
			end
			if cacheFlag == CacheFlag.CACHE_LUCK then
				player.Luck = player.Luck + luck
			end
			if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
				player.TearColor = tearcolor
			end
			if cacheFlag == CacheFlag.CACHE_FLYING then
				player.CanFly = flying
			end
			if cacheFlag == CacheFlag.CACHE_TEARFLAG then
				player.TearFlags = player.TearFlags | tearflag
			end
		end
	end
	mod.EvanAfton_Stats = addStats("Evan Afton", 0, 0, 0, 0, 0, 0, Color(1, 1, 1, 1.0, 0, 0, 0), false, TearFlags.TEAR_NORMAL)
	mod.WilliamAfton_Stats = addStats("William Afton", 0, 0, 0, 0, 0, 0, Color(1, 1, 1, 1.0, 0, 0, 0), false, TearFlags.TEAR_NORMAL)

	if player:GetName() == mod.EvanAfton_Character.NAME then
		if mod.ChildForms == "Evan" then
			if cacheFlag == CacheFlag.CACHE_FLYING then
				player.CanFly = false
			end
		elseif mod.ChildForms == "Freddy" then
			if cacheFlag == CacheFlag.CACHE_FLYING then
				player.CanFly = false
			end
		elseif mod.ChildForms == "Bonnie" then
			if cacheFlag == CacheFlag.CACHE_FLYING then
				player.CanFly = false
			end
		elseif mod.ChildForms == "Chica" then
			if cacheFlag == CacheFlag.CACHE_FLYING then
				player.CanFly = true
			end
		elseif mod.ChildForms == "Foxy" then
			if cacheFlag == CacheFlag.CACHE_FLYING then
				player.CanFly = false
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,mod.evalCache)

function mod:playerSpawn_EvanWilliam(player)
    if player:GetName() == mod.EvanAfton_Character.NAME then
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/EvanAfton-head.anm2"))
		player:AddCollectible(CollectibleType.COLLECTIBLE_AQUARIUS, 0, true, 0, 0)
		mod.ChildForms = "Evan" -- Evan
    end
    if player:GetName() == mod.WilliamAfton_Character.NAME then
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/WilliamAfton-head.anm2"))
		player:AddCollectible(CollectibleType.COLLECTIBLE_ANEMIC, 0, true, 0, 0)
		player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_ANEMIC))
		player:AddCollectible(CollectibleType.COLLECTIBLE_NIGHT_LIGHT, 0, true, 0, 0)
		player:AddCollectible(CollectibleType.COLLECTIBLE_DADDY_LONGLEGS, 0, true, 0, 0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.playerSpawn_EvanWilliam)

local ChildFormEffects = {
	FREDDY_EFKT = false,
	BONNIE_EFKT = false,
	CHICA_EFKT = false,
	FOXY_EFKT = false,
}

function mod:Update(player)
	if player:GetName() == mod.EvanAfton_Character.NAME then
		if mod.ChildForms == "Freddy" then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_2SPOOKY) == false then
				player:AddCollectible(CollectibleType.COLLECTIBLE_2SPOOKY, 0, true, 0, 0)
				ChildFormEffects.FREDDY_EFKT = true
			else
				ChildFormEffects.FREDDY_EFKT = false
			end
		elseif ChildFormEffects.FREDDY_EFKT == true then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_2SPOOKY, true)
			ChildFormEffects.FREDDY_EFKT = false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.Update)