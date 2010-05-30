require "test_helper"

class ReservationsTest < ActiveSupport::TestCase
  context "Gitorious::Reservations" do
    should "get controller names" do
      n = Gitorious::Reservations.controller_names
      assert n.include?("projects")
      assert !n.include?(":project_id")
      assert !n.include?(nil)
    end
  end
end
