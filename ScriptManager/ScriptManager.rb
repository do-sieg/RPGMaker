#==============================================================================
# ** ScriptManager 1.0a
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This script manages scripts on external .rb files. It allows the user to
#  export, use and import these scripts.
#------------------------------------------------------------------------------
#  Overview
#------------------------------------------------------------------------------
#  Scripts are exported in a folder named 'Scripts' in the project folder. This
#  folder is called the root folder. Inside, there will be a _Backup folder used
#  by the system to store copies of the scripts during a risky manipulation.
#  There is also a file named _List.rb, which will contain the list of script
#  files and subfolders to load. The order in which all scripts load is the one
#  on this list:
#    Script 1
#    Script 2
#    etc.
#  The names for all these folders and files can be changed but in a careful
#  way to avoid problems. In general, the user should always save copies of
#  the project to avoid irreversible mistakes.
#------------------------------------------------------------------------------
#  Subfolders can be used, but not subfolders in subfolders. Each subfolder will
#  have its own _List.rb, managing the order in which its files are loaded.
#  To use a subfolder in the root list, add a slash (/) behind the subfolder
#  name, like this:
#    Subfolder/
#  Without a slash, the system will look for a .rb file with that name.
#------------------------------------------------------------------------------
#  Functions
#------------------------------------------------------------------------------
#  There are a few functions to use with the ScriptManager module. In order to
#  be able to call it from its location, all calls must be preceeded by :
#    Kernel.require(File.expand_path("ScriptManager.rb"))
#  Ready-to-use codes are given below.
#------------------------------------------------------------------------------
#  ScriptManager.setup
#  This is used to setup the system. It creates the root folder, the list File
#  and the backup subfolder. Usually, it is unnecessary to call it, since it is
#  done automatically when exporting scripts, but it can be useful to check if
#  the system works.
#  Code:
#    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.setup
#------------------------------------------------------------------------------
#  ScriptManager.export
#  This is used to copy all scripts from the editor in external .rb files.
#  There are a few useful things to know here:
#    -Empty scripts are not exported
#    -If a script has no name, it will be renamed to -Untitled-
#    -If many scripts share one name, (1), (2), etc. is added after their name
#    -Characters forbidden on file names are all replaced by a dash (-).
#    -Default RPG Maker scripts are organised in subfolders: Base Game Objects,
#     Base Sprites, Base Windows, Base Scenes, and Main Process. Scripts added
#     by the user (the ones between Scene_Debug and Main) are exported in a
#     Materials subfolder. These names should NEVER be used for other scripts.
#    -The previous behaviour only happens when there are no formatting in the
#     script list. If the list has already been formatted, the system will
#     follow that instead. See below for more information on formatting.
#  In any case, the subfolders and lists are made and ordered automatically.
#  Existing files could be overwritten, so manual backups will be necessary.
#  Code:
#    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.export
#------------------------------------------------------------------------------
#  ScriptManager.externalize
#  This does exactly the same as .export, but continues by removing all scripts
#  from inside the script editor and replace it by a unique loading script (see
#  below).
#  Restarting the editor will be necessary to see these changes.
#  Code:
#    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.externalize
#------------------------------------------------------------------------------
#  ScriptManager.load
#  This allows to load scripts from external files at the start of the game.
#  To be able to manage errors coming from external files, a function has been
#  added. The code given below is automatically set in the script editor when
#  using .externalize, but here it is in case of problems.
#  Code:
#    begin
#      Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.load
#    rescue Exception => error
#      ScriptManager.print_error(error)
#    end
#------------------------------------------------------------------------------
#  ScriptManager.import
#  This is the opposite of .export: it brings back all scripts from external
#  files back to the script editor, saving them to Scripts.rxdata. External
#  files will still be present in the root folder.
#  The list in the editor will follow the formatting rules (see below).
#  Restarting the editor will be necessary to see these changes.
#  Code:
#    Kernel.require(File.expand_path("ScriptManager.rb")); ScriptManager.import
#------------------------------------------------------------------------------
#  Syntax & Formatting
#------------------------------------------------------------------------------
#  List files are flexible.
#  You can add comments like in Ruby, using #. This is useful to deactivate a
#  full script very easily.
#  Spaces at the beginning or the end of a line do not count.
#  Each script or subfolder should be on its own line, in the order the game
#  will load it.
#  Subfolders have to be followed by a slash (/). Example:
#    Subfolder/
#    Script 1
#    #Script 2 (deactivated)
#    Script 3
#------------------------------------------------------------------------------
#  Inside the script editor, categories are separated by an empty row.
#  Category titles start with "@ " (the space is necessary). These categories
#  will be used as subfolders when exported. Every script placed below a
#  category until the next one will be placed in that subfolder.
#  Scripts not belonging to a category for some reason will be placed in a
#  category named -UNSORTED when exported.
#==============================================================================

