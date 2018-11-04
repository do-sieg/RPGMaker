#==============================================================================
# ** XPAL (XP Antilag System)
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This series of scripts rewrites some core classes of RPG Maker to reduce
#  issues with low frame rate occasionnally happening when using too many
#  events on a map. It touches classes such as RPG::Weather, Game_Map,
#  Game_Character, Game_Player and Sprite_Character.
#  Please be advised that it is not compatible with scripts that change some of
#  the functions in those classes. It is also designed for tile movement, and
#  is not going to fully work with things like pixel movement. However, some
#  features could still be adapted with work.
#==============================================================================

#==============================================================================
# ** XPAL System
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This script manages activation and deactivation for all or part of the
#  Antilag system.
#==============================================================================

#==============================================================================
# ** Game_System
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :xpal_map_pass            # map passability check antilag
  attr_accessor :xpal_map_bush            # map bush check antilag
  attr_accessor :xpal_map_counter         # map counter check antilag
  attr_accessor :xpal_evt_loop            # event loop antilag
  attr_accessor :xpal_spr_char            # character sprites antilag
  attr_accessor :xpal_scr_char            # only on screen sprites antilag
  attr_accessor :xpal_weather             # weather bitmaps antilag
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias xpal_initialize initialize
  def initialize
    xpal_initialize
    @xpal_map_pass = false
    @xpal_map_bush = false
    @xpal_map_counter = false
    @xpal_evt_loop = false
    @xpal_spr_char = false
    @xpal_scr_char = false
    @xpal_weather = false
  end
  #--------------------------------------------------------------------------
  # * Antilag Switch
  #     value : true/false
  #--------------------------------------------------------------------------
  def switch_antilag(value)
    @xpal_map_pass = value
    @xpal_map_bush = value
    @xpal_map_counter = value
    @xpal_evt_loop = value
    @xpal_spr_char = value
    @xpal_scr_char = value
    @xpal_weather = value
  end
end
