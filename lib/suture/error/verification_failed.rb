module Suture::Error
  class VerificationFailed < StandardError
    def initialize(test_results)
      super
      @test_results = test_results
    end

    # def message
    # end

  end
end
