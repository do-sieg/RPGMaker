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
