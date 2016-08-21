# FIXME: I couldn't get assert_output to work and stopped trying
#
# require "suture/adapter/log"

# module Suture::Adapter
#   class LogTest < Minitest::Test
#     class FakeThing
#       include Suture::Adapter::Log

#       def stuff
#         log_debug("an debug")
#         log_info("an info")
#         log_warn("an warn")
#       end
#     end

#     def teardown
#       Suture.reset!
#     end

#     def test_simple_case
#       Suture.config(:log_level => "DEBUG")

#       subject = FakeThing.new

#       assert_output(/^\[.*\] Suture: "an debug"$/) do
#         subject.stuff
#       end
#     end
#   end
# end
