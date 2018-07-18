#==============================================================================
# ** RPG::Sprite (Ace Style)
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This script allows to use some effects from RPG Maker VX Ace in RPG Maker XP
#  such as different colors for whiten and collapse effects, and a special boss
#  collapse effect. To set an enemy as a boss, use the options below.
#  It requires a rewrite of RPG::Sprite.
#==============================================================================

#==============================================================================
# ** Sprite_Config
#------------------------------------------------------------------------------
#  This module allows the user to change the settings for RPG::Sprite.
#==============================================================================

module Sprite_Config
  # Boss list: add all the boss monsters IDs like this [1, 2, 3...]
  BOSS_TABLE = []
  # Boss death sound effect, leave "" to not use this option
  BOSS_SE = "051-Explosion04"
end

#==============================================================================
# ** RPG::Sprite
#------------------------------------------------------------------------------
#  This class handles sprites with various effects within RPG Maker XP.
#==============================================================================

module RPG
  class Sprite < ::Sprite
    #--------------------------------------------------------------------------
    # * Collapse Effect
    #--------------------------------------------------------------------------
    alias ace_collapse collapse
    def collapse
      if self.is_a?(Sprite_Battler)
        # If the collapsing enemy is registered as a boss
        if Sprite_Config::BOSS_TABLE.include?(self.battler.id)
          # Use a different collapse effect
          start_effect(:boss_collapse)
          # If the current frame is registered in $game_system
          if $game_system.en_collapse_frames.include?(Graphics.frame_count)
            # If a sound file is set
            if Sprite_Config::BOSS_SE != ""
              # Play the boss collapse SE
              Audio.se_play("Audio/SE/" + Sprite_Config::BOSS_SE)
            else
              # Play normal enemy collapse SE
              se = $data_system.enemy_collapse_se
              Audio.se_play("Audio/SE/" + se.name, se.volume, se.pitch)
            end
          end
          # Return
          return
        # If the collapsing enemy is not registered as a boss
        else
          # If the current frame is registered in $game_system
          if $game_system.en_collapse_frames.include?(Graphics.frame_count)
            # Play normal enemy collapse SE
            se = $data_system.enemy_collapse_se
            Audio.se_play("Audio/SE/" + se.name, se.volume, se.pitch)
          end
        end
      end
      # Use the default collapse effect for other sprites
      ace_collapse
    end
    #--------------------------------------------------------------------------
    # * Set Effect Duration
    #--------------------------------------------------------------------------
    alias ace_effect_duration get_effect_duration
    def get_effect_duration
      case @effect_type
      when :boss_collapse
        return bitmap.height
      end
      return ace_effect_duration
    end
    #--------------------------------------------------------------------------
    # * Update Current Effect
    #--------------------------------------------------------------------------
    alias ace_effect_branch update_effect_branch
    def update_effect_branch
      ace_effect_branch
      case @effect_type
      when :boss_collapse
        update_boss_collapse
      end
    end
    #--------------------------------------------------------------------------
    # * Update White Flash Effect
    #--------------------------------------------------------------------------
    def update_whiten
      self.color.set(255, 255, 255, 0)
      self.color.alpha = 128 - (16 - @effect_duration) * 10
    end
    #--------------------------------------------------------------------------
    # * Update Collapse Effect
    #--------------------------------------------------------------------------
    def update_collapse
      self.blend_type = 1
      self.color.set(255, 128, 128, 128)
      self.opacity = 256 - (48 - @effect_duration) * 6
    end
    #--------------------------------------------------------------------------
    # * Update Boss Collapse Effect
    #--------------------------------------------------------------------------
    def update_boss_collapse
      # Update sprite effect
      alpha = @effect_duration * 120 / bitmap.height
      self.ox = bitmap.width / 2 + @effect_duration % 2 * 4 - 2
      self.blend_type = 1
      self.color.set(255, 255, 255, 255 - alpha)
      self.opacity = alpha
      self.src_rect.y -= 1
    end
  end
end

#==============================================================================
# ** Game_System
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :en_collapse_frames       # enemy collapse frames
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias boss_se_initialize initialize
  def initialize
    boss_se_initialize
    @en_collapse_frames = []
  end
  #--------------------------------------------------------------------------
  # * Play Sound Effect
  #--------------------------------------------------------------------------
  alias boss_se_play se_play
  def se_play(se)
    # Clear collapse frames table
    if @en_collapse_frames[0] != Graphics.frame_count
      @en_collapse_frames.clear
    end
    # Register the frame instead of playing the collapse SE
    if se == $data_system.enemy_collapse_se
      @en_collapse_frames.push(Graphics.frame_count)
    else
      boss_se_play(se)
    end
  end
end