module ScriptManager
  #--------------------------------------------------------------------------
  # * Invariables
  #--------------------------------------------------------------------------
  # Folder and file names
  ROOT_DIR = "Scripts"
  BACKUP_DIR = "_Backups"
  LIST_FILENAME = "_List.rb"
  # Information messages
  SETUP_MSG = "SceneManager is set up. Check the Scripts folder."
  EXPORT_MSG = [
    "All scripts from the editor have been exported to subfolders.\n",
    "Be sure to check #{ROOT_DIR}/#{LIST_FILENAME}."
  ]
  EXTERN_MSG = "Scripts removed from the internal list.\nPlease close the editor and restart it."
  IMPORT_MSG = "External scripts have been imported in the editor.\nPlease restart it."
  BACKUP_MSG = "Backup created for "
  # Error messages
  NO_TEST_ERR = "The project must be open in the editor to use ScriptManager"
  NO_EXPORT_ERR = "There seems to be nothing to export."

  class << self
    #--------------------------------------------------------------------------
    # * Get Scripts.rxdata path
    #--------------------------------------------------------------------------
    def scripts_data_filename
      ini_data = File.open("Game.ini") {|file| file.read.split("\n") }
      ini_data.each do |line|
        if line[0...8] == "Scripts="
          @script_path = line[8..-1]
          break
        end
      end
      return @script_path
    end
    #--------------------------------------------------------------------------
    # * Get Internal List from the Editor
    #--------------------------------------------------------------------------
    def get_internal_list
      scripts = load_data(scripts_data_filename)
      list = []
      # Add each script's name to the list
      scripts.each_with_index do |script, i|
        list.push(script[1])
      end
      return list
    end
    #--------------------------------------------------------------------------
    # * Get External List from a Folder
    #--------------------------------------------------------------------------
    def get_external_list(filename)
      if FileTest.exist?(filename)
        file = File.open(filename, "rb")
        content = file.read
        file.close
        table = []
        # Scan each line
        content.each do |line|
          # Remove control characters
          line.gsub!("\n", "")
          line.gsub!("\r", "")
          line.gsub!("\t", "")
          # Clean spaces at the beginning
          while line[0...1] == " "
            line = line[1...line.length]
          end
          # Clean spaces at the end
          while line[line.length - 1...line.length] == " "
            line = line[0...line.length - 1]
          end
          # Remove comments
          if line.index("#")
            line = line[0...line.index("#")]
          end
          # If line isn't empty or a comment, add it to the list
          if line != ""
            table.push(line)
          end
        end
        return table
      else
        print "File not found: #{filename}"
        return nil
      end
    end
    #--------------------------------------------------------------------------
    # * Get Export Folder for Default Export
    #--------------------------------------------------------------------------
    def get_export_folder(name)
      game_objects = [
        "Game_Temp", "Game_System", "Game_Switches", "Game_Variables", "Game_SelfSwitches",
        "Game_Screen", "Game_Picture",
        "Game_Battler 1", "Game_Battler 2", "Game_Battler 3", "Game_BattleAction",
        "Game_Actor", "Game_Enemy", "Game_Actors", "Game_Party", "Game_Troop",
        "Game_Map", "Game_CommonEvent", "Game_Character 1", "Game_Character 2", "Game_Character 3",
        "Game_Event", "Game_Player",
        "Interpreter 1", "Interpreter 2", "Interpreter 3", "Interpreter 4",
        "Interpreter 5", "Interpreter 6", "Interpreter 7",
      ]
      sprites = [
        "Sprite_Character", "Sprite_Battler", "Sprite_Picture", "Sprite_Timer",
        "Spriteset_Map", "Spriteset_Battle",
        "Arrow_Base", "Arrow_Enemy", "Arrow_Actor",
      ]
      windows = [
        "Window_Base", "Window_Selectable", "Window_Command", "Window_Help",
        "Window_Gold", "Window_PlayTime", "Window_Steps", "Window_MenuStatus",
        "Window_Item", "Window_Skill", "Window_SkillStatus", "Window_Target",
        "Window_EquipLeft", "Window_EquipRight", "Window_EquipItem", "Window_Status",
        "Window_SaveFile", "Window_ShopCommand", "Window_ShopBuy", "Window_ShopSell",
        "Window_ShopNumber", "Window_ShopStatus",
        "Window_NameEdit", "Window_NameInput", "Window_InputNumber", "Window_Message",
        "Window_PartyCommand", "Window_BattleStatus", "Window_BattleResult",
        "Window_DebugLeft", "Window_DebugRight",
      ]
      scenes = [
        "Scene_Title", "Scene_Map", "Scene_Menu",
        "Scene_Item", "Scene_Skill", "Scene_Equip", "Scene_Status",
        "Scene_File", "Scene_Save", "Scene_Load", "Scene_End",
        "Scene_Battle 1", "Scene_Battle 2", "Scene_Battle 3", "Scene_Battle 4",
        "Scene_Shop", "Scene_Name", "Scene_Gameover", "Scene_Debug",
      ]
      return "Base Game Objects" if game_objects.include?(name)
      return "Base Sprites" if sprites.include?(name)
      return "Base Windows" if windows.include?(name)
      return "Base Scenes" if scenes.include?(name)
      return "Main Process" if name == "Main"
      return "Materials"
    end
    #--------------------------------------------------------------------------
    # * Make Scripts Tree to Export
    #--------------------------------------------------------------------------
    def make_export_tree(formatted)
      section_tree = Tree.new
      name_table = []
      scripts = load_data(scripts_data_filename)
      current_section_title = nil
      scripts.each do |script|
        if section_title?(script[1])
          current_section_title = script[1][2..-1]
        end
        # Skip if script content is empty
        next if Zlib::Inflate.inflate(script[2]) == ""
        # If only the name is empty, rename the script
        script[1] = "-Untitled-" if script[1] == ""
        # Replace forbidden characters
        characters = "\\/:*?\"<>|"
        characters.split("").each do |char|
          script[1].gsub!(char, "-")
        end
        # Rename scripts who have the same name
        if name_table.include?(script[1])
          i = 1
          while name_table.include?("#{script[1]} (#{i})")
            i += 1
          end
          script[1] = "#{script[1]} (#{i})"
        end
        unless formatted
          section_name = get_export_folder(script[1])
        else
          current_section_title ||= "-UNSORTED"
          section_name = current_section_title
        end
        section_tree.add_branch(section_name) unless section_tree.has_branch?(section_name)
        section_tree.add_item(script[1], section_name)
        name_table.push(script[1])
      end
      # Save the new names to manage untitled scripts
      save_data(scripts, scripts_data_filename)
      return section_tree
    end
    #--------------------------------------------------------------------------
    # * Make Virtual List of all External Scripts
    #--------------------------------------------------------------------------
    def make_virtual_list(formatting = false)
      list = []
      # Get the external root list file
      main_list = get_external_list("#{ROOT_DIR}/#{LIST_FILENAME}")
      # Go through each item of the external list
      last_line ||= nil
      main_list.each do |name|
        if name[-1..-1] == "/"
          sublist_filename = "#{ROOT_DIR}/"
          sublist_filename += "#{name[0...-1]}/"
          sublist_filename += "#{LIST_FILENAME}"
          # Get subfolder list
          if get_external_list(sublist_filename)
            if formatting
              list.push(separator) if last_line == :file
              list.push(section_title(name))
            end
            sub_list = get_external_list(sublist_filename)
            sub_list.each do |subname|
              list.push("#{name[0...-1]}/#{subname}.rb")
            end
          end
          last_line = sub_list ? :file : :dir
        else
          list.push(separator) if formatting and last_line == :dir
          list.push("#{name}.rb")
          last_line = :file
        end
      end
      return list
    end
    #--------------------------------------------------------------------------
    # * Setup
    #--------------------------------------------------------------------------
    def setup(message = true)
      # Check if the game is launched through the editor
      unless $DEBUG
        print NO_TEST_ERR
        return
      end
      # Create root folder and subfolders
      Dir.mkdir("#{ROOT_DIR}") rescue nil
      Dir.mkdir("#{ROOT_DIR}/#{BACKUP_DIR}") rescue nil
      # Create root list
      file = File.open("#{ROOT_DIR}/#{LIST_FILENAME}", "wb")
      file.write(list_header)
      file.close
      # Display information popup
      print SETUP_MSG if message
    end
    #--------------------------------------------------------------------------
    # * Backup Scripts.rxdata
    #--------------------------------------------------------------------------
    def backup_rxdata
      # Get the name of the scripts data file
      filename = scripts_data_filename
      # Create a copy in the backup subfolder
      path = "#{ROOT_DIR}/#{BACKUP_DIR}/"
      ext = File.extname(filename)
      base = File.basename(filename, ext)
      backup = "#{path}#{base}#{ext}"
      save_data(load_data(filename), backup)
      # Rename the copy by adding the time as a suffix
      suffix = File.mtime(backup).strftime("%Y-%m-%d-%Hh%Mm%Ss")
      File.rename(backup, "#{path}#{base}_#{suffix}#{ext}")
      # Display information popup
      print BACKUP_MSG + "#{base}#{ext}."
    end
    #--------------------------------------------------------------------------
    # * Export
    #--------------------------------------------------------------------------
    def export
      # Check if the game is launched through the editor
      unless $DEBUG
        print NO_TEST_ERR
        return
      end
      # Check if the base scripts have already been exported
      int_list = self.get_internal_list
      if int_list.size == 1
        print NO_EXPORT_ERR
        return
      end
      # Setup the folders and files without informing the user
      setup(false)
      # Make the script tree
      formatted = int_list.any? {|name| name if section_title?(name) }
      section_tree = make_export_tree(formatted)
      # Export scripts to .rb files
      scripts = load_data(scripts_data_filename)
      section_tree.get_branches.each do |branch_name|
        section_tree.get_branch_data(branch_name).each do |name|
          script = scripts.find {|script| script[1] == name}
          export_script(script, branch_name) if script
        end
      end
      # Make the root list file
      filename = "#{ROOT_DIR}/#{LIST_FILENAME}"
      file = File.open(filename, "wb")
      file.write(list_header)
      section_tree.get_branches.each do |name|
        file.write("#{name}/\r\n")
      end
      file.close
      # Make sublist files
      section_tree.get_branches.each do |branch_name|
        filename = "#{ROOT_DIR}/#{branch_name}/#{LIST_FILENAME}"
        file = File.open(filename, "wb")
        file.write(sub_list_header(branch_name))
        section_tree.get_branch_data(branch_name).each do |name|
          file.write("#{name}\r\n")
        end
        file.close
      end
      # Display information popup
      print EXPORT_MSG
    end
    #--------------------------------------------------------------------------
    # * Export a Script
    #--------------------------------------------------------------------------
    def export_script(script, directory = nil)
      # Create a subfolder if it doesn't exist
      if directory
        Dir.mkdir("#{ROOT_DIR}/#{directory}") rescue nil
      end
      # Make the path for the .rb file
      name = script[1]
      code = Zlib::Inflate.inflate(script[2])
      filename = "#{ROOT_DIR}/"
      filename += "#{directory}/" if directory
      filename += "#{name}.rb"
      # Paste the code in the .rb file
      file = File.open(filename, "wb")
      file.write(code)
      file.close
    end
    #--------------------------------------------------------------------------
    # * Externalize
    #--------------------------------------------------------------------------
    def externalize
      # Check if the game is launched through the editor
      unless $DEBUG
        print NO_TEST_ERR
        return
      end
      # Check if the base scripts have already been exported
      int_list = self.get_internal_list
      if int_list.size == 1
        print NO_EXPORT_ERR
        return
      end
      # Make a backup file for the scripts in the editor
      backup_rxdata
      # Export all scripts to external files
      export
      # Create script to load external files
      name = "ScriptManager (Load)"
      code = make_load_code
      # Reduce the internal list to only this script
      scripts = [[rand_script_id, name, Zlib::Deflate.deflate(code)]]
      # Save it into Scripts.rxdata
      save_data(scripts, scripts_data_filename)
      # Display information popup
      print EXTERN_MSG
      # Close the game
      exit
    end
    #--------------------------------------------------------------------------
    # * Load
    #--------------------------------------------------------------------------
    def load
      # Check if the game is launched through the editor
      unless $DEBUG
        print NO_TEST_ERR
        return
      end
      # Make the final list without formatting
      list = make_virtual_list
      list.each do |name|
        filename = "#{ROOT_DIR}/#{name}"
        if FileTest.exist?(filename)
          Kernel.require(File.expand_path(filename))
        else
          print "Couldn't load the script '#{File.basename(filename, ".rb")}', #{filename} doesn't exist."
        end
      end
    end
    #--------------------------------------------------------------------------
    # * Print Errors from External Files
    #--------------------------------------------------------------------------
    def print_error(error)
      error_table = error.backtrace[0].split("/")
      # If the error comes from an external script
      dir_index = error_table.index(ScriptManager::ROOT_DIR)
      if dir_index
        unless error.type == Reset
          file_table = error_table[dir_index..-1]
          (0...file_table.size).each do |i|
            file_table[i] = "/#{file_table[i]}"
          end
          filename = file_table.to_s.split(':')[0]
          line = file_table.to_s.split(':')[1]
          print [
            "Script '#{filename}' line #{line}: #{error.type} occured.\n\n",
            error.message,
          ]
        end
      # If the error comes from the ScriptManager file
      elsif error_table[-1] =~ "ScriptManager.rb"
        unless error.type == SystemExit
          filename = error_table[-1].split(':')[0]
          line = error_table[-1].split(':')[1]
          function = error_table[-1].split(':')[2]
          print [
            "'#{filename}' line #{line}: #{error.type} occured in #{function}.\n\n",
            error.message,
          ]
        end
      end
    end
    #--------------------------------------------------------------------------
    # * Import
    #--------------------------------------------------------------------------
    def import
      # Check if the game is launched through the editor
      unless $DEBUG
        print NO_TEST_ERR
        return
      end
      # Make a backup file for the scripts in the editor
      backup_rxdata
      # Make the final list with formatting
      list = make_virtual_list(true)
      id_table = []
      scripts_table = []
      list.each do |name|
        # If the script is a title or a separator
        if section_title?(name) or name == separator
          script_name = name
          script_name = name[0...-1] if section_title?(name)
          script_code = Zlib::Deflate.deflate("")
        # If the script is a standard script with code
        else
          script_name = File.basename(name, ".rb")
          if FileTest.exist?("#{ROOT_DIR}/#{name}")
            file = File.open("#{ROOT_DIR}/#{name}", "rb")
            script_code = Zlib::Deflate.deflate(file.read)
            file.close
          else
            script_code = Zlib::Deflate.deflate("")
          end
        end
        # Make a random ID for the script
        script_id = 0
        loop do
          str = ""
          8.times { str += "#{rand(9)}" }
          script_id = str.to_i
          break unless id_table.include?(script_id)
        end
        id_table.push(script_id)
        script_object = [script_id, script_name, script_code]
        scripts_table.push(script_object)
      end
      # Save imported scripts to Scripts.rxdata
      save_data(scripts_table, scripts_data_filename)
      print IMPORT_MSG
      exit
    end
    #--------------------------------------------------------------------------
    # * Section Title
    #--------------------------------------------------------------------------
    def section_title(name)
      return "@ #{name}"
    end
    #--------------------------------------------------------------------------
    # * Section Title Test
    #--------------------------------------------------------------------------
    def section_title?(name)
      return (name[0..1] == "@ " and name.length > 2)
    end
    #--------------------------------------------------------------------------
    # * Editor List Separator
    #--------------------------------------------------------------------------
    def separator
      return ""
    end
    #--------------------------------------------------------------------------
    # * List File Header
    #--------------------------------------------------------------------------
    def list_header
      code = ""
      code += "#{code_separator(1)}\n"
      code += "# ** External Scripts List\n"
      code += "#{code_separator(2)}\n"
      code += "#  Add external scripts here, in the order they would appear in the editor.\n"
      code += "#  Folders have to end with a slash (ex: Folder/).\n"
      code += "#  Main Process/ should always be at the very bottom.\n"
      code += "#  To deactivate a script or a full subfolder, put # in front of its name.\n"
      code += "#{code_separator(1)}\n"
      return code
    end
    #--------------------------------------------------------------------------
    # * Subfolder List File Header
    #--------------------------------------------------------------------------
    def sub_list_header(section_name)
      code = ""
      code += "#{code_separator(1)}\n"
      code += "# ** #{section_name} Scripts List\n"
      code += "#{code_separator(2)}\n"
      code += "#  This list should not be altered unless you know what you're doing.\n"
      code += "#  Be sure to add #{section_name}/ in the root list.\n"
      code += "#  To deactivate a script, put # in front of its name.\n"
      code += "#{code_separator(1)}\n"
      return code
    end
    #--------------------------------------------------------------------------
    # * Code Separator
    #--------------------------------------------------------------------------
    def code_separator(depth)
      code = "#"
      char = ["=", "-"][depth - 1]
      78.times { code += char }
      return code
    end
    #--------------------------------------------------------------------------
    # * Load Code and Errors Management
    #--------------------------------------------------------------------------
    def make_load_code
      code = ""
      code += "begin\n"
      code += "  Kernel.require(File.expand_path(\"ScriptManager.rb\")); ScriptManager.load\n"
      code += "rescue Exception => error\n"
      code += "  ScriptManager.print_error(error)\n"
      code += "end\n"
      return code
    end
    #--------------------------------------------------------------------------
    # * Random Script ID Generator
    #--------------------------------------------------------------------------
    def rand_script_id
      str = ""
      8.times { str += "#{rand(9)}" }
      return str.to_i
    end
  end
