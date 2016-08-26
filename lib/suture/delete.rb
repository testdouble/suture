require "suture/create/builds_plan"
require "suture/adapter/dictaphone"

module Suture
  def self.delete(id, options = {})
    plan = BuildsPlan.new.build(name, options)
    Suture::Adapter::Dictaphone.new(plan).delete(id)
  end
end
