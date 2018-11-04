(French version: https://github.com/do-sieg/RPGMaker/blob/master/XPAL-Antilag/Readme_FR.md)

# XPAL (XP Antilag System)
Ce script résout un grand problème de RPG Maker XP: le ralentissement (ou lag) du jeu quand trop de personnages sont sur la map.

### Comment ça marche ?
Après des essais sur les scripts de base, en activant/désactivant des parties de code, j'ai réussi à identifier les causes du problème.
La plupart des scripts Antilag passés se contentaient de désactiver le rafraîchissement des personnages hors-écran. Cependant, il semblait que le simple fait d'avoir des personnages mobiles, même sans aucun sprite, suffisait à ralentir tout le jeu. XPAL va plus loin...

### Fonctionnalités
* Le système peut être activé ou désactivé, en tout ou partie, même en cours de jeu (comme ça, vous pouvez vérifier que ça marche).
* Les bitmaps pour les sprites des effets météo (pluie, neige, etc...) étaient redessinés à chaque ouverture de map. XPAL les stocke dans le Cache pour les recycler, comme le reste des graphismes.
* RMXP scanne TOUS les événements de la map à chaque vérification pour les interactions et passabilités. Le jeu cherche dans tous les événements celui ou ceux qui ont pour coordonnée X et Y. Pour éviter ces boucles inutiles (des boucles for en plus), les personnages sont organisés par carreaux, et on analyse le carreau seulement.
* RMXP vérifie si un carreau est passable en scannant les 3 couches de la map, carreau par carreau. XPAL crée un tableau en deux dimensions qui stocke les passabilités en une couche, ce qui accélère un peu le processus (les carreaux ne changent habituellement pas leurs propriétés in-game, donc aucun souci).
* Une des plus grosses sources de ralentissement, et la plus incroyable, provenait des carreaux d'herbe, ceux qui font qu'en marchant dessus, le bas du personnage devient transparent. Sachez que RPG Maker XP...
  * change constamment le sprite
  * en scannant les trois couches de la map
  * carreau par carreau
  * pour chaque personnage
  * qu'il bouge on non
  * à CHAQUE FRAME
  * même dans des maps qui n'ont aucun carreau avec une telle propriété.... 

  Il a donc été décidé de passer par un simple tableau où sont stockés les carreaux en buisson. Quand le personnage BOUGE, on vérifie si un changement est nécessaire et ensuite seulement on change le sprite.
* De même, les carreaux d'interaction (comptoir et autres) ont aussi été ramenés à un simple tableau pour légèrement accélèrer le processus.
* Pour gérer correctement l'organisation des characters en carreaux, une vérification de déplacement a été ajoutée à Game_Character. La fonction .on_move vérifie si le personnage change de coordonnées, et peut être utile à certains scripteurs.
* Autre gros morceau, que je donnerais comme responsable de la moitié du lag au moins, Sprite_Character, et plus exactement sa méthode update. La mise à jour des sprites de personnages se faisait de façon constante et sans aucune restriction pour voir si le changement était nécessaire. Les coordonnées X, Y, Z, la visibilité, l'opacité, le truc des tiles d'herbe, etc... étaient tous constamment mis à jour.

  J'ai décidé de faire une mise à jour sélective qui change les valeurs seulement si nécessaire. Le personnage bouge vers les bords de l'écran ? On change ses coordonnées d'affichage. Il devient transparent ? On change sa transparence. Il marche sur de l'herbe ? Vous voyez le concept...
* Enfin, bien entendu, on ne met pas à jour les sprites des personnages hors-écran, pour alléger un peu le processus. La taille du character est prise en compte et j'ai laissé une petite marge juste au cas où.

### Alors... est-ce que ça marche ?
* Oui. Si on n'est pas à du full 40 FPS, je tourne personnellement à 37-40 sur une grande map avec près de 200 événements mobiles (16 FPS sans l'antilag). Et s'ils sont hors écran, je suis à 39-40.
* Cela dit, le lag peut venir de beaucoup de choses : processeur faible, trop d'applications ouvertes, etc...
* Puisque ce script change l'organisation des maps et des personnages, ne vous attendez pas à une pleine compatibilité avec d'autres scripts. Par exemple, organiser les personnages en carreaux est incompatible avec des scripts de déplacement en pixel, même dans la logique. Cependant, j'ai réussi à faire quelques changements et à rendre ce système compatible avec mes déplacements personnalisés, donc ça reste possible.
De plus, si vous avez des systèmes qui changent les propriétés des carreaux en cours de jeu, modifier XPAL sera nécessaire dans les tableaux de passabilité, etc...

### Utilisation
* Avant tout, il faut ajouter ma [réécriture Sprite_Character](https://github.com/do-sieg/RPGMaker/blob/master/SpriteCharacter/Sprite_Character%20(Rewrite)).
* Ensuite, collez les 6 scripts ou la version megascript qui les fusionne en un script si vous êtes pressé.
* Une démonstration est disponible pour essayer le système.
