require "suture"

class Calculator
  def initialize
    @eww_gross_state = 0
  end

  def add(a,b)
    Suture.create :add,
      :old => method(:old_add),
      :new => method(:new_add),
      :args => [a,b]
  end

  private

  def old_add(a,b)
    a + b
  end

  def new_add(a,b)
    b + a
  end

  def broken_add(a,b)
    (b + a + @eww_gross_state).tap { @eww_gross_state += 1 }
  end

  def really_broken_add(a,b)
    b + a + 3
  end
end
