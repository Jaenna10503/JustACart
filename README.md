# JustACart
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

- Option 1 will try to find a horse it can use within a certain distance, and transports the horse in front of the cart and tethers her if a usable horse has been found. If chosen while a horse is tethered, the horse is released from the cart, and the cart will become fixed/stop moving until a horse is tethered again.
- Option 2 will give the player access to the cart's cargo. The cargo remains accessible with any cart summoned by the mod.
- Option 3 will try to find a horse it can use within a certain distance, and transports the horse in front of the cart. (This is basically the same as option 1, except it won't do any tethering/untethering.)
- Option 4 will simply close the menu without anything happening.

Next to the "Bring Cart to Player" button is a "Delete Cart" button. This exists primarily in case an update to the mod requires the old carriage to no longer exist, or if you intend to use the optional feature (below) to switch cart model. Your stored inventory will be unaffected and completely safe, and can still be accessed with your new cart.

### Future Plans for Core Features

Adding a lore-friendly way to get the cart without needing the MCM button for the first spawning.
Possibly compatibility with SkyrimVR (If I can figure it out, which is a big if.)

## Optional Settings

- The MCM includes an option to allow the player to untether the horse from the cart on the fly, without dismounting first. This is done with a hotkey, which can be changed through the MCM (Default: G)

- You can switch between unlimited (default) and limited storage. Limited storage has a weight limit (default 2000), and this limit can be changed with a slider (from 0 to 10,000 in increments of 50). These two types of storage exist separately, so switching from one to the other temporarily prevents you from accessing the other storage (and items contained therein) until you switch back. Switching back and forth during the course of gameplay is (should be) completely safe.

- An additional optional toggle to switch to the base game model for the cart. By default, the mod uses a custom model based on models from [Snazzy Diverse Carriages](https://www.nexusmods.com/skyrimspecialedition/mods/112041). You can switch between the base game and custom models by turning the toggle on and off. If you already have a cart, you'll need to delete it with the MCM button first and get a new one.

- An optional toggle to expand what the mod considers an acceptable/usable horse. By default, the mod only recognises horses that are player owned and belong to the Player Horse Faction. With this toggle on, the carriage will accept any horse that has the ActorTypeHorse keyword. This can "steal" an NPC owned horse, even from right under them, if they happen to be close enough to the carriage when you're tethering a horse. You can always untether unwanted horses, but the tethering itself may cause minor mayhem to the AI.

### Future Plans for Optional Features

Possibly further realism toggles.

## Notes on the use of the mod

It's recommended to make sure you're facing forward, on a flat stretch of road before accessing the MCM to summon the cart. Summoning the cart where it doesn't have enough room may result in violent physics shenanigans.

Also make sure the cart has enough room in front of it before moving the horse in front of it. For the same reason.

Using the expanded compatibility option can make the carriage "steal" an NPC owned horse, even from right under them, if they happen to be close enough to the carriage when you're tethering a horse. You can always untether unwanted horses, but the tethering itself may cause minor mayhem to the AI. It's recommended to make sure such unwanted horses are a bit further away from the carriage when trying to tether a horse (around 5 metres or so should be enough).

Due to the inherently janky physics of the cart, it's recommended that you stick to flat terrain, preferably roads, while traveling with your horse tethered to the cart. If you need to go to or through rough terrain, it's best to leave the cart waiting until you come back.

Additionally, when traveling through narrower or populated areas, it's best to slow down and pass the area at walking pace. The cart **will** damage or even kill other actors who get (accidentally) trampled by the cart, when moving at normal/running or sprinting pace.

The mod should be compatible with any **ownable** horse in the game, and is compatible with at least some mods that add horses. The mod works as a standalone, but is also designed to be (as) compatible (as possible) with mods that change/enhance horse behaviour/utility. I've mainly tested the mod with [Simplest Horses (and other mounts)](https://www.nexusmods.com/skyrimspecialedition/mods/54225). If you find issues with compatibility with similar mods, please leave a comment on this mod's Nexus page. I'll try to investigate the issue, and update this mod to become compatible if I can.

## Download Link: https://www.nexusmods.com/skyrimspecialedition/mods/151651

## Additional Thanks

Thank you to [gutmaw](https://next.nexusmods.com/profile/gutmaw) for permission to use his models from [Snazzy Diverse Carriages](https://www.nexusmods.com/skyrimspecialedition/mods/112041).

This mod is heavily inspired by [Dragonkiller Cart SE](https://www.nexusmods.com/skyrimspecialedition/mods/6521) and [Dovah Rider Cart](https://www.nexusmods.com/skyrimspecialedition/mods/52931). Especially Dragonkiller Cart. That mod opened my eyes to what's possible in modding Skyrim back in the day, good 10 years ago. Big thank you to MrowPurr of [SkyrimScripting](https://www.youtube.com/@SkyrimScripting) for the great tutorials that finally helped me learn the basics of Papyrus and Creation Kit, and to all the great folks, admins, helpers, mod and modlist authors and [Biggie](https://next.nexusmods.com/profile/dabiggieboss) himself at the Modding Bungalo (Linking [LoreRim's](https://lorerim.com/) website here, specifically, because that's the modlist that I **really** hyperfixated on). Y'all helped me gather up the courage to finally try making something myself.