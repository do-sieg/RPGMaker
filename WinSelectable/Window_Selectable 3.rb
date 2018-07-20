#==============================================================================
# ** Window_Selectable (part 3)
#------------------------------------------------------------------------------
#  This script adds functions to manage commands in subclasses.
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias initialize_3 initialize
  def initialize(x, y, width, height)
    initialize_3(x, y, width, height)
    @commands = []
    @disabled_commands = []
    @align = 0
  end
  #--------------------------------------------------------------------------
  # * Set Contents
  #--------------------------------------------------------------------------
  def setup_contents(width = self.width, height = self.height, padding = 16)
    self.contents = Bitmap.new(width - padding * 2, height - padding * 2)
  end
  #--------------------------------------------------------------------------
  # * Set Commands
  #--------------------------------------------------------------------------
  def set_commands(commands)
    if commands != @commands
      @commands = commands
      @item_max = [commands.size, 1].max
      setup_contents(self.width, row_max * row_height + 32)
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Command X-Coordinate Modifier
  #--------------------------------------------------------------------------
  def command_display_x
    return 4
  end
  #--------------------------------------------------------------------------
  # * Set Alignment
  #--------------------------------------------------------------------------
  def set_align(value)
    @align = value
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    (0...@item_max).each {|i| draw_item(i) }
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    self.contents.font.color = normal_color
    self.contents.font.color = disabled_color if disabled?(index)
    clear_row(index)
    self.contents.draw_text(command_text_rect(index), command_text(index),
      @align)
  end
  #--------------------------------------------------------------------------
  # * Clear Row
  #--------------------------------------------------------------------------
  def clear_row(index)
    self.contents.fill_rect(command_rect(index), Color.new(0, 0, 0, 0))
  end
  #--------------------------------------------------------------------------
  # * Command Area
  #--------------------------------------------------------------------------
  def command_rect(index)
    x = index % @column_max * ((self.width - 32) / @column_max)
    y = (index / @column_max) * row_height
    w = self.contents.width / @column_max
    return Rect.new(x, y, w, row_height)
  end
  #--------------------------------------------------------------------------
  # * Command Text Area
  #--------------------------------------------------------------------------
  def command_text_rect(index)
    rect = command_rect(index).clone
    rect.x += command_display_x
    rect.width -= command_display_x * 2
    return rect
  end
  #--------------------------------------------------------------------------
  # * Command
  #--------------------------------------------------------------------------
  def command(index = @index)
    return @commands[index]
  end
  #--------------------------------------------------------------------------
  # * Command Text
  #--------------------------------------------------------------------------
  def command_text(index)
    return command(index)
  end
  #--------------------------------------------------------------------------
  # * Enable Command
  #--------------------------------------------------------------------------
  def enable(index)
    @disabled_commands.delete(index)
    draw_item(index)
  end
  #--------------------------------------------------------------------------
  # * Disable Command
  #--------------------------------------------------------------------------
  def disable(index)
    @disabled_commands.push(index) unless disabled?(index)
    draw_item(index)
  end
  #--------------------------------------------------------------------------
  # * Disabled Test
  #--------------------------------------------------------------------------
  def disabled?(index)
    return @disabled_commands.include?(index)
  end
end
