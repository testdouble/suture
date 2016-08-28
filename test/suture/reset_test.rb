module Suture
  class ResetTest < UnitTest
    def teardown
      Gimme.reset
    end

    def test_reset
      return # TODO - there is a bug in gimme w/ module methods!!

      give(Suture).config_reset!
      give(Adapter::Log).reset!

      Suture.reset!

      verify(Suture).config_reset!
      verify(Adapter::Log).reset!
    end
  end
end
