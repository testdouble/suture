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

    ##
    # Fails unless +matcher+ <tt>=~</tt> +obj+ (with whitespace normalized a bit)

    def assert_spacey_match matcher, obj, msg = nil
      msg = message(msg) { "Expected #{mu_pp matcher} to match #{mu_pp obj} (with relaxed whitespace)" }
      assert_respond_to matcher, :"=~"
      matcher = Regexp.new Regexp.escape matcher.gsub(/\s+/, ' ') if String === matcher
      assert matcher =~ obj.gsub(/\s+/, ' '), msg
    end
  end
end
