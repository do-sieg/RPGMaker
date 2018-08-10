
# ScriptManager 1.0a
Ce script résulte de vaines tentatives pour réussir un truc simple. Au final, j'ai codé un clone (en moins bien) du buildozer de Joke (https://github.com/RMEx/buildozer).
Ce script est un système complet qui permet d'utiliser des fichiers externes comme scripts pour RPG Maker XP. Il permet d'exporter, de charger et d'importer ces scripts.

**Ce script est assez dangereux à utiliser. Faites des copies de votre projet avant tout manipulation.**

## Présentation
* Avant tout, il faut placer ce script dans un fichier nommé `ScriptManager.rb` dans le dossier du projet.
* Les scripts sont exportés dans un dossier **Scripts** dans le dossier du projet. Ce dossier est le **dossier racine** du système. Dans ce dossier, il y aura un sous-dossier nommé **_Backup** où seront sauvegardées des copies des scripts avant tout manipulation à risque.
* Il y a aussi un fichier **_List.rb**, qui contiendra la liste des fichiers de scripts ou des sous-dossiers à charger.  
L'ordre dans lequel seront chargé tous les scripts est celui de cette liste.  
Exemple :
```ruby
    Script 1
    Script 2
    etc.
```
* Les noms de tous ces dossiers et fichiers peuvent être modifiés, mais avec beaucoup de prudence. Il est conseillé de façon générale de sauvegarder son projet en faisant des copies, cela pour éviter des erreurs irréversibles.
---
* Les **sous-dossiers** peuvent être utilisés, mais pas de sous-dossiers dans des sous-dossiers.  
Chaque sous-dossier aura sa propre **_List.rb**, qui gère l'ordre dans lequel sont chargés ses fichiers.  
Pour utiliser un sous-dossier dans le dossier racine, ajoutez un slash (`/`) après son nom, comme suit:
```ruby
    Sous-dossier/
```
* Sans un slash, le système va chercher un fichier .rb avec ce nom.
---
## Fonctions
Plusieurs fonctions peuvent être utilisées avec le module ScriptManager. Pour pouvoir l'utiliser de là où il se trouve, tous les appels de script doivent être précédés de :
```ruby
    Kernel.require(File.expand_path("ScriptManager.rb"))
```
Des codes à copier-coller sont fournis plus bas.

---
####  ScriptManager.setup
Cette fonction installe le système. Elle crée le dossier racine (Scripts), le fichier de liste et le dossier de sauvegarde.  
Normalement, cette fonction n'a pas besoin d'être appelée, puisqu'elle se lance automatiquement lors de l'exportation. Mais elle peut servir à vérifier si le système fonctionne.  
* Code :
```ruby
    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.setup
```
---
####  ScriptManager.export
Cette fonction copie tous les scripts de l'éditeur dans des fichiers .rb externes.  
Quelques informations utiles:
* Les scripts au code vide ne sont pas exportés
* Si un script a un code, mais un nom vide, il sera renommé -Untitled-
* Si plusieurs scripts portent le même nom, les copies se voient ajouter (1), (2), etc...
* Les caractères interdits dans des noms de fichier sont tous remplacés par un tiret (`-`).
* Les scripts par défaut de RPG Maker sont organisés en sous-dossiers : **Base Game Objects**,
* **Base Sprites**, **Base Windows**, **Base Scenes**, et **Main Process**. Les scripts ajoutés par l'utilisateur (entre Scene_Debug et Main) sont exportés dans le sous-dossier **Materials**. Ces noms ne doivent JAMAIS être utilisés pour autre chose.
* Le processus décrit au point précédent ne se produit que s'il n'y a aucun formatage dans la liste de scripts. Si la liste de l'éditeur a déjà été formatée, le système la suivra en priorité. Plus d'informations sur le formatage plus bas.

Dans tous les cas, les sous-dossiers et les listes sont faits et arrangés de façon automatique.  
Des fichiers existants pouvant être remplacés, des copies manuelles seront parfois nécessaires.
* Code :
```ruby
    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.export
```
---
####  ScriptManager.externalize
Ceci fait exactement la même chose qu'`.export`, mais continue en supprimant tous les scripts de l'éditeur pour les remplacer par un script unique qui va charger les scripts externes (voir plus bas).  
Redémarrer RPG Maker sera nécessaire pour voir ces changements.
* Code :
```ruby
    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.externalize
```
---
####  ScriptManager.load
Ceci permet de charger les script externes et de les utiliser dans le jeu.  
Pour gèrer les erreurs provenant de ces fichiers externes, une fonction doit être ajoutée. Le code ci-dessous apparaît automatiquement dans l'éditeur quand `.externalize` est utilisée, mais il est reproduit ici en cas de problèmes.
* Code :
```ruby
    begin
      Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.load
    rescue Exception => error
      ScriptManager.print_error(error)
    end
```
---
####  ScriptManager.import
C'est l'opposé d'`.export`: cette fontion ramène tous les scripts des fichiers externes dans l'éditeur de RPG Maker, en les sauvegardant dans `Scripts.rxdata`. Les fichiers externes ne seront pas supprimés pour autant.  
La liste dans l'éditeur suivra certaines règles de formatage (voir ci-dessous).  
Redémarrer RPG Maker sera nécessaire pour voir ces changements.
* Code :
```ruby
    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.import
```
---
## Syntaxe & Formatage
Les **fichiers de liste** sont flexibles.  
* Vous pouvez y mettre des **commentaires** comme en Ruby, en utilisant `#`. Cela peut être utile pour désactiver un script entier très facilement.
* Les espaces en début et fin de ligne ne sont pas pris en compte.
* Chaque script ou sous-dossier doit être sur sa ligne, en suivant l'ordre dans lequel le jeu va le charger.
* Les sous-dossiers doivent être suivis d'un slash (`/`). Exemple :
```ruby
    Sous-dossier/
    Script 1
    #Script 2 (désactivé)
    Script 3
```
---
Dans l'éditeur de scripts, les **catégories** sont séparées par un script vide.
* Les titres de catégories commencent par `@ ` (l'espace est indispensable). Ces catégories seront utilisées comme sous-dossiers durant l'exportation.
* Chaque script placé sous un titre de catégorie jusqu'au prochain appartient à cette catégorie.
* Les scripts sans catégories seront placés dans une catégorie nommée -UNSORTED lors de l'exportation.
