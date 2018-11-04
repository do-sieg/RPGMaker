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
