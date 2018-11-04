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

#==============================================================================
# ** XPAL Weather
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This script changes how the bitmaps for weather sprites are created, using
#  RPG::Cache to store them once for all.
#==============================================================================

#==============================================================================
# ** RPG::Cache
#==============================================================================

module RPG::Cache
  #--------------------------------------------------------------------------
  # * Weather Element
  #--------------------------------------------------------------------------
  def self.weather_element(filename)
    root = "Weather/Elements/"
    # If the cache doesn't contain the weather bitmap, create it
    unless @cache[root + filename]
      color1 = Color.new(255, 255, 255, 255)
      color2 = Color.new(255, 255, 255, 128)
      case filename
      when "Rain"
        bitmap = Bitmap.new(7, 56)
        (0..6).each do |i|
          bitmap.fill_rect(6 - i, i * 8, 1, 8, color1)
        end
      when "Storm"
        bitmap = Bitmap.new(34, 64)
        (0..31).each do |i|
          bitmap.fill_rect(33-i, i*2, 1, 2, color2)
          bitmap.fill_rect(32-i, i*2, 1, 2, color1)
          bitmap.fill_rect(31-i, i*2, 1, 2, color2)
        end
      when "Snow"
        bitmap = Bitmap.new(6, 6)
        bitmap.fill_rect(0, 1, 6, 4, color2)
        bitmap.fill_rect(1, 0, 4, 6, color2)
        bitmap.fill_rect(1, 2, 4, 2, color1)
        bitmap.fill_rect(2, 1, 2, 4, color1)
      end
      @cache[root + filename] = bitmap
    end
    return @cache[root + filename]
  end
end

#==============================================================================
# ** RPG::Weather
#==============================================================================

module RPG
  class Weather
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    alias xpal_initialize initialize
    def initialize(viewport = nil)
      unless $game_system.xpal_weather
        xpal_initialize
      else
        @type = 0
        @max = 0
        @ox = 0
        @oy = 0
        @rain_bitmap = RPG::Cache.weather_element("Rain")
        @storm_bitmap = RPG::Cache.weather_element("Storm")
        @snow_bitmap = RPG::Cache.weather_element("Snow")
        @sprites = []
        200.times do
          sprite = Sprite.new(viewport)
          sprite.z = 1000
          sprite.visible = false
          sprite.opacity = 0
          @sprites.push(sprite)
        end
      end
    end
    #--------------------------------------------------------------------------
    # * Dispose
    #--------------------------------------------------------------------------
    alias xpal_dispose dispose
    def dispose
      unless $game_system.xpal_weather
        xpal_dispose
      else
        @sprites.each {|sprite| sprite.dispose }
      end
    end
  end
end

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

#==============================================================================
# ** XPAL Player
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This script rewrites the interaction checks for the Game_Player class, to
#  make it compatible with the Antilag event searching system.
#==============================================================================

#==============================================================================
# ** Game_Player
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Same Position Starting Determinant
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end
    # Loop all events present on the destination
    $game_map.find_events(@x, @y).each do |event|
      # If event triggers are consistent
      if triggers.include?(event.trigger)
        # If starting determinant is same position event (other than jumping)
        if not event.jumping? and event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Front Envent Starting Determinant
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end
    # Calculate front event coordinates
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    # Loop all events present on the destination
    $game_map.find_events(new_x, new_y).each do |event|
      # If event triggers are consistent
      if triggers.include?(event.trigger)
        # If starting determinant is front event (other than jumping)
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    # If fitting event is not found
    if result == false
      # If front tile is a counter
      if $game_map.counter?(new_x, new_y)
        # Calculate 1 tile inside coordinates
        new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        # Loop all events present on the destination
        $game_map.find_events(new_x, new_y).each do |event|
          # If event triggers are consistent
          if triggers.include?(event.trigger)
            # If starting determinant is front event (other than jumping)
            if not event.jumping? and not event.over_trigger?
              event.start
              result = true
            end
          end
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Touch Event Starting Determinant
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end
    # Loop all events present on the destination
    $game_map.find_events(x, y).each do |event|
      # If event triggers are consistent
      if [1,2].include?(event.trigger)
        # If starting determinant is front event (other than jumping)
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
end

