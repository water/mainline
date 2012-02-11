# encoding: utf-8

require_relative "../test_helper"
gem("geoip", ">=0")
require 'geoip'

class ClonerTest < ActiveSupport::TestCase

  def setup
    @geoip = GeoIP.new(File.join(Rails.root, "data", "GeoIP.dat"))
    @cloner = Cloner.new
  end

  should " has a valid country" do
    localization = @geoip.country(cloners(:argentina).ip)
    assert_equal cloners(:argentina).country_code, localization[3]
    assert_equal cloners(:argentina).country, localization[5]
  end
end
