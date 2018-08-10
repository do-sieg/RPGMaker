
# ScriptManager 1.0a
Ce script résulte de vaines tentatives pour réussir un truc simple. Au final, j'ai codé un clone (en moins bien) du buildozer de Joke (https://github.com/RMEx/buildozer).
Ce script est un système complet qui permet d'utiliser des fichiers externes comme scripts pour RPG Maker XP. Il permet d'exporter, de charger et d'importer ces scripts.

**Ce script est assez dangereux à utiliser. Faites des copies de votre projet avant tout manipulation.**

## Présentation
* Avant tout, il faut placer ce script dans un fichier nommé `ScriptManager.rb` dans le dossier du projet.
* Les scripts sont exportés dans un dossier **Scripts** dans le dossier du projet. Ce dossier est le **dossier racine** du système. Dans ce dossier, il y aura un sous-dossier nommé **_Backup** où seront sauvegardées des copies des scripts avant tout manipulation à risque.
* Il y a aussi un fichier **_List.rb**, qui contiendra la liste des fichiers de scripts ou des sous-dossiers à charger.  
L'ordre dans lequel seront chargé tous les scripts est celui de cette liste.  
Exemple:
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
* Code:
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
Des fichiers existants peuvent être remplacés, ce qui signifie que des copies manuelles seront parfois nécessaires.
* Code:
```ruby
    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.export
```
---
####  ScriptManager.externalize
This does exactly the same as `.export`, but continues by removing all scripts from inside the script editor and replace it by a unique loading script (see below).  
Restarting the editor will be necessary to see these changes.
* Code:
```ruby
    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.externalize
```
---
####  ScriptManager.load
This allows to load scripts from external files at the start of the game.  
To be able to manage errors coming from external files, a function has been added. The code given below is automatically set in the script editor when using `.externalize`, but here it is in case of problems.
* Code:
```ruby
    begin
      Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.load
    rescue Exception => error
      ScriptManager.print_error(error)
    end
```
---
####  ScriptManager.import
This is the opposite of `.export`: it brings back all scripts from external files back to the script editor, saving them to `Scripts.rxdata`. External files will still be present in the root folder.  
The list in the editor will follow the formatting rules (see below).  
Restarting the editor will be necessary to see these changes.
* Code:
```ruby
    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.import
```
---
## Syntax & Formatting
**List files** are flexible.  
* You can add **comments** like in Ruby, using `#`. This is useful to deactivate a full script very easily.
* Spaces at the beginning or the end of a line do not count.
* Each script or subfolder should be on its own line, in the order the game will load it.
* Subfolders have to be followed by a slash (/). Example:
```ruby
    Subfolder/
    Script 1
    #Script 2 (deactivated)
    Script 3
```
---
Inside the script editor, **categories** are separated by an empty row.
* Category titles start with `@ ` (the space is necessary). These categories will be used as subfolders when exported.
* Every script placed below a category until the next one will be placed in that subfolder.
* Scripts not belonging to a category for some reason will be placed in a category named -UNSORTED when exported.
