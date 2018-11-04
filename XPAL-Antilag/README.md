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
* The main culprit for the lag (maybe half of it) was the Sprite_Character class, more precisely its update function. 


La mise à jour des sprites de personnages se faisait de façon constante et sans aucune restriction pour voir si le changement était nécessaire. Les coordonnées X, Y, Z, la visibilité, l'opacité, le truc des tiles d'herbe, etc... étaient tous constamment mis à jour.
J'ai décidé de faire une mise à jour sélective qui change les valeurs seulement si nécessaire. Le personnage bouge vers les bords de l'écran ? On change ses coordonnées d'affichage. Il devient transparent ? On change sa transparence. Il marche sur de l'herbe ? Vous voyez le concept...
Enfin, bien entendu, on ne met pas à jours les sprites des personnages hors-écran, pour alléger un peu le processus. La taille du character est prise en compte et j'ai laissé une petite marge juste au cas où.
Alors... est-ce que ça marche ?
- Oui. Si on n'est pas à du full 40 FPS, je tourne personnellement à 37-40 sur une grande map avec près de 200 événements mobiles. Et s'ils sont hors écran, je suis à 39-40.
- Cela dit, le lag peut venir de beaucoup de choses : processeur faible, trop d'applications ouvertes, etc...

Le script est en version béta pour vérifier qu'il marche bien chez tout le monde. Testez-le dans un projet vierge de préférence ou téléchargez la Démo ici.

Voici le script (je ferai un truc plus classe sur gitHub quand j'aurai le temps).
