module Suture
  class Comparator
    def call(recorded, actual)
      recorded == actual
    end
  end
end
