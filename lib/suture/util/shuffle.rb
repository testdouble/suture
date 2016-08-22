module Suture::Util
  module Shuffle
    def self.shuffle(random, unshuffled_array)
      old_array = unshuffled_array.dup
      new_array = []
      while new_array.size < unshuffled_array.size
        index = random.rand(old_array.size)
        new_array << old_array.delete_at(index)
      end
      return new_array
    end
  end
end
