require "suture/create/builds_plan"
require "suture/adapter/dictaphone"

module Suture
  def self.delete!(id, options = {})
    plan = BuildsPlan.new.build(:name_not_used_here, options)
    Adapter::Dictaphone.new(plan).delete_by_id!(id)
  end

  def self.delete_all!(name, options = {})
    plan = BuildsPlan.new.build(:name_not_used_here, options)
    Adapter::Dictaphone.new(plan).delete_by_name!(name)
  end
end
