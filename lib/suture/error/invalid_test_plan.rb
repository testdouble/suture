module Suture::Error
  class InvalidTestPlan < StandardError
    def message
      "Suture.verify requires a `:subject` that responds to `:call`."
    end
  end
end
