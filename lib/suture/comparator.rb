module Suture
  class Comparator
    def call(recorded, actual)
      recorded == actual || Marshal.dump(recorded) == Marshal.dump(actual)
    end
  end
end
