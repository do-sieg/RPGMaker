#==============================================================================
# ** Font Effects 1.1
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This script adds shadow and outline properties to the Font class.
#  To use these properties in a specific window, use the following lines:
#    self.contents.font.shadow = true
#    self.contents.font.outline = true
#  To set these properties to be used by default, use these lines anywhere:
#    Font.default_shadow = true
#    Font.default_outline = true
#  Colors can be changed using .shadow_color and .out_color.
#  Alternatively, Font.default_shadow_color and Font.default_out_color can be
#  used to make a general change.
#==============================================================================

#==============================================================================
# ** Font
#==============================================================================

class Font
  #--------------------------------------------------------------------------
  # * Public Class Variables
  #--------------------------------------------------------------------------
  class << self
    attr_accessor :default_shadow           # default shadow flag
    attr_accessor :default_outline          # default outline flag
    attr_accessor :default_shadow_color     # default shadow color
    attr_accessor :default_out_color        # default outline color
  end
  #--------------------------------------------------------------------------
  # * Class Variables Initialization
  #--------------------------------------------------------------------------
  Font.default_shadow = false
  Font.default_outline = false
  Font.default_shadow_color = Color.new(0, 0, 0, 64)
  Font.default_out_color = Color.new(0, 0, 0, 128)
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :shadow                   # shadow flag
  attr_accessor :outline                  # outline flag
  attr_accessor :shadow_color             # shadow color
  attr_accessor :out_color                # outline color
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias fx_initialize initialize
  def initialize
    fx_initialize
    @shadow = Font.default_shadow
    @shadow_color = Font.default_shadow_color
    @outline = Font.default_outline
    @out_color = Font.default_out_color
  end
end

#==============================================================================
# ** Bitmap
#==============================================================================

class Bitmap
  #--------------------------------------------------------------------------
  # * Font Initialization
  #--------------------------------------------------------------------------
  alias fx_font font=
  def font=(new_font)
    fx_font(new_font)
    self.font.shadow = new_font.shadow
    self.font.shadow_color = new_font.shadow_color
    self.font.outline = new_font.outline
    self.font.out_color = new_font.out_color
  end
  #--------------------------------------------------------------------------
  # * Draw Text
  #--------------------------------------------------------------------------
  alias fx_draw_text draw_text
  def draw_text(*args)
    # Get the color from the current font
    font_color = self.font.color.clone
    # Change arguments to Rect for easier calculations
    unless args[0].is_a?(Rect)
      # Make a Rect object out of the x, y, width and height arguments
      rect = Rect.new(*args[0..3])
      # Delete the x, y, width and height arguments
      4.times { args.delete_at(0) }
      # Insert the Rect object as the first argument
      args.insert(0, rect)
    end
    # Memorize text coordinates
    text_x = args[0].x
    text_y = args[0].y
    # Shadow
    if self.font.shadow
      # Change font color
      self.font.color = self.font.shadow_color
      # Set shadow coordinates
      args[0].x = text_x + 2
      args[0].y = text_y + 2
      # Draw shadow
      fx_draw_text(*args)
      # Restore text coordinates
      args[0].x, args[0].y = text_x, text_y
    end
    # Outline
    if self.font.outline
      # Change font color
      self.font.color = self.font.out_color
      # Draw outline in 8 directions
      (-1..1).each do |y_plus|
        (-1..1).each do |x_plus|
          # Set outline coordinates
          args[0].x = text_x + x_plus
          args[0].y = text_y + y_plus
          # Draw outline
          fx_draw_text(*args) if x_plus.abs + y_plus.abs != 0
        end
      end
    end
    # Restore the original color
    self.font.color = font_color
    # Restore text coordinates
    args[0].x, args[0].y = text_x, text_y
    # Draw original text
    fx_draw_text(*args)
  end
end
