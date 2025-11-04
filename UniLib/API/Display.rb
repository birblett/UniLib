# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.8, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

<<-DOC
>> pokemon battle display api. allows for custom display hooks.
DOC
module Display

  <<-DOC
  @param id - id to register under. prevents duplicates.
  @param proc - accepts 4 arguments, the pokemon (PokeBattle_Battler), the bitmap (AnimatedBitmap),  whether the battle is doubles 
                (boolean), and whether the pokemon is on the opponent side (boolean).
  @param block - for convenience/syntax purposes, otherwise identical to proc
  >> used to register battle display hooks.
  DOC
  def self.add_display_hook(id, proc = nil, &block)
    UniLib::DISPLAY_OVERWRITE[id] = block ? block : proc
  end

end