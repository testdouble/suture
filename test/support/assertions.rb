module Support
  module Assertions
    ##
    # Fails if +matcher+ <tt>=~</tt> +obj+.

    def assert_not_match matcher, obj
      msg = proc { "Expected #{mu_pp matcher} NOT to match #{mu_pp obj} (but it totally did)" }
      assert_respond_to matcher, :=~
      matcher = Regexp.new Regexp.escape matcher if String === matcher
      assert !(matcher =~ obj), msg
    end

    ##
    # Fails unless +matcher+ <tt>=~</tt> +obj+ (with whitespace normalized a bit)
    # Flips expected & actual so it's easier to use heredocs

    def assert_spacey_match obj, matcher
      og_matcher = matcher
      msg = proc {
        <<-MSG.gsub(/^ {10}/, "")
          Expected this #{obj.class}:
          ```
          #{obj}
          ```

          To match this #{og_matcher.class}:
          ```
          #{og_matcher}
          ```
        MSG
      }
      assert_respond_to matcher, :=~
      matcher = Regexp.new(Regexp.escape(matcher.gsub(/\s+/, ""))) if String === matcher
      assert(matcher =~ obj.gsub(/\s+/, ""), msg)
    end
  end
end
