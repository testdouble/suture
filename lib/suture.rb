require "suture/version"

require "suture/builds_plan"
require "suture/chooses_surgeon"
require "suture/performs_surgery"

require "suture/prescribes_test_plan"
require "suture/tests_patient"
require "suture/interprets_results"

module Suture
  DEFAULT_OPTIONS = {
    :database_path => "db/suture.sqlite3"
  }

  def self.create(name, options)
    plan = BuildsPlan.new.build(name, options)
    surgeon = ChoosesSurgeon.new.choose(plan)
    PerformsSurgery.new.perform(plan, surgeon)
  end

  def self.verify(name, options)
    test_plan = Suture::PrescribesTestPlan.new.prescribe(name, options)
    test_results = Suture::TestsPatient.new.test(test_plan)
    if test_results.failed?
      Suture::InterpretsResults.new.interpret(test_results)
    end
  end
end
