require "suture"

class Mathy
  def add(a,b)
    Suture.create :add,
      :old => lambda {|c,d| c + d },
      :args => [a,b]
  end
end
