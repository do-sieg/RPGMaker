#==============================================================================
# ** Window_Selectable (part 2)
#------------------------------------------------------------------------------
#  This script rewrites or adds some functions of the class.
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias initialize_2 initialize
  def initialize(x, y, width, height)
    initialize_2(x, y, width, height)
    # Enable directional and trigger input
    @dir4_input = true
    @trigger_input = true
  end
  #--------------------------------------------------------------------------
  # * Get Row Height
  #--------------------------------------------------------------------------
  def row_height
    return 32
  end
  #--------------------------------------------------------------------------
  # * Get Top Row
  #--------------------------------------------------------------------------
  def top_row
    # Divide y-coordinate of window contents transfer origin by row height
    return self.oy / row_height
  end
  #--------------------------------------------------------------------------
  # * Set Top Row
  #     row : row shown on top
  #--------------------------------------------------------------------------
  def top_row=(row)
    # If row is less than 0, change it to 0
    if row < 0
      row = 0
    end
    # If row exceeds row_max - 1, change it to row_max - 1
    if row > row_max - 1
      row = row_max - 1
    end
    # Multiply 1 row height for y-coordinate of window contents
    # transfer origin
    self.oy = row * row_height
  end
  #--------------------------------------------------------------------------
  # * Get Number of Rows Displayable on 1 Page
  #--------------------------------------------------------------------------
  def page_row_max
    # Subtract a frame height of 32 from the window height, and divide it by
    # 1 row height
    return (self.height - 32) / row_height
  end
  #--------------------------------------------------------------------------
  # * Update Cursor Rectangle
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # If cursor position is less than 0
    if @index < 0
      self.cursor_rect.empty
      return
    end
    # Get current row
    row = @index / @column_max
    # If current row is before top row
    if row < self.top_row
      # Scroll so that current row becomes top row
      self.top_row = row
    end
    # If current row is more to back than back row
    if row > self.top_row + (self.page_row_max - 1)
      # Scroll so that current row becomes back row
      self.top_row = row - (self.page_row_max - 1)
    end
    # Draw cursor
    draw_cursor
  end
  #--------------------------------------------------------------------------
  # * Draw Cursor Rectangle
  #--------------------------------------------------------------------------
  def draw_cursor
    # Calculate cursor width
    cursor_width = self.width / @column_max - 32
    # Calculate cursor coordinates
    x = @index % @column_max * (cursor_width + 32)
    y = @index / @column_max * row_height - self.oy
    # Update cursor rectangle
    self.cursor_rect.set(x, y, cursor_width, row_height)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    # If cursor is movable
    if self.active and @item_max > 0 and @index >= 0
      # If pressing down on the directional buttons
      update_dir4 if @dir4_input
      # If pressing down on L or R
      update_triggers if @trigger_input
    end
    # Update help text (update_help is defined by the subclasses)
    if self.active and @help_window != nil
      update_help
    end
    # Update cursor rectangle
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # * Update Directional Input
  #--------------------------------------------------------------------------
  def update_dir4
    # If the down directional button was pressed
    if Input.repeat?(Input::DOWN)
      # If column count is 1 and directional button was pressed down with no
      # repeat, or if cursor position is more to the front than
      # (item count - column count)
      if (@column_max == 1 and Input.trigger?(Input::DOWN)) or
         @index < @item_max - @column_max
        # Move cursor down
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + @column_max) % @item_max
      end
    end
    # If the up directional button was pressed
    if Input.repeat?(Input::UP)
      # If column count is 1 and directional button was pressed up with no
      # repeat, or if cursor position is more to the back than column count
      if (@column_max == 1 and Input.trigger?(Input::UP)) or
         @index >= @column_max
        # Move cursor up
        $game_system.se_play($data_system.cursor_se)
        @index = (@index - @column_max + @item_max) % @item_max
      end
    end
    # If the right directional button was pressed
    if Input.repeat?(Input::RIGHT)
      # If column count is 2 or more, and cursor position is closer to front
      # than (item count -1)
      if @column_max >= 2 and @index < @item_max - 1
        # Move cursor right
        $game_system.se_play($data_system.cursor_se)
        @index += 1
      end
    end
    # If the left directional button was pressed
    if Input.repeat?(Input::LEFT)
      # If column count is 2 or more, and cursor position is more back than 0
      if @column_max >= 2 and @index > 0
        # Move cursor left
        $game_system.se_play($data_system.cursor_se)
        @index -= 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Trigger Input
  #--------------------------------------------------------------------------
  def update_triggers
    # If L button was pressed
    if Input.repeat?(Input::L)
      # If top row being displayed is more to back than 0
      if self.top_row > 0
        # Move cursor 1 page forward
        $game_system.se_play($data_system.cursor_se)
        @index = [@index - self.page_item_max, 0].max
        self.top_row -= self.page_row_max
      end
    end
    # If R button was pressed
    if Input.repeat?(Input::R)
      # If bottom row being displayed is more to front than bottom data row
      if self.top_row + (self.page_row_max - 1) < (self.row_max - 1)
        # Move cursor 1 page back
        $game_system.se_play($data_system.cursor_se)
        @index = [@index + self.page_item_max, @item_max - 1].min
        self.top_row += self.page_row_max
      end
    end
  end
end
