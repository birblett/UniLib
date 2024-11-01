# ======================================================================================================================================== #
# ============================================================= DEPENDENCIES ============================================================= #
# ======================================================================================================================================== #

UniLib.verify_version(0.5, __FILE__)

# ======================================================================================================================================== #
# ============================================================== PUBLIC API ============================================================== #
# ======================================================================================================================================== #

class NumberContainer

  def set(other)
    @number = other
  end

  def +(other)
    @number + other
  end

  def -(other)
    @number - other
  end

  def *(other)
    @number * other
  end

  def /(other)
    @number / other
  end

  def add(other)
    @number += other
  end

  def sub(other)
    @number -= other
  end

  def mul(other)
    @number *= other
  end

  def div(other)
    @number /= other
  end

  def ==(other)
    @number == other
  end

  def >=(other)
    @number >= other
  end

  def <=(other)
    @number <= other
  end

  def >(other)
    @number > other
  end

  def <(other)
    @number < other
  end

  def value
    @number
  end

end