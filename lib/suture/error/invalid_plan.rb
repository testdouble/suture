module Suture::Error
  class InvalidPlan < StandardError
    def self.missing_requirements(requirements)
      new <<-MSG.gsub(/^ {8}/,'')
        Suture was unable to create your seam, because options passed to
        `Suture.create` were invalid.

        The following options are required:

          #{requirements.map {|(name,explanation)|
              "* #{name.inspect} - #{explanation}"
            }.join("\n  ")}
      MSG
    end
  end
end