end

#==============================================================================
# ** Tree
#------------------------------------------------------------------------------
#  This class allows organizing data in branches.
#==============================================================================

class Tree
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #--------------------------------------------------------------------------
  # * Branch Test
  #--------------------------------------------------------------------------
  def has_branch?(branch_name)
    return @data.any? {|branch| branch[0] == branch_name }
  end
  #--------------------------------------------------------------------------
  # * Get List or Branches
  #--------------------------------------------------------------------------
  def get_branches
    return @data.map {|branch| branch[0]}
  end
  #--------------------------------------------------------------------------
  # * Get Content for a Branch
  #--------------------------------------------------------------------------
  def get_branch_data(branch_name)
    branch = @data.find {|branch| branch[0] == branch_name }
    return branch[1]
  end
  #--------------------------------------------------------------------------
  # * Add Branch
  #--------------------------------------------------------------------------
  def add_branch(branch_name)
    if has_branch?(branch_name)
      print "Branch #{branch_name} already exists"
      return
    end
    @data.push([branch_name, []])
  end
  #--------------------------------------------------------------------------
  # * Add Item in a Branch
  #--------------------------------------------------------------------------
  def add_item(item, branch_name)
    branch = @data.find {|branch| branch[0] == branch_name }
    if branch
      branch[1].push(item)
    else
      print "Can't add item to nonexisting branch #{branch_name}"
    end
  end
end
