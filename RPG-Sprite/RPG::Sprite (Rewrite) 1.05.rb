#==============================================================================
# ** RPG::Sprite (Rewrite) 1.05
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This class rewrites RPG::Sprite, a class that handles sprites with various
#  effects such as damage, animations, etc.
#  Changes in functions are based on RPG Maker VX Ace. Effects are the ones
#  displayed by default in RPG Maker XP.
#  Some values previously not accessible can now be changed, and it is easier
#  for scripters to work on the class.
#==============================================================================

#==============================================================================
# ** Sprite_Config
#------------------------------------------------------------------------------
#  This module allows the user to change the settings for RPG::Sprite.
#==============================================================================

module Sprite_Config
  # Normal Damage Text Font
  DAMAGE_FONT_NAME = "Arial Black"
  DAMAGE_FONT_SIZE = 32
  # Missed Hit Text
  MISSED_TEXT = "Miss"
  # Critical Hit Text
  CRITICAL_TEXT = "CRITICAL"
  # Critical Hit Text Font
  CRITICAL_FONT_NAME = "Arial Black"
  CRITICAL_FONT_SIZE = 20
  # Normal Damage Text Color
  NORMAL_COLOR = Color.new(255, 255, 255)
  # Recovery Text Color
  RECOVERY_COLOR = Color.new(176, 255, 144)
  # Missed Hit Text Color
  MISS_COLOR = Color.new(255, 255, 255)
  # Critical Hit Text Color
  CRITICAL_COLOR = Color.new(255, 255, 64)
end

#==============================================================================
# ** RPG::Sprite
#------------------------------------------------------------------------------
#  This class handles sprites with various effects within RPG Maker XP.
#==============================================================================

