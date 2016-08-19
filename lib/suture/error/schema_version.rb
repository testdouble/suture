module Suture::Error
  class SchemaVersion < StandardError
    def initialize(expected, actual)
      @expected = expected
      @actual = actual
    end

    def message
      "Your suture gem is too #{@expected > @actual ? "new" : "old"} for this schema. Either delete your database or #{@expected > @actual ? "upgrade" : "downgrade"} the gem (expected schema version #{@expected}, was #{@actual})"
    end
  end
end
