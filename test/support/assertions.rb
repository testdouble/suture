module Support
  module Assertions
    ##
    # Fails if +matcher+ <tt>=~</tt> +obj+.

    def assert_not_match matcher, obj, msg = nil
      msg = message(msg) { "Expected #{mu_pp matcher} NOT to match #{mu_pp obj} (but it totally did)" }
      assert_respond_to matcher, :"=~"
      matcher = Regexp.new Regexp.escape matcher if String === matcher
      assert !(matcher =~ obj), msg
    end
  end
end
