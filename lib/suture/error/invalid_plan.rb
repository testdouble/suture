module Suture::Error
  class InvalidPlan < StandardError
    HEADER = "Suture was unable to create your seam, because options passed to `Suture.create` were invalid."

    def self.missing_requirements(requirements)
      new <<-MSG.gsub(/^ {8}/,'')
        #{HEADER}

        The following options are required:

          #{requirements.map {|(name,explanation)|
              "* #{name.inspect} - #{explanation}"
            }.join("\n  ")}
      MSG
    end

    def self.invalid_options(invalids)
      new <<-MSG.gsub(/^ {8}/,'')
        #{HEADER}

        The following options were invalid:

          #{invalids.map {|(name,rule)|
              "* #{name.inspect} - #{rule[:message]}"
            }.join("\n  ")}
      MSG
    end

    def self.conflicting_options(conflicts)
      new <<-MSG.gsub(/^ {8}/,'')
        #{HEADER}

        Suture isn't sure how to best handle the combination of options passed:

          #{conflicts.map {|message|
              "* #{message}"
            }.join("\n  ")}
      MSG
    end
  end
end
