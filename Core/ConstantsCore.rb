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

  # clouds, dance floor, darkness from deso

  FIELDS = [:ASHENBEACH, :BACKALLEY, :BEWITCHED, :BIGTOP, :BURNING, :CAVE, :CHESS, :CITY, :CLOUDS, :COLOSSEUM, :CONCERT1, :CONCERT2,
            :CONCERT3, :CONCERT4, :CORROSIVE, :CORROSIVEMIST, :CORRUPTED, :CRYSTALCAVERN, :DANCEFLOOR, :DARKCRYSTALCAVERN, :DARKNESS1,
            :DARKNESS2, :DARKNESS3, :DEEPEARTH, :DESERT, :DIMENSIONAL, :DRAGONSDEN, :ELECTERRAIN, :FACTORY, :FAIRYTALE, :FLOWERGARDEN1,
            :FLOWERGARDEN2, :FLOWERGARDEN3, :FLOWERGARDEN4, :FLOWERGARDEN5, :FOREST, :FROZENDIMENSION, :GLITCH, :GRASSY, :HAUNTED, :HOLY,
            :ICY, :INFERNAL, :INVERSE, :MIRROR, :MISTY, :MOUNTAIN, :MURKWATERSURFACE, :NEWWORLD, :PSYTERRAIN, :RAINBOW, :ROCKY,
            :SHORTCIRCUIT, :SKY, :SNOWYMOUNTAIN, :STARLIGHT, :SUPERHEATED, :SWAMP, :UNDERWATER, :VOLCANIC, :VOLCANICTOP, :WASTELAND,
            :WATERSURFACE]

  FIELD_TYPES = {
    :NORMAL => [:CITY, :HOLY, :INVERSE, ],
    :FIRE => [:BURNING, :DRAGONSDEN, :FLOWERGARDEN3, :FLOWERGARDEN4, :FLOWERGARDEN5, :INFERNAL, :SUPERHEATED, :VOLCANIC, :VOLCANICTOP, ],
    :WATER => [:MURKWATERSURFACE, :SWAMP, :UNDERWATER, :WATERSURFACE, ],
    :ELECTRIC => [:ELECTERRAIN, :FACTORY, :MURKWATERSURFACE, :UNDERWATER, :WATERSURFACE, ],
    :GRASS => [:BEWITCHED, :FLOWERGARDEN2, :FLOWERGARDEN3, :FLOWERGARDEN4, :FLOWERGARDEN5, :FOREST, :GRASSY, :SWAMP, ],
    :ICE => [:FROZENDIMENSION, :ICY, :INVERSE, :SNOWYMOUNTAIN, ],
    :FIGHTING => [:BIGTOP, ],
    :POISON => [:BACKALLEY, :CITY, :CORROSIVE, :CORROSIVEMIST, :CORRUPTED, :MURKWATERSURFACE, :WASTELAND, ],
    :GROUND => [:DEEPEARTH, :DESERT,],
    :FLYING => [:MOUNTAIN, :SKY, :SNOWYMOUNTAIN, ],
    :PSYCHIC => [:DEEPEARTH, :GLITCH, :PSYTERRAIN, :STARLIGHT, ],
    :BUG => [:BACKALLEY, :CITY, :FLOWERGARDEN3, :FLOWERGARDEN4, :FLOWERGARDEN5, :SWAMP, ],
    :ROCK => [:CAVE, :CRYSTALCAVERN, :DEEPEARTH, :DRAGONSDEN, :MOUNTAIN, :ROCKY, :SNOWYMOUNTAIN, ],
    :GHOST => [:DARKCRYSTALCAVERN, :HAUNTED, ],
    :DRAGON => [:CRYSTALCAVERN, :DRAGONSDEN, :FAIRYTALE, ],
    :DARK => [:BACKALLEY, :BEWITCHED, :DARKCRYSTALCAVERN, :FROZENDIMENSION, :INFERNAL, :NEWWORLD, :STARLIGHT, ],
    :STEEL => [:BACKALLEY, :CITY, :FAIRYTALE, ],
    :FAIRY => [:BEWITCHED, :FAIRYTALE, :HOLY, :MISTY, :STARLIGHT, ]
  }

  FIELD_TYPES_SECONDARY = {
    :NORMAL => [:RAINBOW, ],
    :FIRE => [:CORROSIVEMIST, :GRASSY, ],
    :WATER => [],
    :ELECTRIC => [:SHORTCIRCUIT, ],
    :GRASS => [],
    :ICE => [],
    :FIGHTING => [:ASHENBEACH, ],
    :POISON => [],
    :GROUND => [:ASHENBEACH, :CAVE, ],
    :FLYING => [],
    :PSYCHIC => [:HOLY, ],
    :BUG => [:FOREST, ],
    :ROCK => [:CORRUPTED, ],
    :GHOST => [:DIMENSIONAL, :FROZENDIMENSION, ],
    :DRAGON => [:HOLY, ],
    :DARK => [:DIMENSIONAL, ],
    :STEEL => [:CORROSIVE, :CORRUPTED, :FACTORY, ],
    :FAIRY => []
  }

  FIELD_BAD_TYPES = {
    :NORMAL => [],
    :FIRE => [:FROZENDIMENSION, :ICY, :SNOWYMOUNTAIN, :SWAMP, :UNDERWATER, :WATERSURFACE, ],
    :WATER => [:BURNING, :DESERT, :DRAGONSDEN, :INFERNAL, :SUPERHEATED, :VOLCANICTOP, ],
    :ELECTRIC => [:DESERT, ],
    :GRASS => [:CORROSIVE, :CORRUPTED, :VOLCANIC, ],
    :ICE => [:BURNING, :DRAGONSDEN, :SUPERHEATED, :VOLCANIC, :VOLCANICTOP, ],
    :FIGHTING => [],
    :POISON => [],
    :GROUND => [:MURKWATERSURFACE, :SKY, :WATERSURFACE, ],
    :FLYING => [:CAVE, :CORRUPTED, ],
    :PSYCHIC => [],
    :BUG => [],
    :ROCK => [],
    :GHOST => [:HOLY, ],
    :DRAGON => [:MISTY, ],
    :DARK => [:HOLY, ],
    :STEEL => [:INVERSE, ],
    :FAIRY => [:BACKALLEY, :CITY, :CORRUPTED, :DIMENSIONAL, :GLITCH, :INFERNAL, ]
  }

end unless UniLib.lib_loaded(__FILE__)