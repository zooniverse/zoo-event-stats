require_relative "../test_helper"
require_relative '../../lib/models'

module Models
  class TestOuroborosClassification < Minitest::Test

    def classification
      @classification ||= Models.for(event)
    end

    def event_data(attribute)
      event.dig("data",attribute)
    end

    def timestamp
      @timestamp ||= DateTime.parse(event_data("timestamp"))
    end

    def subject_data
      event_data("subject").map {|subject| subject["zooniverse_id"] }.join(",")
    end

    def test_timestamp
      assert_equal(timestamp, classification.timestamp)
    end

    def test_attributes
      expected = {
        user_id: event_data("user_id"),
        user_ip: nil,
        subjects: subject_data,
        lang: "Unknown",
        user_agent: nil,
        user_name: "Zookeeper",
        data: nil,
        created_at: timestamp,
        project: event_data("project"),
        geo: {}
      }
      assert_equal(expected, classification.attributes)
    end

    def event
      {
        "source" => "ouroboros",
        "type" => "classification",
        "version" => "1.0.0",
        "timestamp" => "2016-10-10T14:46:41Z",
        "data" => {
          "project" => "galaxy_zoo",
          "subject" => [{
            "id" => "56f3de0c5925d900420319a7",
            "activated_at" => "2016-10-07T21:00:38Z",
            "created_at" => "2016-03-30T12:58:29Z",
            "metadata" => { "redshift" => 0.02837243862450123 },
            "project_id" => "502a90cd516bcb060c000001",
            "random" => 0.3,
            "state" => "active",
            "updated_at" => "2016-03-30T12:58:29Z",
            "workflow_ids" => ["55db7cf01766276e7b000002"],
            "zooniverse_id" => "AGZ000bqmz"
          }],
          "timestamp" => "2016-10-10T14:46:41Z",
          "user_ip" => "127.0.0.1",
          "annotations" => [
            {"lang" => "en"},
            {"decals-0" => "a-1"}
          ],
          "user" => "Zookeeper",
          "user_id" => "1"
        },
        "linked" => {}
      }
    end
  end
end
