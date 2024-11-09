# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.6, __FILE__)

# ======================================================================================================================================== #
# ============================================================ INTERNAL/CORE ============================================================= #
# ======================================================================================================================================== #

module UniLib

  TYPE_WEAKNESS_MAP = { :NORMAL => [:FIGHTING], :FIGHTING => [:FLYING, :PSYCHIC, :FAIRY], :FLYING => [:ROCK, :ELECTRIC, :ICE],
                        :GROUND => [:WATER, :GRASS, :ICE], :POISON => [:GROUND, :PSYCHIC],
                        :ROCK => [:FIGHTING, :GROUND, :STEEL, :WATER, :GRASS], :BUG => [:FLYING, :ROCK, :FIRE], :GHOST => [:GHOST, :DARK],
                        :STEEL => [:FIGHTING, :GROUND, :FIRE], :QMARKS => [], :FIRE => [:GROUND, :ROCK, :WATER],
                        :WATER => [:GRASS, :ELECTRIC], :GRASS => [:FLYING, :POISON, :BUG, :FIRE, :ICE], :ELECTRIC => [:GROUND],
                        :PSYCHIC => [:BUG, :GHOST, :DARK], :ICE => [:FIGHTING, :ROCK, :STEEL, :FIRE], :DRAGON => [:ICE, :DRAGON, :FAIRY],
                        :DARK => [:FIGHTING, :BUG, :FAIRY], :FAIRY => [:POISON, :STEEL] }

  TYPE_IMMUNITY_MAP = { :NORMAL => [:GHOST], :FIGHTING => [], :FLYING => [:GROUND], :GROUND => [:ELECTRIC], :POISON => [], :ROCK => [],
                        :BUG => [], :GHOST => [:NORMAL, :FIGHTING], :STEEL => [:POISON], :QMARKS => [], :FIRE => [], :WATER => [],
                        :GRASS => [], :ELECTRIC => [], :PSYCHIC => [], :ICE => [], :DRAGON => [], :DARK => [:PSYCHIC], :FAIRY => [:DRAGON] }

  TYPE_RESISTANCE_MAP = { :NORMAL => [], :FIGHTING => [:ROCK, :BUG, :DARK], :FLYING => [:FIGHTING, :BUG, :GRASS], :GROUND => [:POISON, :ROCK],
                          :POISON => [:FIGHTING, :POISON, :BUG, :GRASS], :ROCK => [:NORMAL, :FLYING], :BUG => [:GROUND, :GRASS],
                          :STEEL => [:NORMAL, :FLYING, :ROCK, :BUG, :STEEL, :GRASS, :PSYCHIC, :ICE, :DRAGON, :FAIRY],
                          :QMARKS => [], :FIRE => [:BUG, :FIRE, :GRASS, :ICE], :WATER => [:FIRE, :STEEL, :WATER, :ICE],
                          :GRASS => [:GROUND, :WATER, :GRASS, :ELECTRIC], :ELECTRIC => [:FLYING, :ELECTRIC],
                          :PSYCHIC => [:FIGHTING, :PSYCHIC], :ICE => [:ICE], :DRAGON => [:FIRE, :WATER, :GRASS, :ELECTRIC],
                          :DARK => [:GHOST, :DARK], :FAIRY => [:FIGHTING, :BUG, :DARK], :GHOST => [:BUG] }

  FULL_BODY_MOVES = [:AURAWHEEL, :BODYPRESS, :BODYSLAM, :DOUBLEEDGE, :FLAMECHARGE, :FLAMEWHEEL, :FLAREBLITZ, :FLYINGPRESS, :GIGAIMPACT,
                     :GYROBALL, :HEATCRASH, :HEAVYSLAM, :HIGHHORSEPOWER, :LUNGE, :RAGINGFURY, :RAPIDSPIN, :ROCKCLIMB, :ROLLOUT, :SKYDROP,
                     :SLAM, :SPARK, :SUBMISSION, :TACKLE, :TAKEDOWN, :VOLTTACKLE, :WATERFALL, :WAVECRASH, :WILDCHARGE]

  HAND_MOVES = [:BREAKINGSWIPE, :BRICKBREAK, :CROSSCHOP, :CRUSHCLAW, :CRUSHGRIP, :DOUBLEHIT, :DOUBLESLAP, :DUALCHOP, :FALSESWIPE,
                :FURYSWIPES, :KNOCKOFF, :METALCLAW, :POISONJAB, :SKYUPPERCUT, :WAKEUPSLAP]

  KICKING_MOVES = [:DOUBLEKICK, :MEGAKICK, :JUMPKICK, :ROLLINGKICK, :LOWKICK, :HIJUMPKICK, :TRIPLEKICK, :BLAZEKICK, :TROPKICK,
                   :THUNDEROUSKICK, :TRIPLEAXEL]

  WIND_MOVES = [:AEROBLAST, :AIRCUTTER, :BLEAKWINDSTORM, :BLIZZARD, :FAIRYWIND, :GUST, :HEATWAVE, :HURRICANE, :ICYWIND, :PETALBLIZZARD,
                :SANDSEARSTORM, :SPRINGTIDESTORM, :TWISTER, :WHIRLWIND, :WILDBOLDSTORM]

end unless UniLib.lib_loaded(__FILE__)