module RPG
  class Sprite < ::Sprite
    #--------------------------------------------------------------------------
    # * Class Variables
    #--------------------------------------------------------------------------
    @@ani_checker = []
    @@ani_spr_checker = []
    @@_reference_count = {}
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize(viewport = nil)
      super(viewport)
      @effect_type = nil
      @effect_duration = 0
      @blink = false
      @animation_duration = 0
      @damage_duration = 0
      @animation_bitmaps = []
      @loop_animation_bitmaps = []
    end
    #--------------------------------------------------------------------------
    # * Dispose
    #--------------------------------------------------------------------------
    def dispose
      dispose_damage
      dispose_animation
      dispose_loop_animation
      super
    end
    #--------------------------------------------------------------------------
    # * Dispose of Damage Sprite
    #--------------------------------------------------------------------------
    def dispose_damage
      if @damage_sprite
        @damage_sprite.bitmap.dispose
        @damage_sprite.dispose
        @damage_sprite = nil
        @damage_duration = 0
      end
    end
    #--------------------------------------------------------------------------
    # * Dispose of Animation
    #--------------------------------------------------------------------------
    def dispose_animation
      # Free animation bitmaps
      @animation_bitmaps.each do |bitmap|
        @@_reference_count[bitmap] -= 1
        bitmap.dispose if @@_reference_count[bitmap] == 0
      end
      @animation_bitmaps = []
      # Free animation sprites
      if @animation_sprites
        @animation_sprites.each {|sprite| sprite.dispose }
        @animation_sprites = nil
        #Free animation
        @animation = nil
      end
    end
    #--------------------------------------------------------------------------
    # * Dispose of Loop Animation
    #--------------------------------------------------------------------------
    def dispose_loop_animation
      # Free loop animation bitmaps
      @loop_animation_bitmaps.each do |bitmap|
        @@_reference_count[bitmap] -= 1
        bitmap.dispose if @@_reference_count[bitmap] == 0
      end
      @loop_animation_bitmaps = []
      # Free loop animation sprites
      if @loop_animation_sprites
        @loop_animation_sprites.each {|sprite| sprite.dispose }
        @loop_animation_sprites = nil
        #Free loop animation
        @loop_animation = nil
      end
    end
    #--------------------------------------------------------------------------
    # * Make Damage Text
    #--------------------------------------------------------------------------
    def damage_text(value = @damage_value)
      return value.is_a?(Numeric) ? value.abs.to_s : value.to_s
    end
    #--------------------------------------------------------------------------
    # * Damage Text Font Name
    #--------------------------------------------------------------------------
    def damage_font_name
      return Sprite_Config::DAMAGE_FONT_NAME
    end
    #--------------------------------------------------------------------------
    # * Damage Text Font Size
    #--------------------------------------------------------------------------
    def damage_font_size
      return Sprite_Config::DAMAGE_FONT_SIZE
    end
    #--------------------------------------------------------------------------
    # * Missed Hit Text
    #--------------------------------------------------------------------------
    def miss_text
      return Sprite_Config::MISSED_TEXT
    end
    #--------------------------------------------------------------------------
    # * Critical Hit Text
    #--------------------------------------------------------------------------
    def critical_text
      return Sprite_Config::CRITICAL_TEXT
    end
    #--------------------------------------------------------------------------
    # * Critical Hit Text Font Name
    #--------------------------------------------------------------------------
    def critical_font_name
      return Sprite_Config::CRITICAL_FONT_NAME
    end
    #--------------------------------------------------------------------------
    # * Critical Hit Text Font Size
    #--------------------------------------------------------------------------
    def critical_font_size
      return Sprite_Config::CRITICAL_FONT_SIZE
    end
    #--------------------------------------------------------------------------
    # * Normal Damage Color
    #--------------------------------------------------------------------------
    def damage_color
      return Sprite_Config::NORMAL_COLOR
    end
    #--------------------------------------------------------------------------
    # * Recovery Color
    #--------------------------------------------------------------------------
    def recovery_color
      return Sprite_Config::RECOVERY_COLOR
    end
    #--------------------------------------------------------------------------
    # * Missed Hit Color
    #--------------------------------------------------------------------------
    def miss_color
      return Sprite_Config::MISS_COLOR
    end
    #--------------------------------------------------------------------------
    # * Critical Hit Color
    #--------------------------------------------------------------------------
    def critical_color
      return Sprite_Config::CRITICAL_COLOR
    end
    #--------------------------------------------------------------------------
    # * Effect Methods Calling
    #--------------------------------------------------------------------------
    def appear;   start_effect(:appear);    end
    def escape ;  start_effect(:disappear); end
    def whiten ;  start_effect(:whiten);    end
    def collapse; start_effect(:collapse);  end
    #--------------------------------------------------------------------------
    # * Start Effect
    #--------------------------------------------------------------------------
    def start_effect(effect_type)
      @effect_type = effect_type
      @effect_duration = get_effect_duration
      revert_to_normal
      self.opacity = 0 if @effect_type == :appear
    end
    #--------------------------------------------------------------------------
    # * Set Effect Duration
    #--------------------------------------------------------------------------
    def get_effect_duration
      case @effect_type
      when :appear;     return 16
      when :disappear;  return 32
      when :whiten;     return 16
      when :collapse;   return 48
      end
    end
    #--------------------------------------------------------------------------
    # * Revert to Normal Settings
    #--------------------------------------------------------------------------
    def revert_to_normal
      self.blend_type = 0
      self.color.set(0, 0, 0, 0)
      self.opacity = 255
      self.ox = bitmap.width / 2 if bitmap
      self.src_rect.y = 0
    end
    #--------------------------------------------------------------------------
    # * Start Blink Effect
    #--------------------------------------------------------------------------
    def blink_on
      return if @blink
      @blink = true
      @blink_count = 0
    end
    #--------------------------------------------------------------------------
    # * Stop Blink Effect
    #--------------------------------------------------------------------------
    def blink_off
      return unless @blink
      @blink = false
      self.color.set(0, 0, 0, 0)
    end
    #--------------------------------------------------------------------------
    # * Start Damage
    #--------------------------------------------------------------------------
    def damage(value, tag = nil)
      dispose_damage
      # Replace default Miss text
      @damage_value = value == "Miss" ? miss_text : value
      # Replace old critical flag by a critical symbol tag
      tag = :critical if tag == true
      tag = nil if tag == false
      # Apply critical flag
      @critical = tag == :critical
      # Set damage sprite and duration
      make_damage_sprite
      @damage_duration = 40
    end
    #--------------------------------------------------------------------------
    # * Damage Y-Coordinate (Original)
    #--------------------------------------------------------------------------
    def damage_base_y
      return self.y - self.oy / 2
    end
    #--------------------------------------------------------------------------
    # * Damage Y-Coordinate (Displayed)
    #--------------------------------------------------------------------------
    def damage_real_y
      return damage_base_y
    end
    #--------------------------------------------------------------------------
    # * Damage Y-Coordinate (Jump)
    #--------------------------------------------------------------------------
    def damage_jump_y
      # Change the Y-coordinate to make a jump effect
      case 40 - @damage_duration
      when 1..2;  return -4
      when 3..4;  return -2
      when 5..6;  return 2
      when 7..12; return 4
      end
      return 0
    end
    #--------------------------------------------------------------------------
    # * Create Damage Sprite
    #--------------------------------------------------------------------------
    def make_damage_sprite
      @damage_sprite = ::Sprite.new(self.viewport)
      @damage_sprite.bitmap = Bitmap.new(160, 48)
      draw_damage_bitmap
      @damage_sprite.ox = 80
      @damage_sprite.oy = 20
      @damage_sprite.x = self.x
      @damage_sprite.y = damage_real_y
      @damage_sprite.z = 3000
      # Setup damage sprite y-coordinate modifier
      @damage_y_plus = 0
    end
    #--------------------------------------------------------------------------
    # * Get Damage Bitmap
    #--------------------------------------------------------------------------
    def damage_bitmap
      return @damage_sprite.bitmap
    end
    #--------------------------------------------------------------------------
    # * Draw Damage Bitmap
    #--------------------------------------------------------------------------
    def draw_damage_bitmap
      # Draw normal damage text
      draw_damage_text
      # Draw critical hit text
      draw_critical_text if @critical
    end
    #--------------------------------------------------------------------------
    # * Draw Normal Damage Text
    #--------------------------------------------------------------------------
    def draw_damage_text
      # Set damage text font information
      damage_bitmap.font.name = damage_font_name
      damage_bitmap.font.size = damage_font_size
      # Set damage text color
      damage_bitmap.font.color = get_damage_color
      # Draw damage text
      draw_outlined_text(0, 12, 160, 36, damage_text)
    end
    #--------------------------------------------------------------------------
    # * Draw Critical Hit Text
    #--------------------------------------------------------------------------
    def draw_critical_text
      # Set critical text font information
      damage_bitmap.font.name = critical_font_name
      damage_bitmap.font.size = critical_font_size
      # Set critical text color
      damage_bitmap.font.color = critical_color
      # Draw critical text
      draw_outlined_text(0, 0, 160, 20, critical_text)
      # Deactivate critical hit value
      @critical = false
    end
    #--------------------------------------------------------------------------
    # * Draw Text with Outline
    #--------------------------------------------------------------------------
    def draw_outlined_text(x, y, width, height, text)
      # Save original text color
      text_color = damage_bitmap.font.color.clone
      # Draw text outline
      damage_bitmap.font.color.set(0, 0, 0)
      damage_bitmap.draw_text(x - 1, y - 1, width, height, text, 1)
      damage_bitmap.draw_text(x + 1, y - 1, width, height, text, 1)
      damage_bitmap.draw_text(x - 1, y + 1, width, height, text, 1)
      damage_bitmap.draw_text(x + 1, y + 1, width, height, text, 1)
      # Draw text
      damage_bitmap.font.color = text_color
      damage_bitmap.draw_text(x, y, width, height, text, 1)
    end
    #--------------------------------------------------------------------------
    # * Set Damage Color
    #--------------------------------------------------------------------------
    def get_damage_color
      # Miss
      if @damage_value == miss_text
        return miss_color
      end
      # Recovery
      if @damage_value.is_a?(Numeric) and @damage_value < 0
        return recovery_color
      end
      # Critical hit
      return critical_color if @critical
      # Normal damage
      return damage_color
    end
    #--------------------------------------------------------------------------
    # * Start Animation
    #--------------------------------------------------------------------------
    def animation(animation, hit)
      # Free the current animation
      dispose_animation
      # Set the new animation
      @animation = animation
      if @animation
        @animation_hit = hit
        @animation_duration = @animation.frame_max
        load_animation_bitmap
        make_animation_sprites
      end
    end
    #--------------------------------------------------------------------------
    # * Start Loop Animation
    #--------------------------------------------------------------------------
    def loop_animation(animation)
      # Skip if the new loop animation is already playing
      return if animation == @loop_animation
      # Free the current loop animation
      dispose_loop_animation
      # Set the new loop animation
      @loop_animation = animation
      if @loop_animation
        @loop_animation_index = 0
        load_loop_animation_bitmap
        make_loop_animation_sprites
      end
    end
    #--------------------------------------------------------------------------
    # * Read (Load) Animation Graphics
    #--------------------------------------------------------------------------
    def load_animation_bitmap
      # Get animation graphic data
      animation_name = @animation.animation_name
      animation_hue = @animation.animation_hue
      # Create animation bitmap
      bitmap = RPG::Cache.animation(animation_name, animation_hue)
      if @@_reference_count.include?(bitmap)
        @@_reference_count[bitmap] += 1
      else
        @@_reference_count[bitmap] = 1
      end
      @animation_bitmaps.push(bitmap)
      # Reset screen refresh timing
      Graphics.frame_reset
    end
    #--------------------------------------------------------------------------
    # * Read (Load) Loop Animation Graphics
    #--------------------------------------------------------------------------
    def load_loop_animation_bitmap
      # Get loop animation graphic data
      animation_name = @loop_animation.animation_name
      animation_hue = @loop_animation.animation_hue
      # Create loop animation bitmap
      bitmap = RPG::Cache.animation(animation_name, animation_hue)
      if @@_reference_count.include?(bitmap)
        @@_reference_count[bitmap] += 1
      else
        @@_reference_count[bitmap] = 1
      end
      @loop_animation_bitmaps.push(bitmap)
      # Reset screen refresh timing
      Graphics.frame_reset
    end
    #--------------------------------------------------------------------------
    # * Create Animation Sprites
    #--------------------------------------------------------------------------
    def make_animation_sprites
      # Create 16 sprites
      @animation_sprites = []
      unless @@ani_checker.include?(@animation)
        16.times do
          sprite = ::Sprite.new(self.viewport)
          sprite.visible = false
          @animation_sprites.push(sprite)
        end
        # Store animations targeting the screen
        if @animation.position == 3
          @@ani_spr_checker.push(@animation)
        end
        if !@@ani_checker.include?(@animation) && @animation.position == 3
          @@ani_checker.push(@animation)
        end
      end
    end
    #--------------------------------------------------------------------------
    # * Create Loop Animation Sprites
    #--------------------------------------------------------------------------
    def make_loop_animation_sprites
      # Create 16 animation sprites
      @loop_animation_sprites = []
      16.times do
        sprite = ::Sprite.new(self.viewport)
        sprite.visible = false
        @loop_animation_sprites.push(sprite)
      end
    end
    #--------------------------------------------------------------------------
    # * Get Animation Origin
    #--------------------------------------------------------------------------
    def get_animation_origin(animation)
      # If the animation targets the screen
      if animation.position == 3
        if self.viewport == nil
          ani_ox = Graphics.width / 2
          ani_oy = Graphics.height / 2
        else
          ani_ox = self.viewport.rect.width / 2
          ani_oy = self.viewport.rect.height / 2
        end
      # If the animation targets different positions
      else
        ani_ox = x - ox + self.bitmap.width / 2
        ani_oy = y - oy + self.bitmap.height / 2
        if animation.position == 0
          ani_oy -= self.bitmap.height / 2
        elsif animation.position == 2
          ani_oy += self.bitmap.height / 2
        end
      end
      return [ani_ox, ani_oy]
    end
    #--------------------------------------------------------------------------
    # * Determine if Effect is Executing
    #--------------------------------------------------------------------------
    def effect?
      @effect_type != nil or @damage_duration > 0 or @animation_duration > 0
    end
    #--------------------------------------------------------------------------
    # * Determine if Blink Effect is Executing
    #--------------------------------------------------------------------------
    def blink?
      return @blink
    end
    #--------------------------------------------------------------------------
    # * Frame Update
    #--------------------------------------------------------------------------
    def update
      super
      # Update graphic effects
      update_effect
      update_blink if @blink
      # Update damage sprite
      update_damage
      # Update animation sprites (normal and loop)
      update_animation
      update_loop_animation
      # Clear animation tables
      @@ani_checker.clear
      @@ani_spr_checker.clear
    end
    #--------------------------------------------------------------------------
    # * Update Effects
    #--------------------------------------------------------------------------
    def update_effect
      if @effect_duration > 0
        # Decrease effect duration
        @effect_duration -= 1
        # Update the current effect
        update_effect_branch
        # Delete effect at the end of its duration
        @effect_type = nil if @effect_duration == 0
      end
    end
    #--------------------------------------------------------------------------
    # * Update Current Effect
    #--------------------------------------------------------------------------
    def update_effect_branch
      case @effect_type
      when :whiten
        update_whiten
      when :blink
        update_blink
      when :appear
        update_appear
      when :disappear
        update_disappear
      when :collapse
        update_collapse
      end
    end
    #--------------------------------------------------------------------------
    # * Update White Flash Effect
    #--------------------------------------------------------------------------
    def update_whiten
      self.color.set(255, 255, 255, 128)
      self.color.alpha = 128 - (16 - @effect_duration) * 10
    end
    #--------------------------------------------------------------------------
    # * Update Appearance Effect
    #--------------------------------------------------------------------------
    def update_appear
      self.opacity = (16 - @effect_duration) * 16
    end
    #--------------------------------------------------------------------------
    # * Updated Disappear Effect
    #--------------------------------------------------------------------------
    def update_disappear
      self.opacity = 256 - (32 - @effect_duration) * 10
    end
    #--------------------------------------------------------------------------
    # * Update Collapse Effect
    #--------------------------------------------------------------------------
    def update_collapse
      self.blend_type = 1
      self.color.set(255, 64, 64, 255)
      self.opacity = 256 - (48 - @effect_duration) * 6
      if @effect_duration == 0
        self.blend_type = 0
        self.color.set(0, 0, 0, 0)
      end
    end
    #--------------------------------------------------------------------------
    # * Update Blink Effect
    #--------------------------------------------------------------------------
    def update_blink
      @blink_count = (@blink_count + 1) % 32
      mod = @blink_count < 16 ? 1 : -1
      alpha = (16 - @blink_count) * mod * 6
      self.color.set(255, 255, 255, alpha)
    end
    #--------------------------------------------------------------------------
    # * Update Damage Sprite
    #--------------------------------------------------------------------------
    def update_damage
      if @damage_duration > 0
        @damage_duration -= 1
        # Change y-coordinate modifier
        @damage_y_plus += damage_jump_y
        # Set Y-coordinate
        @damage_sprite.y = damage_real_y + @damage_y_plus
        # Change opacity
        @damage_sprite.opacity = 256 - (12 - @damage_duration) * 32
        # Delete damage sprite at the end
        dispose_damage if @damage_duration == 0
      end
    end
    #--------------------------------------------------------------------------
    # * Update Animation
    #--------------------------------------------------------------------------
    def update_animation
      # Skip if no animation is playing, and skip frames
      return if @animation == nil or (Graphics.frame_count % 2 != 0)
      # Decrease animation duration
      @animation_duration -= 1
      # If animation is playing
      if @animation_duration > 0
        # Update animation frame
        frame_index = @animation.frame_max - @animation_duration
        cell_data = @animation.frames[frame_index].cell_data
        position = @animation.position
        animation_set_sprites(cell_data, position)
        @animation.timings.each do |timing|
          if timing.frame == frame_index
            animation_process_timing(timing, @animation_hit)
          end
        end
      else
        # Delete animation
        dispose_animation
      end
    end
    #--------------------------------------------------------------------------
    # * Update Loop Animation
    #--------------------------------------------------------------------------
    def update_loop_animation
      # Skip if no loop animation is playing, and skip frames
      return if @loop_animation == nil or (Graphics.frame_count % 2 != 0)
      # Update loop animation frame
      frame_index = @loop_animation_index
      cell_data = @loop_animation.frames[frame_index].cell_data
      position = @loop_animation.position
      animation_set_sprites(cell_data, position, true)
      @loop_animation.timings.each do |timing|
        if timing.frame == frame_index
          animation_process_timing(timing, true)
        end
      end
      @loop_animation_index += 1
      @loop_animation_index %= @loop_animation.frame_max
    end
    #--------------------------------------------------------------------------
    # * Set Animation Sprite
    #--------------------------------------------------------------------------
    def animation_set_sprites(cell_data, position, loop = false)
      # Get animation origin position 
      origin = get_animation_origin(!loop ? @animation : @loop_animation)
      # Get sprites and bitmaps
      sprites = !loop ? @animation_sprites : @loop_animation_sprites
      bitmaps = !loop ? @animation_bitmaps : @loop_animation_bitmaps
      # Loop through the animation sprites
      sprites.each_with_index do |sprite, i|
        # Skip if sprite doesn't exist
        next unless sprite
        # Update animation sprite 
        pattern = cell_data[i, 0]
        if !pattern || pattern < 0
          sprite.visible = false
          next
        end
        bitmap_index = pattern < 100 ? 0 : 1
        sprite.bitmap = bitmaps[bitmap_index]
        sprite.visible = true
        sprite.src_rect.set(pattern % 5 * 192, pattern / 5 * 192, 192, 192)
        sprite.x = origin[0] + cell_data[i, 1]
        sprite.y = origin[1] + cell_data[i, 2]
        sprite.z = 2000
        sprite.ox = 96
        sprite.oy = 96
        sprite.zoom_x = cell_data[i, 3] / 100.0
        sprite.zoom_y = cell_data[i, 3] / 100.0
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
        sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
        sprite.blend_type = cell_data[i, 7]
      end
    end
    #--------------------------------------------------------------------------
    # * SE and Flash Timing Processing
    #     timing : Timing data (RPG::Animation::Timing)
    #--------------------------------------------------------------------------
    def animation_process_timing(timing, hit)
      if (timing.condition == 0) or
         (timing.condition == 1 and hit == true) or
         (timing.condition == 2 and hit == false)
        if timing.se.name != ""
          se = timing.se
          Audio.se_play("Audio/SE/" + se.name, se.volume, se.pitch)
        end
        case timing.flash_scope
        when 1
          self.flash(timing.flash_color, timing.flash_duration * 2)
        when 2
          if self.viewport != nil
            self.viewport.flash(timing.flash_color, timing.flash_duration * 2)
          end
        when 3
          self.flash(nil, timing.flash_duration * 2)
        end
      end
    end
  end
end
