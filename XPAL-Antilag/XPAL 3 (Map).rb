#==============================================================================
# ** XPAL Map
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This script changes a few things in the Game_Map class:
#    -Characters are stored in each tile to speed up the process when checking
#     interactions.
#    -Passages are stored in a 2D table instead of the game going through all
#     map layers.
#    -Bush and Counter tiles are stored in an array to speed up the process.
#==============================================================================

#==============================================================================
# ** Game_Map
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  alias xpal_setup setup
  def setup(map_id)
    xpal_setup(map_id)
    setup_character_tiles
    setup_flat_passages
    setup_flat_bushes_counters
  end
  #--------------------------------------------------------------------------
  # * Setup Character Tiles
  #--------------------------------------------------------------------------
  def setup_character_tiles
    @character_tiles = []
    (0...self.height).each do |y|
      @character_tiles.push([])
      (0...self.width).each do |x|
        @character_tiles[y].push([])
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Setup Flat Passages
  #--------------------------------------------------------------------------
  def setup_flat_passages
    @flat_passages = Table.new(self.width, self.height)
    (0..2).each do |layer|
      (0...self.height).each do |y|
        (0...self.width).each do |x|
          tile_id = data[x, y, layer]
          # Tile ID acquistion failure
          if tile_id == nil
            @flat_passages[x, y] = 0x0f
          # Set obstacle bit if it exists
          elsif @passages[tile_id] != 0
            @flat_passages[x, y] = @passages[tile_id]
          # If priorities other than that are 0
          elsif @priorities[tile_id] == 0
            @flat_passages[x, y] = 0
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Setup Flat Bush Tiles and Counters
  #--------------------------------------------------------------------------
  def setup_flat_bushes_counters
    @flat_bushes = []
    @flat_counters = []
    (0..2).each do |layer|
      (0...self.height).each do |y|
        (0...self.width).each do |x|
          tile_id = data[x, y, layer]
          if @passages[tile_id] & 0x40 == 0x40
            @flat_bushes.push(x + y * self.height)
          elsif @passages[tile_id] & 0x80 == 0x80
            @flat_counters.push(x + y * self.height)
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Find Events in a Position
  #--------------------------------------------------------------------------
  def find_events(x, y, include_player = false)
    unless $game_system.xpal_evt_loop
      # Equivalent to the old system where all map events are checked
      return @events.values.find_all do |event|
        event.x == x and event.y == y
      end
    else
      return tile_characters(x, y, include_player).map do |id|
        $game_map.events[id]
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Characters from a Position
  #--------------------------------------------------------------------------
  def tile_characters(x, y, include_player = false)
    if $game_map.valid?(x, y)
      if include_player
        return @character_tiles[y][x]
      else
        return @character_tiles[y][x].map {|id| id if id != 0 }.compact
      end
    else
      return []
    end
  end
  #--------------------------------------------------------------------------
  # * Move a Character to a New Position
  #--------------------------------------------------------------------------
  def move_character(character)
    tile_characters(character.last_x, character.last_y, true).delete(character.id)
    tile_characters(character.x, character.y, true).push(character.id)
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #--------------------------------------------------------------------------
  alias xpal_passable passable?
  def passable?(x, y, d, self_event = nil)
    unless $game_system.xpal_map_pass
      xpal_passable(x, y, d, self_event)
    else
      # If coordinates given are outside of the map
      unless valid?(x, y)
        # impassable
        return false
      end
      # Change direction (0,2,4,6,8,10) to obstacle bit (0,1,2,4,8,0)
      bit = (1 << (d / 2 - 1)) & 0x0f
      # Loop in all events
      find_events(x, y).each do |event|
        # If tiles other than self are consistent with coordinates
        #if event.tile_id >= 0 and event != self_event and
        #   event.x == x and event.y == y and not event.through
        if event.tile_id >= 0 and event != self_event and not event.through
          # If obstacle bit is set
          if @passages[event.tile_id] & bit != 0
            # impassable
            return false
          # If obstacle bit is set in all directions
          elsif @passages[event.tile_id] & 0x0f == 0x0f
            # impassable
            return false
          # If priorities other than that are 0
          elsif @priorities[event.tile_id] == 0
            # passable
            return true
          end
        end
      end
      # If obstacle bit is set
      if @flat_passages[x, y] & bit != 0
        # impassable
        return false
      # If obstacle bit is set in all directions
      elsif @flat_passages[x, y] & 0x0f == 0x0f
        # impassable
        return false
      end
      # passable
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if there is any Bush Tile
  #--------------------------------------------------------------------------
  def has_bushes?
    return !@flat_bushes.empty?
  end
  #--------------------------------------------------------------------------
  # * Determine Thicket
  #--------------------------------------------------------------------------
  alias antilag_bush bush?
  def bush?(x, y)
    if $game_system.xpal_map_bush
      return @flat_bushes.include?(x + y * self.height)
    else
      antilag_bush(x, y)
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Counter
  #--------------------------------------------------------------------------
  alias antilag_counter counter?
  def counter?(x, y)
    if $game_system.xpal_map_counter
      return @flat_counters.include?(x + y * self.height)
    else
      antilag_counter(x, y)
    end
  end
end
