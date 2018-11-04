


Bonjour à tous.
J'en parlais depuis quelques jours sur le Discord, et voici enfin le truc publié.

La semaine dernière, je voulais trouver un moyen de zoomer/dézoomer la map, et une chose en entraînant une autre, je me suis retrouvé à regarder un peu comment les classes de base étaient faites pour les maps et les personnages. Bien sûr, depuis le temps que je bosse dessus, je savais à peu près ce qu'il fallait, mais je voulais en savoir plus sur un des plus gros défis de RPG Maker XP...

Comme certains ici, je suis un utilisateur du logiciel, et comme tout le monde, une des choses qui m'énerve le plus est la lenteur dès qu'on met quelques événements sur la map.

J'ai donc découpé les scripts de base et désactivé toutes les mises à jour des sprites. En réactivant chaque partie une par une, j'ai peu à peu compris ce qui faisait lagger, et ce qui ne le faisait pas.
La plupart des scripts antilag cherchent juste à désactiver la mise à jour des sprites hors de l'écran. Mais même sans ça, le simple fait d'avoir des événements qui bougent sur la map, même sans sprites, suffit à ralentir le jeu. Désactiver les sprites hors écran ne suffit pas. Ce script va bien plus loin...

Le système peut être activé ou désactivé, en tout ou partie (comme ça, vous pouvez vérifier que ça marche).
Les bitmaps pour les sprites des effets météo (pluie, neige, etc...) étaient redessinés à chaque ouverture de map. XPAL les stocke dans le Cache pour les recycler, comme le reste des graphismes.
RMXP scanne TOUS les événements de la map à chaque vérification pour les interactions et passabilités. Le jeu cherche dans tous les événements celui ou ceux qui ont pour coordonnée X et Y. Pour éviter ces boucles inutiles (des boucles for en plus), les personnages sont organisés par carreaux, et on analyse le carreau seulement.
RMXP vérifie si un carreau est passable en scannant les 3 couches de la map, carreau par carreau. XPAL crée un tableau en deux dimensions qui stocke les passabilités en une couche, ce qui accélère un peu le processus (les carreaux ne changent habituellement pas leurs propriétés in-game, donc aucun souci).
Vous ne croirez jamais qui était une des plus grosses sources de ralentissement ! Vous voyez les carreaux d'herbe, où quand on marche dessus, le bas du personnage devient transparent ? Et bien sachez que RMXP...
change constamment le sprite
en scannant les trois couches de la map
carreau par carreau
pour chaque personnage
qu'il bouge on non
à CHAQUE FRAME
même dans des maps qui n'ont aucun carreau avec une telle propriété.... 

Il a donc été décidé de passer par un simple tableau où sont stockés les carreaux en buisson. Quand le personnage BOUGE, on vérifie si un changement est nécessaire et ensuite seulement on change le sprite.
De même, les carreaux d'interaction (comptoir et autres) ont aussi été ramenés à un simple tableau pour légèrement accélèrer le processus.
Pour gérer correctement l'organisation des characters en carreaux, une vérification de déplacement a été ajoutée à Game_Character. La fonction .on_move vérifie si le personnage change de coordonnées, et peut être utile à certains scripteurs.
Autre gros morceau, que je donnerais comme responsable de la moitié du lag au moins, Sprite_Character, et plus exactement sa méthode update. La mise à jour des sprites de personnages se faisait de façon constante et sans aucune restriction pour voir si le changement était nécessaire. Les coordonnées X, Y, Z, la visibilité, l'opacité, le truc des tiles d'herbe, etc... étaient tous constamment mis à jour.
J'ai décidé de faire une mise à jour sélective qui change les valeurs seulement si nécessaire. Le personnage bouge vers les bords de l'écran ? On change ses coordonnées d'affichage. Il devient transparent ? On change sa transparence. Il marche sur de l'herbe ? Vous voyez le concept...
Enfin, bien entendu, on ne met pas à jours les sprites des personnages hors-écran, pour alléger un peu le processus. La taille du character est prise en compte et j'ai laissé une petite marge juste au cas où.
Alors... est-ce que ça marche ?
- Oui. Si on n'est pas à du full 40 FPS, je tourne personnellement à 37-40 sur une grande map avec près de 200 événements mobiles. Et s'ils sont hors écran, je suis à 39-40.
- Cela dit, le lag peut venir de beaucoup de choses : processeur faible, trop d'applications ouvertes, etc...

Le script est en version béta pour vérifier qu'il marche bien chez tout le monde. Testez-le dans un projet vierge de préférence ou téléchargez la Démo ici.

Voici le script (je ferai un truc plus classe sur gitHub quand j'aurai le temps).
