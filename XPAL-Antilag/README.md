# XPAL (XP Antilag System)
This script fixes a huge issue in RPG Maker: the game slowing down when too many characters are used on a map.

### How does it work?
After testing the base scripts and activating/deactivating many code parts, I managed to put together a list of reasons for this issue.
Most Antilag scripts in the past have all been about deactivating update for sprites belonging to off-screen characters. However, it seemed that just the fact of having characters moving around, even without any sprite being involved, was enough to slow down the whole thing. XPAL goes a little further...

### Features
* The first interesting thing with XPAL is that you can activate/deactivate it any time, even in game, and try to figure if it works for your situation or not.
* Weather sprites bitmaps (rain, snow, etc.) were redrawn everytime a map was loaded. XPAL stores them in the Cache to reuse them in all the maps, just like other graphics.
* RPG Maker XP loops through ALL events on a map for every interaction and passability check. The engine looks each event to find one that has the needed X and Y coordinate. To avoid these useless loops, characters are organised in tiles, and we only check the tile(s) we need.
* RPG Maker XP checks if a tile is passable by verifying all 3 map layers, tile by tile. XPAL creates a two-dimensions table to store the passages in one tile, which makes the passability check process a little faster (tiles don't change their properties in game anyway).
* One of the greatest and most unbelievable reason for the whole game slowing down was the Bush Flag tiles check! You see these tiles that make your character bottom go semi-transparent? Actually, RPG Maker XP...
  * constlantly changes the character sprite
  * scanning all three map layers
  * tile by tile
  * for each character
  * whether it moves or not
  * on EACH FRAME
  * even in maps that have absolutely no tile with a bush tile...

  XPAL uses a simple array storing bush tiles. When the character actually moves, it checks if a change is necessary and only then we change the sprite.
* In a similar manner, counter tiles have been stored in a simple array to speed up the process.
* To manage characters on tiles, a new function `.on_move` has been added to Game_Character, checking if the character changed its position. This function can be useful for other scripts.
* The main culprit for the lag (maybe half of it) was the Sprite_Character class, more precisely its update function. It was being called constantly and without any restriction or check to see if it was necessary. X/Y coordinates, transparency, opacity, bush depth... eveything was constantly being updated.

  XPAL does a selective update changing only values when it is necessary. For example, we only change the coordinates if the character comes near the edges of the map. We only update the opacity when the character actually changes it. Bush depth is updated when the character enters or leaves a bush tile, if there is even one on the map. You get the idea.
* And of course, off-screen sprites are not updated, to lighten up the engine. Character sprite size is taken into account, and there is a little margin to be sure nothing weird happens, just in case.

### Does it work?
* Yes. Even if the result isn't always at 40 FPS, I personally got from around 16 FPS to 37-40 FPS on a map with 200 moving events. If I go to a corner of the map where there is no character other than the player, I am at 39-40.
* Just know that the lag can also have external reasons: old processor, too many open programs...
* Since this script changes the very way maps and characters are organised, do not expect a full compatibility with other scripts. For example, organizing characters in tiles is not compatible with pixel movement scripts, by any logic. However, I managed to make changes and make it work with my custom movement systems, so it shouldn't be a huge obstacle. Also, if you have systems changing tile properties in-game, make sure to edit XPAL to reflect the changes in the arrays of the 2D Table for map passages.

### How to use
* First, you need my ![rewrite of Sprite_Character](https://github.com/do-sieg/RPGMaker/blob/master/SpriteCharacter/Sprite_Character%20(Rewrite)).
* Then, paste the 6 scripts or the megascript version that contains all of them if you feel lazy.
* A demo is available for you to try.
