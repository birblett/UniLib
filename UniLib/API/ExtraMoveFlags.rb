# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.7, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

class PokeBattle_Move

  def is_bite_move?
    PBStuff::BITEMOVE.include?(@move)
  end

  def is_dance_move?
    PBStuff::DANCEMOVE.include?(@move)
  end
  def is_full_body_move?
    UniLib::FULL_BODY_MOVES.include?(@move)
  end

  def is_grappling_move?
    UniLib::GRAPPLING_MOVES.include?(@move)
  end

  def is_hand_move?
    UniLib::HAND_MOVES.include?(@move)
  end

  def is_kicking_move?
    UniLib::KICKING_MOVES.include?(@move)
  end

  def is_stabbing_move?
    PBStuff::STABBINGMOVE.include?(@move)
  end

  def is_wind_move?
    UniLib::WIND_MOVES.include?(@move)
  end

end