#==============================================================================
# ** Battle Sound Control
#------------------------------------------------------------------------------
#  By Siegfried (http://saleth.fr)
#------------------------------------------------------------------------------
#  This script allows the user to prevent music change when starting a battle.
#  It can also prevent the battle start Sound Event from being called.
#  The script rewrites Scene_Map.call_battle.
#==============================================================================

#==============================================================================
# ** Battle_Sound
#==============================================================================

module Battle_Sound
  #--------------------------------------------------------------------------
  # * Invariables
  #--------------------------------------------------------------------------
  # Add map IDs where there is no music change when entering battle.
  NO_BATTLE_BGM_MAPS = [
    1,
    2,
  ]
  # Add map IDs where there is no sound effect change when entering battle.
  NO_BATTLE_SE_MAPS = [
    1,
    2,
  ]
end

#==============================================================================
# ** Scene_Map
#==============================================================================

class Scene_Map
  #--------------------------------------------------------------------------
  # * Battle Call
  #--------------------------------------------------------------------------
  def call_battle
    # Clear battle calling flag
    $game_temp.battle_calling = false
    # Clear menu calling flag
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    # Make encounter count
    $game_player.make_encounter_count
    # Memorize map BGM
    $game_temp.map_bgm = $game_system.playing_bgm
    # Stop BGM
    unless Battle_Sound::NO_BATTLE_BGM_MAPS.include?($game_map.map_id)
      $game_system.bgm_stop
    endx
    # Play battle start SE
    unless Battle_Sound::NO_BATTLE_SE_MAPS.include?($game_map.map_id)
      $game_system.se_play($data_system.battle_start_se)
    end
    # Play battle BGM
    unless Battle_Sound::NO_BATTLE_BGM_MAPS.include?($game_map.map_id)
      $game_system.bgm_play($game_system.battle_bgm)
    end
    # Straighten player position
    $game_player.straighten
    # Switch to battle screen
    $scene = Scene_Battle.new
  end
end
