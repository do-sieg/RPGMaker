
# ScriptManager 1.0a
This script is the result of a poor attempt to make something simpler. It ended up being a clone (of lesser quality) of the buildozer by Joke (https://github.com/RMEx/buildozer).
This script is a full system allowing to use external files to run as scripts for RPG Maker XP. It allows the user to
export, use and import these scripts.

**NOTE THAT THIS IS A DANGEROUS SCRIPT TO USE. MAKE COPIES OF YOUR PROJECT BEFORE USING IT.**

## Overview
* Scripts are exported in a folder named **Scripts** in the project folder. This folder is called the **root folder**. Inside, there will be a **_Backup** folder used by the system to store copies of the scripts during a risky manipulation.  
* There is also a file named **_List.rb**, which will contain the list of script files and subfolders to load.  
The order in which all scripts load is the one on the list.  
Example:
```ruby
    Script 1
    Script 2
    etc.
```
* The names for all these folders and files can be changed but in a careful way to avoid problems. In general, the user should always save copies of the project to avoid irreversible mistakes.
---
* **Subfolders** can be used, but not subfolders in subfolders.  
Each subfolder will have its own **_List.rb**, managing the order in which its files are loaded.  
To use a subfolder in the root list, add a slash (`/`) behind the subfolder name, like this:
```ruby
    Subfolder/
```
* Without a slash, the system will look for a .rb file with that name.
---
## Functions
There are a few functions to use with the ScriptManager module. In order to be able to call it from its location, all calls must be preceeded by :
```ruby
    Kernel.require(File.expand_path("ScriptManager.rb"))
```
Ready-to-use codes are given below.

---
####  ScriptManager.setup
This is used to setup the system. It creates the root folder, the list file and the backup subfolder.  
Usually, it is unnecessary to call it, since it is done automatically when exporting scripts, but it can be useful to check if the system works.  
* Code:
```ruby
    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.setup
```
---
####  ScriptManager.export
This is used to copy all scripts from the editor in external .rb files.  
There are a few useful things to know here:
* Empty scripts are not exported
* If a script has no name, it will be renamed to -Untitled-
* If many scripts share one name, (1), (2), etc. is added after their name
* Characters forbidden on file names are all replaced by a dash (-).
* Default RPG Maker scripts are organised in subfolders: **Base Game Objects**,
* **Base Sprites**, **Base Windows**, **Base Scenes**, and **Main Process**. Scripts added by the user (the ones between Scene_Debug and Main) are exported in a **Materials** subfolder. These names should NEVER be used for other scripts.
* The previous behaviour only happens when there is no formatting in the script list. If the list has already been formatted, the system will follow that instead. See below for more information on formatting.

In any case, the subfolders and lists are made and ordered automatically.
Existing files could be overwritten, so manual backups will be necessary.
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
