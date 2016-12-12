require_relative './test_helper'
require_relative '../lib/models'

class TestModels < Minitest::Test
  def test_unknown_source
    event = {"source" => "unknown", "type" => "classification"}
    assert_equal(Models.for(event), nil)
  end

  def test_unknown_type
    event = {"source" => "panoptes", "type" => "unknown"}
    assert_equal(Models.for(event), nil)
  end

  def test_known_type
    event = {"source" => "panoptes", "type" => "classification"}
    assert(Models.for(event).is_a?(Models::PanoptesClassification))
  end
end

