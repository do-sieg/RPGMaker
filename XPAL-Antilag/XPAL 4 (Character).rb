#==============================================================================
# ** XPAL Character
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This script changes a few things in the Game_Character class:
#    -Added an .on_move? function that checks if a character is moving to
#     another tile (not the same as the .moving? function).
#    -Rewrote the .passable? function to make it compatible with the Antilag
#     event searching system.
#==============================================================================

#==============================================================================
# ** Game_Character
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :last_x
  attr_reader   :last_y
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias on_move_initialize initialize
  def initialize
    on_move_initialize
    @on_move = false
    @mem_x = @x
    @mem_y = @y
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias on_move_update update
  def update
    on_move_update
    @on_move = (@mem_x != @x or @mem_y != @y)
    if on_move?
      @last_x = @mem_x
      @last_y = @mem_y
      $game_map.move_character(self)
    end
    @mem_x = @x
    @mem_y = @y
  end
  #--------------------------------------------------------------------------
  # * Determine if a Character Moving to Another Tile
  #--------------------------------------------------------------------------
  def on_move?
    return @on_move
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    # Get new coordinates
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # If coordinates are outside of map
    unless $game_map.valid?(new_x, new_y)
      # impassable
      return false
    end
    # If through is ON
    if @through
      # passable
      return true
    end
    # If unable to leave first move tile in designated direction
    unless $game_map.passable?(x, y, d, self)
      # impassable
      return false
    end
    # If unable to enter move tile in designated direction
    unless $game_map.passable?(new_x, new_y, 10 - d)
      # impassable
      return false
    end
    # Loop all events present on the destination
    $game_map.find_events(new_x, new_y).each do |event|
      # If through is OFF
      unless event.through
        # If self is event
        if self != $game_player
          # impassable
          return false
        end
        # With self as the player and partner graphic as character
        if event.character_name != ""
          # impassable
          return false
        end
      end
    end
    # If player coordinates are consistent with move destination
    if $game_player.x == new_x and $game_player.y == new_y
      # If through is OFF
      unless $game_player.through
        # If your own graphic is the character
        if @character_name != ""
          # impassable
          return false
        end
      end
    end
    # passable
    return true
  end
end