#==============================================================================
# ** XPAL Sprites
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This script reworks the whole update function of the Sprite_Character class
#  to make it happen only when needed, instead of checking everything on every
#  frame. It also doesn't update characters whose sprites don't appear on
#  screen.
#  It requires a rewrite of Sprite_Character.
#==============================================================================

#==============================================================================
# ** Sprite_Character
#==============================================================================

class Sprite_Character < RPG::Sprite
  #--------------------------------------------------------------------------
  # * Determine if an Update is Needed
  #--------------------------------------------------------------------------
  def need_update?
    return (
      graphic_changed? ||
      frame_changed? ||
      x_changed? ||
      y_changed? ||
      z_changed? ||
      visible_changed? ||
      opacity_changed? ||
      blend_type_changed? ||
      bush_depth_changed?
    )
  end
  #--------------------------------------------------------------------------
  # * Determine if Frame Changed
  #--------------------------------------------------------------------------
  def frame_changed?
    if self.bitmap and @tile_id == 0
      sx = @character.pattern * @cw
      sy = (@character.direction - 2) / 2 * @ch
      return (self.src_rect.x != sx or self.src_rect.y != sy)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Determine if X-Coordinate Changed
  #--------------------------------------------------------------------------
  def x_changed?
    return self.x != @character.screen_x
  end
  #--------------------------------------------------------------------------
  # * Determine if Y-Coordinate Changed
  #--------------------------------------------------------------------------
  def y_changed?
    return self.y != @character.screen_y
  end
  #--------------------------------------------------------------------------
  # * Determine if Z-Coordinate Changed
  #--------------------------------------------------------------------------
  def z_changed?
    if self.bitmap
      return self.z != @character.screen_z(@ch)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Determine if Transparency Changed
  #--------------------------------------------------------------------------
  def visible_changed?
    return self.visible != !@character.transparent
  end
  #--------------------------------------------------------------------------
  # * Determine if Opacity Changed
  #--------------------------------------------------------------------------
  def opacity_changed?
    return self.opacity != @character.opacity
  end
  #--------------------------------------------------------------------------
  # * Determine if Blend Type Changed
  #--------------------------------------------------------------------------
  def blend_type_changed?
    return self.blend_type != @character.blend_type
  end
  #--------------------------------------------------------------------------
  # * Determine if Bush Depth Changed
  #--------------------------------------------------------------------------
  def bush_depth_changed?
    if $game_system.xpal_map_bush
      # If the map has any bush tile
      if $game_map.has_bushes?
        # If the character moves to another tile
        if @character.on_move?
          # If the character is moving to a bush tile
          if $game_map.bush?(@character.x, @character.y) and
             self.bush_depth == 0
            return true
          # If the character is moving away from a bush tile
          elsif !$game_map.bush?(@character.x, @character.y) and
             self.bush_depth > 0
            return true
          end
        end
      end
      return false
    else
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if a Character appears On Screen
  #--------------------------------------------------------------------------
  def on_screen?
    if self.bitmap
      # Do not show characters above the screen area
      return false if @character.screen_y < -32
      # Do not show characters below the screen area
      return false if @character.screen_y >= 480 + @ch + 32
      # Do not show characters to the left of the screen area
      return false if @character.screen_x < -@cw / 2 - 32
      # Do not show characters to the right of the screen area
      return false if @character.screen_x >= 640 + @cw / 2 + 32
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias xpal_update update
  def update
    unless $game_system.xpal_spr_char
      xpal_update
    else
      # Do not update the sprite is the character is off screen
      if $game_system.xpal_scr_char
        return unless on_screen?
      end
      # Only update when it is necessary
      if need_update?
        super
        update_bitmap
        update_src_rect if graphic_changed? or frame_changed?
        update_position
        update_other
        update_animation
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Position
  #--------------------------------------------------------------------------
  def update_position
    self.x = @character.screen_x if x_changed?
    self.y = @character.screen_y if y_changed?
    self.z = @character.screen_z(@ch) if z_changed?
  end
  #--------------------------------------------------------------------------
  # * Update Other
  #--------------------------------------------------------------------------
  def update_other
    self.opacity = @character.opacity if opacity_changed?
    self.blend_type = @character.blend_type if blend_type_changed?
    self.bush_depth = @character.bush_depth if bush_depth_changed?
    self.visible = !@character.transparent if visible_changed?
  end
end
