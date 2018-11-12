module Suture
  class ResetTest < UnitTest
    def teardown
      Gimme.reset
    end

    # TODO: - there is a bug in gimme w/ module methods!!
    # def test_reset
    #   give(Suture).config_reset!
    #   give(Adapter::Log).reset!

    #   Suture.reset!

    #   verify(Suture).config_reset!
    #   verify(Adapter::Log).reset!
    # end
  end
end
