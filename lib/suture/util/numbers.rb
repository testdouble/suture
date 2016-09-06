module Suture::Util
  module Numbers
    def self.percent(x, out_of_y)
      ((x.to_f / out_of_y.to_f) * 100).round
    end
  end
end
