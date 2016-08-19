require "suture"

class Mathy
  def add(a,b)
    Suture.create :add,
      :old => ->(c,d){ c + d },
      :args => [a,b]
  end
end
