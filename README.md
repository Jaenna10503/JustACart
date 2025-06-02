# [JustACart](https://www.nexusmods.com/skyrimspecialedition/mods/151651)
Skyrim SE mod that gives you a cart for your horse to pull

## Dependencies
- [SKSE](https://skse.silverlock.org/)
- [SkyUI](https://www.nexusmods.com/skyrimspecialedition/mods/12604)
- [PapyrusUtil SE](https://www.nexusmods.com/skyrimspecialedition/mods/13048)

## Basic Info

Currently, the only way to get the cart is through the mod's MCM. Clicking on the button titled "Bring Cart to Player" will spawn a cart in front of the player if no such cart exists yet, or will move the cart in front of the player if the already exists.

Activating the cart gives four options:
1. Tether/Untether the horse.
2. Access the cart's cargo.
3. Move the horse in front of the cart.
4. Cancel.

Option 1 will try to find a horse it can use within a certain distance, and transports the horse in front of the cart and tethers her if a usable horse has been found. If chosen while a horse is tethered, the horse is released from the cart, and the cart will become fixed/stop moving until a horse is tethered again.

Option 2 will give the player access to the cart's cargo. The cargo remains accessible with any cart summoned by the mod.

Option 3 wwill try to find a horse it can use within a certain distance, and transports the horse in front of the cart. (This is basically the same as option 1, except it won't do any tethering/untethering.)

Option 4 will simply close the menu without anything happening.

### Future Plans for Core Features

Adding a lore-friendly way to get the cart without needing the MCM button for the first spawning.

## Optional Settings

The MCM includes an option to allow the player to untether the horse from the cart on the fly, without dismounting first. This is done with a hotkey, which can be changed through the MCM (Default: G)

### Future Plans for Optional Features

Optional realism settings, such as limits to the weight the cart's cargo can hold, and temporary reduction to the movement speed of the tethered horse while above a specific weight limit (based on the extra weight over the limit, increasing with increased weight).

## Notes on the use of the mod

It's recommended to make sure you're facing forward, on a flat stretch of road before accessing the MCM to summon the cart. Summoning the cart where it doesn't have enough room may result in violent physics shenanigans.

Also make sure the cart has enough room in front of it before moving the horse in front of it. For the same reason.

Due to the inherently janky physics of the cart, it's recommended that you stick to flat terrain, preferably roads, while traveling with your horse tethered to the cart. If you need to go to or through rough terrain, it's best to leave the cart waiting until you come back.

Additionally, when traveling through narrower or populated areas, it's best to slow down and pass the area at walking pace. The cart **will** damage or even kill other actors who get (accidentally) trampled by the cart, when moving at normal/running or sprinting pace.

The mod should be compatible with any **ownable** horse in the game, and is probably compatible with most mods that add ownable horses. The mod works as a standalone, but is also designed to be (as) compatible (as possible) with mods that change/enhance horse behaviour/utility. I've mainly tested the mod with [Simplest Horses (and other mounts)](https://www.nexusmods.com/skyrimspecialedition/mods/54225). If you find issues with compatibility with similar mods, please leave a comment on this mod's Nexus page. I'll try to investigate the issue, and update this mod to become compatible if I can.

## Additional Thanks

This mod is heavily inspired by [Dragonkiller Cart SE](https://www.nexusmods.com/skyrimspecialedition/mods/6521) and [Dovah Rider Cart](https://www.nexusmods.com/skyrimspecialedition/mods/52931). Especially Dragonkiller Cart. That mod opened my eyes to what's possible in modding Skyrim back in the day, good 10 years ago. Big thank you to MrowPurr of [SkyrimScripting](https://www.youtube.com/@SkyrimScripting) for the great tutorials that finally helped me learn the basics of Papyrus and Creation Kit, and to all the great folks, admins, helpers, mod and modlist authors and [Biggie](https://next.nexusmods.com/profile/dabiggieboss) himself at the Modding Bungalo (Linking [LoreRim's](https://lorerim.com/) website here, specifically, because that's the modlist that I **really** hyperfixated on). Y'all helped me gather up the courage to finally try making something myself.