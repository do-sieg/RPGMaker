#==============================================================================
# ** Speed Control 2.2
#------------------------------------------------------------------------------
#  For RPG Maker XP, VX and VX Ace
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  While in Debug Mode, press F8 (the key can be modified) to rotate between
#  three speed settings (high, low, normal).
#==============================================================================

#==============================================================================
# ** Speed_Control
#==============================================================================

module Speed_Control
  #--------------------------------------------------------------------------
  # * Invariables
  #--------------------------------------------------------------------------
  KEY = Input::F8                         # input key
  LOW = 10                                # low speed (normal = 40)
  HIGH = 120                              # high speed (normal = 40)
  DISABLE_TEXT = false                    # disables the pop-up text
  LOW_TEXT = "Low speed"                  # displayed text (low)
  NORMAL_TEXT = "Normal speed"            # displayed text (normal)
  HIGH_TEXT = "High speed"                # displayed text (high)
end

#==============================================================================
# ** Input
#==============================================================================

module Input
  class << self
    #--------------------------------------------------------------------------
    # * Frame Update
    #--------------------------------------------------------------------------
    alias speed_control_update update
    def update
      speed_control_update
      # Get the standard frame_rate
      @normal_speed = Graphics.frame_rate if @normal_speed.nil?
      # If a test is running, and the speed key is pressed
      if ($DEBUG || $TEST) and trigger?(Speed_Control::KEY)
        # When the game speed is low
        if Graphics.frame_rate < @normal_speed
          Graphics.frame_rate = @normal_speed
          text = Speed_Control::NORMAL_TEXT
        # When the game speed is high
        elsif Graphics.frame_rate > @normal_speed
          Graphics.frame_rate = Speed_Control::LOW
          text = Speed_Control::LOW_TEXT
        # When the game speed is normal
        else
          Graphics.frame_rate = Speed_Control::HIGH
          text = Speed_Control::HIGH_TEXT
        end
        unless Speed_Control::DISABLE_TEXT
          p "#{text} (#{Graphics.frame_rate} FPS)"
        end
        # Play decision sound
        $game_system.se_play($data_system.decision_se) if $DEBUG
        Sound.play_decision if $TEST and defined?(Sound.play_decision)
        Sound.play_ok if $TEST and defined?(Sound.play_ok)
      end
    end
  end
end
