#==============================================================================
# ** Slow Message (VX Ace)
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr), based on Phantou's work
#------------------------------------------------------------------------------
#  This script allows the game to slow down the text speed in a message using
#  control characters.
#    \£ : slow down the text
#    \µ : bring it back to normal speed
#  The speed is set back to normal on a new message.
#==============================================================================

#==============================================================================
# ** Window_Message
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # * Invariables
  #--------------------------------------------------------------------------
  SLOW_WAIT = 10
  #--------------------------------------------------------------------------
  # * Clear Flag
  #--------------------------------------------------------------------------
  alias slow_clear_flags clear_flags
  def clear_flags
    slow_clear_flags
    @show_slow = false          # Slow down flag
  end
  #--------------------------------------------------------------------------
  # * Destructively Get Control Code
  #--------------------------------------------------------------------------
  def obtain_escape_code(text)
    text.slice!(/^[\$\.\|\^!><£µ\{\}\\]|^[A-Z]+/i)
  end
  #--------------------------------------------------------------------------
  # * Control Character Processing
  #--------------------------------------------------------------------------
  alias slow_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
    # This line avoids a crash if an antislash is written by itself
    code = "" if code.nil?
    # Check for the slow_down control character
    case code.upcase
    when "£"
      @show_slow = true
    when "µ"
      @show_slow = false
    else
      slow_process_escape_character(code, text, pos)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Fast Forward Flag
  #--------------------------------------------------------------------------
  alias slow_update_show_fast update_show_fast
  def update_show_fast
    slow_update_show_fast
    wait(SLOW_WAIT) if @show_slow and not @show_fast
  end
end
